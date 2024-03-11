%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef Calc_SampDensStandard_v2a < handle

properties (SetAccess = private)                   
    Method = 'Calc_SampDensStandard_v2a'
    MaxRelChangeEnd
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [CALC,err] = Calc_SampDensStandard_v2a(CALCipt)     
    err.flag = 0;
    CALC.MaxRelChangeEnd = str2double(CALCipt.('MaxRelChangeEnd'));     
end

%==================================================================
% CalcComp
%==================================================================  
function [SampDensComp,err] = CalcComp(CALC,SDCMETH)    
    err.flag = 0;
    CTFV = SDCMETH.CTFV;
    IT = SDCMETH.IT;
    
    %---------------------------------------------
    % Calculate SampDensComp
    %---------------------------------------------
    SampDensComp = (CTFV.DesiredOutputValues ./ IT.WeightVals) .* IT.SampDensComp;                                      

    %---------------------------------------------
    % Disregard Negative
    %---------------------------------------------
    SampDensComp(SampDensComp < 0) = IT.SampDensComp(SampDensComp < 0);
    if not(isempty(find(SampDensComp < 0,1)))
        error
    end

    maxrelchange = CALC.MaxRelChangeEnd * CTFV.DesiredOutputValues * 5;
    maxrelchange(maxrelchange < CALC.MaxRelChangeEnd) = CALC.MaxRelChangeEnd;

    %---------------------------------------------
    % Constrain
    %---------------------------------------------
    Test1 = sum(SampDensComp > maxrelchange.*IT.SampDensComp);
    SampDensComp(SampDensComp > maxrelchange.*IT.SampDensComp) = maxrelchange(SampDensComp > maxrelchange.*IT.SampDensComp) .* IT.SampDensComp(SampDensComp > maxrelchange.*IT.SampDensComp);
    Test2 = sum(SampDensComp < (1./maxrelchange).*IT.SampDensComp);
    SampDensComp(SampDensComp < (1./maxrelchange).*IT.SampDensComp) = (1./maxrelchange(SampDensComp < (1./maxrelchange).*IT.SampDensComp)) .* IT.SampDensComp(SampDensComp < (1./maxrelchange).*IT.SampDensComp);
    
end


end
end

