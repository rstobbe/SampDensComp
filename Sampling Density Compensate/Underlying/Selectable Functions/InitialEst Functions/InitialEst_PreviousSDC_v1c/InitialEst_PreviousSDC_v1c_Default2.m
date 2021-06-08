%=========================================================
% 
%=========================================================

function [default] = InitialEst_PreviousSDC_v1c_Default2(SCRPTPATHS)

m = 1;
default{m,1}.entrytype = 'RunExtFunc';
default{m,1}.labelstr = 'SDC_File';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Load';
default{m,1}.runfunc1 = 'LoadSDCCur';
default{m,1}.(default{m,1}.runfunc1).curloc = SCRPTPATHS.outloc;
default{m,1}.runfunc2 = 'LoadSDCDef';
default{m,1}.(default{m,1}.runfunc2).defloc = SCRPTPATHS.outloc;
