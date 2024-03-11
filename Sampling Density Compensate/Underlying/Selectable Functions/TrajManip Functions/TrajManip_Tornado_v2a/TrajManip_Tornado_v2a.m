%==================================================================
% (v2a)
%   - 
%==================================================================

classdef TrajManip_Tornado_v2a < handle

properties (SetAccess = private)                   
    Method = 'TrajManip_Tornado_v2a'
    FullSampSpin
    FullSampWindow
    TotalWindow
    TrajCen
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [TM,err] = TrajManip_Tornado_v2a(TMipt)     
    err.flag = 0;
    TM.FullSampWindow = str2double(TMipt.('FullSampWindow'));
    TM.TotalWindow = str2double(TMipt.('TotalWindow'));  
    TM.TrajCen = str2double(TMipt.('TrajCen')); 
end


%==================================================================
% DefineTransferFunction
%==================================================================  
function err = ManipulateTrajectory(TM,SDCMETH) 
    err.flag = 0;
    KINFO = SDCMETH.KINFO;
    
    SPIN = SDCMETH.DES.SPIN;
    SPIN.SetMatRad(KINFO(1).rad)
    SPIN.DefineSpin;
    TM.FullSampSpin = SPIN.RelSpinProj(1);
    
    RelRad = 0:0.01:1;
    TrajsAtRelRad = ((TM.FullSampSpin./SPIN.RelSpinProj).^2 - 1);
    TrajsAtRelRad = TrajsAtRelRad/TrajsAtRelRad(end);
    TrajsAtRelRad = TrajsAtRelRad * ((TM.TotalWindow-TM.FullSampWindow)/TM.FullSampWindow);
    TrajsAtRelRad = (TrajsAtRelRad+1)*TM.FullSampWindow;
    
    figure(456);
    plot(TrajsAtRelRad);

    MagKspace = sqrt(KINFO.kSpace(1,:,1).^2 + KINFO.kSpace(1,:,2).^2 + KINFO.kSpace(1,:,3).^2);
    RelKspace = MagKspace/MagKspace(end);

    TrajsAtSamp = round(interp1(RelRad,TrajsAtRelRad,RelKspace)/2)*2;
    
    Traj = [];
    ReadOut = [];
    sz = size(KINFO.kSpace);
    for n = 1:sz(2)
        TrajStart = TM.TrajCen - TrajsAtSamp(n)/2;
        if TrajStart < 1
            TrajStart = 1;
        end
        Traj = [Traj TrajStart:TrajStart+TrajsAtSamp(n)-1];
        ReadOut = [ReadOut n*ones(1,TrajsAtSamp(n))];
    end
    
    idx = sub2ind(sz,Traj,ReadOut);    
    KINFO.SetUseIndex(idx);
    
end



end
end





