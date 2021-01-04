%==================================================
% (v1e)
%   - same ase CalcSDC_ConstDefAcc_v1e (but no 'acc')
%==================================================

function [SCRPTipt,CALC,err] = Calc_SampDensStandard_v1e(SCRPTipt,CALCipt)

Status2('busy','Get SDC Calculation Info',2);
Status2('done','',3);

err.flag = 0;
err.mgs = '';

%---------------------------------------------
% Return Input
%---------------------------------------------
CALC.method = CALCipt.Func;
CALC.maxrelchange = str2double(CALCipt.('MaxRelChangeEnd'));

Status2('done','',2);
Status2('done','',3);
