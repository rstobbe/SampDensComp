%==================================================
% Testing
%==================================================

function [Err Ccomp Eff] = SDC_Testing_v5(W,DOV,AIDrp,SDC,j,Err,Ccomp,Eff)

E = 1 - (W./DOV);
Err(1,j) = sum(abs(E))/(AIDrp.npro*AIDrp.nproj)*100;       % Average error in %

Test = zeros(1,AIDrp.npro);
Test2 = zeros(1,AIDrp.npro);
for m = 1:AIDrp.npro
    for n = 1:AIDrp.nproj
        Test(m) = Test(m) + (1-(W(m+AIDrp.npro*(n-1)) / DOV(m+AIDrp.npro*(n-1))));
        Test2(m) = Test2(m) + SDC(m+AIDrp.npro*(n-1));
    end
end
Test = Test/AIDrp.nproj*100;                       % Error in %
Test2 = (Test2/AIDrp.nproj)*100;                   

Ccomp(1,j) = Test2(1);
Ccomp(2,j) = Test2(2);
Ccomp(3,j) = Test2(3);
Ccomp(4,j) = Test2(4);
Ccomp(5,j) = Test2(5);

Err(:,1) = NaN;    

Err(2,j) = Test(1);                
Err(3,j) = Test(2);
Err(4,j) = Test(3);
Err(5,j) = Test(4);
Err(6,j) = Test(5);

SPG = (sum(SDC))^2;                              % signal power gain           
NPG = sum(SDC.^2);                               % noise power gain
WPG = SPG/NPG;                                   % WPG(weighted processing gain) compare to total number of data points
NWPG = AIDrp.npro*AIDrp.nproj;                   % NWPG(non-weighted processing gain) total number of data points = processing gain if no weighting (SDC = ones)
Eff(j) = sqrt(WPG/NWPG)                          % Sampling efficiency
