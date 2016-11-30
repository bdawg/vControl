% Actual measured values:
% For 10 HWp psoitions, with aohwp=2 and re-home of hwp being
% aoHWP*(nHWPS/2),
% time = 5008s (1.4hrs), or 6334s (1.8hrs) with no-pol set.



aohwp = 1.5; %A nominal time for small (~20 deg) rotation. Check this more carefully?
% It says in the code that it only takes 3 seconds to do biggets move (0 to 67.5) 
pQWP_225 = 8;
pQWP_18 = 6.5;
pQWP_20 = 7.2;

nQWPs = 10;
maxQWP = 180;
nHWPs = 8;
%aoHwpPosns=[0 22.5 45 67.5 90 112.5 135 157.5]/2;

etime=0;

% Do old way (hwps in outer loop)
for h = 1:nHWPs
    if (h ~= 1) 
        etime = etime + aohwp;
    end
    
    for q1 = 1:nQWPs
        if (q1 ~= 1) 
            etime = etime + pQWP_20;
        end
        
        for q2 = 1:nQWPs
            if (q2 ~= 1) 
                etime = etime + pQWP_20;
            end
        end        
        etime = etime + pQWP_20*nQWPs; %Return to zero
        
    end
    etime = etime + pQWP_20*nQWPs; %Return to zero
end
etime = etime + aohwp*nHWPs;

disp('Old method, elapsed time (hours): ')
disp(etime/60/60)




% Do new way (hwps in inner loop)
etime=0;
for q1 = 1:nQWPs
    if (q1 ~= 1) 
        etime = etime + pQWP_20;
    end

    for q2 = 1:nQWPs
        if (q2 ~= 1) 
            etime = etime + pQWP_20;
        end
        
        for h = 1:nHWPs
            if (h ~= 1) 
                etime = etime + aohwp;
            end
        end
        etime = etime + aohwp*nHWPs;
        
    end        
    etime = etime + pQWP_20*nQWPs; %Return to zero

end
etime = etime + pQWP_20*nQWPs; %Return to zero


disp('New method, elapsed time (hours): ')
disp(etime/60/60)
