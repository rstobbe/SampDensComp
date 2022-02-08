%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef TF_KaiserPlank_v2a < handle

properties (SetAccess = private)                   
    Method = 'TF_KaiserPlank_v2a'
    Beta
    EndDrop
    Rad
    RelEndDrop
    RelEffRad
    TransFuncOut
    ForSdcEst
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [TFO,err] = TF_KaiserPlank_v2a(TFOipt)     
    err.flag = 0;
    TFO.Beta = str2double(TFOipt.('Beta'));
    TFO.EndDrop = str2double(TFOipt.('EndDrop'));        
end


%==================================================================
% DefineTransferFunction
%==================================================================  
function err = DefineTransferFunction(TFO,SDCMETH,IMP) 
    err.flag = 0;
    KINFO = SDCMETH.KINFO;
    
    %---------------------------------------------
    % Kaiser
    %---------------------------------------------
    TFO.Rad = (0:0.0001:1);
    Kaiser = besseli(0,TFO.Beta * sqrt(1 - TFO.Rad.^2)); 
    Kaiser = Kaiser/Kaiser(1);

    fh = figure(400); 
    fh.Name = 'Sampling Density Compensation Setup';
    fh.NumberTitle = 'off';
    fh.Position = [400 150 1000 800];
    subplot(2,2,1); hold on;
    plot(TFO.Rad,Kaiser);

    %---------------------------------------------
    % Plank Taper
    %---------------------------------------------
    TFO.RelEndDrop = TFO.EndDrop/KINFO.rad;
    N = length(TFO.Rad);
    Plank0 = ones(1,N);
    for n = 1:N
        if n > (1-TFO.RelEndDrop)*N
            Plank0(n) = 1/((exp(TFO.RelEndDrop*(1/(1-n/N) + 1/(1-TFO.RelEndDrop-n/N))))+1);
        end
    end     
    ind = find(Plank0 < 1e-2,1,'first');
    Plank = ones(1,N);
    Plank(N-ind+1:N) = Plank0(1:ind);
    plot(TFO.Rad,Plank);        

    %---------------------------------------------
    % Find RelEffRad
    %---------------------------------------------
    start = find(Plank > 0.9,1,'last');
    TFO.RelEffRad = round(interp1(Plank(start:end),TFO.Rad(start:end),0.5)*10000)/10000;

    %---------------------------------------------
    % Combine
    %---------------------------------------------  
    KaiserPlank = Plank.*Kaiser + 0.01;
    KaiserPlank = KaiserPlank/max(KaiserPlank);
    plot(TFO.Rad,KaiserPlank);
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
    TFO.TransFuncOut = KaiserPlank;
    TFO.ForSdcEst = Kaiser/max(Kaiser);

    %----------------------------------------------------
    % Panel Items
    %----------------------------------------------------
    TFO.Panel(1,:) = {'TFO_Shape','KaiserPlank','Output'};
    TFO.Panel(2,:) = {'TFO_beta',TFO.Beta,'Output'};
    TFO.Panel(3,:) = {'TFO_enddrop',TFO.EndDrop,'Output'};
    TFO.Panel(4,:) = {'RelEffRad',TFO.RelEffRad,'Output'};
end



end
end





