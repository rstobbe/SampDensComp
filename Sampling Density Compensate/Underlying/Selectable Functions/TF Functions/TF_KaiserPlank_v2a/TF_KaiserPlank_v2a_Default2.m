%=========================================================
% 
%=========================================================

function [default] = TF_KaiserPlank_v2a_Default2(SCRPTPATHS)

m = 1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'Beta';
default{m,1}.entrystr = '4';

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'EndDrop';
default{m,1}.entrystr = '6';