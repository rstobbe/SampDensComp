%=========================================================
% 
%=========================================================

function [default] = Options_Standard_v1c_Default2(SCRPTPATHS)

m = 1;
default{m,1}.entrytype = 'Choose';
default{m,1}.labelstr = 'Precision';
default{m,1}.entrystr = 'Double';
default{m,1}.options = {'Single','Double'};

m = m+1;
default{m,1}.entrytype = 'Choose';
default{m,1}.labelstr = 'ResetGpus';
default{m,1}.entrystr = 'Yes';
default{m,1}.options = {'No','Yes'};

