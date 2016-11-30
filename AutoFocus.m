
datapath='/data/2015April/20150405/';
%filepref='focustest3__775-50_EmptySlot_';

%filepref='focustest6_775-50_9hole_';
%filepref='focustest7_775-50_EmptySlot_';
filepref='focustest8_775-50_EmptySlot_';
%filepref='focTest_01_775-50_9hole_'
filepref='focTest_02_775-50_EmptySlot_'

nfiles=6;%6
focPosns1=[0 100 200 300 400 500];
rep=8;%10;%5;
focPosns = repmat(focPosns1,1,rep);
nfiles = nfiles*rep;

sshs = 50;%25; %Half-width of sub-sub-im

allims=zeros(512,512,nfiles);
subims=zeros(256,256,nfiles);
%allFitVals=zeros(7,nfiles);
%allWidths=zeros(nfiles,1);
allL2s=zeros(nfiles,1);

figure(7)
for ii = 1:nfiles
    cube=fitsread([datapath filepref num2str(ii-1) '.fits']);
    nf = length(cube(1,1,:));
    allims(:,:,ii) = sum(cube,3)/nf;
    %tmp=allims(1:256,257:512,ii); %Wollaston
    tmp=allims(1:256,1:256,ii); %New BS
    bg=mean(tmp(:));
    allims(:,:,ii) = allims(:,:,ii) - bg;
    %imagesc(allims(:,:,ii));
    %subims(:,:,ii) = allims(257:512,257:512,ii); %Wollaston
    subims(:,:,ii) = allims(1:256,257:512,ii);  %New BS
    im = subims(:,:,ii);
    imagesc(im);
    
    %hold on
    %imagesc(im);
    %[fitres,gof]=Gauss2DRotFit(subims(:,:,ii));
    %allWidths(ii) =  sqrt(fitres.w1^2 + fitres.w2^2)  
    [v,ind]=max(im(:));
    [y,x] = ind2sub(size(im),ind);
    %plot(x,y,'x')
    %hold off
    
    subsubim=im(y-sshs:y+sshs,x-sshs:x+sshs);
    imagesc(subsubim)
    L2mean = sum(subsubim(:).^2) / sum(subsubim(:))^2;
    allL2s(ii)=L2mean;
    disp(focPosns(ii))
    pause(0.5)
end


figure(8)
hold on
%plot(focPosns,allL2s)
plot(focPosns,allL2s,'x')
p = polyfit(focPosns, allL2s', 3);
xs = focPosns(1):10:focPosns(nfiles);
pfunc = p(1)*xs.^3 + p(2)*xs.^2 + p(3)*xs + p(4);
plot(xs, pfunc, 'r')
[m, bestind] = max(pfunc);
best=xs(bestind);
plot(best,pfunc(bestind),'o')
disp(['Best focus: ' num2str(best)])
hold off
