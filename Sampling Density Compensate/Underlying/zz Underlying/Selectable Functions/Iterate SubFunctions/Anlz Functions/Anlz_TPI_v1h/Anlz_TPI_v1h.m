%==================================================
% (v1h)
%     - Add Figure Selection
%     - Change to relative error calculation (now with respect to value at
%     centre)
%==================================================

function [SCRPTipt,ANLZ,err] = Anlz_TPI_v1h(SCRPTipt,ANLZipt)

Status2('busy','Get Anlyze Function Info',2);
Status2('done','',3);

err.flag = 0;
err.mgs = '';

%---------------------------------------------
% Return Input
%---------------------------------------------
ANLZ.method = ANLZipt.Func;
ANLZ.visuals = ANLZipt.('Visuals');
ANLZ.xaxis = ANLZipt.('xAxis');