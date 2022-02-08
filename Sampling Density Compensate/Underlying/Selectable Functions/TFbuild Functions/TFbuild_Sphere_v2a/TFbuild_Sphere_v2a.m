%==================================================================
% (v2a)
%   - Convert to Object
%==================================================================

classdef TFbuild_Sphere_v2a < handle

properties (SetAccess = private)                   
    Method = 'TFbuild_Sphere_v2a'
    RadDim
    SubSamp
    Loc
    Val
    LocMax
    rLocMax
    Panel = cell(0)
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function [TFB,err] = TFbuild_Sphere_v2a(TFBipt)     
    err.flag = 0;
end

%==================================================================
% Constructor
%==================================================================  
function err = BuildTransFunc(TFB,SDCMETH,IMP)   
    err.flag = 0;
    Status2('done','Build TF',2);
    Status2('done','',3);

    TFO = SDCMETH.TFO;
    KRN = SDCMETH.OPT.KRN;
    KINFO = IMP.KINFO;

    %----------------------------------------
    % Error Tests
    %----------------------------------------
    if KINFO.Elip ~= 1                  
        err.flag = 1;
        err.msg = 'Elip Not Supported with TFbuildSphere';
        return
    end

    %----------------------------------------
    % Filter
    %----------------------------------------
    if (length(TFO.Rad)-1)/TFO.Rad(end) ~= 10000
        error                                       % fix
    end

    %----------------------------------------
    % 'Sphere-Array' Size Test
    %----------------------------------------
    m = 1;
    MaxSubSamp = 15;
    for n = MaxSubSamp:-0.0005:KRN.DesforSS
        test = round(1e9/(n*KRN.res))/1e9;
        if not(rem(test,1)) && not(rem(KRN.W*n,1))
            pSubSamp(m) = n;
            m = m+1;
        end    
    end
    for n = 1:length(pSubSamp)
        RadDim0 = round(KINFO.rad*pSubSamp(n));
        if pSubSamp(n)==2.5 || pSubSamp(n)==4
            if RadDim0 < 250
                break
            end
        elseif pSubSamp(n)==10 || pSubSamp(n)==8 || pSubSamp(n)==6.4 || pSubSamp(n)==6.25 || pSubSamp(n)==5
            if RadDim0 < 200
                break
            end
        elseif pSubSamp(n)==12.5
            if RadDim0 < 150
                break
            end
        elseif pSubSamp(n)==2
            if RadDim0 > 200
                break
            end        
        else
            err.flag = 1;
            err.msg = 'Kern_File not supported';
            return
        end
    end
    TFB.SubSamp = pSubSamp(n);
    TFB.RadDim = KINFO.rad*TFB.SubSamp;

    %----------------------------------------
    % Build 'Sphere-Array'
    %----------------------------------------
    Status2('busy','Build Transfer Function Shape',2);
    top = ceil(TFB.RadDim) + 1;
    bot = ceil(KRN.W*TFB.SubSamp) + 1;
    Loc0 = zeros((2*bot+1)^2*(top+bot+1),3);
    Val0 = zeros((2*bot+1)^2*(top+bot+1),3);
    n = 1;
    m = 1;
    L = 10000;
    for x = -bot:top
        for y = -bot:bot
            for z = -bot:bot
                r = sqrt(x^2 + y^2 + z^2)/TFB.RadDim;
                if r <= 1
                    Loc0(n,:) = [x y z];  
                    Val0(n) = lin_interp4(TFO.TransFuncOut,r,L);
                    n = n+1;             
                end
            end
        end
        Status2('busy',num2str(top+bot-m+1),3);
        m = m+1;    
    end
    TFB.Loc = Loc0(1:n-1,:)*(KINFO.kstep/TFB.SubSamp);
    TFB.Val = Val0(1:n-1);
    TFB.LocMax = max((TFB.Loc(:,1).^2 + TFB.Loc(:,2).^2 + TFB.Loc(:,3).^2).^(0.5));
    TFB.rLocMax = TFB.LocMax/KINFO.kmax;
    Status2('done','',2);
    Status2('done','',3);  
end

%==================================================================
% Clear
%==================================================================  
function Clear(TFB)
   TFB.Loc = [];
   TFB.Val = [];
end

end
end
