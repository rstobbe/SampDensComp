%====================================================
% (v1a)
%      
%====================================================

function [SCRPTipt,IE,err] = InitialEst_TrajSampDensEstTpi_v1a(SCRPTipt,IEipt)

Status2('done','Get Initial Estimate Function Input',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Load Input
%---------------------------------------------
IE.script = IEipt.Func;
IE.smoothing = str2double(IEipt.('Smoothing'));
IE.scale = str2double(IEipt.('Scale'));

Status2('done','',2);
Status2('done','',3);