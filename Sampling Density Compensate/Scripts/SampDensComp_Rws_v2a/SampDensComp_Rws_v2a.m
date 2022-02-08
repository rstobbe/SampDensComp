%=========================================================
% (v2a)
%   - Facilitate objects
%=========================================================

function [SCRPTipt,SCRPTGBL,err] = SampDensComp_Rws_v2a(SCRPTipt,SCRPTGBL)

Status('busy','Sampling Density Compensation');
Status2('done','',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

global COMPASSINFO
drv = COMPASSINFO.USERGBL.softwaredrive;

%---------------------------------------------
% Clear Naming
%---------------------------------------------
inds = strcmp('Sdc_Name',{SCRPTipt.labelstr});
indnum = find(inds==1);
if length(indnum) > 1
    indnum = indnum(SCRPTGBL.RWSUI.scrptnum);
end
SCRPTipt(indnum).entrystr = '';
setfunc = 1;
DispScriptParam(SCRPTipt,setfunc,SCRPTGBL.RWSUI.tab,SCRPTGBL.RWSUI.panelnum);

%---------------------------------------------
% Tests
%---------------------------------------------
if not(isfield(SCRPTGBL,'Imp_File_Data'))
    if isfield(SCRPTGBL.CurrentTree.('Imp_File').Struct,'selectedfile')
    file = SCRPTGBL.CurrentTree.('Imp_File').Struct.selectedfile;
        if not(exist(file,'file'))
            file = [drv file(4:end)];
            if not(exist(file,'file'))
                err.flag = 1;
                err.msg = '(Re) Load Imp_File - path no longer valid';
                ErrDisp(err);
                return
            end
        end
        Status('busy','Load Trajectory Implementation');
        load(file);
        saveData.path = file;
        SCRPTGBL.('Imp_File_Data') = saveData;
    else
        err.flag = 1;
        err.msg = '(Re) Load Imp_File';
        ErrDisp(err);
        return
    end
end

%---------------------------------------------
% Load Input
%---------------------------------------------
SDC.method = SCRPTGBL.CurrentTree.Func;
SDC.sdcmethfunc = SCRPTGBL.CurrentTree.('SdcMethfunc').Func;

%---------------------------------------------
% Get Trajectory Implementation
%---------------------------------------------
IMP = SCRPTGBL.Imp_File_Data.IMP;

%---------------------------------------------
% Get Working Structures from Sub Functions
%---------------------------------------------
SDCMETHipt = SCRPTGBL.CurrentTree.('SdcMethfunc');  
if isfield(SCRPTGBL,('SdcMethfunc_Data'))
    SDCMETHipt.SdcMethfunc_Data = SCRPTGBL.SdcMethfunc_Data;
end

%---------------------------------------------
% Compensate
%---------------------------------------------
func = str2func(SDC.sdcmethfunc);           
[SDCMETH,err] = func(SDCMETHipt);
if err.flag
    return
end
err = SDCMETH.Compensate(IMP);
if err.flag
    return
end
SDC = SDCMETH;

%--------------------------------------------
% Output to TextBox
%--------------------------------------------
global FIGOBJS
FIGOBJS.(SCRPTGBL.RWSUI.tab).Info.String = SDC.ExpDisp;
    
%--------------------------------------------
% Return
%--------------------------------------------
name = inputdlg('Name SampDensComp:','Name',[1 60],{SDC.name});
if isempty(name)
    SCRPTGBL.RWSUI.SaveGlobal = 'no';
    return
end
SDC.name = name{1};

SCRPTipt(indnum).entrystr = SDC.name;
SCRPTGBL.RWSUI.SaveVariables = SDC;
SCRPTGBL.RWSUI.SaveVariableNames = 'SDC';
SCRPTGBL.RWSUI.SaveGlobal = 'yes';
SCRPTGBL.RWSUI.SaveGlobalNames = SDC.name;
SCRPTGBL.RWSUI.SaveScriptOption = 'yes';
SCRPTGBL.RWSUI.SaveScriptPath = 'outloc';
SCRPTGBL.RWSUI.SaveScriptName = SDC.name;

Status('done','');
Status2('done','',2);
Status2('done','',3);

