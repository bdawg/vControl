%%% Extracts fluxes from pqwpGrid and fits to expected result %%%
%%% To be incorporated into a GUI launched from vControl. %%%

boxsz=10;
%load('pqwpGrid_allImages_775_15posn_Scan1.mat')
%load('pqwpGrid_allImages_775_zoomedIn1.mat')
%load('pqwpGrid_allImages_Output_v73.mat')
%load('/data/pqwpScans/pqwpGrid_allImages_Output_775_hires.mat')
%%load('/data/pqwpScans/pqwpGrid_allImages_Output_710-75nm_0-180.mat')

load('ao188cal_775_grid_roughgrid__IMR90__allImages');
%/data/pqwpScans/ao188cal_650_grid__IMR90__allImages.mat')

%%%allImages=zeros(512,512,nQWPPosns,nQWPPosns,nPolas);
nQWPPosns=length(allImages(1,1,:,1,1));
nPolas=length(allImages(1,1,1,1,:));

% Identify spot positions
meanIm=sum(allImages,5);
meanIm=sum(meanIm,4);
meanIm=sum(meanIm,3);
meanIm=meanIm/(nQWPPosns*nQWPPosns*nPolas);
figure(1)
imagesc(meanIm)

% disp('Click top-left (low X/Y vals) spot:')
% [x1,y1]=ginput(1);
% disp('Click bottom-right (high X/Y vals) spot:')
% [x2,y2]=ginput(1);
disp('Click in an empty place for background:')
[xb,yb]=ginput(1);
% x1=fix(round(x1));
% x2=fix(round(x2));
% y1=fix(round(y1));
% y2=fix(round(y2));
xb=fix(round(xb));
yb=fix(round(yb));
bw=boxsz/2;
bgim = meanIm((yb-bw):(yb+bw),(xb-bw):(xb+bw));
bg=mean(mean(bgim));


% allFluxes(wollchan, qwpPosn1, qwpPosn2, nPolas)
allFluxes=zeros(2, nQWPPosns, nQWPPosns, nPolas);
imsz=512;

for p = 1:nPolas
    for q1 = 1:nQWPPosns
        for q2 = 1:nQWPPosns
            im=allImages(:,:,q1,q2,p) - bg;
            im((imsz/2):imsz,:)=0;
            [maxval,maxind]=max(im(:));
            oldx1=x1;
            oldy1=y1;
            [y1,x1]=ind2sub([imsz,imsz],maxind);
                if (x1 < 20) || (x1 > 492)
                    x1=oldx1;
                end
                if (y1 < 20) || (y1 > 492)
                    y1=oldy1;
                end
            subim = im((y1-bw):(y1+bw),(x1-bw):(x1+bw));
            figure(1)
            imagesc(subim)
            flux=sum(sum(subim));
            allFluxes(1,q1,q2,p)=flux;
            disp(['Flux: ' num2str(flux)])
            %pause(0.02)
            
            im=allImages(:,:,q1,q2,p) - bg;
            im(1:(imsz/2),:)=0;
            [maxval,maxind]=max(im(:));
            [y2,x2]=ind2sub([imsz,imsz],maxind);
            subim = im((y2-bw):(y2+bw),(x2-bw):(x2+bw));
            figure(1)
            imagesc(subim)
            flux=sum(sum(subim));
            allFluxes(2,q1,q2,p)=flux;
            disp(['Flux: ' num2str(flux)])
            %pause(0.02)
        end
    end
end

save('/data/pqwpScans/pqwpGrid_allFluxes','allFluxes','polaPosns','qwpPosns1','qwpPosns2')
%save('/data/pqwpScans/pqwpGrid_allFluxes','allFluxes','polaPosns' ,'qwpPosns1','qwpPosns2')