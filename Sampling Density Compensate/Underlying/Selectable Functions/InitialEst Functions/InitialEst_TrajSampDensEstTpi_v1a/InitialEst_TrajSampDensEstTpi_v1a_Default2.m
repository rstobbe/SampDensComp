%=========================================================
% 
%=========================================================

function [default] = InitialEst_TrajSampDensEstTpi_v1a_Default2(SCRPTPATHS)

m = 1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'Smoothing';
default{m,1}.entrystr = '5';

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'Scale';
default{m,1}.entrystr = '0.2';
