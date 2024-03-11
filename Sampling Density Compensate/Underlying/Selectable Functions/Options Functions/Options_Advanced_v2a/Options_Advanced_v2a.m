%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef Options_Advanced_v2a < handle

properties (SetAccess = private)                   
    Method = 'Options_Advanced_v2a'
    KRN
    Precision
    ResetGpus
    S2GConvfunc
    G2SConvfunc
    CTFVvis = 1
    ANLZvis = 1
    IEvis = 1
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [OPT,err] = Options_Advanced_v2a(OPTipt)     
    err.flag = 0;
    OPT.Precision = OPTipt.('Precision');
    OPT.ResetGpus = 'Yes';
    
    CallingLabel = OPTipt.Struct.labelstr;
    if not(isfield(OPTipt,[CallingLabel,'_Data']))
        if isfield(OPTipt.('Kern_File').Struct,'selectedfile')
            file = OPTipt.('Kern_File').Struct.selectedfile;
            if not(exist(file,'file'))
                err.flag = 1;
                err.msg = '(Re) Load Kern_File';
                ErrDisp(err);
                return
            else
                load(file);
                OPTipt.([CallingLabel,'_Data']).('Kern_File_Data') = saveData;
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load Kern_File';
            ErrDisp(err);
            return
        end
    end
    OPT.KRN = OPTipt.([CallingLabel,'_Data']).('Kern_File_Data').KRNprms;            
end

%==================================================================
% GetOptions
%==================================================================  
function [err] = SetOptions(OPT,CUDA)
    err.flag = 0;
    
    %--------------------------------------
    % Reset Gpus
    %--------------------------------------               
    Status2('busy','Reset GPUs',2);          % always do this... (possible error otherwise!)
    NoGPUs = gpuDeviceCount;
    for n = 1:NoGPUs
        CUDA = gpuDevice(n);               % Cuda initialization (i.e. a Cuda reset).  'CudaDevice' not needed down pipe... (historic)
    end

    %--------------------------------------
    % Specify Convolution Function
    %--------------------------------------
    ComputeCapability = str2double(CUDA.ComputeCapability);
    if ComputeCapability > 6.0
        if strcmp(OPT.Precision,'Double')
            OPT.S2GConvfunc = 'mS2GCUDADoubleR_v5b';
            OPT.G2SConvfunc = 'mG2SCUDADoubleR_v5b';
        elseif strcmp(OPT.Precision,'Single')
            OPT.S2GConvfunc = 'mS2GCUDASingleR_v5b';
            OPT.G2SConvfunc = 'mG2SCUDASingleR_v5b';
        end
    else
        OPT.S2GConvfunc = 'mS2GCUDADoubleR_v4g';
        OPT.G2SConvfunc = 'mG2SCUDADoubleR_v4g';
    end
end

%==================================================================
% Clear
%==================================================================  
function Clear(OPT)
   OPT.KRN = [];
end

end
end




