%===============================================
% 
%===============================================

function [BRK,err] = Break_Iterations_v1f_Func(BRK,INPUT)

Status2('done','Test for Stopping Criteria',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Working Structures / Variables
%---------------------------------------------
j = INPUT.j;
ANLZ = INPUT.ANLZ;

%---------------------------------------------
% Test for Stopping
%---------------------------------------------
if j > BRK.itnum
    BRK.stop = 1;
    BRK.stopreason = 'Objective Reached';
else
    BRK.stop = 0;
    BRK.stopreason = '';
end

%---------------------------------------------
% Test for Stopping - increasing error
%---------------------------------------------
if j > 2 && BRK.stop == 0 && ANLZ.MeanAbsErrTot(j-1) ~= 0
    if ANLZ.MeanAbsErrTot(j-1) > ANLZ.MeanAbsErrTot(j-2)
        if ANLZ.MeanAbsErrTot(j) > ANLZ.MeanAbsErrTot(j-1)
            BRK.stop = 1;
            BRK.stopreason = 'Error Increasing';
        end
    end
end

%----------------------------------------------------
% Panel Items
%----------------------------------------------------
Panel(1,:) = {'Iterations',j-1,'Output'};
Panel(2,:) = {'StepReason',BRK.stopreason,'Output'};
PanelOutput = cell2struct(Panel,{'label','value','type'},2);
BRK.PanelOutput = PanelOutput;