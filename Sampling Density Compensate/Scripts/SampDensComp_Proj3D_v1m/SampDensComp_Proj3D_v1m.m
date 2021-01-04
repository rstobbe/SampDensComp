%===========================================================================================
% (v1m)
%     - Scale value out of 'Options' function
%===========================================================================================

function [SCRPTipt,SCRPTGBL,err] = SampDensComp_Proj3D_v1m(SCRPTipt,SCRPTGBL)

Status('busy','Compensate Sampling Density');
Status2('done','',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Clear Naming
%---------------------------------------------
inds = strcmp('SDC_Name',{SCRPTipt.labelstr});
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
            err.flag = 1;
            err.msg = '(Re) Load Imp_File - path no longer valid';
            ErrDisp(err);
            return
        else
            Status('busy','Load Trajectory Implementation');
            load(file);
            saveData.path = file;
            SCRPTGBL.('Imp_File_Data') = saveData;
        end
    else
        err.flag = 1;
        err.msg = '(Re) Load Imp_File';
        ErrDisp(err);
        return
    end
end
if not(isfield(SCRPTGBL,'Kern_File_Data'))
    if isfield(SCRPTGBL.CurrentTree.('Kern_File').Struct,'selectedfile')
    file = SCRPTGBL.CurrentTree.('Kern_File').Struct.selectedfile;
        if not(exist(file,'file'))
            err.flag = 1;
            err.msg = '(Re) Load Kern_File';
            ErrDisp(err);
            return
        else
            Status('busy','Load Convolution Kernel');
            load(file);
            saveData.path = file;
            SCRPTGBL.('Kern_File_Data') = saveData;
        end
    else
        err.flag = 1;
        err.msg = '(Re) Load Kern_File';
        ErrDisp(err);
        return
    end
end

%---------------------------------------------
% Load Input
%---------------------------------------------
SDCS.method = SCRPTGBL.CurrentTree.Func;
SDCS.ImpFile = SCRPTGBL.CurrentTree.('Imp_File').EntryStr;
SDCS.KernFile = SCRPTGBL.CurrentTree.('Kern_File').EntryStr;
SDCS.Optfunc = SCRPTGBL.CurrentTree.('Optionsfunc').Func;
SDCS.TFfunc = SCRPTGBL.CurrentTree.('TFfunc').Func;
SDCS.CTFVfunc = SCRPTGBL.CurrentTree.('CTFVatSPfunc').Func;
SDCS.InitialEstfunc = SCRPTGBL.CurrentTree.('InitialEstfunc').Func;
SDCS.Iteratefunc = SCRPTGBL.CurrentTree.('Iteratefunc').Func;

%---------------------------------------------
% Load Implementation and Kernel
%---------------------------------------------
IMP = SCRPTGBL.Imp_File_Data.IMP;
KRNprms = SCRPTGBL.Kern_File_Data.KRNprms;

%---------------------------------------------
% Get Working Structures from Sub Functions
%---------------------------------------------
OPTipt = SCRPTGBL.CurrentTree.('Optionsfunc');
if isfield(SCRPTGBL,('Optionsfunc_Data'))
    OPTipt.Optionsfunc_Data = SCRPTGBL.Optionsfunc_Data;
end
TFOipt = SCRPTGBL.CurrentTree.('TFfunc');
if isfield(SCRPTGBL,('TFfunc_Data'))
    TFOipt.TFfunc_Data = SCRPTGBL.TFfunc_Data;
end
CTFVipt = SCRPTGBL.CurrentTree.('CTFVatSPfunc');
if isfield(SCRPTGBL,('CTFVatSPfunc_Data'))
    CTFVipt.CTFVatSPfunc_Data = SCRPTGBL.CTFVatSPfunc_Data;
end
IEipt = SCRPTGBL.CurrentTree.('InitialEstfunc');
if isfield(SCRPTGBL,('InitialEstfunc_Data'))
    IEipt.InitialEstfunc_Data = SCRPTGBL.InitialEstfunc_Data;
end
ITipt = SCRPTGBL.CurrentTree.('Iteratefunc');
if isfield(SCRPTGBL,('Iteratefunc_Data'))
    ITipt.Iteratefunc_Data = SCRPTGBL.Iteratefunc_Data;
end

%------------------------------------------
% Get  Function Info
%------------------------------------------
func = str2func(SDCS.Optfunc);           
[SCRPTipt,OPT,err] = func(SCRPTipt,OPTipt);
if err.flag
    return
end
func = str2func(SDCS.TFfunc);           
[SCRPTipt,TFO,err] = func(SCRPTipt,TFOipt);
if err.flag
    return
end
func = str2func(SDCS.CTFVfunc);           
[SCRPTipt,CTFV,err] = func(SCRPTipt,CTFVipt);
if err.flag
    return
end
func = str2func(SDCS.InitialEstfunc);           
[SCRPTipt,IE,err] = func(SCRPTipt,IEipt);
if err.flag
    return
end
func = str2func(SDCS.Iteratefunc);           
[SCRPTipt,IT,err] = func(SCRPTipt,ITipt);
if err.flag
    return
end

%------------------------------------------
% Run SDC
%------------------------------------------
func = str2func([SDCS.method,'_Func']);
INPUT.OPT = OPT;
INPUT.IMP = IMP;
INPUT.KRNprms = KRNprms;
INPUT.TFO = TFO;
INPUT.CTFV = CTFV;
INPUT.IE = IE;
INPUT.IT = IT;
[SDCS,err] = func(INPUT,SDCS);
if err.flag
    return
end

%--------------------------------------------
% Output to TextBox
%--------------------------------------------
Text = PanelStruct2Text(SDCS.PanelOutput);
Text = [Text char(10) PanelStruct2Text(SDCS.TFO.PanelOutput)];
SDCS.ExpDisp = [Text char(10) PanelStruct2Text(SDCS.IT.PanelOutput)];
global FIGOBJS
FIGOBJS.(SCRPTGBL.RWSUI.tab).Info.String = SDCS.ExpDisp;

%--------------------------------------------
% Name
%--------------------------------------------
if isfield(IMP,'name')
    name = ['SDC_',IMP.name(5:end)];
else
    name = 'SDC_';
end

%--------------------------------------------
% Return
%--------------------------------------------
name = inputdlg('Name SDC:','Name',1,{name});
if isempty(name)
    SCRPTGBL.RWSUI.SaveVariables = {SDCS};
    SCRPTGBL.RWSUI.SaveGlobal = 'no';
    return
end
SDCS.name = name{1};

SCRPTipt(indnum).entrystr = SDCS.name;
SCRPTGBL.RWSUI.SaveVariables = SDCS;
SCRPTGBL.RWSUI.SaveVariableNames = 'SDCS';
SCRPTGBL.RWSUI.SaveGlobal = 'yes';
SCRPTGBL.RWSUI.SaveGlobalNames = SDCS.name;
SCRPTGBL.RWSUI.SaveScriptOption = 'yes';
SCRPTGBL.RWSUI.SaveScriptPath = 'outloc';
SCRPTGBL.RWSUI.SaveScriptName = SDCS.name;

Status('done','');
Status2('done','',2);
Status2('done','',3);

