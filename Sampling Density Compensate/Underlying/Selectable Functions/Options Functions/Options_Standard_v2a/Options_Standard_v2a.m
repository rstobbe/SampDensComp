%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef Options_Standard_v2a < handle

properties (SetAccess = private)                   
    Method = 'Options_Standard_v2a'
    OPTipt
    Precision
    ResetGpus
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [OPT,err] = Options_Standard(OPTipt)     
    err.flag = 0;
    OPT.OPTipt = OPTipt;
    OPT.precision = OPTipt.('Precision');
    OPT.ResetGpus = OPTipt.('ResetGpus');
end

%==================================================================
% GetOptions
%==================================================================  
function [err] = GetOptions(OPT,CUDA)
    err.flag = 0;
    
    %--------------------------------------
    % Reset Gpus
    %--------------------------------------
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
        if strcmp(OPT.Precision,'Double')
            OPT.S2GConvfunc = 'mS2GCUDADoubleR_v5b';
            OPT.G2SConvfunc = 'mG2SCUDADoubleR_v5b';
        elseif strcmp(OPT.precision,'Single')
            OPT.S2GConvfunc = 'mS2GCUDASingleR_v5b';
            OPT.G2SConvfunc = 'mG2SCUDASingleR_v5b';
        end
    else
        OPT.S2GConvfunc = 'mS2GCUDADoubleR_v4g';
        OPT.G2SConvfunc = 'mG2SCUDADoubleR_v4g';
    end
end



end
end




