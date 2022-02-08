%==================================================
% 
%==================================================

function [CALC,err] = Calc_SampDensStandard_v1e_Func(CALC,INPUT)

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get INPUT
%---------------------------------------------
DOV = INPUT.DOV;
W = INPUT.W;
SDC0 = INPUT.SDC0;
j = INPUT.j;
clear INPUT

%---------------------------------------------
% Acceleration
%---------------------------------------------
acc = 1;

%---------------------------------------------
% Calculate SDC
%---------------------------------------------
SDC = ((double(DOV) ./ W).^acc) .* SDC0;                                      

%---------------------------------------------
% Disregard Negative
%---------------------------------------------
maxrelchange = CALC.maxrelchange;
SDC(SDC < 0) = SDC0(SDC < 0);

if not(isempty(find(SDC < 0,1)))
    error
end

maxrelchange0 = maxrelchange * DOV * 5;
maxrelchange0(maxrelchange0 < maxrelchange) = maxrelchange;
%figure(12341234)
%plot(maxrelchange0);

%---------------------------------------------
% Constrain
%---------------------------------------------
maxrelchange = maxrelchange0;
SDC(SDC > maxrelchange0.*SDC0) = maxrelchange(SDC > maxrelchange0.*SDC0).*SDC0(SDC > maxrelchange0.*SDC0);
maxrelchange = maxrelchange0;
SDC(SDC < (1./maxrelchange0).*SDC0) = (1./maxrelchange(SDC < (1./maxrelchange0).*SDC0)).*SDC0(SDC < (1./maxrelchange0).*SDC0);

%---------------------------------------------
% Return
%---------------------------------------------
CALC.SDC = SDC;

