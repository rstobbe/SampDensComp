%====================================================
% 
%====================================================

function [OPT,err] = Options_BigSave_v1c_Func(OPT,INPUT)

global COMPASSINFO
CUDA = COMPASSINFO.CUDA;

Status2('busy','Setup',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
KRNprms = INPUT.KRNprms;
SDCS = INPUT.SDCS;
IMP = INPUT.IMP;
clear INPUT;

%---------------------------------------------
% Set SDCS
%---------------------------------------------
SDCS.SubSamp = KRNprms.DesforSS;
SDCS.precision = OPT.precision;

%--------------------------------------
% Test (unnecessary) 
%--------------------------------------
if rem(round(1e9*(1/(KRNprms.DblKern.res*SDCS.SubSamp)))/1e9,1)
    err.flag = 1;
    err.msg = '1/(KernRes*SS) not an integer';
    return
end

%--------------------------------------
% Reset Gpus
%--------------------------------------
%OPT.ResetGpus = 'Yes';
if strcmp(OPT.ResetGpus,'Yes')
    Status2('busy','Reset GPUs',3);
    NoGPUs = gpuDeviceCount;
    for n = 1:NoGPUs
        CUDA = gpuDevice(n);               % Cuda initialization (i.e. a Cuda reset).  'CudaDevice' not needed down pipe... (historic)
    end
end

%--------------------------------------
% Specify Convolution Function
%--------------------------------------
ComputeCapability = str2double(CUDA.ComputeCapability);
if ComputeCapability > 6.0
    if strcmp(SDCS.precision,'Double')
        SDCS.S2GConvfunc = 'mS2GCUDADoubleR_v5b';
        SDCS.G2SConvfunc = 'mG2SCUDADoubleR_v5b';
    elseif strcmp(SDCS.precision,'Single')
        SDCS.S2GConvfunc = 'mS2GCUDASingleR_v5b';
        SDCS.G2SConvfunc = 'mG2SCUDASingleR_v5b';
    end
else
    SDCS.S2GConvfunc = 'mS2GCUDADoubleR_v4g';
    SDCS.G2SConvfunc = 'mG2SCUDADoubleR_v4g';
end

%--------------------------------------
% Big Save
%--------------------------------------
OPT.BigSave = 'Yes';

%--------------------------------------
% Return
%--------------------------------------
OPT.SDCS = SDCS;
OPT.IMP = IMP;

Status2('done','',2);
Status2('done','',3);



