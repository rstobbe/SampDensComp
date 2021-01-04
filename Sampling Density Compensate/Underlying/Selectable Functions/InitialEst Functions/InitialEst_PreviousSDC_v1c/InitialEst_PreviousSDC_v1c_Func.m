%====================================================
% 
%====================================================

function [IE,err] = InitialEst_PreviousSDC_v1c_Func(IE,INPUT)

Status2('busy','Return Previous SDC',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Input
%---------------------------------------------
nproj = INPUT.IMP.PROJimp.nproj;
npro = INPUT.IMP.PROJimp.npro;
if isfield(IE.iSDCS.IT,'iterations')
    IE.iterations = IE.iSDCS.IT.iterations;
else
    IE.iterations = 0;
end
iSDC = IE.iSDCS.SDC;

%----------------------------------------
% Return
%----------------------------------------
IE = rmfield(IE,'iSDCS');
IE.iSDC = SDCArr2Mat(iSDC,nproj,npro);

Status2('done','',2);
Status2('done','',3);

