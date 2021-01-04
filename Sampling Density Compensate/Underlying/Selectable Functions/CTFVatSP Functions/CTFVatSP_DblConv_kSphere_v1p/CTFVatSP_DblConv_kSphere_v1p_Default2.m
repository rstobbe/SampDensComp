%=========================================================
% 
%=========================================================

function [default] = CTFVatSP_DblConv_kSphere_v1p_Default2(SCRPTPATHS)

if strcmp(filesep,'\')
    TFbuildPath = [SCRPTPATHS.pioneerloc,'Sampling Density Compensate\Underlying\zz Underlying\Selectable Functions\CTFVatSP SubFunctions\TFbuild Functions\'];
elseif strcmp(filesep,'/')
end
TFbuildfunc = 'TFbuildSphere_v1i';

m = 1;
default{m,1}.entrytype = 'Choose';
default{m,1}.labelstr = 'Normalize';
default{m,1}.entrystr = 'OneAtCen';
default{m,1}.options = {'SampChars','OneAtCen'};

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'TFbuildfunc';
default{m,1}.entrystr = TFbuildfunc;
default{m,1}.searchpath = TFbuildPath;
default{m,1}.path = [TFbuildPath,TFbuildfunc];