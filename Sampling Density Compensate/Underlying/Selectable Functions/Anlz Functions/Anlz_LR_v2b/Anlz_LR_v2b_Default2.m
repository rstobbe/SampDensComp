%=========================================================
% 
%=========================================================

function [default] = Anlz_LR_v1j_Default2(SCRPTPATHS)

m = 1;
default{m,1}.entrytype = 'Choose';
default{m,1}.labelstr = 'Visuals';
default{m,1}.entrystr = 'On';
default{m,1}.options = {'On','Off'};

m = m+1;
default{m,1}.entrytype = 'Choose';
default{m,1}.labelstr = 'xAxis';
default{m,1}.entrystr = 'Rads';
default{m,1}.options = {'SampNum','Rads'};