%%% Extracts fluxes from pqwpGrid and fits to expected result %%%
%%% To be incorporated into a GUI launched from vControl. %%%




%load('/data/pqwpScans/ao188cal_775_measure1__IMR90__allImages.mat')
%load('/data/pqwpScans/ao188cal_775_measure1b__IMR67-5__allImages.mat')
%load('/data/pqwpScans/ao188cal_650_grid__IMR90__allImages.mat')
%load('ao188cal_725_grid__IMR90__allImages.mat')
%load('ao188cal_newBS_775grid1__IMR90__allImages.mat')

%inFilename='ao188cal_Mar2015_newBS_grid3_775_90__IMR90__allImages.mat' % Taken with V2(25V)
%inFilename='ao188cal_Mar2015_newBS_grid4_725_90__IMR90__allImages' % Taken with V2(25V)

%inFilename='/data/pqwpScans/ao188cal_Aug2015_newBS_grid_750__IMR90__allImages.mat'% Problem - didn't check V1 vs V2... back it out.

%inFilename='/data/pqwpScans/ao188cal_08Aug2015_newBS_grid_V2_IMR100_Filter775-50__allImages.mat'
inFilename='/data/pqwpScans/ao188cal_11Oct2015_newBS_grid_V2_IMR90_Filter625-50__allImages_NONoPol.mat'

%saveFilename=['/data/pqwpScans/',inFilename,'_allFluxes']
saveFilename=[inFilename,'_allFluxes']

darkfilename=('ao188_darkcube_05s.fits')

%load('flatFieldstopMasks.mat')
load('flatFieldstopMasks_NewBS_Aug2015.mat')
%load('flatFieldstopMasks_NewBS_align2_Jan2014.mat')
dark=fitsread(darkfilename);
dark=mean(dark,3);
load(inFilename);

%%%allImages=zeros(512,512,nQWPPosns,nQWPPosns,nPolas);
nQWPPosns=length(allImages(1,1,:,1,1));
nPolas=length(allImages(1,1,1,1,:));



% allFluxes(wollchan, qwpPosn1, qwpPosn2, nPolas)
allFluxes=zeros(2, nQWPPosns, nQWPPosns, nPolas);
imsz=512;

for p = 1:nPolas
    for q1 = 1:nQWPPosns
        for q2 = 1:nQWPPosns
            im=allImages(:,:,q1,q2,p) - dark;          
            subim = im.*ch2Mask;
            npix=sum(ch2Mask(:));
            figure(1)
            imagesc(subim)
            flux=sum(subim(:))/npix;
            allFluxes(1,q1,q2,p)=flux;
            disp(['Flux: ' num2str(flux)])
            %pause(0.02)
            
            im=allImages(:,:,q1,q2,p) - dark;
            subim = im.*ch1Mask;
            npix=sum(ch1Mask(:));
            figure(2)
            imagesc(subim)
            flux=sum(subim(:))/npix;
            allFluxes(2,q1,q2,p)=flux;
            disp(['Flux: ' num2str(flux)])
            %pause(0.02)
        end
    end
end

%save('/data/pqwpScans/pqwpGrid_allFluxes','allFluxes','aoHwpPosns','qwpPosns1','qwpPosns2')
%save('/data/pqwpScans/ao188cal_newBS_775grid1__IMR90__allFluxes','allFluxes','aoHwpPosns','qwpPosns1','qwpPosns2')
save(saveFilename,'allFluxes','aoHwpPosns','qwpPosns1','qwpPosns2')


