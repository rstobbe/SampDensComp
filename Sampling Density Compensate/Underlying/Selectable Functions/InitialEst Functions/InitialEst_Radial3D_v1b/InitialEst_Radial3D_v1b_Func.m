%====================================================
%
%====================================================

function [IE,err] = InitialEst_Radial3D_v1b_Func(IE,INPUT)

Status2('busy','Determine Initial Estimate',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
PROJdgn = INPUT.IMP.impPROJdgn;
PROJimp = INPUT.IMP.PROJimp;
Kmat = INPUT.IMP.Kmat;
TFO = INPUT.TFO;
clear INPUT

%---------------------------------------------
% Radial3D estimate
%---------------------------------------------
Rad = sqrt(Kmat(1,:,1).^2 + Kmat(1,:,2).^2 + Kmat(1,:,3).^2);               % use only one traj in case of elip
iSDC = (Rad/PROJdgn.kmax).^2;

%--------------------------------------------
% Interp at Sampling Points
%--------------------------------------------
kmax = PROJdgn.kmax;
r = sqrt(Kmat(:,:,1).^2 + Kmat(:,:,2).^2 + Kmat(:,:,3).^2)/kmax;
rprof0 = mean(r,1);
TFOKmat = interp1(TFO.r,TFO.forsdcest,rprof0,'linear','extrap');
iSDC = TFOKmat.*iSDC;   

%---------------------------------------------
% Scaling
%---------------------------------------------
if PROJdgn.projosamp > 1
    scale = PROJimp.trajosamp * PROJdgn.projosamp;   
else
    scale = PROJimp.trajosamp; 
end
scale = scale/2;            % start higher
iSDC = iSDC/scale;

figure(400); 
subplot(2,2,3);
plot(iSDC,'k'); 
xlabel('Sampling Point'); 
title('Initial SDC Estimate');

iSDC = meshgrid(iSDC,(1:PROJdgn.nproj));
IE.iSDC = iSDC;
IE.iterations = 0;

Status2('done','',2);
Status2('done','',3);

