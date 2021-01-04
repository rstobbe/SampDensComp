%====================================================
%
%====================================================

function [IE,err] = InitialEst_TPI_v1c_Func(IE,INPUT)

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
clear INPUT

%---------------------------------------------
% TPI estimate
%---------------------------------------------
Rad = sqrt(Kmat(1,:,1).^2 + Kmat(1,:,2).^2 + Kmat(1,:,3).^2);               % use only one traj in case of elip
iSDC = zeros(size(Rad));
for n = 1:length(Rad)
    if Rad(n) < (PROJdgn.kmax*PROJdgn.p)
        iSDC(n) = ((Rad(n)/PROJdgn.kmax)/PROJdgn.p).^2;
    else
        iSDC(n) = 1;
    end
end

%---------------------------------------------
% Scaling
%---------------------------------------------
scale = PROJimp.trajosamp * (1/PROJdgn.p) * PROJdgn.projosamp * (1/PROJdgn.elip);   % will overestimate when large CATPIS (trajosamp with respect to gradient).
scale = scale/5;            % start higher
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

