%=========================================================
% 
%=========================================================

function [CTFV,err] = CTFVatSP_DblConv_kElip_v1o_Func(CTFV,INPUT)

global COMPASSINFO

Status2('busy','Convolved Output Transfer Function at Samp',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
IMP = INPUT.IMP;
if isfield(IMP,'impPROJdgn')
    PROJdgn = IMP.impPROJdgn;
else
    PROJdgn = IMP.PROJdgn;
end
PROJimp = IMP.PROJimp;
Kmat = IMP.Kmat;
TFO = INPUT.TFO;
KRNprms = INPUT.KRNprms;
FwdKern = KRNprms.FwdKern;
RvsKern = FwdKern;
SDCS = INPUT.SDCS;
clear INPUT;

%---------------------------------------------
% Common Variables
%---------------------------------------------
kstep = PROJdgn.kstep;
CTFvis = 'On';

%---------------------------------------------
% Functions
%---------------------------------------------
S2Gconvfunc = str2func(SDCS.S2GConvfunc);
G2Sconvfunc = str2func(SDCS.G2SConvfunc);

%---------------------------------------------
% Centre Value Normalize
%---------------------------------------------
if strcmp(CTFV.Norm,'SampChars')
    TFO.tf = TFO.tf*PROJimp.projosamp*PROJimp.trajosamp/PROJdgn.elip;
elseif strcmp(CTFV.Norm,'OneAtCen')
    TFO.tf = TFO.tf/TFO.tf(1);
end

%---------------------------------------------
% Build Desired TF
%---------------------------------------------
Status2('busy','Build Desired TF',2);
func = str2func([CTFV.TFbuildfunc,'_Func']);  
TFB = CTFV.TFB;
INPUT.IMP = IMP;
INPUT.TFO = TFO;
INPUT.KRNprms = KRNprms;
[TFB,err] = func(TFB,INPUT);
if err.flag
    return
end
clear INPUT

%--------------------------------------
% Test
%--------------------------------------
% button = questdlg(['TF array is ',num2str(length(TFB.Loc)),' points long. SubSamp is ',num2str(TFB.SubSamp),'. RadDim is ',num2str(TFB.RadDim),'. Continue?']); 
% if strcmp(button,'No') || strcmp(button,'Cancel')
%     err.flag = 4;
%     err.msg = '';
%     return
% end

%----------------------------------------
% FwdKern Convolve Setup
%----------------------------------------
zWtest = 2*(ceil((FwdKern.W*TFB.SubSamp-2)/2)+1)/TFB.SubSamp;                       
if zWtest > FwdKern.zW
    error('Kernel Zero-Fill Too Small');
end
FwdKern.W = FwdKern.W*TFB.SubSamp;
FwdKern.res = FwdKern.res*TFB.SubSamp;
if round(1e9/FwdKern.res) ~= 1e9*round(1/FwdKern.res)
    error('should not get here - already tested');
end    
FwdKern.iKern = round(1/FwdKern.res);
CONVprms.chW = ceil((FwdKern.W-2)/2);                    

%----------------------------------------
% Normalize Desired TF to Grid
%----------------------------------------
[~,~,~,~,centre1] = NormProjGrid_v4c(TFB.Loc,NaN,NaN,kstep,CONVprms.chW,TFB.SubSamp,'A2A');
[~,~,~,~,centre2] = NormProjGrid_v4c(Kmat,PROJimp.nproj,PROJimp.npro,kstep,CONVprms.chW,TFB.SubSamp,'M2A');
Fcentre = max([centre1 centre2]);
[Ksz,Kx,Ky,Kz,centre] = NormProjGridExt_v4c(TFB.Loc,NaN,NaN,kstep,CONVprms.chW,TFB.SubSamp,Fcentre,'A2A');

%----------------------------------------
% FwdKern Convolve 
%----------------------------------------
Status2('busy','Convolve TF to Grid',2);
StatLev = 3;
%tic
[ConvTF,err] = S2Gconvfunc(Ksz,Kx,Ky,Kz,FwdKern,TFB.Val,CONVprms,StatLev,COMPASSINFO.CUDA);
%toc
%DataSumTest = sum(ConvTF(:))/1e6
if err.flag
    return
end
ConvTF = ConvTF/(FwdKern.convscaleval*TFB.SubSamp^3);

if (strcmp(CTFvis,'On'))         
    figure(400); 
    subplot(2,2,4); hold on;
    rconv = (0:(centre-1))/TFB.RadDim; 
    ConvTFprof = ConvTF(centre:Ksz,centre,centre);
    plot(rconv,ConvTFprof,'r-');
    box on;
    title('Convolved Output');
end

%----------------------------------------
% Reverse Convolve Setup
%----------------------------------------
zWtest = 2*(ceil((RvsKern.W*TFB.SubSamp-2)/2)+1)/TFB.SubSamp;                       % with mFCMexSingleR_v3
if zWtest > RvsKern.zW
    error('Kernel Zero-Fill Too Small');
end
RvsKern.W = RvsKern.W*TFB.SubSamp;
RvsKern.res = RvsKern.res*TFB.SubSamp;
if round(1e9/RvsKern.res) ~= 1e9*round(1/RvsKern.res)
    error('should not get here - already tested');
end    
RvsKern.iKern = round(1/RvsKern.res);
CONVprms.chW = ceil((RvsKern.W-2)/2);                    % with mFCMexSingleR_v3

%----------------------------------------
% Normalize Sampling Locations to Grid
%----------------------------------------
[Ksz,Kx,Ky,Kz,centre] = NormProjGridExt_v4c(Kmat,PROJimp.nproj,PROJimp.npro,kstep,CONVprms.chW,TFB.SubSamp,Fcentre,'M2A');

%----------------------------------------
% Test
%----------------------------------------
if centre~=Fcentre
    error('coding problem');
end

%----------------------------------------
% Reverse Convolve 
%----------------------------------------
Status2('busy','Convolve Grid to Sampling Points',2);
StatLev = 3;
Kx = [centre;Kx];
Ky = [centre;Ky];
Kz = [centre;Kz];
[DOV,err] = G2Sconvfunc(Ksz,Kx,Ky,Kz,RvsKern,ConvTF,CONVprms,StatLev,COMPASSINFO.CUDA);
if err.flag == 1
    return
end

DOV = DOV/(RvsKern.convscaleval*TFB.SubSamp^3);
%-----
%normDOV = DOV(1);                  % don't do
%DOV = DOV/normDOV;
%-----
% if (strcmp(CTFvis,'On'))         
%     DOVmat = SDCArr2Mat(DOV(2:end),PROJimp.nproj,PROJimp.npro);
%     figure(401); hold on;
%     rad = sqrt(Kmat(1,:,1).^2 + Kmat(1,:,2).^2 + Kmat(1,:,3).^2);
%     plot(rad,DOVmat(1,:),'k');              
% end
DOV = DOV(2:length(DOV));

%----------------------------------------
% Return
%----------------------------------------
CTFV.DOV = DOV;
TFB = rmfield(TFB,{'Loc','Val'});
CTFV.TFB = TFB;

%----------------------------------------------------
% Panel Output
%----------------------------------------------------
Panel(1,:) = {'TF_RadDim',TFB.RadDim,'Output'};
Panel(2,:) = {'TF_SubSamp',TFB.SubSamp,'Output'};
Panel(3,:) = {'TF_rLocMax',TFB.rLocMax,'Output'};
PanelOutput = cell2struct(Panel,{'label','value','type'},2);
CTFV.PanelOutput = PanelOutput;

Status2('done','',2);
Status2('done','',3);

