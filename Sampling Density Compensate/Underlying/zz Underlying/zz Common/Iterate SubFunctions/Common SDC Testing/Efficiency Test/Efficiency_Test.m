%==================================================
% Testing
%==================================================

function [Eff] = Efficiency_Test(npro,nproj,SDC)

SPG = (sum(SDC(:)))^2;                              % signal power gain           
NPG = sum(SDC(:).^2);                               % noise power gain
WPG = SPG/NPG;                                   % WPG(weighted processing gain) compare to total number of data points
NWPG = npro*nproj;                             % NWPG(non-weighted processing gain) total number of data points = processing gain if no weighting (SDC = ones)
Eff = sqrt(WPG/NWPG);                            % Sampling efficiency
