%==================================================================
% (v2b)
%   - Add TrajManip
%==================================================================

classdef SdcMeth_YarnBall_v2b < handle

properties (SetAccess = private)                   
    Method = 'SdcMeth_YarnBall_v2b'
    Optionsfunc
    TFfunc
    TrajManipfunc
    CTFVatSPfunc
    InitialEstfunc
    Iteratefunc
    OPT
    TFO
    CTFV
    IE
    IT
    TM
    KINFO
    DES
    AcqNum
    Panel = cell(0)
    PanelOutput
    ExpDisp
end
properties (SetAccess = public)    
    name
    path
    saveSCRPTcellarray
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [SDCMETH,err] = SdcMeth_YarnBall_v2b(SDCMETHipt)    
    
    err.flag = 0;
    %---------------------------------------------
    % Load Panel Input
    %---------------------------------------------
    SDCMETH.Optionsfunc = SDCMETHipt.('Optionsfunc').Func;
    SDCMETH.TFfunc = SDCMETHipt.('TFfunc').Func;
    SDCMETH.TrajManipfunc = SDCMETHipt.('TrajManipfunc').Func;
    SDCMETH.CTFVatSPfunc = SDCMETHipt.('CTFVatSPfunc').Func;
    SDCMETH.InitialEstfunc = SDCMETHipt.('InitialEstfunc').Func;
    SDCMETH.Iteratefunc = SDCMETHipt.('Iteratefunc').Func;    
    SDCMETH.AcqNum = str2double(SDCMETHipt.('AcqNum'));
    
    %---------------------------------------------
    % Get Working Structures from Sub Functions
    %---------------------------------------------
    CallingFunction = SDCMETHipt.Struct.labelstr;
    OPTipt = SDCMETHipt.('Optionsfunc');
    if isfield(SDCMETHipt,([CallingFunction,'_Data']))
        if isfield(SDCMETHipt.([CallingFunction,'_Data']),('Optionsfunc_Data'))
            OPTipt.Optionsfunc_Data = SDCMETHipt.([CallingFunction,'_Data']).Optionsfunc_Data;
        end
    end
    TFOipt = SDCMETHipt.('TFfunc');
    if isfield(SDCMETHipt,([CallingFunction,'_Data']))
        if isfield(SDCMETHipt.([CallingFunction,'_Data']),('TFfunc_Data'))
            TFOipt.TFfunc_Data = SDCMETHipt.([CallingFunction,'_Data']).TFfunc_Data;
        end
    end
    TMipt = SDCMETHipt.('TrajManipfunc');
    if isfield(SDCMETHipt,([CallingFunction,'_Data']))
        if isfield(SDCMETHipt.([CallingFunction,'_Data']),('TrajManipfunc_Data'))
            TMipt.TrajManipfunc_Data = SDCMETHipt.([CallingFunction,'_Data']).TrajManipfunc_Data;
        end
    end
    CTFVipt = SDCMETHipt.('CTFVatSPfunc');
    if isfield(SDCMETHipt,([CallingFunction,'_Data']))
        if isfield(SDCMETHipt.([CallingFunction,'_Data']),('CTFVatSPfunc_Data'))
            CTFVipt.CTFVatSPfunc_Data = SDCMETHipt.([CallingFunction,'_Data']).CTFVatSPfunc_Data;
        end
    end
    IEipt = SDCMETHipt.('InitialEstfunc');
    if isfield(SDCMETHipt,([CallingFunction,'_Data']))
        if isfield(SDCMETHipt.([CallingFunction,'_Data']),('InitialEstfunc_Data'))
            IEipt.InitialEstfunc_Data = SDCMETHipt.([CallingFunction,'_Data']).InitialEstfunc_Data;
        end
    end
    ITipt = SDCMETHipt.('Iteratefunc');
    if isfield(SDCMETHipt,([CallingFunction,'_Data']))
        if isfield(SDCMETHipt.([CallingFunction,'_Data']),('Iteratefunc_Data'))
            ITipt.Iteratefunc_Data = SDCMETHipt.([CallingFunction,'_Data']).Iteratefunc_Data;
        end
    end

    %------------------------------------------
    % Build Object Shells
    %------------------------------------------
    func = str2func(SDCMETH.Optionsfunc);                   
    SDCMETH.OPT = func(OPTipt);
    func = str2func(SDCMETH.TFfunc);           
    SDCMETH.TFO = func(TFOipt);
    func = str2func(SDCMETH.TrajManipfunc);           
    SDCMETH.TM = func(TMipt);
    func = str2func(SDCMETH.CTFVatSPfunc);           
    SDCMETH.CTFV = func(CTFVipt);
    func = str2func(SDCMETH.InitialEstfunc);                   
    SDCMETH.IE = func(IEipt); 
    func = str2func(SDCMETH.Iteratefunc);                   
    SDCMETH.IT = func(ITipt); 
end 

%==================================================================
% Compensate
%==================================================================  
function err = Compensate(SDCMETH,IMP) 
    err.flag = 0;
    
    %--------------------------------------------
    % Test
    %--------------------------------------------  
    NumAcqs = length(IMP.KINFO);
    if SDCMETH.AcqNum > NumAcqs
        err.flag = 1;
        err.msg = 'AcqNum larger than number of acquisitions';
        return
    end
    SDCMETH.KINFO = IMP.KINFO(SDCMETH.AcqNum);
    SDCMETH.DES = IMP.DES;
    
    %--------------------------------------------
    % Test
    %--------------------------------------------  
    global COMPASSINFO
    CUDA = COMPASSINFO.CUDA;
    SDCMETH.OPT.SetOptions(CUDA);

    %--------------------------------------------
    % Trajectory Manipulation
    %--------------------------------------------  
    err = SDCMETH.TM.ManipulateTrajectory(SDCMETH);
    if err.flag
        return
    end    
    
    %--------------------------------------------
    % Define Output Transfer Function
    %--------------------------------------------  
    err = SDCMETH.TFO.DefineTransferFunction(SDCMETH);
    if err.flag
        return
    end

    %--------------------------------------------
    % Determine Initial Estimate
    %--------------------------------------------  
    err = SDCMETH.IE.DetermineInitialEstimate(SDCMETH);    
    if err.flag
        return
    end

    %--------------------------------------------
    % Determine CtfvAtSp
    %--------------------------------------------  
    err = SDCMETH.CTFV.DetermineCtfvAtSp(SDCMETH,CUDA);    
    if err.flag
        return
    end    
    
    %--------------------------------------------
    % Sampling Density Compensate
    %--------------------------------------------  
    err = SDCMETH.IT.SamplingDensityCompensate(SDCMETH,CUDA);    
    if err.flag
        return
    end    
    
    %--------------------------------------------
    % Add Sampling to KINFO
    %--------------------------------------------     
    if isempty(SDCMETH.KINFO.UseIndex)
        SampDensCompMat = SDCArr2Mat(SDCMETH.IT.SampDensComp,SDCMETH.KINFO.nproj,SDCMETH.KINFO.SamplingPts);
        SDCMETH.KINFO.AddSampDensComp(SampDensCompMat);
    else
        SDCMETH.KINFO.AddSampDensComp(SDCMETH.IT.SampDensComp);
    end
    SDCMETH.IT.Clear;
    SDCMETH.IE.Clear;
    SDCMETH.CTFV.Clear;
    SDCMETH.OPT.Clear;
    
    %--------------------------------------------
    % Name
    %--------------------------------------------
    SDCMETH.name = ['SDC',num2str(SDCMETH.AcqNum),'_',IMP.name(5:end)];

    %--------------------------------------------
    % Panel
    %--------------------------------------------    
    Panel0(1,:) = {'Method',SDCMETH.Method,'Output'};
    Panel0(2,:) = {'AcqNum',SDCMETH.AcqNum,'Output'};
    SDCMETH.Panel = [Panel0;SDCMETH.IT.Panel]; 
    SDCMETH.PanelOutput = cell2struct(SDCMETH.Panel,{'label','value','type'},2);
    SDCMETH.ExpDisp = PanelStruct2Text(SDCMETH.PanelOutput);
end


end
end









