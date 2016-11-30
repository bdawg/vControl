% Dumb way to wait until some time before continuing
targetHour = 01;
targetMinute = 24;

timeReached = false;

while timeReached == false
    c=clock;
    if (c(4) >= targetHour) && (c(5) >= targetMinute)
        timeReached = true;
        disp('Target time reached')
    else
        hr2go = targetHour - c(4);
        min2go = targetMinute - c(5);
        disp([num2str(hr2go) ' hours and ' num2str(min2go) ' minutes to go.'])
        pause(10)
    end
end
