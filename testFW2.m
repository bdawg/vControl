data = rand(512,512,800)*2^16;
data = uint16(data);

keyword1 = {'value1', 23, 'comment1'};
keyword2 = {'value2', 233, 'comment2'};
keywordList = [keyword1; keyword2];

tic
fitswrite2(data,'testfile.fits', 'keywords', keywordList)
toc
