%=========================================================
% 
%=========================================================

function [default] = TrajManip_Tornado_v2a_Default2(SCRPTPATHS)

m = 1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'FullSampWindow';
default{m,1}.entrystr = '800';

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'TotalWindow';
default{m,1}.entrystr = '4000';

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'TrajCen';
default{m,1}.entrystr = '1';