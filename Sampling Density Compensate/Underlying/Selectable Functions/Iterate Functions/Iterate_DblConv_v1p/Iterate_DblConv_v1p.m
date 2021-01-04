%=========================================================
% (v1p)
%       - Gridding function selection (from above - Options)
%=========================================================

function [SCRPTipt,IT,err] = Iterate_DblConv_v1p(SCRPTipt,ITipt)

Status2('busy','Get SDC Iteration Info',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

CallingPanel = ITipt.Struct.labelstr;
%---------------------------------------------
% Load Input
%---------------------------------------------
IT.method = ITipt.Func; 
IT.Calcfunc = ITipt.('Calcfunc').Func;
IT.Anlzfunc = ITipt.('Anlzfunc').Func;
IT.Breakfunc = ITipt.('Breakfunc').Func;

%---------------------------------------------
% Get Working Structures from Sub Functions
%---------------------------------------------
CALCipt = ITipt.('Calcfunc');
if isfield(ITipt,([CallingPanel,'_Data']))
    if isfield(ITipt.([CallingPanel,'_Data']),('Calcfunc_Data'))
        CALCipt.('Calcfunc_Data') = ITipt.([CallingPanel,'_Data']).('Calcfunc_Data');
    end
end
ANLZipt = ITipt.('Anlzfunc');
if isfield(ITipt,([CallingPanel,'_Data']))
    if isfield(ITipt.([CallingPanel,'_Data']),('Anlzfunc_Data'))
        ANLZipt.('Anlzfunc_Data') = ITipt.([CallingPanel,'_Data']).('Anlzfunc_Data');
    end
end
BRKipt = ITipt.('Breakfunc');
if isfield(ITipt,([CallingPanel,'_Data']))
    if isfield(ITipt.([CallingPanel,'_Data']),('Breakfunc_Data'))
        BRKipt.('Breakfunc_Data') = ITipt.([CallingPanel,'_Data']).('Breakfunc_Data');
    end
end

%------------------------------------------
% Get Calculation Info
%------------------------------------------
func = str2func(IT.Calcfunc);           
[SCRPTipt,CALC,err] = func(SCRPTipt,CALCipt);
if err.flag
    return
end

%------------------------------------------
% Get Analyze Info
%------------------------------------------
func = str2func(IT.Anlzfunc);           
[SCRPTipt,ANLZ,err] = func(SCRPTipt,ANLZipt);
if err.flag
    return
end

%------------------------------------------
% Get Break Info
%------------------------------------------
func = str2func(IT.Breakfunc);           
[SCRPTipt,BRK,err] = func(SCRPTipt,BRKipt);
if err.flag
    return
end

%------------------------------------------
% Return
%------------------------------------------
IT.CALC = CALC;
IT.ANLZ = ANLZ;
IT.BRK = BRK;

Status2('done','',2);
Status2('done','',3);
