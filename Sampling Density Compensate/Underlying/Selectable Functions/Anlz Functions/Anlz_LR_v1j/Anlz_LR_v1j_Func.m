%================================================
%  
%================================================

function [ANLZ,err] = Anlz_LR_v1j_Func(ANLZ,INPUT)

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
% Set Up Figure
%---------------------------------------------
FirstPass = 0;
if ANLZ.draw == 0 && strcmp(ANLZ.visuals,'On')
    fh = figure(50); clf;
    fh.Name = 'Sampling Density Compensation Iterations';
    fh.NumberTitle = 'off';
    fh.Position = [400 150 1000 800];
    FirstPass = 1;
    ANLZ.draw = 1;
end

%---------------------------------------------
% Store Current for Possible Saving
%---------------------------------------------
ANLZ.DOV = DOV;
ANLZ.W = W;

%---------------------------------------------
% Mean Error Calculation
%---------------------------------------------    
E = (W - DOV)/DOV(1);
[Emat] = SDCArr2Mat(E,PROJimp.nproj,PROJimp.npro);
ANLZ.MeanErrTrajArr = mean(Emat,1);
[DOVmat] = SDCArr2Mat(DOV,PROJimp.nproj,PROJimp.npro);
DOVarr = mean(DOVmat,1);
[Wmat] = SDCArr2Mat(W,PROJimp.nproj,PROJimp.npro);
Warr = mean(Wmat,1);

%--------------------------------------
% Relative Error
%--------------------------------------
E = (W - DOV)/DOV(1);
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
if length(ANLZ.MeanAbsErrTrajArr) > 1
    MeanAbsErrTrajArr = ANLZ.MeanAbsErrTrajArr(1:12)
else
    MeanAbsErrTrajArr = ANLZ.MeanAbsErrTrajArr(1)
end
    
%--------------------------------------
% Figures
%--------------------------------------
[ArrKmat] = KMat2Arr(Kmat,PROJimp.nproj,PROJimp.npro);
rads = (sqrt(ArrKmat(:,1).^2 + ArrKmat(:,2).^2 + ArrKmat(:,3).^2))/PROJdgn.kmax;
ANLZ.rads = rads;

meanrads = (sqrt(Kmat(:,:,1).^2 + Kmat(:,:,2).^2 + Kmat(:,:,3).^2))/PROJdgn.kmax;
meanrads = mean(meanrads,1);

sampno = meshgrid((1:PROJimp.npro),(1:PROJimp.nproj));
ANLZ.sampno = reshape(sampno,1,(PROJimp.npro*PROJimp.nproj));

if strcmp(ANLZ.xaxis,'SampNum')
    %xax = ANLZ.sampno;
    xaxmean = (1:PROJimp.npro);
    xstring = 'sampling point number';
else
    %xax = ANLZ.rads;
    xaxmean = meanrads;
    xstring = 'Relative Radius';
end
    
if strcmp(ANLZ.visuals,'On')
    hFig = figure(50); clf;
    subplot(2,2,1); hold on;
    plot(xaxmean,ANLZ.MeanSDCTrajArr,'k');
    title('Mean SDC Values at Sampling Point Locations'); xlabel(xstring);  

    subplot(2,2,2); hold on;
    plot(xaxmean,DOVarr,'k');
    plot(xaxmean,Warr,'r');
    title('Mean Output Values at Sampling Point Locations'); xlabel(xstring);  

    if FirstPass == 1
        answer = questdlg('Continue?');
        if strcmp(answer,'No') || strcmp(answer,'Cancel')
            err.flag = 4;
            err.msg = '';
            return
        end
    end
    
    subplot(2,2,3); hold on;
    plot(xaxmean,ANLZ.MeanErrTrajArr,'r*');
    smootherr = smooth(ANLZ.MeanErrTrajArr,20);
    plot(xaxmean,smootherr,'k');
    title('Mean Relative Error Along Trajectory'); xlabel(xstring);       
    
    subplot(2,2,4); hold on;
    plot(ANLZ.Eff);
    title('Sampling Efficiency'); xlabel('iteration');        
end

ANLZ.Figure(1).Name = 'SDC Characteristics';
ANLZ.Figure(1).Type = 'Graph';
ANLZ.Figure(1).hFig = hFig;
ANLZ.Figure(1).hAx = gca;

%----------------------------------------------------
% Panel Items
%----------------------------------------------------
Panel(1,:) = {'MeanAbsErrTot (%)',MeanAbsErrTot,'Output'};
Panel(2,:) = {'MeanAbsErrCen (%)',MeanAbsErrTrajArr(1),'Output'};
Panel(3,:) = {'Eff',Eff,'Output'};
PanelOutput = cell2struct(Panel,{'label','value','type'},2);
ANLZ.PanelOutput = PanelOutput;

