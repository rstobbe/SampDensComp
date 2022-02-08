%=========================================================
% 
%=========================================================

function [default] = Iterate_DblConv_v2a_Default2(SCRPTPATHS)

if strcmp(filesep,'\')
    CalcPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\zz Underlying\Selectable Functions\Iterate SubFunctions\Calc Functions\'];
    AnlzPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\zz Underlying\Selectable Functions\Iterate SubFunctions\Anlz Functions\'];
    BreakPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\zz Underlying\Selectable Functions\Iterate SubFunctions\Break Functions\'];
elseif strcmp(filesep,'/')
end
CalcFunc = 'Calc_SampDensStandard_v2a';
AnlzFunc = 'Anlz_LR_v2a';
BreakFunc = 'Break_Iterations_v2a';

m = 1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'Calcfunc';
default{m,1}.entrystr = CalcFunc;
default{m,1}.searchpath = CalcPath;
default{m,1}.path = [CalcPath,CalcFunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'Anlzfunc';
default{m,1}.entrystr = AnlzFunc;
default{m,1}.searchpath = AnlzPath;
default{m,1}.path = [AnlzPath,AnlzFunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'Breakfunc';
default{m,1}.entrystr = BreakFunc;
default{m,1}.searchpath = BreakPath;
default{m,1}.path = [BreakPath,BreakFunc];

