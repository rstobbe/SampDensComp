%==================================================================
% (v2b)
%   - Include option for 'UseIndex'
%==================================================================

classdef Iterate_DblConv_v2b < handle

properties (SetAccess = private)                   
    Method = 'Iterate_DblConv_v2b'
    Calcfunc
    Anlzfunc
    Breakfunc
    CALC
    ANLZ
    BRK
    WeightVals
    SampDensComp
    ItNum
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [IT,err] = Iterate_DblConv_v2b(ITipt)     
    err.flag = 0;
    IT.Calcfunc = ITipt.('Calcfunc').Func;
    IT.Anlzfunc = ITipt.('Anlzfunc').Func;
    IT.Breakfunc = ITipt.('Breakfunc').Func;    
    
    %---------------------------------------------
    % Get Working Structures from Sub Functions
    %---------------------------------------------
    CallingPanel = ITipt.Struct.labelstr;
    CALCipt = ITipt.('Calcfunc');
    if isfield(ITipt,([CallingPanel,'_Data']))
        if isfield(ITipt.([CallingPanel,'_Data']),('Calcfunc_Data'))
            CALCipt.('Calcfunc_Data') = ITipt.([CallingPanel,'_Data']).('Calcfunc_Data');
        end
    end
    ANLZipt = ITipt.('Anlzfunc');
    if isfield(ITipt,([CallingPanel,'_Data']))
        if isfield(ITipt.([CallingPanel,'_Data']),('Anlzfunc_Data'))
            ANLZipt.('Anlzfunc_Data') = ITipt.([CallingPanel,'_Data']).('Anlzfunc_Data');
        end
    end
    BRKipt = ITipt.('Breakfunc');
    if isfield(ITipt,([CallingPanel,'_Data']))
        if isfield(ITipt.([CallingPanel,'_Data']),('Breakfunc_Data'))
            BRKipt.('Breakfunc_Data') = ITipt.([CallingPanel,'_Data']).('Breakfunc_Data');
        end
    end    

    %------------------------------------------
    % Build Object Shells
    %------------------------------------------
    func = str2func(IT.Calcfunc);                   
    IT.CALC = func(CALCipt);
    func = str2func(IT.Anlzfunc);           
    IT.ANLZ = func(ANLZipt);
    func = str2func(IT.Breakfunc);                   
    IT.BRK = func(BRKipt); 
    
end

%==================================================================
% Sampling Density Compensate
%==================================================================  
function err = SamplingDensityCompensate(IT,SDCMETH,CUDA) 

    Status2('busy','Perform SDC Iterations',2);
    Status2('done','',3);

    err.flag = 0;
    err.msg = '';

    %---------------------------------------------
    % Get Input
    %---------------------------------------------
    OPT = SDCMETH.OPT;
    KRN = OPT.KRN;
    IE = SDCMETH.IE;
    KINFO = SDCMETH.KINFO;
    CTFV = SDCMETH.CTFV;
    FwdKern = KRN.FwdKern;
    RvsKern = FwdKern;
    SubSamp = KRN.DesforSS;
    IT.ItNum = IE.ItNumCur; 
    
    %---------------------------------------------
    % Define Functions
    %---------------------------------------------
    S2Gconvfunc = str2func(OPT.S2GConvfunc);
    G2Sconvfunc = str2func(OPT.G2SConvfunc);

    %--------------------------------------
    % Setup Fwd Conv
    %--------------------------------------
    zWtest = 2*(ceil((FwdKern.W*SubSamp-2)/2)+1)/SubSamp;                       
    if zWtest > FwdKern.zW
        error('Kernel Zero-Fill Too Small');
    end
    FwdKern.W = FwdKern.W*SubSamp;
    FwdKern.res = FwdKern.res*SubSamp;
    if round(1e9/FwdKern.res) ~= 1e9*round(1/FwdKern.res)
        error('should not get here - already tested');
    end    
    FwdKern.iKern = round(1/FwdKern.res);
    FwdConvPrms.chW = ceil((FwdKern.W-2)/2);                   

    %--------------------------------------
    % Setup Rvs Conv
    %--------------------------------------
    zWtest = 2*(ceil((RvsKern.W*SubSamp-2)/2)+1)/SubSamp;                       
    if zWtest > RvsKern.zW
        error('Kernel Zero-Fill Too Small');
    end
    RvsKern.W = RvsKern.W*SubSamp;
    RvsKern.res = RvsKern.res*SubSamp;
    if round(1e9/RvsKern.res) ~= 1e9*round(1/RvsKern.res)
        error('should not get here - already tested');
    end    
    RvsKern.iKern = round(1/RvsKern.res);
    RvsConvPrms.chW = ceil((RvsKern.W-2)/2);                    

    %--------------------------------------
    % Use largest chW
    %--------------------------------------
    if FwdConvPrms.chW >= RvsConvPrms.chW
        chW = FwdConvPrms.chW;
    else
        chW = RvsConvPrms.chW;
    end

    %--------------------------------------
    % Normalize Projections to Grid
    %--------------------------------------
    if isempty(KINFO.UseIndex)
        [Ksz,Kx,Ky,Kz,C] = NormProjGrid_v4c(KINFO.kSpace,KINFO.nproj,KINFO.SamplingPts,KINFO.kstep,chW,SubSamp,'M2A');
    else
        [Ksz,Kx,Ky,Kz,C] = NormProjGridIdx_v4c(KINFO.kSpace,KINFO.nproj,KINFO.SamplingPts,KINFO.kstep,chW,SubSamp,'M2A',KINFO.UseIndex);
    end

    %--------------------------------------
    % Iterate
    %--------------------------------------
    StatLev = 3;
    if isempty(KINFO.UseIndex)
        IT.SampDensComp = SDCMat2Arr(IE.iSampDensComp,KINFO.nproj,KINFO.SamplingPts);
    else
        IT.SampDensComp = IE.iSampDensComp(KINFO.UseIndex).';
    end
    for j = IT.ItNum + 1:500   

        IT.ItNum = j;
        Status2('busy',['Iteration: ',num2str(IT.ItNum-1)],2);       
        %--------------------------------------
        % Convolve
        %--------------------------------------
        [CV,~] = S2Gconvfunc(Ksz,Kx,Ky,Kz,FwdKern,IT.SampDensComp,FwdConvPrms,StatLev,CUDA);                
        CV = CV/(FwdKern.convscaleval);
        [W,~] = G2Sconvfunc(Ksz,Kx,Ky,Kz,RvsKern,CV,RvsConvPrms,StatLev,CUDA);          
        IT.WeightVals = W/(RvsKern.convscaleval*SubSamp^3);                        

        %--------------------------------------
        % Analysis
        %--------------------------------------
        if isempty(KINFO.UseIndex)
            err = IT.ANLZ.TestSdc(SDCMETH);
            if err.flag
                return
            end
        else
            Error = (IT.WeightVals - CTFV.DesiredOutputValues)/CTFV.DesiredOutputValues(1);
            Rad = ((Kx-C).^2 + (Ky-C).^2 + (Kz-C).^2).^0.5;
            figure(245623); plot(Rad,Error,'*');
        end
        clear INPUT    

        %--------------------------------------
        % Test for Completion
        %--------------------------------------    
        if isempty(KINFO.UseIndex)
            err = IT.BRK.FinishTest(SDCMETH);
            if err.flag
                return
            end 
            if IT.BRK.Stop == 1
                break
            end
        elseif IT.ItNum > IT.BRK.ItNum
            break
        end

        %--------------------------------------
        % Calculate Comp
        %--------------------------------------
        [IT.SampDensComp,err] = IT.CALC.CalcComp(SDCMETH);
        if err.flag
            return
        end
    end

    %--------------------------------------
    % Panel
    %--------------------------------------
    IT.Panel = [IT.ANLZ.Panel;IT.BRK.Panel];
    Status2('done','',2);    
end

%==================================================================
% Clear
%==================================================================  
function Clear(IT)
   IT.SampDensComp = [];
   IT.WeightVals = [];
end


end
end













