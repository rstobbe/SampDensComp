%================================================
%  
%================================================

function [ANLZ,err] = Anlz_TPI_v1h_Func(ANLZ,INPUT)

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
projindx = IMP.PSMP.PCD.projindx;
clear INPUT

%---------------------------------------------
% Store Current for Possible Saving
%---------------------------------------------
%ANLZ.DOV = DOV;
%ANLZ.W = W;

%---------------------------------------------
% Mean Error Calculation
%---------------------------------------------    
E = (W - DOV)/DOV(1);
[Emat] = SDCArr2Mat(E,PROJimp.nproj,PROJimp.npro);
ANLZ.MeanErrTrajArr = 100*(mean(Emat,1));

%--------------------------------------
% Relative Error
%--------------------------------------
E(E < -1) = -1;
E(E > 1) = 1;
[Emat] = SDCArr2Mat(E,PROJimp.nproj,PROJimp.npro);
tdp = PROJimp.npro*PROJimp.nproj;
ANLZ.MeanAbsErrTrajArr = (sum(abs(Emat))/PROJimp.nproj)*100;
ANLZ.MeanAbsErrTot(j) = (sum(abs(Emat(:)))/tdp)*100;
if ANLZ.MeanAbsErrTot(j) > 100
    ANLZ.MeanAbsErrTot(j) = 100;
end
ANLZ.CErr(j) = ANLZ.MeanAbsErrTrajArr(1);
if ANLZ.CErr(j) > 100
    ANLZ.CErr(j) = 100;
end
for n = 1:length(projindx)
    ANLZ.MeanAbsErrCones(n) = (sum(sum(abs(Emat(projindx{n},:))))/(length(projindx{n})*PROJimp.npro))*100;
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
TrajAveSDC = mean(SDC0mat(:,1:12))
MeanAbsErrTrajArr = ANLZ.MeanAbsErrTrajArr(1:12)

%--------------------------------------
% Figures
%--------------------------------------
[ArrKmat] = KMat2Arr(Kmat,PROJimp.nproj,PROJimp.npro);
rads = (sqrt(ArrKmat(:,1).^2 + ArrKmat(:,2).^2 + ArrKmat(:,3).^2))/(PROJimp.meanrelkmax*PROJdgn.kmax);
%ANLZ.rads = rads;

sampno = meshgrid((1:PROJimp.npro),(1:PROJimp.nproj));
sampno = reshape(sampno,1,(PROJimp.npro*PROJimp.nproj));
%ANLZ.sampno = sampno;

if strcmp(ANLZ.xaxis,'SampNum');
    xax = sampno;
    xstring = 'sampling point number';
else
    xax = rads;
    xstring = 'relative radial dimension';
end

%--------------------------------------
% Basic Plot
if strcmp(ANLZ.visuals,'Basic') 
    hFig = figure(50); clf(50); hold on;
    [Wmat] = SDCArr2Mat(W,PROJimp.nproj,PROJimp.npro);
    [DOVmat] = SDCArr2Mat(DOV,PROJimp.nproj,PROJimp.npro);
    xax = SDCArr2Mat(xax,PROJimp.nproj,PROJimp.npro);
    xax = squeeze(xax(1,:));
    subplot(2,1,1); hold on;
    plot(xax,mean(DOVmat,1),'k');
    plot(xax,mean(Wmat,1),'r*');
    title('Output Values at Sampling Point Locations'); xlabel(xstring);
    
    subplot(2,1,2); hold on;
    plot(xax,ANLZ.MeanErrTrajArr,'r*');
    smootherr = smooth(ANLZ.MeanErrTrajArr,20);
    plot(xax,smootherr,'k');
    title('Mean Relative Error Along Trajectory'); xlabel(xstring); ylabel('% error');   
end

ANLZ.Figure(1).Name = 'SDC Characteristics';
ANLZ.Figure(1).Type = 'Graph';
ANLZ.Figure(1).hFig = hFig;
ANLZ.Figure(1).hAx = gca;

%figure(54);
%plot(xax,E*100,'r*');
%title('Error (%) at Sampling Point Locations'); xlabel(xstring);

%figure(55);
%plot(ANLZ.MeanAbsErrTrajArr,'r*');
%title('Average Absolute Error (%) Along Trajectory'); xlabel('sampling point number');    

%figure(57);
%plot(ANLZ.MeanSDCTrajArr,'r*');
%title('Mean SDC Along Trajectory'); xlabel('sampling point number');   

%figure(58);
%plot(ANLZ.MeanAbsErrCones,'r*');
%title('Mean Absolute Error on Cones'); xlabel('cone number');       


%----------------------------------------------------
% Panel Items
%----------------------------------------------------
Panel(1,:) = {'MeanAbsErrTot',MeanAbsErrTot,'Output'};
Panel(2,:) = {'MeanAbsErrCen',MeanAbsErrTrajArr(1),'Output'};
Panel(3,:) = {'Eff',Eff,'Output'};
PanelOutput = cell2struct(Panel,{'label','value','type'},2);
ANLZ.PanelOutput = PanelOutput;
