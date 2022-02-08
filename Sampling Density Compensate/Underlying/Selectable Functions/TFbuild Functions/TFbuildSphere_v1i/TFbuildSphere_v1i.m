%================================================================================
% (v1i)
%       - Make MinSubSamp -> DesSubSamp
%================================================================================

function [SCRPTipt,TFB,err] = TFbuildSphere_v1i(SCRPTipt,TFBipt)

Status2('done','Get Build TF Input',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Return Input
%---------------------------------------------
TFB.method = TFBipt.Func;

Status2('done','',2);
Status2('done','',3);