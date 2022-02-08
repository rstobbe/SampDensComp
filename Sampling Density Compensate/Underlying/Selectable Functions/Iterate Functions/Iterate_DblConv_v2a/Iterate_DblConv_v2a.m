%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef Iterate_DblConv_v2a < handle

properties (SetAccess = private)                   
    Method = 'Iterate_DblConv_v2a'
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
function [IT,err] = Iterate_DblConv_v2a(ITipt)     
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
function err = SamplingDensityCompensate(IT,SDCMETH,IMP,CUDA) 

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
    [Ksz,Kx,Ky,Kz,C] = NormProjGrid_v4c(KINFO.kSpace,KINFO.nproj,KINFO.SamplingPts,KINFO.kstep,chW,SubSamp,'M2A');

    %--------------------------------------
    % Iterate
    %--------------------------------------
    StatLev = 3;
    IT.SampDensComp = SDCMat2Arr(IE.iSampDensComp,KINFO.nproj,KINFO.SamplingPts);
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
        err = IT.ANLZ.TestSdc(SDCMETH,IMP);
        if err.flag
            return
        end
        clear INPUT    

        %--------------------------------------
        % Test for Completion
        %--------------------------------------    
        err = IT.BRK.FinishTest(SDCMETH,IMP);
        if err.flag
            return
        end 
        if IT.BRK.Stop == 1
            break
        end

        %--------------------------------------
        % Calculate Comp
        %--------------------------------------
        [IT.SampDensComp,err] = IT.CALC.CalcComp(SDCMETH,IMP);
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













