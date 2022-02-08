%====================================================
%
%====================================================

function [default] = SampDensComp_Rws_v2a_Default2(SCRPTPATHS)

if strcmp(filesep,'\')
    SdcMethpath = [SCRPTPATHS.pioneerloc,'Trajectory Implementation\Underlying\Selectable Functions\Scanner Related\SdcMeth Functions\'];
elseif strcmp(filesep,'/')
end
SdcMethfunc = 'SdcMeth_YarnBall_v2a';

m = 1;
default{m,1}.entrytype = 'OutputName';
default{m,1}.labelstr = 'Sdc_Name';
default{m,1}.entrystr = '';

m = m+1;
default{m,1}.entrytype = 'ScriptName';
default{m,1}.labelstr = 'Script_Name';
default{m,1}.entrystr = '';

m = m+1;
default{m,1}.entrytype = 'RunExtFunc';
default{m,1}.labelstr = 'Imp_File';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Load';
default{m,1}.runfunc1 = 'LoadTrajImpCur';
default{m,1}.(default{m,1}.runfunc1).curloc = SCRPTPATHS.outloc;
default{m,1}.runfunc2 = 'LoadTrajImpDef';
default{m,1}.(default{m,1}.runfunc2).defloc = SCRPTPATHS.outloc;

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'SdcMethfunc';
default{m,1}.entrystr = SdcMethfunc;
default{m,1}.searchpath = SdcMethpath;
default{m,1}.path = [SdcMethpath,SdcMethfunc];

m = m+1;
default{m,1}.entrytype = 'RunScrptFunc';
default{m,1}.scrpttype = 'SDC';
default{m,1}.labelstr = 'SampDensComp';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Run';
