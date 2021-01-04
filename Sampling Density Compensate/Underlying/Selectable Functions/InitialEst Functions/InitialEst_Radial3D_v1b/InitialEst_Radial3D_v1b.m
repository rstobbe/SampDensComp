%====================================================
% (v1b)
%     - update scale
%====================================================

function [SCRPTipt,IE,err] = InitialEst_Radial3D_v1b(SCRPTipt,IEipt)

Status2('done','Get Initial Estimate Function Input',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Load Input
%---------------------------------------------
IE.script = IEipt.Func;

Status2('done','',2);
Status2('done','',3);