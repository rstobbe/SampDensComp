%====================================================
% 
%====================================================

function [TF,err] = TF_KaiserPlank_v1c_Func(TF,INPUT)

Status2('busy','Return KaiserPlank Transfer Function',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
IMP = INPUT.IMP;
if not(isfield(IMP,'impPROJdgn'))
    PROJdgn = IMP.PROJdgn;
else
    PROJdgn = IMP.impPROJdgn;
end

%---------------------------------------------
% Create Base Transfer Function
%---------------------------------------------
if not(isfield(PROJdgn,'spiralaccom'))
    PROJdgn.spiralaccom = 1;
end
rmax = ceil(PROJdgn.spiralaccom*100)/100;
r = (0:0.0001/rmax:1);
Kaiser = besseli(0,TF.beta * sqrt(1 - r.^2)); 
Kaiser = Kaiser/Kaiser(1);

fh = figure(400); 
fh.Name = 'Sampling Density Compensation Setup';
fh.NumberTitle = 'off';
fh.Position = [400 150 1000 800];
subplot(2,2,1); hold on;
TF.r = (0:0.0001:rmax);
plot(TF.r,Kaiser);

%---------------------------------------------
% Plank Taper
%---------------------------------------------
reldrop = TF.enddrop/PROJdgn.rad;
N = length(r);
Plank0 = ones(1,N);
for n = 1:N
    if n > (1-reldrop)*N
        Plank0(n) = 1/((exp(reldrop*(1/(1-n/N) + 1/(1-reldrop-n/N))))+1);
    end
end     
ind = find(Plank0 < 1e-2,1,'first');
Plank = ones(1,N);
Plank(N-ind+1:N) = Plank0(1:ind);
plot(TF.r,Plank);        

%---------------------------------------------
% Find RelEffRad
%---------------------------------------------
start = find(Plank > 0.9,1,'last');
TF.RelEffRad = round(interp1(Plank(start:end),TF.r(start:end),0.5)*10000)/10000;

%---------------------------------------------
% Combine
%---------------------------------------------  
KaiserPlank = Plank.*Kaiser + 0.01;
KaiserPlank = KaiserPlank/max(KaiserPlank);
plot(TF.r,KaiserPlank);
xlabel('Relative Radius'); title('Output Transfer Function');

%---------------------------------------------
% Plot Profiles
%---------------------------------------------        
psfKaiser = ifftshift(ifft([Kaiser zeros(1,179999) flip(Kaiser(2:end),2)]));
psfPlank = ifftshift(ifft([Plank zeros(1,179999) flip(Plank(2:end),2)]));
psfKaiserPlank = ifftshift(ifft([KaiserPlank zeros(1,179999) flip(KaiserPlank(2:end),2)]));

figure(fh); 
subplot(2,2,2); hold on;
L = length(psfKaiser);
plot(psfKaiser(L/2-300:L/2+299)/max(psfPlank));
plot(psfPlank(L/2-300:L/2+299)/max(psfPlank));
plot(psfKaiserPlank(L/2-300:L/2+299)/max(psfPlank));
box on;
title('Output PSF (Cart-1D)');

%---------------------------------------------
% Output
%---------------------------------------------  
TF.tf = KaiserPlank;
TF.forsdcest = Kaiser/max(Kaiser);

%----------------------------------------------------
% Panel Items
%----------------------------------------------------
Panel(1,:) = {'TF_Shape','KaiserPlank','Output'};
Panel(2,:) = {'TF_beta',TF.beta,'Output'};
Panel(3,:) = {'TF_enddrop',TF.enddrop,'Output'};
Panel(4,:) = {'RelEffRad',TF.RelEffRad,'Output'};
PanelOutput = cell2struct(Panel,{'label','value','type'},2);
TF.Panel = Panel;
TF.PanelOutput = PanelOutput;


