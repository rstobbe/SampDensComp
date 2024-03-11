%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef InitialEst_TrajSampDensEstScale_v2a < handle

properties (SetAccess = private)                   
    Method = 'InitialEst_TrajSampDensEstScale_v2a'
    Smoothing
    Scale
    iSampDensComp
    ItNumCur
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [IE,err] = InitialEst_TrajSampDensEstScale_v2a(IEipt)     
    err.flag = 0;
    IE.Smoothing = str2double(IEipt.('Smoothing'));
    IE.Scale = str2double(IEipt.('Scale'));
end

%==================================================================
% DetermineInitialEstimate
%==================================================================  
function [err] = DetermineInitialEstimate(IE,SDCMETH)    
    err.flag = 0;
    KINFO = SDCMETH.KINFO;
    TFO = SDCMETH.TFO;
    OPT = SDCMETH.OPT;

    %--------------------------------------------
    % Get SD Shape
    %--------------------------------------------
    Backup = 0;
    Pts = KINFO.SamplingPts-Backup;
    RelRads = sqrt(KINFO.kSpace(:,:,1).^2 + KINFO.kSpace(:,:,2).^2 + KINFO.kSpace(:,:,3).^2)/KINFO.kmax;
    RelRadProf = mean(RelRads,1);
    RelRadProfBackup = RelRadProf(1:end-Backup);
    sRelRadProfBackup = smooth(RelRadProfBackup,IE.Smoothing/Pts,'lowess').';
    sRelRadProfBackup = sRelRadProfBackup(1:end-IE.Smoothing);
    Pts = Pts - IE.Smoothing;
    dRelRadProfBackup = sRelRadProfBackup(2:end) - sRelRadProfBackup(1:end-1);
    SampDensEst = zeros(1,Pts);
    SampDensEst(2:Pts) = 1./(dRelRadProfBackup.*sRelRadProfBackup(1:Pts-1).^2);
    SampDensEst(1) = SampDensEst(2);
    SampDensEst = 2*SampDensEst/min(abs(SampDensEst));
    
    %--------------------------------------------
    % Interp at Sampling Points
    %--------------------------------------------
    SampDensEstAlongTraj = interp1(sRelRadProfBackup,SampDensEst,RelRadProf,'linear','extrap');
    TransFuncOutAlongTraj = interp1(TFO.Rad,TFO.ForSdcEst,RelRadProf,'linear','extrap');
    iSampDensCompAlongTraj = TransFuncOutAlongTraj./SampDensEstAlongTraj;   
    iSampDensCompAlongTraj(iSampDensCompAlongTraj < 0) = -iSampDensCompAlongTraj(iSampDensCompAlongTraj < 0);
    iSampDensCompAlongTraj = iSampDensCompAlongTraj*IE.Scale;
    
    %--------------------------------------------
    % Plot 
    %--------------------------------------------
    if OPT.IEvis
        figure(400); 
        subplot(2,2,3);
        plot(iSampDensCompAlongTraj,'k'); 
        xlim([0 KINFO.SamplingPts]); 
        xlabel('Sampling Point'); 
        title('Initial Compensation Estimate');
    end

    %--------------------------------------------
    % Test
    %--------------------------------------------
    if (find(iSampDensCompAlongTraj < 0))
        error;                  % fix up above
    end
    
    IE.iSampDensComp = meshgrid(iSampDensCompAlongTraj,1:KINFO.nproj);
    IE.ItNumCur = 0;
end

%==================================================================
% Clear
%==================================================================  
function Clear(IE)
   IE.iSampDensComp = [];
end


end
end



