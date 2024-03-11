%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef TrajManip_ExtractLowRes_v2a < handle

properties (SetAccess = private)                   
    Method = 'TrajManip_ExtractLowRes_v2a'
    RelRad
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [TM,err] = TrajManip_ExtractLowRes_v2a(TMipt)     
    err.flag = 0;
    TM.RelRad = str2double(TMipt.('RelRad'));     
end


%==================================================================
% DefineTransferFunction
%==================================================================  
function err = ManipulateTrajectory(TM,SDCMETH) 
    err.flag = 0;
    KINFO = SDCMETH.KINFO;
    
    %---------------------------------------------
    % ExtractLowRes
    %---------------------------------------------
    MagKspace = sqrt(KINFO.kSpace(1,:,1).^2 + KINFO.kSpace(1,:,2).^2 + KINFO.kSpace(1,:,3).^2);
    RelKspace = MagKspace/MagKspace(end);
    figure(3456234); hold on; plot(RelKspace); plot([1 length(RelKspace)],[TM.RelRad TM.RelRad]);
    ind = find(RelKspace > TM.RelRad,1,'first');
    
    KINFO.SetSamplingPts(ind);
    KINFO.SetkSpace(KINFO.kSpace(:,1:ind,:,:));
    KINFO.SetSamplingTimeOnTrajectory(KINFO.SamplingTimeOnTrajectory(1:ind));
    KINFO.SetVox(KINFO.vox/TM.RelRad); 
    
    %----------------------------------------------------
    % Panel Items
    %----------------------------------------------------
    TM.Panel(1,:) = {'RelRad',TM.RelRad,'Output'};
end



end
end





