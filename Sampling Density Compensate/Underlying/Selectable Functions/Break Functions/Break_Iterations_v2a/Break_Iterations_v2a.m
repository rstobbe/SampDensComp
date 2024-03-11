%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef Break_Iterations_v2a < handle

properties (SetAccess = private)                   
    Method = 'Break_Iterations_v2a'
    ItNum
    Stop
    StopReason
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [BRK,err] = Break_Iterations_v2a(BRKipt)     
    err.flag = 0;
    BRK.ItNum = str2double(BRKipt.('ItNum')); 
    BRK.Stop = 0;
end

%==================================================================
% FinishTest
%==================================================================  
function err = FinishTest(BRK,SDCMETH)
    err.flag = 0;
    IT = SDCMETH.IT;
    ANLZ = IT.ANLZ;

    %---------------------------------------------
    % Test for Stopping
    %---------------------------------------------
    if IT.ItNum > BRK.ItNum
        BRK.Stop = 1;
        BRK.StopReason = 'Objective Reached';
    end

    %---------------------------------------------
    % Test for Stopping - increasing error
    %---------------------------------------------
    if IT.ItNum > 3 && BRK.Stop == 0 && ANLZ.MeanAbsErrTot(IT.ItNum-1) ~= 0
        if ANLZ.MeanAbsErrTot(IT.ItNum-2) > ANLZ.MeanAbsErrTot(IT.ItNum-3)
            if ANLZ.MeanAbsErrTot(IT.ItNum-1) > ANLZ.MeanAbsErrTot(IT.ItNum-2)
                if ANLZ.MeanAbsErrTot(IT.ItNum) > ANLZ.MeanAbsErrTot(IT.ItNum-1)
                    BRK.Stop = 1;
                    BRK.StopReason = 'Error Increasing';
                end
            end
        end
    end

    %----------------------------------------------------
    % Panel Items
    %----------------------------------------------------
    BRK.Panel(1,:) = {'Iterations',IT.ItNum-1,'Output'};
    BRK.Panel(2,:) = {'StepReason',BRK.StopReason,'Output'};

end   
    
end
end






