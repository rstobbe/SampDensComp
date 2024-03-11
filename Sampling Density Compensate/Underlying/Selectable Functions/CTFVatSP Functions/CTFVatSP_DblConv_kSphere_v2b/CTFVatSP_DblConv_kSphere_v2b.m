%==================================================================
% (v2b)
%   - Include option for 'UseIndex'
%==================================================================

classdef CTFVatSP_DblConv_kSphere_v2b < handle

properties (SetAccess = private)                   
    Method = 'CTFVatSP_DblConv_kSphere_v2b'
    TFB
    DesiredOutputValues
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [CTFV,err] = CTFVatSP_DblConv_kSphere_v2b(CTFVipt)     
    err.flag = 0;
    func = str2func('TFbuild_Sphere_v2a');           
    CTFV.TFB = func('');    
end

%==================================================================
% Constructor
%==================================================================  
function err = DetermineCtfvAtSp(CTFV,SDCMETH,CUDA)    
    
    err.flag = 0; 
    Status2('busy','Convolved Output Transfer Function at Samp',2);
    Status2('done','',3);

    KINFO = SDCMETH.KINFO;
    OPT = SDCMETH.OPT;
    KRN = OPT.KRN;
    FwdKern = KRN.FwdKern;
    RvsKern = FwdKern;
    
    %----------------------------------------
    % Tests
    %----------------------------------------
    if KINFO.Elip ~= 1                  
        err.flag = 1;
        err.msg = 'Elip Not Supported with ''CTFVatSP_DblConv_kSphere''';
        return
    end

    %---------------------------------------------
    % Functions
    %---------------------------------------------
    S2Gconvfunc = str2func(OPT.S2GConvfunc);
    G2Sconvfunc = str2func(OPT.G2SConvfunc);

    %---------------------------------------------
    % Build Desired TF
    %---------------------------------------------
    CTFV.TFB.BuildTransFunc(SDCMETH);

    %----------------------------------------
    % FwdKern Convolve Setup
    %----------------------------------------
    zWtest = 2*(ceil((FwdKern.W*CTFV.TFB.SubSamp-2)/2)+1)/CTFV.TFB.SubSamp;                       
    if zWtest > FwdKern.zW
        error('Kernel Zero-Fill Too Small');
    end
    FwdKern.W = FwdKern.W*CTFV.TFB.SubSamp;
    FwdKern.res = FwdKern.res*CTFV.TFB.SubSamp;
    if round(1e9/FwdKern.res) ~= 1e9*round(1/FwdKern.res)
        error('should not get here - already tested');
    end    
    FwdKern.iKern = round(1/FwdKern.res);
    CONVprms.chW = ceil((FwdKern.W-2)/2);                    

    %----------------------------------------
    % Normalize Desired TF to Grid
    %----------------------------------------
    [~,~,~,~,centre1] = NormProjGrid_v4c(CTFV.TFB.Loc,NaN,NaN,KINFO.kstep,CONVprms.chW,CTFV.TFB.SubSamp,'A2A');
    [~,~,~,~,centre2] = NormProjGrid_v4c(KINFO.kSpace,KINFO.nproj,KINFO.SamplingPts,KINFO.kstep,CONVprms.chW,CTFV.TFB.SubSamp,'M2A');
    Fcentre = max([centre1 centre2]);
    [Ksz,Kx,Ky,Kz,centre] = NormProjGridExt_v4c(CTFV.TFB.Loc,NaN,NaN,KINFO.kstep,CONVprms.chW,CTFV.TFB.SubSamp,Fcentre,'A2A');

    %----------------------------------------
    % FwdKern Convolve 
    %----------------------------------------
    Status2('busy',['Convolve TF to Grid (',num2str(length(Kx)),' Pts)'],2);
    StatLev = 3;
    [ConvTF,err] = S2Gconvfunc(Ksz,Kx,Ky,Kz,FwdKern,CTFV.TFB.Val,CONVprms,StatLev,CUDA);
    if err.flag
        return
    end
    ConvTF = ConvTF/(FwdKern.convscaleval*CTFV.TFB.SubSamp^3);                  
    if OPT.CTFVvis         
        figure(400); 
        subplot(2,2,4); hold on;
        rconv = (0:(centre-1))/CTFV.TFB.RadDim; 
        ConvTFprof = ConvTF(centre:Ksz,centre,centre);
        plot(rconv,ConvTFprof,'r-');
        title('Convolved Output');
    end

    %----------------------------------------
    % Reverse Convolve Setup
    %----------------------------------------
    zWtest = 2*(ceil((RvsKern.W*CTFV.TFB.SubSamp-2)/2)+1)/CTFV.TFB.SubSamp;                       % with mFCMexSingleR_v3
    if zWtest > RvsKern.zW
        error('Kernel Zero-Fill Too Small');
    end
    RvsKern.W = RvsKern.W*CTFV.TFB.SubSamp;
    RvsKern.res = RvsKern.res*CTFV.TFB.SubSamp;
    if round(1e9/RvsKern.res) ~= 1e9*round(1/RvsKern.res)
        error('should not get here - already tested');
    end    
    RvsKern.iKern = round(1/RvsKern.res);
    CONVprms.chW = ceil((RvsKern.W-2)/2);                    % with mFCMexSingleR_v3

    %----------------------------------------
    % Normalize Sampling Locations to Grid
    %----------------------------------------
    if isempty(KINFO.UseIndex)
        [Ksz,Kx,Ky,Kz,centre] = NormProjGridExt_v4c(KINFO.kSpace,KINFO.nproj,KINFO.SamplingPts,KINFO.kstep,CONVprms.chW,CTFV.TFB.SubSamp,Fcentre,'M2A');
    else
        [Ksz,Kx,Ky,Kz,centre] = NormProjGridExtIdx_v4c(KINFO.kSpace,KINFO.nproj,KINFO.SamplingPts,KINFO.kstep,CONVprms.chW,CTFV.TFB.SubSamp,Fcentre,'M2A',KINFO.UseIndex);
    end

    %----------------------------------------
    % Test
    %----------------------------------------
    if centre~=Fcentre
        error('coding problem');
    end

    %----------------------------------------
    % Reverse Convolve 
    %----------------------------------------
    Status2('busy','Convolve Grid to Sampling Points',2);
    StatLev = 3;
    Kx = [centre;Kx];
    Ky = [centre;Ky];
    Kz = [centre;Kz];
    Rad = ((Kx-centre).^2 + (Ky-centre).^2 + (Kz-centre).^2).^(0.5);
    Kx = Rad + centre;
    Ky = zeros(size(Kx)) + centre;
    Kz = zeros(size(Kx)) + centre;
    [DesiredOutputValues0,err] = G2Sconvfunc(Ksz,Kx,Ky,Kz,RvsKern,ConvTF,CONVprms,StatLev,CUDA);
    if err.flag == 1
        return
    end

    DesiredOutputValues0 = DesiredOutputValues0/(RvsKern.convscaleval*CTFV.TFB.SubSamp^3);        
    if OPT.CTFVvis        
        figure(400); 
        subplot(2,2,4); hold on;
        plot((((Kx(1:100:end)-centre).^2 + (Ky(1:100:end)-centre).^2 + (Kz(1:100:end)-centre).^2).^(0.5))/CTFV.TFB.RadDim,DesiredOutputValues0(1:100:end),'k*');              % too many points to show...
        plot(0,1,'b*');                     % non-sampled centre differently
    end
    CTFV.DesiredOutputValues = DesiredOutputValues0(2:length(DesiredOutputValues0));
    CTFV.TFB.Clear;
    
    %----------------------------------------------------
    % Panel Output
    %----------------------------------------------------
    CTFV.Panel(1,:) = {'TF_RadDim',CTFV.TFB.RadDim,'Output'};
    CTFV.Panel(2,:) = {'TF_SubSamp',CTFV.TFB.SubSamp,'Output'};
    CTFV.Panel(3,:) = {'TF_rLocMax',CTFV.TFB.rLocMax,'Output'};
    Status2('done','',2);
    Status2('done','',3);    
end

%==================================================================
% Clear
%==================================================================  
function Clear(CTFV)
   CTFV.DesiredOutputValues = [];
end


end
end



