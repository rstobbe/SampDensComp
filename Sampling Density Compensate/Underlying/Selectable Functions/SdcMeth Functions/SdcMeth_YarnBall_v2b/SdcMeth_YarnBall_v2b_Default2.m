%=========================================================
% 
%=========================================================

function [default] = SdcMeth_YarnBall_v2b_Default2(SCRPTPATHS)

if strcmp(filesep,'\')
    OPTPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\Options Functions\'];
    TMPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\TrajManip Functions\'];
    IEPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\InitialEst Functions\'];
    TFPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\TF Functions\'];
    CTFPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\CTFVatSP Functions\'];
    ITPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\Selectable Functions\Iterate Functions\'];
elseif strcmp(filesep,'/')
end
OPTfunc = 'Options_Advanced_v2a';
TMfunc = 'TrajManip_ExtractLowRes_v2a';
TFfunc = 'TF_KaiserPlank_v2a';
CTFfunc = 'CTFVatSP_DblConv_kSphere_v2a';
IEfunc = 'InitialEst_TrajSampDensEstScale_v2a';
ITfunc = 'Iterate_DblConv_v2a';


m = 1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'AcqNum';
default{m,1}.entrystr = '1';

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'Optionsfunc';
default{m,1}.entrystr = OPTfunc;
default{m,1}.searchpath = OPTPath;
default{m,1}.path = [OPTPath,OPTfunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'TrajManipfunc';
default{m,1}.entrystr = TMfunc;
default{m,1}.searchpath = TMPath;
default{m,1}.path = [TMPath,TMfunc];

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