datapath='/data/20141113/';
%filepref='focustest5_775-50_EmptySlot_';
%filepref='focustest7_775-50_EmptySlot_';
filepref='hr8799_3_20141113_775-50_AnnulusNudged_0';



datapath='/data/2014September/20140914/';
filepref='HD15115_20140914T140729_775-50_AnnulusNudged_'

nfiles=1;
focPosns1=[0 100 200 300 400 500];
rep=11;
focPosns = repmat(focPosns1,1,rep);
nfiles = nfiles*rep;

%sshs = 50;%25; %Half-width of sub-sub-im
%allims=zeros(512,512,nfiles);
%subims=zeros(256,256,nfiles);
%allFitVals=zeros(7,nfiles);
%allWidths=zeros(nfiles,1);
%allL2s=zeros(nfiles,1);
allPSs=zeros(256,256,nfiles);
allSDs=zeros(nfiles,1);


w1D = hamming(256); % Some 1D window
window = w1D(:) * w1D(:).'; % Outer product

figure(1)
for ii = 1:2;%nfiles
    tic
    cube=fitsread([datapath filepref num2str(ii-1) '.fits']);
    nframes=length(cube(1,1,:));
    pscube=zeros(256,256,nframes);
    
    for k = 1:nframes
        im=cube(:,:,k);
        im=im(257:512,257:512);
  
        [v,ind]=max(im(:));
        [y,x] = ind2sub(size(im),ind);
        im=circshift(im, [(256-y+128),(256-x+128)]);     
        im=im.*window;
        ps=abs(fft2(im)).^2;
        ps = ps/ps(1,1);
        ps=circshift(ps,[128,128]);
        pscube(:,:,k)=ps;
    end
    
    allPSs(:,:,ii) = sum(pscube,3)/nframes;
    imagesc(log10(allPSs(:,:,ii)));
    ps = allPSs(:,:,ii);
    
    allSDs(ii)=(std(log10(ps(:))))
%     % Average radially by rebinning into polar coords
%     ps = allPSs(:,:,ii);
%     x = repmat(1:256,1,256);
%     y = repmat(1:256,256,1);
%     y = y(:);
%     rbins=64;
%     %r = sqrt((1:256).^2+(1:256).^2);
%     r = sqrt(x'.^2 + y.^2);
%     bi=bindex(r,rbins);
%     nbins=length(rbins)-1;
%     sumz=sparse(bi,1,ps(:),nbins,1);
%     n=sparse(bi,1,1,nbins,1);
%     meanz = sumz./n;
    
    
    toc
    pause(0.1)
end


% figure(10)
% hold on
% %plot(focPosns,allSDs)
% plot(focPosns,allSDs,'x')
% p = polyfit(focPosns, allSDs', 3);
% xs = focPosns(1):10:focPosns(nfiles);
% pfunc = p(1)*xs.^3 + p(2)*xs.^2 + p(3)*xs + p(4);
% plot(xs, pfunc, 'r')
% [m, bestind] = max(pfunc);
% best=xs(bestind);
% plot(best,pfunc(bestind),'o')
% disp(['Best focus: ' num2str(best)])
% hold off

