%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef Anlz_LR_v2a < handle

properties (SetAccess = private)                   
    Method = 'Anlz_LR_v2a'
    Visuals
    xAxis
    Draw = 0;
    MeanErrTrajArr
    MeanAbsErrTrajArr
    MeanAbsErrTot
    MeanSDCTrajArr
    Eff
    CErr
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [ANLZ,err] = Anlz_LR_v2a(ANLZipt)     
    err.flag = 0;
    ANLZ.Visuals = ANLZipt.('Visuals');  
    ANLZ.xAxis = ANLZipt.('xAxis');   
end

%==================================================================
% TestSdc
%==================================================================
function err = TestSdc(ANLZ,SDCMETH,IMP)
    err.flag = 0;
    CTFV = SDCMETH.CTFV;
    KINFO = SDCMETH.KINFO;
    IT = SDCMETH.IT;
    OPT = SDCMETH.OPT;
    
    %---------------------------------------------
    % Set Up Figure
    %---------------------------------------------
    FirstPass = 0;
    if ANLZ.Draw == 0 && OPT.ANLZvis
        fh = figure(50); clf;
        fh.Name = 'Sampling Density Compensation Iterations';
        fh.NumberTitle = 'off';
        fh.Position = [400 150 1000 800];
        FirstPass = 1;
        ANLZ.Draw = 1;
    end

    %---------------------------------------------
    % Mean Error Calculation
    %---------------------------------------------    
    Error = (IT.WeightVals - CTFV.DesiredOutputValues)/CTFV.DesiredOutputValues(1);
    [ErrorMat] = SDCArr2Mat(Error,KINFO.nproj,KINFO.SamplingPts);
    ANLZ.MeanErrTrajArr = mean(ErrorMat,1);
    [DovMat] = SDCArr2Mat(CTFV.DesiredOutputValues,KINFO.nproj,KINFO.SamplingPts);
    DovArr = mean(DovMat,1);
    [WeightMat] = SDCArr2Mat(IT.WeightVals,KINFO.nproj,KINFO.SamplingPts);
    WeightArr = mean(WeightMat,1);

    %--------------------------------------
    % Relative Error
    %--------------------------------------
    Error = (IT.WeightVals - CTFV.DesiredOutputValues)/CTFV.DesiredOutputValues(1);
    Error(Error < -1) = -1;
    Error(Error > 1) = 1;
    [ErrorMat] = SDCArr2Mat(Error,KINFO.nproj,KINFO.SamplingPts);
    tdp = KINFO.nproj*KINFO.SamplingPts;
    ANLZ.MeanAbsErrTrajArr = (sum(abs(ErrorMat))/KINFO.nproj)*100;
    ANLZ.MeanAbsErrTot(IT.ItNum) = (sum(abs(ErrorMat(:)))/tdp)*100;
    if ANLZ.MeanAbsErrTot(IT.ItNum) > 100
        ANLZ.MeanAbsErrTot(IT.ItNum) = 100;
    end
    ANLZ.CErr(IT.ItNum) = ANLZ.MeanAbsErrTrajArr(1);
    if ANLZ.CErr(IT.ItNum) > 100
        ANLZ.CErr(IT.ItNum) = 100;
    end

    %--------------------------------------
    % Sampling Efficiency
    %--------------------------------------
    [SampDensCompMat] = SDCArr2Mat(IT.SampDensComp,KINFO.nproj,KINFO.SamplingPts);
    ANLZ.MeanSDCTrajArr = mean(SampDensCompMat,1);
    ANLZ.Eff(IT.ItNum) = Efficiency_Test(KINFO.SamplingPts,KINFO.nproj,SampDensCompMat);

    %--------------------------------------
    % Display
    %--------------------------------------
    Iteration = (IT.ItNum-1)
    MeanAbsErrTot = ANLZ.MeanAbsErrTot(IT.ItNum)
    Eff = ANLZ.Eff(IT.ItNum)
    TrajAveSDC = mean(SampDensCompMat(:,1:12))
    if length(ANLZ.MeanAbsErrTrajArr) > 1
        MeanAbsErrTrajArr = ANLZ.MeanAbsErrTrajArr(1:12)
    else
        MeanAbsErrTrajArr = ANLZ.MeanAbsErrTrajArr(1)
    end

    %--------------------------------------
    % Figures
    %--------------------------------------
    meanrads = (sqrt(KINFO.kSpace(:,:,1).^2 + KINFO.kSpace(:,:,2).^2 + KINFO.kSpace(:,:,3).^2))/KINFO.kmax;
    meanrads = mean(meanrads,1);

    if strcmp(ANLZ.xAxis,'SampNum')
        xaxmean = (1:KINFO.SamplingPts);
        xstring = 'Sampling Point Number';
    else
        xaxmean = meanrads;
        xstring = 'Relative Radius';
    end

    if OPT.ANLZvis
        hFig = figure(50); clf;
        subplot(2,2,1); hold on;
        plot(xaxmean,ANLZ.MeanSDCTrajArr,'k');
        title('Mean SDC Values at Sampling Point Locations'); xlabel(xstring);  

        subplot(2,2,2); hold on;
        plot(xaxmean,DovArr,'k');
        plot(xaxmean,WeightArr,'r');
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

    %----------------------------------------------------
    % Panel Items
    %----------------------------------------------------
    ANLZ.Panel(1,:) = {'MeanAbsErrTot (%)',ANLZ.MeanAbsErrTot(end),'Output'};
    ANLZ.Panel(2,:) = {'MeanAbsErrCen (%)',ANLZ.MeanAbsErrTrajArr(1),'Output'};
    ANLZ.Panel(3,:) = {'Eff',ANLZ.Eff(end),'Output'};
       
end

end
end


