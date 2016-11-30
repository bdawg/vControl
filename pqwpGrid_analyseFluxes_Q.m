

% This is copied from vControl. Shoudl probably save these
% into the m file.

% load('/data/pqwpScans/pqwpGrid_allImages_775_15posn_Scan1_FLUXES.mat')
% polaPosns=[0 22.5 45 67.5 90 112.5 135 157.5];
% nQWPPosns=15;
% nPolas=length(polaPosns);
% qwpPosns1=0:(180/(nQWPPosns-1)):180;
% qwpRange=[0,180]; %For plotting
% qwpPosns2=qwpPosns1;

% 
% load('/data/pqwpScans/pqwpGrid_allFluxes_Output_710-75nm_0-180.mat')
% polaPosns=[0 22.5 45 67.5 90 112.5 135 157.5];
% nQWPPosns=20;
% nPolas=length(polaPosns);
% qwpPosns1=0:(180/(nQWPPosns-1)):180;
% qwpRange=[0,180]; %For plotting
% qwpPosns2=qwpPosns1;

% load('/data/pqwpScans/pqwpGrid_allFluxes_775_zoomedIn1.mat')
% polaPosns=[0 22.5 45 67.5 90 112.5 135 157.5];
% nQWPPosns=20;
% nPolas=length(polaPosns);
% qwpPosns1=110:(60/(nQWPPosns-1)):170;
% qwpPosns2=10:(60/(nQWPPosns-1)):70;

% load('/data/pqwpScans/pqwpGrid_allFluxes_zoomin90_775.mat')
% polaPosns=[0 22.5 45 67.5 90 112.5 135 157.5];
% nQWPPosns=20;
% nPolas=length(polaPosns);
% qwpPosns1=75:(30/(nQWPPosns-1)):105;
% qwpPosns2=75:(30/(nQWPPosns-1)):105;

load('/data/pqwpScans/pqwpSingleScan_allFluxes_775_90_90.mat')
nQWPPosns=length(qwpPosns1);

%load('/data/pqwpScans/pqwpGrid_allFluxes_Output_775_hires.mat')
%nQWPPosns=length(qwpPosns1);

% allFluxes(wollchan, qwpPosn1, qwpPosn2, nPolas)
allChisq=zeros(nQWPPosns,nQWPPosns);


for q1 = 1:nQWPPosns
    for q2 = 1:nQWPPosns

            current1=transpose(squeeze(allFluxes(1,q1,q2,:)));
            %current=current/max(current);
            current2=transpose(squeeze(allFluxes(2,q1,q2,:)));
            currentQ=(current1-current2)./(current1+current2);
            
            figure(1)
            clf
            hold on
            plot(polaPosns,currentQ)
            plot(polaPosns,currentQ,'*')
            
            predFlux=sind(polaPosns).^2-cosd(polaPosns).^2;
            plot(polaPosns,predFlux,'r')
            hold off           
            chisq1=sum((currentQ-predFlux).^2);
            %pause(0.5)
                     
            allChisq(q1,q2)=chisq1;
            disp(allChisq(q1,q2))
            %pause(.1)
    end
end

figure
hold on
im1=allChisq;
%imagesc(qwpRange,qwpRange,im1)


imagesc(im1)
[minval,minind]=min(im1(:));
[y1,x1]=ind2sub([nQWPPosns,nQWPPosns],minind);
plot(x1,y1,'w*')
q1=y1;
q2=x1;

current1=transpose(squeeze(allFluxes(1,q1,q2,:)));
current2=transpose(squeeze(allFluxes(2,q1,q2,:)));
currentQ=(current1-current2)./(current1+current2);

figure(1)
clf
hold on
plot(polaPosns,currentQ)
plot(polaPosns,currentQ,'*')

predFlux=sind(polaPosns).^2-cosd(polaPosns).^2;
plot(polaPosns,predFlux,'r')
hold off           
chisq1=sum((currentQ-predFlux).^2);
            

disp('Final chisq:')
disp(chisq1)

disp('QWP1 Angle: ')
disp(qwpPosns1(q1));
disp('QWP2 Angle: ')
disp(qwpPosns2(q2));



%%%%%%%%%%% Un-comment for interpolation %%%%%%%%%%%%
%%%%%%%%%%% Assumes qwpPosns1=qwpPosns2 %%%%%%%%%%%%%
% intS=min(qwpPosns1);
% intE=max(qwpPosns1);
% [xq,yq]=meshgrid(intS:1:intE);
% x=qwpPosns1;
% y=qwpPosns2;
% im1=interp2(x,y,im1,xq,yq,'cubic');
% xinds=xq(1,:);
% yinds=yq(:,1);
% figure
% hold on
% imagesc(im1)
% [minval,minind]=min(im1(:));
% newsz=length(xq(:,1));
% [y1,x1]=ind2sub([newsz,newsz],minind);
% plot(x1,y1,'w*')
% hold off
% q1=y1;
% q2=x1;
% disp('Interpolated values: ')
% disp('QWP1 Angle: ')
% disp(xinds(q1));
% disp('QWP2 Angle: ')
% disp(yinds(q2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


