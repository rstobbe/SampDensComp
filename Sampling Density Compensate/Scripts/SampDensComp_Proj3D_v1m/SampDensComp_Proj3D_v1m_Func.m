%====================================================
%
%====================================================

function [SDCS,err] = SampDensComp_Proj3D_v1m_Func(INPUT,SDCS)

Status('busy','Compensate Sampling Density');
Status2('done','',2);
Status2('done','',3);

%---------------------------------------------
% Load Input
%---------------------------------------------
IMP = INPUT.IMP;
KRNprms = INPUT.KRNprms;
OPT = INPUT.OPT;
TFO = INPUT.TFO;
CTFV = INPUT.CTFV;
IE = INPUT.IE;
IT = INPUT.IT;
clear INPUT

%---------------------------------------------
% Test
%---------------------------------------------
sz = size(IMP.Kmat);
if sz(1)~= IMP.PROJimp.nproj
    err.flag = 1;
    err.msg = 'Probably a ''testing'' implementation used';
    return
end

%---------------------------------------------
% Get Global Options
%---------------------------------------------
func = str2func([OPT.method,'_Func']);
INPUT.KRNprms = KRNprms;
INPUT.SDCS = SDCS;
INPUT.IMP = IMP;
[OPT,err] = func(OPT,INPUT);
if err.flag
    return
end
BigSave = 'No';
if isfield(OPT,'BigSave')
    BigSave = OPT.BigSave;
end
Scale = 1;
if isfield(OPT,'Scale')
    Scale = OPT.Scale;
end
IMP = OPT.IMP;
SDCS = OPT.SDCS;
clear OPT;
clear INPUT

%---------------------------------------------
% Determine if Multi-Echo
%---------------------------------------------
sz = size(IMP.Kmat);
if length(sz) == 3
    Echos = 1;
else
    Echos = sz(4);
end

Kmat0 = IMP.Kmat;
SDC = zeros([sz(1)*sz(2) Echos]);

%----
sz = size(Kmat0);
IMP.PROJimp.npro = sz(2);               % hack
%----

for n = 1:Echos
    if Echos > 1
        IMP.Kmat = squeeze(Kmat0(:,:,:,n));
    end
    
    %--------------------------------------
    % Load Desired Output Transfer Function
    %--------------------------------------
    func = str2func([SDCS.TFfunc,'_Func']);
    INPUT.IMP = IMP;
    [TFO,err] = func(TFO,INPUT);
    if err.flag
        return
    end
    clear INPUT

    %--------------------------------------
    % Initial Estimate
    %--------------------------------------
    func = str2func([SDCS.InitialEstfunc,'_Func']);
    INPUT.IMP = IMP;
    INPUT.TFO = TFO;
    INPUT.CTFV = CTFV;                     
    [IE,err] = func(IE,INPUT);
    if err.flag
        return
    end
    clear INPUT

    %--------------------------------------
    % Determine Convolved Transfer Function Values at Sampling Points
    %--------------------------------------
    func = str2func([SDCS.CTFVfunc,'_Func']);
    INPUT.IMP = IMP;
    INPUT.TFO = TFO;
    INPUT.KRNprms = KRNprms;
    INPUT.SDCS = SDCS;
    [CTFV,err] = func(CTFV,INPUT);
    if err.flag
        return
    end
    clear INPUT

    %--------------------------------------
    % Sampling Density Compensate
    %--------------------------------------
    func = str2func([SDCS.Iteratefunc,'_Func']);
    INPUT.IMP = IMP;
    INPUT.CTFV = CTFV;
    INPUT.IE = IE;
    INPUT.KRNprms = KRNprms;
    INPUT.SDCS = SDCS;
    INPUT.Scale = Scale;
    [IT,err] = func(IT,INPUT);
    if err.flag
        return
    end
    clear INPUT

    %--------------------------------------
    % Save
    %--------------------------------------
    SDC(:,n) = IT.SDC;    
end

%----------------------------------------------------
% Save ANLZ Figure
%----------------------------------------------------
if isfield(IT.ANLZ,'Figure')
    SDCS.Figure = IT.ANLZ.Figure;
    IT.ANLZ = rmfield(IT.ANLZ,'Figure');
end

%----------------------------------------------------
% Panel Items
%----------------------------------------------------
Panel(1,:) = {'','','Output'};
Panel(2,:) = {'Imp_File',SDCS.ImpFile,'Output'};
Panel(3,:) = {'Kern_File',SDCS.KernFile,'Output'};
Panel(4,:) = {'SubSamp',SDCS.SubSamp,'Output'};
PanelOutput = cell2struct(Panel,{'label','value','type'},2);
SDCS.PanelOutput = PanelOutput;

%--------------------------------------------
% Output
%--------------------------------------------
SDCS.SDC = SDC;    
if strcmp(BigSave,'Yes')
    SDCS.W = IT.W;
end
%SDCS.DOV = CTFV.DOV;    
IT = rmfield(IT,{'SDC','W'});
CTFV = rmfield(CTFV,'DOV');
IE = rmfield(IE,'iSDC');
SDCS.IT = IT;
SDCS.CTFV = CTFV;
SDCS.TFO = TFO;
SDCS.IE = IE;




