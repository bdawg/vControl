% Guestimate time to run ao188 cal procedure
tint=0.5;

qwprot=8+tint;
%qwp takes 2 minutes for 15 posns 0-180 including return to 0
% so say 8s

nqwps=5;
hwprot=3.;
nhwps=9; %8 + 1 with no polarizer

nimr=1;%4;

time = qwprot*nqwps^2 * hwprot*nhwps * nimr;

hours=time/60/60