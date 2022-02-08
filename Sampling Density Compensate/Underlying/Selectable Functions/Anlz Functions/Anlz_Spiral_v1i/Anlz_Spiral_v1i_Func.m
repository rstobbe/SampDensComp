%================================================
%  
%================================================

function [ANLZ,err] = Anlz_Spiral_v1i_Func(ANLZ,INPUT)

Status2('done','Analyze SDC',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Working Structures / Variables
%---------------------------------------------
IMP = INPUT.IMP;
PROJimp = IMP.PROJimp;
PROJdgn = IMP.impPROJdgn;
Kmat = IMP.Kmat;
DOV = INPUT.DOV;
W = INPUT.W;
SDC0 = INPUT.SDC0;
j = INPUT.j;
clear INPUT

%---------------------------------------------
% Store Current for Possible Saving
%---------------------------------------------
ANLZ.DOV = DOV;
ANLZ.W = W;

%---------------------------------------------
% Mean Error Calculation
%---------------------------------------------    
E = (W ./ DOV);
[Emat] = SDCArr2Mat(E,PROJimp.nproj,PROJimp.npro);
ANLZ.MeanErrTrajArr = mean(Emat,1);

%--------------------------------------
% Relative Error
%--------------------------------------
E = (W ./ DOV) - 1;
E(E < -1) = -1;
E(E > 1) = 1;
[Emat] = SDCArr2Mat(E,PROJimp.nproj,PROJimp.npro);
tdp = PROJimp.npro*PROJimp.nproj;
ANLZ.MeanAbsErrTrajArr = (sum(abs(Emat),1)/PROJimp.nproj)*100;
ANLZ.MeanAbsErrTot(j) = (sum(abs(Emat(:)))/tdp)*100;
if ANLZ.MeanAbsErrTot(j) > 100
    ANLZ.MeanAbsErrTot(j) = 100;
end
ANLZ.CErr(j) = ANLZ.MeanAbsErrTrajArr(1);
if ANLZ.CErr(j) > 100
    ANLZ.CErr(j) = 100;
end

%--------------------------------------
% Sampling Efficiency
%--------------------------------------
[SDC0mat] = SDCArr2Mat(SDC0,PROJimp.nproj,PROJimp.npro);
ANLZ.MeanSDCTrajArr = mean(SDC0mat,1);
ANLZ.Eff(j) = Efficiency_Test(PROJimp.npro,PROJimp.nproj,SDC0mat);

%--------------------------------------
% Display
%--------------------------------------
Iteration = (j-1)
MeanAbsErrTot = ANLZ.MeanAbsErrTot(j)
Eff = ANLZ.Eff(j)
TrajAveSDC = mean(SDC0mat(:,1:12),1)
MeanAbsErrTrajArr = ANLZ.MeanAbsErrTrajArr(1:12)

%--------------------------------------
% Figures
%--------------------------------------
[ArrKmat] = KMat2Arr(Kmat,PROJimp.nproj,PROJimp.npro);
rads = (sqrt(ArrKmat(:,1).^2 + ArrKmat(:,2).^2))/(PROJimp.meanrelkmax*PROJdgn.kmax);
ANLZ.rads = rads;

sampno = meshgrid((1:PROJimp.npro),(1:PROJimp.nproj));
ANLZ.sampno = reshape(sampno,1,(PROJimp.npro*PROJimp.nproj));

if strcmp(ANLZ.xaxis,'SampNum');
    xax = ANLZ.sampno;
    xstring = 'sampling point number';
else
    xax = ANLZ.rads;
    xstring = 'relative radial dimension';
end
    
if strcmp(ANLZ.visuals,'On');
   
    %figure(51);
    %plot(xax,SDC0,'r*');
    %title('SDC Values at Sampling Point Locations'); xlabel(xstring);

    %figure(52); clf(52); hold on;
    %plot(xax,DOV,'k*');
    %plot(xax,W,'r*');
    %title('Output Values at Sampling Point Locations'); xlabel(xstring);

    figure(53); clf(53); hold on;
    plot(ANLZ.MeanErrTrajArr,'r*');
    smootherr = smooth(ANLZ.MeanErrTrajArr,20);
    plot(smootherr,'k');
    title('Mean Relative Error Along Trajectory'); xlabel('sampling point number');       
    
    %figure(54);
    %plot(xax,E*100,'r*');
    %title('Error (%) at Sampling Point Locations'); xlabel(xstring);

    %figure(55);
    %plot(ANLZ.MeanAbsErrTrajArr,'r*');
    %title('Average Absolute Error (%) Along Trajectory'); xlabel('sampling point number');    

    %figure(57);
    %plot(ANLZ.MeanSDCTrajArr,'r*');
    %title('Mean SDC Along Trajectory'); xlabel('sampling point number');   

end

%----------------------------------------------------
% Panel Items
%----------------------------------------------------
Panel(1,:) = {'MeanAbsErrTot',MeanAbsErrTot,'Output'};
Panel(2,:) = {'MeanAbsErrCen',MeanAbsErrTrajArr(1),'Output'};
Panel(3,:) = {'Eff',Eff,'Output'};
PanelOutput = cell2struct(Panel,{'label','value','type'},2);
ANLZ.PanelOutput = PanelOutput;

