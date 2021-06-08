%====================================================
% 
%====================================================

function [TF,err] = TF_HammingPlank_v1a_Func(TF,INPUT)

Status2('busy','Return HammingPlank Transfer Function',2);
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
Hamming = hamming(2*(length(r)-1)+1);
Hamming = Hamming((length(Hamming)-1)/2+1:end).';
Hamming = Hamming/Hamming(1);

fh = figure(400); 
fh.Name = 'Sampling Density Compensation Setup';
fh.NumberTitle = 'off';
fh.Position = [400 150 1000 800];
subplot(2,2,1); hold on;
TF.r = (0:0.0001:rmax);
plot(TF.r,Hamming);

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
% Combine
%---------------------------------------------  
HammingPlank = Plank.*Hamming + 0.01;
HammingPlank = HammingPlank/max(HammingPlank);
%HammingPlank = Plank.*Hamming;
plot(TF.r,HammingPlank);
xlabel('Relative Radius'); title('Output Transfer Function');

%---------------------------------------------
% Plot Profiles
%---------------------------------------------        
psfHamming = ifftshift(ifft([Hamming zeros(1,179999) flip(Hamming(2:end),2)]));
psfPlank = ifftshift(ifft([Plank zeros(1,179999) flip(Plank(2:end),2)]));
psfHammingPlank = ifftshift(ifft([HammingPlank zeros(1,179999) flip(HammingPlank(2:end),2)]));

figure(fh); 
subplot(2,2,2); hold on;
L = length(psfHamming);
plot(psfHamming(L/2-300:L/2+299)/max(psfPlank));
plot(psfPlank(L/2-300:L/2+299)/max(psfPlank));
plot(psfHammingPlank(L/2-300:L/2+299)/max(psfPlank));
box on;
title('Output PSF (Cart-1D)');

%---------------------------------------------
% Output
%---------------------------------------------  
TF.tf = HammingPlank;
TF.forsdcest = Hamming/max(Hamming);

%----------------------------------------------------
% Panel Items
%----------------------------------------------------
Panel(1,:) = {'TF_Shape','HammingPlank','Output'};
Panel(3,:) = {'TF_enddrop',TF.enddrop,'Output'};
PanelOutput = cell2struct(Panel,{'label','value','type'},2);
TF.Panel = Panel;
TF.PanelOutput = PanelOutput;


