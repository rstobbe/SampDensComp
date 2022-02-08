%====================================================
% 
%====================================================

function [IE,err] = InitialEst_TrajSampDensEstTpi_v1a_Func(IE,INPUT)

Status2('busy','Determine Initial Estimate',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
IMP = INPUT.IMP;
projconeosamp = IMP.PSMP.PCD.projconeosamp;
samp = IMP.samp;
Kmat = IMP.Kmat;
if isfield(IMP,'impPROJdgn')
    PROJdgn = IMP.impPROJdgn;
else
    PROJdgn = IMP.PROJdgn;
end
PROJimp = IMP.PROJimp;
TFO = INPUT.TFO;
clear INPUT

%--------------------------------------------
% Common Variables
%--------------------------------------------
if isfield(PROJdgn,'p')
    p = PROJdgn.p;
else
    p = 1;
end
tro = PROJdgn.tro;
if not(isfield(PROJdgn,'projlen'))
    projlen = 1;
else
    projlen = PROJdgn.projlen;
end
kmax = PROJdgn.kmax;
nproj = PROJimp.nproj;
sz = size(Kmat);
npro = sz(2);

%--------------------------------------------
% Get SD Shape
%--------------------------------------------
backup = 10;
npro = npro-backup;
r = sqrt(Kmat(end,:,1).^2 + Kmat(end,:,2).^2 + Kmat(end,:,3).^2)/kmax;
rprof0 = mean(r,1);
rprof = rprof0(1:end-backup);
rprof = smooth(rprof,IE.smoothing/npro,'lowess').';
rprof = rprof(1:end-IE.smoothing);
relsamp = projlen*(samp/tro);
relsamp = relsamp(1:end-backup-IE.smoothing);
npro = npro-IE.smoothing;
dr = zeros(1,npro);
for m = 2:npro
    dr(m) = (rprof(m)-rprof(m-1))/(relsamp(m)-relsamp(m-1));
end

SDest = zeros(1,npro);
SDest(2:npro) = p^2./(dr(2:npro).*rprof(1:npro-1).^2);
SDest(1) = SDest(2);

%--------------------------------------------
% Add Global Sampling Density
%--------------------------------------------
if isfield(PROJdgn,'edgeSD')
    SDest = SDest*(PROJdgn.edgeSD/SDest(end));
end
SDest = SDest * PROJimp.trajosamp;

%--------------------------------------------
% Interp at Sampling Points
%--------------------------------------------
SDestKmat = interp1(rprof,SDest,rprof0,'linear','extrap');
TFOKmat = interp1(TFO.r,TFO.forsdcest,rprof0,'linear','extrap');
iSDC = TFOKmat./SDestKmat;   

iSDC(iSDC < 0) = -iSDC(iSDC < 0);

iSDC = iSDC*IE.scale;

%--------------------------------------------
% Plot 
%--------------------------------------------
visuals = 1;
if visuals == 1
    figure(400); 
    subplot(2,2,3);
    plot(rprof0,SDestKmat,'k'); 
    ylim([0 1.5*(1/p)^2]); 
    xlim([0 1]);
    xlabel('Relative Radius'); 
    title('Initial Sampling Estimate');
end

%--------------------------------------------
% Test
%--------------------------------------------
if (find(iSDC < 0))
    error;                  % fix up above
end

iSDC = meshgrid(iSDC,1:nproj);

for n = 1:nproj
    iSDC(n,:) = iSDC(n,:)/projconeosamp(n);
end

% figure(2346234);
% plot(iSDC(:,1000));

IE.iSDC = iSDC;
IE.iterations = 0;
