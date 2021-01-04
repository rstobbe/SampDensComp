%====================================================
% (v1c)
%       - update for function splitting
%====================================================

function [SCRPTipt,IE,err] = InitialEst_PreviousSDC_v1c(SCRPTipt,IEipt)

Status2('busy','Return Previous SDC',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

CallingLabel = IEipt.Struct.labelstr;
%---------------------------------------------
% Tests
%---------------------------------------------
if not(isfield(IEipt,[CallingLabel,'_Data']))
    if isfield(IEipt.('SDC_File').Struct,'selectedfile')
        file = IEipt.('SDC_File').Struct.selectedfile;
        if not(exist(file,'file'))
            err.flag = 1;
            err.msg = '(Re) Load SDC_File';
            ErrDisp(err);
            return
        else
            IEipt.([CallingLabel,'_Data']).('SDC_File_Data').path = file;
        end
    else
        err.flag = 1;
        err.msg = '(Re) Load SDC_File';
        ErrDisp(err);
        return
    end
end

%---------------------------------------------
% Return
%---------------------------------------------
IE.SDC_File = IEipt.([CallingLabel,'_Data']).('SDC_File_Data').path;
IE.iSDCS = IEipt.([CallingLabel,'_Data']).('SDC_File_Data').SDCS;

Status2('done','',2);
Status2('done','',3);


