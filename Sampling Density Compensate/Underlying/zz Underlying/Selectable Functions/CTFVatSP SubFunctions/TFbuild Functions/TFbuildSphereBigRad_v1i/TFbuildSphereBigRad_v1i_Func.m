%================================================================================
% 
%================================================================================

function [TFB,err] = TFbuildSphereBigRad_v1i_Func(TFB,INPUT)

Status2('done','Build TF',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
IMP = INPUT.IMP;
TFO = INPUT.TFO;
KRNprms = INPUT.KRNprms;
if isfield(IMP,'impPROJdgn')
    PROJdgn = IMP.impPROJdgn;
else
    PROJdgn = IMP.PROJdgn;
end
clear INPUT

%----------------------------------------
% Error Tests
%----------------------------------------
if isfield(PROJdgn,'elip')
    if PROJdgn.elip ~= 1                  
        err.flag = 1;
        err.msg = 'Elip Not Supported with TFbuildSphere';
        return
    end
end

%----------------------------------------
% Filter
%----------------------------------------
if (length(TFO.r)-1)/TFO.r(end) ~= 10000
    error                                       % trajectory design should be updated
end

%----------------------------------------
% 'Sphere-Array' Size Test
%----------------------------------------
m = 1;
MaxSubSamp = 15;
for n = MaxSubSamp:-0.0005:KRNprms.DesforSS
    test = round(1e9/(n*KRNprms.res))/1e9;
    if not(rem(test,1)) && not(rem(KRNprms.W*n,1))
        pSubSamp(m) = n;
        m = m+1;
    end    
end
for n = 1:length(pSubSamp)
    RadDim = round(PROJdgn.rad*pSubSamp(n));
    if pSubSamp(n)==2.5 || pSubSamp(n)==4
        if RadDim < 400
            break
        end
    elseif pSubSamp(n)==10 || pSubSamp(n)==8 || pSubSamp(n)==6.4 || pSubSamp(n)==5
        if RadDim < 350
            break
        end
    elseif pSubSamp(n)==12.5
        if RadDim < 300
            break
        end
    elseif pSubSamp(n)==2
        if RadDim > 350
            break
        end        
    else
        err.flag = 1;
        err.msg = 'Kern_File not supported';
        return
    end
end
TFB.RadDim = RadDim;
TFB.SubSamp = pSubSamp(n);
TFB.RadDim = PROJdgn.rad*TFB.SubSamp;

%----------------------------------------
% Build 'Sphere-Array'
%----------------------------------------
Status2('busy','Build Transfer Function Shape',2);
top = ceil(TFB.RadDim) + 1;
bot = ceil(KRNprms.W*TFB.SubSamp) + 1;
Loc = zeros((2*bot+1)^2*(top+bot+1),3);
Val = zeros((2*bot+1)^2*(top+bot+1),3);
n = 1;
m = 1;
L = 10000;
for x = -bot:top
    for y = -bot:bot
        for z = -bot:bot
            r = sqrt(x^2 + y^2 + z^2)/TFB.RadDim;
            if r <= 1
                Loc(n,:) = [x y z];  
                Val(n) = lin_interp4(TFO.tf,r,L);
                n = n+1;             
            end
        end
    end
    Status2('busy',num2str(top+bot-m+1),3);
    m = m+1;    
end
Status2('done','',3);
TFB.Loc = Loc(1:n-1,:)*(PROJdgn.kstep/TFB.SubSamp);
TFB.Val = Val(1:n-1);
TFB.LocMax = max((TFB.Loc(:,1).^2 + TFB.Loc(:,2).^2 + TFB.Loc(:,3).^2).^(0.5));
TFB.rLocMax = TFB.LocMax/PROJdgn.kmax;

Status2('done','',2);
Status2('done','',3);


