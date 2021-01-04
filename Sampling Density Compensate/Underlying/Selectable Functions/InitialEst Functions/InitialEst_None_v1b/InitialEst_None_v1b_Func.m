%====================================================
% 
%====================================================

function [IE,err] = InitialEst_None_v1b_Func(IE,INPUT)

Status2('busy','Determine Initial Estimate',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
IMP = INPUT.IMP;
Kmat = IMP.Kmat;
clear INPUT

iSDC = ones(size(Kmat));
IE.iSDC = iSDC;
IE.iterations = 0;