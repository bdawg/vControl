function movePRM(prmObj,angle,dohome)

% Moves PRM1/M-Z7 via TCube.
% if home == 1 then homign is initiated (angle is ignored).

if dohome == 1 
    disp('Homing')
    nbytes=6;
    hexString={'43' '04' '01' '00' '50' '01'}; %Do homing
    for ii = 1:nbytes
        hex=hexString{ii};
        dec=hex2dec(hex);
        fwrite(prmObj,dec,'uint8')
    end
    
else
    
    EncCnt = 682.5;
    absSteps = EncCnt*angle;
    [d1 d2 d3 d4]=entryToBits(absSteps);
    bytes=[d1 d2 d3 d4];
    for ii = 1:4
        absPos{ii}=num2str(dec2hex(bytes(ii)));
    end
    nbytes=12;
    header={'53' '04' '06' '00' '80' '01'};
    chan={'01' '00'};
    hexString=[header, chan, absPos];
    for ii = 1:nbytes
        hex=hexString{ii};
        dec=hex2dec(hex);
        fwrite(prmObj,dec,'uint8')
    end
end



function [d3 d4 d5 d6] = entryToBits(data)
% Convert negative numbers...
if data<0
    data = 256^4 + data;
end

% d6 is the last bit (data must be larger than 256^3 to have a value here)
d6 = floor(data / 256^3);
data   = (data) - 256^3 * d6;

% d5 is the next largest bit... d5 = (0:256)*256^2
d5 = floor(data / 256^2);
if d5>256
    d5 = 256;
end

% d4 is the second smallest bit... d4 = (0:256)*256
data   = data - 256^2 * d5;
d4 = floor(data / 256);
if d4>256
    d4 = 256;
end

% d3 is the smallest bit, values are 0:256
d3 = floor(mod(data,256));
if d3>256
    d3 = 256;
end



