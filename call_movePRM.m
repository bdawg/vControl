angle=360*4+10;
angle=129; %% this value (129) is horizontal
% NB if facing camera it rotates clockwise with positive number rotation

prmObj = serial('/dev/ttyQUARTERWP', ...
    'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');

%prmObj = serial('/dev/serial/by-id/usb-Thorlabs_APT_DC_Motor_Controller_83814999-if00-port0', ...
%    'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');

fopen(prmObj); %Open the device
prmObj.Terminator=''; %Set terminator to ''

movePRM(prmObj,angle,0)

% Clean up when done
fclose(prmObj);
delete(prmObj);
clear lcvrObj
