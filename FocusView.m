ptime=0.1;
nloops=20;

for outer = 1:nloops

for ii = 1:6
    imagesc(log10(allPSs(:,:,ii)))
    pause(ptime)
end

end

