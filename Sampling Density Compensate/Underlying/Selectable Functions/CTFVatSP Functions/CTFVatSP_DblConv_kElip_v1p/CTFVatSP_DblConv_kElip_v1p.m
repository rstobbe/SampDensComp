%=========================================================
% (v1p)
%       - Gridding function selection (from above - Options)
%=========================================================

function [SCRPTipt,CTFV,err] = CTFVatSP_DblConv_kElip_v1p(SCRPTipt,CTFVipt)

Status2('busy','Convolved Output Transfer Function at Samp',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

CallingPanel = CTFVipt.Struct.labelstr;
%---------------------------------------------
% Load Input
%---------------------------------------------
CTFV.method = CTFVipt.Func;
CTFV.Norm = CTFVipt.('Normalize');
CTFV.TFbuildfunc = CTFVipt.('TFbuildfunc').Func;

%---------------------------------------------
% Get Working Structures from Sub Functions
%---------------------------------------------
TFBipt = CTFVipt.('TFbuildfunc');
if isfield(CTFVipt,([CallingPanel,'_Data']))
    if isfield(CTFVipt.([CallingPanel,'_Data']),('TFbuildfunc_Data'))
        TFBipt.('TFbuildfunc_Data') = CTFVipt.([CallingPanel,'_Data']).('TFbuildfunc_Data');
    end
end

%------------------------------------------
% Get TF Building Info
%------------------------------------------
func = str2func(CTFV.TFbuildfunc);           
[SCRPTipt,TFB,err] = func(SCRPTipt,TFBipt);
if err.flag
    return
end

%------------------------------------------
% Return
%------------------------------------------
CTFV.TFB = TFB;

Status2('done','',2);
Status2('done','',3);