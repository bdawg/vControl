q1=5;
q2=5;
% Choose offset:
pOffs=90; %0, 45, 90, 135

current=transpose(squeeze(allFluxes(1,q1,q2,:)));
current=current/max(current);
figure(1)
clf
hold on
plot(polaPosns,current)
plot(polaPosns,current,'*')
% Make predicted value
fluxscale=1;
predFlux=sind(polaPosns+pOffs).^2*fluxscale;
%predFlux=cosd(polaPosns).^2*fluxscale;
plot(polaPosns,predFlux,'r')
hold off
chisq1=sum((current-predFlux).^2);

current=transpose(squeeze(allFluxes(2,q1,q2,:)));
current=current/max(current);
figure(2)
clf
hold on
plot(polaPosns,current)
plot(polaPosns,current,'*')
fluxscale=1;  % Make predicted value
predFlux=cosd(polaPosns+pOffs).^2*fluxscale;
%predFlux=sind(polaPosns).^2*fluxscale;
plot(polaPosns,predFlux,'r')
hold off           
chisq2=sum((current-predFlux).^2);
disp(chisq1+chisq2)