%=========================================================
% 
%=========================================================

function [default] = InitialEst_TrajSampDensEstScale_v1h_Default2(SCRPTPATHS)

m = 1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'Smoothing';
default{m,1}.entrystr = '20';

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'Scale';
default{m,1}.entrystr = '1';
