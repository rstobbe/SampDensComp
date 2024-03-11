%================================================================================
% (v1k)
%       - Facilitate Rotation
%================================================================================

function [SCRPTipt,TFB,err] = TFbuildElipLowMin_v1k(SCRPTipt,TFBipt)

Status2('done','Get Build TF Input',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Return Input
%---------------------------------------------
TFB.method = TFBipt.Func;
TFB.MinRadDim = 40;

Status2('done','',2);
Status2('done','',3);