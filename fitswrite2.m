function fitswrite2(imagedata,filename,varargin)
%FITSWRITE Write image to FITS file.
%
%   NOTE: This is a modified version of Matlab's own fitwsrite function.
%         It adds support for uint16 data (via the BZERO keyword) and
%         passing extra keywords (as a 3-column cell array).
%         Specify the 'uint16' paramter as true to convert to uint16.
%
%   fitswrite(IMAGEDATA,FILENAME) writes IMAGEDATA to the FITS file
%   specified by FILENAME.  If FILENAME does not exist, it is created as a
%   simple FITS file.  If FILENAME does exist, it is either overwritten or
%   the image is appended to the end of the file.
%
%   fitswrite(...,'PARAM','VALUE') writes IMAGEDATA to the FITS file
%   according to the specified parameter value pairs.  The parameter names
%   are as follows:
%
%       'WriteMode'    One of these strings: 'overwrite' (the default)
%                      or 'append'. 
%
%       'Compression'  One of these strings: 'none' (the default), 'gzip', 
%                      'gzip2', 'rice', 'hcompress', or 'plio'.
%
%   Please read the file cfitsiocopyright.txt for more information.
%
%   Example:  Create a FITS file the red channel of an RGB image.
%       X = imread('ngc6543a.jpg');
%       R = X(:,:,1); 
%       fitswrite(R,'myfile.fits');
%       fitsdisp('myfile.fits');
%
%   Example:  Create a FITS file with three images constructed from the
%   channels of an RGB image.
%       X = imread('ngc6543a.jpg');
%       R = X(:,:,1);  G = X(:,:,2);  B = X(:,:,3);
%       fitswrite(R,'myfile.fits');
%       fitswrite(G,'myfile.fits','writemode','append');
%       fitswrite(B,'myfile.fits','writemode','append');
%       fitsdisp('myfile.fits');
%
%   See also FITSREAD, FITSINFO, MATLAB.IO.FITS.

%   Copyright 2011-2013 The MathWorks, Inc.


p = inputParser;

datatypes = {'uint8','int16','int32','int64','single','double'};
p.addRequired('imagedata',@(x) validateattributes(x,datatypes,{'nonempty'}));
p.addRequired('filename', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','FILENAME'));

p.addParamValue('writemode','overwrite', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','WRITEMODE'));

p.addParamValue('compression','none', ...
     @(x) validateattributes(x,{'char'},{'nonempty'},'','COMPRESSION'));

p.addOptional('keywords', [],@(x)  validateattributes(x,{'cell'},{'ncols', 3}))
p.addOptional('uint16', false)

p.parse(imagedata,filename,varargin{:});
keywords=p.Results.keywords;
uint16Mode = p.Results.uint16;

mode = validatestring(p.Results.writemode,{'overwrite','append'});
compscheme = validatestring(p.Results.compression, ...
    {'gzip','gzip2','rice','hcompress','plio','none'});

import matlab.io.*
if strcmpi(mode,'append')
    fptr = fits.openFile(filename,'readwrite');
else
    if exist(filename,'file')
        delete(filename);
    end
    fptr = fits.createFile(filename);
end

BZERO = 0;
if uint16Mode
    % FITS doesn't natively support uint16. Instead, use int16 with an
    % offset.
    imagedata = int16(imagedata - 2^15);
    BZERO = 2^15;
end

try
    if ~strcmpi(compscheme,'none')
        fits.setCompressionType(fptr,compscheme);
    end
    
    fits.createImg(fptr,class(imagedata),size(imagedata));
    fits.writeImg(fptr,imagedata);
    
    % Add offset for uint16 data
    if BZERO > 0
        commentString = 'offset data range to that of unsigned short';
        fits.writeKey(fptr,'BZERO',BZERO,commentString);
    end
    
    % add header words
    for i=1:size(keywords,1)     
        if strcmpi(keywords{i,1},'comment')
            fits.writeComment(fptr,keywords{i,2})
        else
            fits.writeKey(fptr,keywords{i,1},keywords{i,2},keywords{i,3});
        end
    end
    fits.writeDate(fptr);

    
catch me
    fits.closeFile(fptr);
    rethrow(me);
end

fits.closeFile(fptr);
