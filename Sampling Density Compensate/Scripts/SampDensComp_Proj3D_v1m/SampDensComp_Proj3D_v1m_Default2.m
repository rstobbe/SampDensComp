%=========================================================
% 
%=========================================================

function [default] = SampDensComp_Proj3D_v1m_Default2(SCRPTPATHS)

if strcmp(filesep,'\')
    OPTPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\Options Functions\'];
    IEPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\InitialEst Functions\'];
    TFPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\TF Functions\'];
    CTFPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\CTFVatSP Functions\'];
    ITPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\Iterate Functions\'];
elseif strcmp(filesep,'/')
end
OPTfunc = 'Options_Standard_v1c';
TFfunc = 'TF_KaiserPlank_v1c';
CTFfunc = 'CTFVatSP_DblConv_kSphere_v1p';
IEfunc = 'InitialEst_TrajSampDensEst_v1h';
ITfunc = 'Iterate_DblConv_v1p';

m = 1;
default{m,1}.entrytype = 'OutputName';
default{m,1}.labelstr = 'SDC_Name';
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
default{m,1}.entrytype = 'RunExtFunc';
default{m,1}.labelstr = 'Kern_File';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Load';
default{m,1}.runfunc1 = 'LoadConvKernCur';
default{m,1}.(default{m,1}.runfunc1).curloc = SCRPTPATHS.imkernloc;
default{m,1}.runfunc2 = 'LoadConvKernDef';
default{m,1}.(default{m,1}.runfunc2).defloc = SCRPTPATHS.imkernloc;

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'Optionsfunc';
default{m,1}.entrystr = OPTfunc;
default{m,1}.searchpath = OPTPath;
default{m,1}.path = [OPTPath,OPTfunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'TFfunc';
default{m,1}.entrystr = TFfunc;
default{m,1}.searchpath = TFPath;
default{m,1}.path = [TFPath,TFfunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'CTFVatSPfunc';
default{m,1}.entrystr = CTFfunc;
default{m,1}.searchpath = CTFPath;
default{m,1}.path = [CTFPath,CTFfunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'InitialEstfunc';
default{m,1}.entrystr = IEfunc;
default{m,1}.searchpath = IEPath;
default{m,1}.path = [IEPath,IEfunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'Iteratefunc';
default{m,1}.entrystr = ITfunc;
default{m,1}.searchpath = ITPath;
default{m,1}.path = [ITPath,ITfunc];

m = m+1;
default{m,1}.entrytype = 'RunScrptFunc';
default{m,1}.scrpttype = 'SDC';
default{m,1}.labelstr = 'CreateSDC';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Run';

