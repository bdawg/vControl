function varargout = vControl(varargin)
% VCONTROL MATLAB code for vControl.fig
%      VCONTROL, by itself, creates a new VCONTROL or raises the existing
%      singleton*.
%
%      H = VCONTROL returns the handle to a new VCONTROL or the handle to
%      the existing singleton*.
%
%      VCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VCONTROL.M with the given input arguments.
%
%      VCONTROL('Property','Value',...) creates a new VCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vControl

% Last Modified by GUIDE v2.5 12-Sep-2014 23:30:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vControl_OpeningFcn, ...
                   'gui_OutputFcn',  @vControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function logging(txt, keyword)
    if nargin<2
        keyword='vControl';
    end
    dummy = system(strcat('dolog ',32,keyword,32,' ''',strrep(txt, '''',''),''''));

% --- Executes just before vControl is made visible.
function vControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vControl (see VARARGIN)

% Choose default command line output for vControl
logging('Starting');
handles.output = hObject;


%%%%%%%%%%%%%%%%%%%%%%%% Default Settings %%%%%%%%%%%%%%%%%%%%%%%%%
expTime = 0.018;     % Exposure time
emGain = 0;          % EM gain
HSSpeed = 0;         % Horizontal shift speed (index)
VSSpeed = 0;         % Vertical shift speed (index)
VSVolts = 2;         % Vertical shift voltage (index)

kinCycleTime = 0;    % Kinetic Cycle Time (0 sets it to minimum possible)
numKinetics = 16;   % Numer of frames in kinetic series
triggerMode = 0;     % 0 = internal, 1 = external
readoutMode = 0;     % 0 = NFT, 1 = FT

displayFrameRate = 10; % Default frame rate to display live video (FPS)
                       % Actual frame rate of *camera* controlled by
                       % Kinetic Cycle Time

lineProfYMax = 15000;  % Default max y axis for line profile

%%%%%%%%% periscope QWP Calibration %%%%%%%%%
%%% NB pQWP 1 is conex4, pQWP 2 is conex1
% Encoder angle that corresponds to 0 polarisation rotation
pqwp1CalOffset = 45; %This means that GUI's '0' is fast-axis vertical
pqwp2CalOffset = 85; %This means that GUI's '0' is fast-axis vertical
pqwpTol = 0.004; % Tolerance in position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Polariser encoder angle that corresponds to vertical polarisation
polaCalOffset =45; % #### Might be wrong! Re-measure!!!

% QWP encoder angle that corresponds to fast axis being horizontal
qwpCalOffset = 129;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Scexao IP address:
setappdata(handles.vCamGui,'SCExAOIP','133.40.162.11')
%setappdata(handles.vCamGui,'SCExAOIP','192.168.207.191')

%Position of polariser 'in'
setappdata(handles.vCamGui,'polzInPos','2600000')

% Set to 0 to disable these devices
lcvrOn = 1;
tcOn = 1;
conex1On = 1;
conex2On = 1;
arduinoOn = 1;
FWOn = 1;
conex3On = 1;
conex4On = 1;
PRMOn = 0;
zabersOn = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%0.01%%%%%%%%%%%%%%%%%%%%%%%%%%
setappdata(handles.vCamGui,'ExpTime',expTime)
setappdata(handles.vCamGui,'emGain',emGain)
setappdata(handles.vCamGui,'HSSpeed',HSSpeed)
setappdata(handles.vCamGui,'VSSpeed',VSSpeed)
setappdata(handles.vCamGui,'VSVolts',VSVolts)
setappdata(handles.vCamGui,'kinCycleTime',kinCycleTime)
setappdata(handles.vCamGui,'numKinetics',numKinetics)
setappdata(handles.vCamGui,'triggerMode',triggerMode)
setappdata(handles.vCamGui,'readoutMode',readoutMode)
setappdata(handles.vCamGui,'pqwp1CalOffset',pqwp1CalOffset)
setappdata(handles.vCamGui,'pqwp2CalOffset',pqwp2CalOffset)
setappdata(handles.vCamGui,'qwpCalOffset',qwpCalOffset)
setappdata(handles.vCamGui,'polaCalOffset',polaCalOffset)
setappdata(handles.vCamGui,'pqwpTol',pqwpTol)
setappdata(handles.vCamGui,'acqReadoutMode',1)
setappdata(handles.vCamGui,'abortStatus',0)
setappdata(handles.vCamGui,'snapshotStatus',0)
setappdata(handles.vCamGui,'FWName','');
setappdata(handles.vCamGui,'globalPupOffsetUD',0);
setappdata(handles.vCamGui,'globalPupOffsetLR',0);
setappdata(handles.vCamGui,'polzsource','QWP');
%%%%%%%%%%%%%%% Open USBTTY devices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Weird Bug! Matlab crashes when writing to USBTTL device IF the port is
%%% opened *after* the andor library is loaded.

setappdata(handles.vCamGui,'comments',{'Adding some salt...';'Feeding the lab monkey...'; 'The bits are breeding...'; '..and enjoy the elevator music'; 'While the little elves change the sky map...'; 'A few bits tried to escape, but we caught them'; 'Would you like fries with that?';'Checking the gravitational constant in your locale';'Go ahead -- hold your breath'; 'At least you''re not on hold';'We''re testing your patience';'As if you had any other choice';'Don''t think of purple hippos';'Follow the white rabbit';'Why don''t you order a sandwich?';'While the satellite moves into position';'The bits are flowing slowly today';'Wrapping presents';'Turning up the volume';'Micro-wave oven is heating it back up';'Loading, loading, loading';'Wait.. something went strange';'If I were you I''d have some sleep';'With how many holes do you like your masks?';'Blowing away turbulence';'Waiting for the AO loop to crash';'You better restart acquisition';'How fast do you think you can calculate 2378*143?';'You wish'});


setappdata(handles.vCamGui,'lcvrOn',lcvrOn)
if lcvrOn == 1
    lcvrObj = serial('/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A501U6J2-if00-port0', ...
        'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(lcvrObj); %Open the device
    lcvrObj.Terminator='CR'; %Set terminator to CR
    setappdata(handles.vCamGui,'lcvrObj',lcvrObj)
end

setappdata(handles.vCamGui,'tcOn',tcOn)
if tcOn == 1
    tcObj = serial('/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_AE015X9B-if00-port0', ...
        'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(tcObj); %Open the device
    tcObj.Terminator='CR'; %Set terminator to CR
    setappdata(handles.vCamGui,'tcObj',tcObj)
end

setappdata(handles.vCamGui,'FWOn',FWOn)
if FWOn == 1
    fwObj = serial('/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A900c3rB-if00-port0', ...
        'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(fwObj); %Open the device
    fwObj.Terminator='CR'; %Set terminator to CR
    setappdata(handles.vCamGui,'fwObj',fwObj)
end

setappdata(handles.vCamGui,'arduinoOn',arduinoOn)
if arduinoOn == 1
    arduinoObj = serial('/dev/ttyACM0', ...
        'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(arduinoObj);
    arduinoObj.Terminator='CR';
    setappdata(handles.vCamGui,'arduinoObj',arduinoObj)
end

setappdata(handles.vCamGui,'conex1On',conex1On)
if conex1On == 1
    %conex1Obj = serial('/dev/serial/by-id/usb-Newport_CONEX-AGP_A6VMT5XJ-if00-port0', ...
    conex1Obj = serial('/dev/ttyCONEX1', ...
        'BaudRate',921600,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    %conex1Obj.ReadAsyncMode = 'manual';
    fopen(conex1Obj);
    conex1Obj.Terminator='CR/LF'; %Set terminator to CR/LF
    setappdata(handles.vCamGui,'conex1Obj',conex1Obj)
    disp('Initialise conex1...')
    fprintf(conex1Obj,'');
    fprintf(conex1Obj,'1OR');
end

%pause(2)

setappdata(handles.vCamGui,'conex2On',conex2On)
if conex2On == 1
    
    %conex2Obj = serial('/dev/serial/by-id/usb-Newport_CONEX-AGP_A6VRT271-if00-port0', ...
    conex2Obj = serial('/dev/ttyCONEX2', ...
        'BaudRate',921600,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    %conex1Obj.ReadAsyncMode = 'manual';
    fopen(conex2Obj);
    conex2Obj.Terminator='CR/LF'; %Set terminator to CR/LF
    setappdata(handles.vCamGui,'conex2Obj',conex2Obj)
    disp('Initialise conex2...')
    fprintf(conex2Obj,'');
    fprintf(conex2Obj,'1OR');
end

setappdata(handles.vCamGui,'conex3On',conex3On)
if conex3On == 1
    %conex3Obj = serial('/dev/serial/by-id/usb-Newport_CONEX-AGP_A6WMSQ3G-if00-port0', ...
    conex3Obj = serial('/dev/ttyCONEX3', ...
        'BaudRate',921600,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    %conex1Obj.ReadAsyncMode = 'manual';
    fopen(conex3Obj);
    conex3Obj.Terminator='CR/LF'; %Set terminator to CR/LF
    setappdata(handles.vCamGui,'conex3Obj',conex3Obj)
    disp('Initialise conex3...')
    fprintf(conex3Obj,'');
    fprintf(conex3Obj,'1OR');
end

setappdata(handles.vCamGui,'conex4On',conex4On)
if conex4On == 1
    %conex3Obj = serial('/dev/serial/by-id/usb-Newport_CONEX-AGP_A6WMSQ3G-if00-port0', ...
    conex4Obj = serial('/dev/ttyCONEX4', ...
        'BaudRate',921600,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    %conex1Obj.ReadAsyncMode = 'manual';
    fopen(conex4Obj);
    conex4Obj.Terminator='CR/LF'; %Set terminator to CR/LF
    setappdata(handles.vCamGui,'conex4Obj',conex4Obj)
    disp('Initialise conex4...')
    fprintf(conex4Obj,'');
    fprintf(conex4Obj,'1OR');
end

setappdata(handles.vCamGui,'PRMOn',PRMOn)
if PRMOn == 1
    %prmObj = serial('/dev/ttyUSB0', ...
    %prmObj = serial('/dev/serial/by-id/usb-Thorlabs_APT_DC_Motor_Controller_83814999-if00-port0', ...
    prmObj = serial('/dev/ttyQUARTERWP', ...
        'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(prmObj); %Open the device
    prmObj.Terminator=''; %Set terminator to ''
    setappdata(handles.vCamGui,'prmObj',prmObj)
    movePRM(prmObj,0,1) %Do homing
end

setappdata(handles.vCamGui,'zabersOn',zabersOn)
if zabersOn == 1
    %zabersObj = serial('/dev/serial/usb-Prolific_Technology_Inc._USB-Serial_Controller-if00-port0', ...
    zabersObj = serial('/dev/ttyZABCHAIN1', ...   
        'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none','Timeout',60);
    fopen(zabersObj);
    zabersObj.Terminator='';
    setappdata(handles.vCamGui,'zabersObj',zabersObj)
    disp('Initialise Zabers...')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off
header='/usr/local/include/atmcdLXd.h';
[notfound, warnings] = loadlibrary('/usr/local/lib/libandor.so', header);
warning on

%%%%%%%%%%%%%%%% Initialise Camera %%%%%%%%%%%%%%%%%%%%%%%%
error=0;
disp('Initaliasing Camera...')
error=calllib('libandor','Initialize','/usr/local/etc/andor');

if error == 20002
    disp('Initialisation Succesful')
    logging('Initialisation Succesful of Camera');
else
    disp('Initialisation Error')
    logging('Initialisation Error of Camera');
end

% Set read mode to Image
error=calllib('libandor','SetReadMode',4);

% Set acquisition mode to Run Till Abort and related settings
error=calllib('libandor','SetAcquisitionMode',5);
error=calllib('libandor','SetExposureTime',expTime);
error=calllib('libandor','SetNumberAccumulations',1);

error=calllib('libandor','SetNumberKinetics',numKinetics);
error=calllib('libandor','SetTriggerMode',triggerMode);

error=calllib('libandor','SetEMGainMode',2); % Believed to be 'real', docs wrong.
error=calllib('libandor','SetEMAdvanced',1); %%%% Set to 1 at your peril!!! (RTFM) %%%%
error=calllib('libandor','SetEMCCDGain',emGain);
error=calllib('libandor','SetHSSpeed',0,HSSpeed); %Also sets to EM output amp
error=calllib('libandor','SetVSSpeed',VSSpeed);
error=calllib('libandor','SetVSAmplitude',VSVolts);

error=calllib('libandor','SetFrameTransferMode',readoutMode);

% Set trigger mode to internal
error=calllib('libandor','SetTriggerMode',0);
error=calllib('libandor','SetKineticCycleTime',kinCycleTime);

% Set shutter to open
error=calllib('libandor','SetShutter',0,1,50,50); %#ok<*NASGU>

% Setup image size
imw=libpointer('int32Ptr',0);
imh=libpointer('int32Ptr',0);
error=calllib('libandor','GetDetector',imw,imh);
imWidth=imw.value;
imHeight=imw.value;
error=calllib('libandor','SetImage',1,1,1,imWidth,1,imHeight);
    %Temp code to enable binning and cropping:
%     hbin=1;%4;
%     vbin=1;%4;
%     hstart=81-20 +20;
%     hend=440-20 +20;
%     vstart=193+25 -25;
%     vend=288+25 -25;
%     imWidth=hend-hstart+1;
%     imHeight=vend-vstart+1;
%     errorSetImage=calllib('libandor','SetImage',hbin,vbin,hstart,hend,vstart,vend);

setappdata(handles.vCamGui,'imWidth',imWidth)
setappdata(handles.vCamGui,'imHeight',imHeight)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create timer object for video
handles.vidTimer = timer(...
    'ExecutionMode', 'fixedRate', ...
    'Period', 1/displayFrameRate, ...
    'TimerFcn', {@update_display,hObject} );

% Create timer object for value updates (e.g. temperature display)
handles.valTimer = timer(...
    'ExecutionMode', 'fixedRate', ...
    'Period', 1, ...
    'TimerFcn', {@update_values,hObject} );

handles.logTimer = timer(...
    'ExecutionMode', 'fixedRate', ...
    'Period', 10, ...
    'TimerFcn', {@log_values,hObject} );

% Set default line profile position
lineProfStart=[256,1];
lineProfEnd=[256,512];
setappdata(handles.vCamGui,'lineProfStart',lineProfStart)
setappdata(handles.vCamGui,'lineProfEnd',lineProfEnd)
setappdata(handles.vCamGui,'boxCenter',[256,256])
setappdata(handles.vCamGui,'boxCenter2',[256,256])
setappdata(handles.vCamGui,'boxAvCount',0);
setappdata(handles.vCamGui,'box1fluxes',0);
setappdata(handles.vCamGui,'box2fluxes',0);

[dummy,folder]=system('echo $(date -u +''%Y%m%d'')');
system('mkdir -p /data/$(date -u +''%Y%m%d'')');
setappdata(handles.vCamGui,'savefolder',strcat('/data/',folder,'/'));

%%%%%%%%%%%%%%%%%%% Set up TTL devices %%%%%%%%%%%%%%%%%%%%

%LCVR:
if lcvrOn == 1
    % Request and read ID twice, since sometimes has junk data in buffer  
    fprintf(lcvrObj,'*idn?');
    fscanf(lcvrObj); %First read returns echo of sent command
    output=fscanf(lcvrObj); %Actual output returned
    fprintf(lcvrObj,'*idn?');
    fscanf(lcvrObj); %First read returns echo of sent command
    output=fscanf(lcvrObj); %Actual output returned
    exOut=['THORLABS LCC25 vers 1.01' 13];
    if strcmp(output,exOut) ~= 1
        disp('Error communicating with LCVR')
        logging('Error communicating with LCVR')
    end
    fprintf(lcvrObj,'enable=0');
    fscanf(lcvrObj);
    fprintf(lcvrObj,'mode=1');
    fscanf(lcvrObj);
    
    %Get current settings:
    fprintf(lcvrObj,'volt1?');
    fscanf(lcvrObj); %First read returns echo of sent command
    lcvrV1=str2num(fscanf(lcvrObj)); %Actual output returned
    
    fprintf(lcvrObj,'volt2?');
    fscanf(lcvrObj); %First read returns echo of sent command
    lcvrV2=str2num(fscanf(lcvrObj)); %Actual output returned
    
    fprintf(lcvrObj,'freq?');
    fscanf(lcvrObj); %First read returns echo of sent command
    lcvrFreq=str2num(fscanf(lcvrObj)); %Actual output returned
    
    setappdata(handles.vCamGui,'lcvrV1',lcvrV1)
    setappdata(handles.vCamGui,'lcvrV2',lcvrV2)
    setappdata(handles.vCamGui,'lcvrFreq',lcvrFreq)
    
    set(handles.lcvrV1Box,'string',num2str(lcvrV1))
    set(handles.lcvrV2Box,'string',num2str(lcvrV2))
    set(handles.lcvrFreqBox,'string',num2str(lcvrFreq))
end

%TC:
if tcOn == 1
    % Request and read ID twice, since sometimes has junk data in buffer  
    fprintf(tcObj,'*idn?');
    fscanf(tcObj); %First read returns echo of sent command
    output=fscanf(tcObj); %Actual output returned
    fprintf(tcObj,'*idn?');
    fscanf(tcObj); %First read returns echo of sent command
    output=fscanf(tcObj); %Actual output returned
    exOut=['THORLABS TC200 VERSION 2.0' 13];
    if strcmp(output,exOut) ~= 1
        disp('Error communicating with Temperature Controller')
        logging('Error communicating with Temperature Controller')
    end
    
    %enableTC(handles); % See separate function
    %disableTC(handles); % See separate function
    %Get current settings:
    fprintf(tcObj,'tset?'); fscanf(tcObj);
    setTemp=fscanf(tcObj);
    setTemp=str2num(setTemp(1:5));    
    fprintf(tcObj,'tact?'); fscanf(tcObj);
    curTemp=fscanf(tcObj);
    curTemp=str2num(curTemp(1:5));
    
    setappdata(handles.vCamGui,'setTemp',setTemp)
    setappdata(handles.vCamGui,'curTemp',curTemp)
    set(handles.lcvrTempBox,'string',num2str(setTemp))
    set(handles.lcvrTempDisp,'string',num2str(curTemp))
end

% %Conex1
% if conex1On == 1
%     %Get id info:
%     disp('Conex 1:')
%     fprintf(conex1Obj,'1ZT?');
%     output=fscanf(conex1Obj); %Actual output returned
%     disp(output)
% end
% 
% %pause(1)
% 
% %Conex2
% if conex2On == 1
%     %Get id info:
%     disp('Conex 2:')
%     fprintf(conex2Obj,'1ZT?');
%     output=fscanf(conex2Obj); %Actual output returned
%     disp(output)
% end




%%%%%%%%%%%%%%%%%%% Set text-box values %%%%%%%%%%%%%%%%%%%
set(handles.textStatusBox,'string','Idle')
set(handles.expTimeBox,'string',num2str(expTime))
set(handles.emGainBox,'string',num2str(emGain))
set(handles.HSSpeedBox,'string',num2str(HSSpeed))
set(handles.VSSpeedBox,'string',num2str(VSSpeed))
set(handles.VSVoltsBox,'string',num2str(VSVolts))
set(handles.cycTimeBox,'string',num2str(kinCycleTime))
set(handles.numFramesBox,'string',num2str(numKinetics))

set(handles.axesMainVideo,'XTickLabel','')
set(handles.axesMainVideo,'YTickLabel','')

set(handles.lineProfYMaxBox,'string',num2str(lineProfYMax))


%%%%%%%%%%% Set up filter and mask wheel boxes %%%%%%%%%%%%%
wheelFile=get(handles.wheelPresetsBox,'string');
wFile=fopen(['./WheelPresets/',wheelFile,'.txt']);
%maskNames=textscan(wFile,'MaskNames: %s %s %s %s %s %s %*[^\n] ',1);
%maskNames=[maskNames{:}];

textscan(wFile,'%*[^\n] ',1);
nMasks=textscan(wFile,'nmasks: %d %*[^\n] ',1);
nMasks=nMasks{1};
wheelAngs=zeros(nMasks,1);
pupilXs = zeros(nMasks,1);
pupilYs = zeros(nMasks,1);
for ii = 1:nMasks
    %rd=textscan(wFile,'%s %f %f %f %f %f %f %*[^\n] ',1);
    rd=textscan(wFile,'%f %s %f %f %f %*[^\n] ',1);
    %maskNames{ii}=rd{1}{1};
    maskNames{ii}=rd{2}{1};
    wheelAngs(ii)=rd{3};
    pupilXs(ii)=rd{4};
    pupilYs(ii)=rd{5};
end
fclose(wFile);

% nFilts=textscan(wFile,'nfilts: %d %*[^\n] ',1);
% nFilts=nFilts{1};
% textscan(wFile,'%*[^\n] ',1);
% wheelAngs=zeros(6,nFilts);
% for ii = 1:nFilts
%     rd=textscan(wFile,'%s %f %f %f %f %f %f %*[^\n] ',1);
%     filtNames{ii}=rd{1}{1};
%     wheelAngs(:,ii)=[rd{2:7}];
% end
% fclose(wFile);
setappdata(handles.vCamGui,'wheelAngs',wheelAngs);
setappdata(handles.vCamGui,'pupilXs',pupilXs);
setappdata(handles.vCamGui,'pupilYs',pupilYs);
% set(handles.filterWheelMenu,'string',filtNames)
set(handles.maskNameMenu,'string',maskNames);

%curFilterName=filtNames{1};
curMaskName=maskNames{1};
%setappdata(handles.vCamGui,'curFilterName',curFilterName);
setappdata(handles.vCamGui,'curMaskName',curMaskName);



FilterWheelFile=get(handles.filterPresetsBox,'string');
wFile=fopen(['./FilterPresets/',FilterWheelFile,'.txt']);
nFWFilts=textscan(wFile,'nfilts: %d %*[^\n] ',1);
nFWFilts=nFWFilts{1};
for ii = 1:nFWFilts
    rd=textscan(wFile,'%f %s %*[^\n] ',1);
    FWFiltNames{ii}=rd{2}{1};
end
%disp(FWFiltNames)
fclose(wFile);
set(handles.filterWheelMenu,'string',FWFiltNames)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if tcOn == 1
    fprintf(tcObj,'tact?'); 
end
pause(0.2)
start(handles.valTimer)

% Update handles structure
guidata(hObject, handles);
logging('Started');
start(handles.logTimer)

fprintf(lcvrObj,'enable=1');
fscanf(lcvrObj);
logging('LCVR output on');

calllib('libandor','CoolerON');
setTemp=str2double(get(handles.camTempBox,'String'));
error=calllib('libandor','SetTemperature',setTemp);
logging('Camera cooling on');


% UIWAIT makes vControl wait for user response (see UIRESUME)
% uiwait(handles.vCamGui);


% --- Outputs from this function are returned to the command line.
function varargout = vControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnStartVid.
function btnStartVid_Callback(hObject, eventdata, handles)
% hObject    handle to btnStartVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'string') % Get Tag of selected object.
    case 'Start Video'
        start(handles.vidTimer)
        set(handles.textStatusBox,'string','Displaying live video')
        set(hObject,'String','Stop Video')
        calllib('libandor','StartAcquisition');
        enCamControls(handles,'off')
        logging('Started Video');
    case 'Stop Video'
        stop(handles.vidTimer)
        calllib('libandor','AbortAcquisition');
        set(handles.textStatusBox,'string','Idle')
        set(hObject,'String','Start Video')
        enCamControls(handles,'on')
        logging('Stopped Video');
end


%Testing:
%emGain=libpointer('int32Ptr',0);
%calllib('libandor','GetEMCCDGain',emGain);
%disp(emGain.value)


% START USER CODE

function update_display(hObject,eventdata,hfigure)
% vidTimer callback
% Update video display

handles = guidata(hfigure);
imWidth=getappdata(handles.vCamGui,'imWidth');
imHeight=getappdata(handles.vCamGui,'imHeight');
nPixels=imWidth*imHeight;
imPtr = libpointer('int32Ptr',zeros(imWidth,imHeight));
calllib('libandor','GetMostRecentImage',imPtr,nPixels);
im=imPtr.value;

% Subtract stored image if required
if get(handles.subtimChk,'Value') == 1.0 
    im = im - getappdata(handles.vCamGui,'storedImage');
end

% Do clipping
clipHi=str2num(get(handles.textClipHi,'string'));
clipLo=str2num(get(handles.textClipLow,'string'));
if clipHi ~= 0
    im = min(im,clipHi);
end
if clipLo ~= 0
    im = max(im,clipLo);
end

im=single(im);

% Do log view
logview=get(handles.logviewcheck,'Value');
if logview==1
    im = log(im);
end
% print stats
pp=quantile(im(:), [1,0.95,0.2]);
set(handles.maxfluxtxt,'String',strcat('Max:',32,num2str(pp(1)),13,10,'P95%:',32,num2str(pp(2)),13,10,'P20%:',32,num2str(pp(3))));

imagesc(im,'Parent',handles.axesMainVideo)
set(handles.axesMainVideo,'XTickLabel','')
set(handles.axesMainVideo,'YTickLabel','')
%timeTaken=get(handles.vidTimer,'InstantPeriod');
%disp(1/timeTaken)
 
if getappdata(handles.vCamGui,'snapshotStatus') == 1
    FWNames=get(handles.filterWheelMenu,'string');
    maskNames=get(handles.maskNameMenu,'string');
    [dummy,time]=system('echo $(date -u +''%Y%m%dT%H%M%S'')');
    snapshotfilename=['/data/snapshots/' time(1:15) '_' FWNames{get(handles.filterWheelMenu,'Value')} '_' maskNames{get(handles.maskNameMenu,'Value')} '.fits'];
    fits_write(snapshotfilename,im)
    setappdata(handles.vCamGui,'snapshotStatus',0)
end


% Make Line Profile
lineProfStart=getappdata(handles.vCamGui,'lineProfStart');
lineProfEnd=getappdata(handles.vCamGui,'lineProfEnd');
lineProf=improfile(double(im),[lineProfStart(2),lineProfEnd(2)],...
        [lineProfStart(1),lineProfEnd(1)],'bilinear');
plot(lineProf,'Parent',handles.axesLineProfile)
lineProfYMax=str2num(get(handles.lineProfYMaxBox,'string'));
if logview==1
    lineProfYMax = log(lineProfYMax);
end
axis(handles.axesLineProfile,[0,imWidth,0,lineProfYMax]);
axis(handles.axesLineProfile,'auto x');

if get(handles.showLineBox,'Value')==1
    hold(handles.axesMainVideo,'on')
    plot([lineProfStart(2),lineProfEnd(2)],[lineProfStart(1),lineProfEnd(1)]...
        ,'r','Parent',handles.axesMainVideo)
    hold(handles.axesMainVideo,'off')
end

% Show box flux
%boxsz=50;

%numframeavs=50;
%boxAvCount=getappdata(handles.vCamGui,'boxAvCount');
%box1Fluxes=getappdata(handles.vCamGui,'box1fluxes');
%box2Fluxes=getappdata(handles.vCamGui,'box2fluxes');

%boxCnt=getappdata(handles.vCamGui,'boxCenter');
%boxCnt2=getappdata(handles.vCamGui,'boxCenter2');
%flux=sum(sum(double(im((boxCnt(1)-boxsz/2):(boxCnt(1)+boxsz/2-1),(boxCnt(2)-boxsz/2):(boxCnt(2)+boxsz/2-1)))));
%%set(handles.boxFluxText,'String',num2str(flux));
%flux2=sum(sum(double(im((boxCnt2(1)-boxsz/2):(boxCnt2(1)+boxsz/2-1),(boxCnt2(2)-boxsz/2):(boxCnt2(2)+boxsz/2-1)))));
%%set(handles.boxFluxText2,'String',num2str(flux2));

%box1Fluxes=box1Fluxes + flux;
%box2Fluxes=box2Fluxes + flux2;

%if boxAvCount == numframeavs
%    box1Fluxes=box1Fluxes/numframeavs;
%    box2Fluxes=box2Fluxes/numframeavs;
%    set(handles.boxFluxText,'String',num2str(box1Fluxes));
%    set(handles.boxFluxText2,'String',num2str(box2Fluxes));
%    setappdata(handles.vCamGui,'boxAvCount',0);
%    setappdata(handles.vCamGui,'box1fluxes',0);
%    setappdata(handles.vCamGui,'box2fluxes',0);
%else
%    setappdata(handles.vCamGui,'boxAvCount',boxAvCount+1);
%    setappdata(handles.vCamGui,'box1fluxes',box1Fluxes);
%    setappdata(handles.vCamGui,'box2fluxes',box2Fluxes);
%end

%disp(rand)

function update_values(hObject,eventdata,hfigure)
% valTimer callback
% Update text values
handles = guidata(hfigure);

% LCVR Temperature display
% Query at the end and read at the beginnig, to avoid waiting...
tcObj=getappdata(handles.vCamGui,'tcObj');
%fprintf(tcObj,'tact?');
fscanf(tcObj);
curTemp=fscanf(tcObj);
curTemp=str2num(curTemp(1:5));
setappdata(handles.vCamGui,'curTemp',curTemp)
set(handles.lcvrTempDisp,'string',num2str(curTemp))
fprintf(tcObj,'tact?');

% Camera temperature display
curTempPtr=libpointer('int32Ptr',0);
tempError=calllib('libandor','GetTemperature',curTempPtr);
curTemp=curTempPtr.value;
set(handles.camTempDisp,'string',num2str(curTemp))
if tempError == 20036 %stabilised
    set(handles.camTempDisp,'ForegroundColor',[0 1 0])
else
    set(handles.camTempDisp,'ForegroundColor',[1 0 0])
end

% Conex4 (pQWP1) angle display
conex4Obj=getappdata(handles.vCamGui,'conex4Obj');
fprintf(conex4Obj,'1TP?');
output=fscanf(conex4Obj);
output=strrep(output,'1TP','');
wpAngle=str2num(output) - getappdata(handles.vCamGui,'pqwp1CalOffset'); 
set(handles.conex4AngleDisp,'string',num2str(wpAngle))

% Conex1 (pQWP2) angle display
conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
fprintf(conex1Obj,'1TP?');
output=fscanf(conex1Obj);
output=strrep(output,'1TP','');
wpAngle=str2num(output) - getappdata(handles.vCamGui,'pqwp2CalOffset'); 
set(handles.conex1AngleDisp,'string',num2str(wpAngle))

% Conex2 (Filter wheel) angle display
conex2Obj=getappdata(handles.vCamGui,'conex2Obj');
fprintf(conex2Obj,'1TP?');
output=fscanf(conex2Obj);
output=strrep(output,'1TP','');
set(handles.conex2AngleDisp,'string',output)

% Cursor position
curCurs=get(handles.axesMainVideo,'currentpoint');
set(handles.clickLocX,'String',num2str(curCurs(1,1)))
set(handles.clickLocY,'String',num2str(curCurs(1,2)))

% Conex3 (Polariser) angle display
conex3Obj=getappdata(handles.vCamGui,'conex3Obj');
fprintf(conex3Obj,'1TP?');
output=fscanf(conex3Obj);
output=strrep(output,'1TP','');
polaAngle=str2num(output) - getappdata(handles.vCamGui,'polaCalOffset');
set(handles.polaAngleDisp,'string',num2str(polaAngle))


function log_values(hObject,eventdata,hfigure)
% valTimer callback
handles = guidata(hfigure);

% LCVR Temperature display
tcObj=getappdata(handles.vCamGui,'tcObj');
fscanf(tcObj);
curTemp=fscanf(tcObj);
logging(strcat('LCVR temp:',32,curTemp(1:5)),'monitoring');
fprintf(tcObj,'tact?');

% Camera temperature display
curTempPtr=libpointer('int32Ptr',0);
tempError=calllib('libandor','GetTemperature',curTempPtr);
logging(strcat('Camera temp:', 32, num2str(curTempPtr.value)), 'monitoring');

% Conex4 (pQWP1) angle display
conex4Obj=getappdata(handles.vCamGui,'conex4Obj');
fprintf(conex4Obj,'1TP?');
output=strrep(fscanf(conex4Obj),'1TP','');
wpAngle=str2num(output) - getappdata(handles.vCamGui,'pqwp1CalOffset'); 
logging(strcat('Conex 4 (QWP1) angle:',32,num2str(wpAngle),', (abs:',32,output,')'),'monitoring');

% Conex1 (pQWP2) angle display
conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
fprintf(conex1Obj,'1TP?');
output=fscanf(conex1Obj);
output=strrep(output,'1TP','');
wpAngle=str2num(output) - getappdata(handles.vCamGui,'pqwp2CalOffset'); 
logging(strcat('Conex 1 (QWP2) angle:',32,num2str(wpAngle),', (abs:',32,output,')'),'monitoring');

% Conex2 (Filter wheel) angle display
conex2Obj=getappdata(handles.vCamGui,'conex2Obj');
fprintf(conex2Obj,'1TP?');
output=fscanf(conex2Obj);
output=strrep(output,'1TP','');
logging(strcat('Conex 2 (FilterW) angle:',32,output),'monitoring');

% Cursor position
curCurs=get(handles.axesMainVideo,'currentpoint');
set(handles.clickLocX,'String',num2str(curCurs(1,1)))
set(handles.clickLocY,'String',num2str(curCurs(1,2)))

% Conex3 (Polariser) angle display
conex3Obj=getappdata(handles.vCamGui,'conex3Obj');
fprintf(conex3Obj,'1TP?');
output=fscanf(conex3Obj);
output=strrep(output,'1TP','');
polaAngle=str2num(output) - getappdata(handles.vCamGui,'polaCalOffset');
logging(strcat('Conex 3 (Pol) angle:',32,num2str(polaAngle),', (abs:',32,output,')'),'monitoring');

% END USER CODE


% --- Executes on button press in btn_Exit.
function btn_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Switching off the Beast')

setappdata(handles.vCamGui,'vidRunFlag',0)
% Close shutter
error=calllib('libandor','SetShutter',0,2,10,10);
calllib('libandor','CoolerOFF');

error=calllib('libandor','ShutDown');
unloadlibrary libandor;

stop(handles.valTimer)

stop(handles.logTimer)

% Close USB serial ports
if getappdata(handles.vCamGui,'lcvrOn') == 1
    lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
    fclose(lcvrObj);
    delete(lcvrObj);
end

if getappdata(handles.vCamGui,'tcOn') == 1
    tcObj=getappdata(handles.vCamGui,'tcObj');
    fclose(tcObj);
    delete(tcObj);
end

if getappdata(handles.vCamGui,'FWOn') == 1
    fwObj=getappdata(handles.vCamGui,'fwObj');
    fclose(fwObj);
    delete(fwObj);
end

if getappdata(handles.vCamGui,'arduinoOn') == 1
    arduinoObj=getappdata(handles.vCamGui,'arduinoObj');
    fclose(arduinoObj);
    delete(arduinoObj);
end

if getappdata(handles.vCamGui,'conex1On') == 1
    conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
    fclose(conex1Obj);
    delete(conex1Obj);
end

if getappdata(handles.vCamGui,'conex2On') == 1
    conex2Obj=getappdata(handles.vCamGui,'conex2Obj');
    fclose(conex2Obj);
    delete(conex2Obj);
end

if getappdata(handles.vCamGui,'conex3On') == 1
    conex3Obj=getappdata(handles.vCamGui,'conex3Obj');
    fclose(conex3Obj);
    delete(conex3Obj);
end

if getappdata(handles.vCamGui,'conex4On') == 1
    conex4Obj=getappdata(handles.vCamGui,'conex4Obj');
    fclose(conex4Obj);
    delete(conex4Obj);
end

if getappdata(handles.vCamGui,'PRMOn') == 1
    prmObj=getappdata(handles.vCamGui,'prmObj');
    fclose(prmObj);
    delete(prmObj);
end

if getappdata(handles.vCamGui,'zabersOn') == 1
    zabersObj=getappdata(handles.vCamGui,'zabersObj');
    fclose(zabersObj);
    delete(zabersObj);
end
delete(handles.vCamGui)
disp('Bye')
logging('Finished');



% --- Executes during object creation, after setting all properties.
function textClipHi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textClipHi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textClipLow_Callback(hObject, eventdata, handles)
% hObject    handle to textClipLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function textClipLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textClipLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in ReadoutModeBtns.
function ReadoutModeBtns_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ReadoutModeBtns 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'NFTBtn'
        error=calllib('libandor','SetFrameTransferMode',0);
        set(handles.expTimeLabel,'Enable','on')
        set(handles.expTimeBox,'Enable','on')
        ExpTime=getappdata(handles.vCamGui,'ExpTime');
        calllib('libandor','SetExposureTime',ExpTime);
        setappdata(handles.vCamGui,'readoutMode',0)
        
    case 'FTBtn'
        error=calllib('libandor','SetFrameTransferMode',1);
        setappdata(handles.vCamGui,'readoutMode',1)
        if (getappdata(handles.vCamGui,'triggerMode') == 1)
            set(handles.expTimeLabel,'Enable','off')
            set(handles.expTimeBox,'Enable','off')
            calllib('libandor','SetExposureTime',0);
        end
end



function expTimeBox_Callback(hObject, eventdata, handles)
% hObject    handle to expTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expTimeBox as text
%        str2double(get(hObject,'String')) returns contents of expTimeBox as a double
expTime=str2double(get(hObject,'String'));
setappdata(handles.vCamGui,'ExpTime',expTime)
calllib('libandor','SetExposureTime',expTime);
logging(strcat('Set int time to:',32,num2str(expTime)));



% --- Executes during object creation, after setting all properties.
function expTimeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function emGainBox_Callback(hObject, eventdata, handles)
% hObject    handle to emGainBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emGainBox as text
%        str2double(get(hObject,'String')) returns contents of emGainBox as a double
emGain=str2double(get(hObject,'String'));
setappdata(handles.vCamGui,'emGain',emGain)
calllib('libandor','SetEMCCDGain',emGain);
logging(strcat('Set em gain to:',32,num2str(emGain)));


% --- Executes during object creation, after setting all properties.
function emGainBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emGainBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HSSpeedBox_Callback(hObject, eventdata, handles)
% hObject    handle to HSSpeedBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HSSpeedBox as text
%        str2double(get(hObject,'String')) returns contents of HSSpeedBox as a double
HSSpeed=str2double(get(hObject,'String'));
setappdata(handles.vCamGui,'HSSpeed',HSSpeed)
calllib('libandor','SetHSSpeed',0,HSSpeed);


% --- Executes during object creation, after setting all properties.
function HSSpeedBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HSSpeedBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VSSpeedBox_Callback(hObject, eventdata, handles)
% hObject    handle to VSSpeedBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VSSpeedBox as text
%        str2double(get(hObject,'String')) returns contents of VSSpeedBox as a double
VSSpeed=str2double(get(hObject,'String'));
setappdata(handles.vCamGui,'VSSpeed',VSSpeed)
calllib('libandor','SetVSSpeed',VSSpeed);

% --- Executes during object creation, after setting all properties.
function VSSpeedBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VSSpeedBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VSVoltsBox_Callback(hObject, eventdata, handles)
% hObject    handle to VSVoltsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VSVoltsBox as text
%        str2double(get(hObject,'String')) returns contents of VSVoltsBox as a double
VSVolts=str2double(get(hObject,'String'));
setappdata(handles.vCamGui,'VSVolts',VSVolts)
calllib('libandor','SetVSAmplitude',VSVolts);

% --- Executes during object creation, after setting all properties.
function VSVoltsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VSVoltsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cycTimeBox_Callback(hObject, eventdata, handles)
% hObject    handle to cycTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cycTimeBox as text
%        str2double(get(hObject,'String')) returns contents of cycTimeBox as a double
cycTime=str2double(get(hObject,'String'));
setappdata(handles.vCamGui,'kinCycleTime',cycTime)
calllib('libandor','SetKineticCycleTime',cycTime);

%Print the actual cycle time - for now just to console.
actualExp=libpointer('singlePtr',0);
actualAcc=libpointer('singlePtr',0);
actualCyc=libpointer('singlePtr',0);
error=calllib('libandor','GetAcquisitionTimings',actualExp,actualAcc,actualCyc);
disp(strcat('Actual cycle time: ',num2str(actualCyc.value)))
logging(strcat('Actual cycle time: ',32,num2str(actualCyc.value)));

%Tell us about the preamp gain
nGains=libpointer('int32Ptr',0);
error=calllib('libandor','GetNumberPreAmpGains',nGains);
disp(strcat('Number preamp gains: ',num2str(nGains.value)))
logging(strcat('Number preamp gains: ',32,num2str(nGains.value)))
% gainIndex=0;
% gainVal=libpointer('singlePtr',0);
% error=calllib('libandor','GetPreAmpGain',gainIndex,gainVal);
% disp(strcat('Gain for index ',num2str(gainIndex), ': ',num2str(gainVal.value)))
% gainIndex=1;
% gainVal=libpointer('singlePtr',0);
% error=calllib('libandor','GetPreAmpGain',gainIndex,gainVal);
% disp(strcat('Gain for index ',num2str(gainIndex), ': ',num2str(gainVal.value)))
% gainIndex=2;
% gainVal=libpointer('singlePtr',0);
% error=calllib('libandor','GetPreAmpGain',gainIndex,gainVal);
% disp(strcat('Gain for index ',num2str(gainIndex), ': ',num2str(gainVal.value)))


% --- Executes during object creation, after setting all properties.
function cycTimeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cycTimeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numFramesBox_Callback(hObject, eventdata, handles)
% hObject    handle to numFramesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numFramesBox as text
%        str2double(get(hObject,'String')) returns contents of numFramesBox as a double
numFrames=str2double(get(hObject,'String'));
setappdata(handles.vCamGui,'numKinetics',numFrames)
calllib('libandor','SetNumberKinetics',numFrames);


% --- Executes during object creation, after setting all properties.
function numFramesBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numFramesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in TriggerPanel.
function TriggerPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in TriggerPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'intBtn'
        error=calllib('libandor','SetTriggerMode',0);
        set(handles.cycTimeLabel,'Enable','on')
        set(handles.cycTimeBox,'Enable','on')
        
        set(handles.expTimeLabel,'Enable','on')
        set(handles.expTimeBox,'Enable','on')
        ExpTime=getappdata(handles.vCamGui,'ExpTime');
        calllib('libandor','SetExposureTime',ExpTime);
        
        setappdata(handles.vCamGui,'triggerMode',0)
    case 'extBtn'
        error=calllib('libandor','SetTriggerMode',1);
        set(handles.cycTimeLabel,'Enable','off')
        set(handles.cycTimeBox,'Enable','off')
        setappdata(handles.vCamGui,'triggerMode',1)
        if (getappdata(handles.vCamGui,'readoutMode') == 1)
            set(handles.expTimeLabel,'Enable','off')
            set(handles.expTimeBox,'Enable','off')
            calllib('libandor','SetExposureTime',0);
        end
        
        
end


% --- Executes on button press in acquireCubeBtn.
function acquireCubeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to acquireCubeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nLoops=str2num(get(handles.loopBox,'String'));

logging(strcat('Acquisition cube starting, loops:',32,num2str(nLoops)))

% Stop video if necessary
wasRunning = 0;
if strcmp(get(handles.vidTimer, 'Running'), 'on')
    stop(handles.vidTimer)
    calllib('libandor','AbortAcquisition');
    set(handles.textStatusBox,'string','Idle')
    wasRunning = 1;
end

for loops = 1:nLoops

% Set the filename
FWNames=get(handles.filterWheelMenu,'string');
maskNames=get(handles.maskNameMenu,'string');
filename=[getappdata(handles.vCamGui,'savefolder') get(handles.fileNameBox,'String') '_' FWNames{get(handles.filterWheelMenu,'Value')} '_' maskNames{get(handles.maskNameMenu,'Value')} '_'];
incr=0;
while 1
    if exist(strcat(filename,num2str(incr),'.fits')) == 0
        break
    end
    incr = incr + 1;
end
filename = strcat(filename,num2str(incr));

% Perform Kinetic Series acquisition, spool to file
error=calllib('libandor','SetAcquisitionMode',3);
error=calllib('libandor','SetSpool',1,5,filename,10);

numFrames=getappdata(handles.vCamGui,'numKinetics');
calllib('libandor','SetNumberKinetics',numFrames);

error=calllib('libandor','StartAcquisition');

status = 20072; %Initialise with state 'DRV_ACQUIRING'
        while status == 20072
            statptr=libpointer('int32Ptr',0);
            error=calllib('libandor','GetStatus',statptr);
            status=statptr.value;
            
            imsacqptr=libpointer('int32Ptr',0);
            error=calllib('libandor','GetTotalNumberImagesAcquired',imsacqptr);
            statString=['Acquiring single cube - ' num2str(imsacqptr.value) ...
                 ' images acquired.'];
            set(handles.textStatusBox,'string',statString)
            
            if getappdata(handles.vCamGui,'abortStatus') == 1
                status = 0;
                error=calllib('libandor','AbortAcquisition');
                setappdata(handles.vCamGui,'abortStatus',0)
            end
            
            pause(0.1)
        end


error=calllib('libandor','SetSpool',0,5,'fitsspoolfile',10);
error=calllib('libandor','SetAcquisitionMode',5);
set(handles.textStatusBox,'string','Idle')
logging('Acquisition 1 cube finished')

pause(0.1)
end

%Go back to live video if necessary
if wasRunning == 1
    start(handles.vidTimer)
    set(handles.textStatusBox,'string','Displaying live video')
    calllib('libandor','StartAcquisition');
end


function fileNameBox_Callback(hObject, eventdata, handles)
% hObject    handle to fileNameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileNameBox as text
%        str2double(get(hObject,'String')) returns contents of fileNameBox as a double
filename=strcat('/',strrep(get(hObject,'String'),' ',''));
pos=length(filename)-strfind(fliplr(filename),'/')+2;
filename=filename(pos:(length(filename)));
set(hObject,'String',filename);
logging(strcat('Output file set to:',32,filename));


% --- Executes during object creation, after setting all properties.
function fileNameBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function enCamControls(handles,state)
% Hide or show Camera Controls
% State is 'off' or 'on'
set(handles.NFTBtn,'Enable',state)
set(handles.FTBtn,'Enable',state)
set(handles.expTimeBox,'Enable',state)
set(handles.expTimeLabel,'Enable',state)
set(handles.emGainBox,'Enable',state)
set(handles.emGainLabel,'Enable',state)
set(handles.HSSpeedBox,'Enable',state)
set(handles.HSSpeedLabel,'Enable',state)
set(handles.VSSpeedBox,'Enable',state)
set(handles.VSSpeedLabel,'Enable',state)
set(handles.VSVoltsBox,'Enable',state)
set(handles.VSVoltsLabel,'Enable',state)
set(handles.intBtn,'Enable',state)
set(handles.extBtn,'Enable',state)
set(handles.cycTimeLabel,'Enable',state)
set(handles.cycTimeBox,'Enable',state)
set(handles.numFramesLabel,'Enable',state)
set(handles.numFramesBox,'Enable',state)


% --- Executes on button press in setLineBtn.
function setLineBtn_Callback(hObject, eventdata, handles)
% hObject    handle to setLineBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stop(handles.vidTimer)
oldStatus=get(handles.textStatusBox,'string');
set(handles.textStatusBox,'string','Click the start and end points, then press ENTER')
[x,y]=getpts(handles.axesMainVideo);
setappdata(handles.vCamGui,'lineProfStart',[y(1),x(1)])
setappdata(handles.vCamGui,'lineProfEnd',[y(2),x(2)])
set(handles.textStatusBox,'String',oldStatus)
start(handles.vidTimer)


function lineProfYMaxBox_Callback(hObject, eventdata, handles)
% hObject    handle to lineProfYMaxBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lineProfYMaxBox as text
%        str2double(get(hObject,'String')) returns contents of lineProfYMaxBox as a double



% --- Executes during object creation, after setting all properties.
function lineProfYMaxBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineProfYMaxBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showLineBox.
function showLineBox_Callback(hObject, eventdata, handles)
% hObject    handle to showLineBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showLineBox



function lcvrV1Box_Callback(hObject, eventdata, handles)
% hObject    handle to lcvrV1Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
lcvrV1=str2double(get(hObject,'String'));
fprintf(lcvrObj,strcat('volt1=',num2str(lcvrV1)));
fscanf(lcvrObj);
logging(strcat('LCVR V1 set to:',32,get(hObject,'String')))


% --- Executes during object creation, after setting all properties.
function lcvrV1Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcvrV1Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lcvrV2Box_Callback(hObject, eventdata, handles)
% hObject    handle to lcvrV2Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
lcvrV2=str2double(get(hObject,'String'));
fprintf(lcvrObj,strcat('volt2=',num2str(lcvrV2)));
fscanf(lcvrObj);
logging(strcat('LCVR V2 set to:',32,get(hObject,'String')))

% --- Executes during object creation, after setting all properties.
function lcvrV2Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcvrV2Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lcvrFreqBox_Callback(hObject, eventdata, handles)
% hObject    handle to lcvrFreqBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
lcvrFreq=str2double(get(hObject,'String'));
fprintf(lcvrObj,strcat('freq=',num2str(lcvrFreq)));
fscanf(lcvrObj);


% --- Executes during object creation, after setting all properties.
function lcvrFreqBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcvrFreqBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in lcvrOuputBtns.
function lcvrOuputBtns_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in lcvrOuputBtns 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'lcvrEn'
        fprintf(lcvrObj,'enable=1');
        fscanf(lcvrObj);
        logging('LCVR output on');
    case 'lcvrDis'
        fprintf(lcvrObj,'enable=0');
        fscanf(lcvrObj);
        logging('LCVR output off');
end


% --- Executes when selected object is changed in lcvrModBtns.
function lcvrModBtns_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in lcvrModBtns 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'lcvrModV1'
        fprintf(lcvrObj,'mode=1');
        fscanf(lcvrObj);
        fprintf(lcvrObj,'extern=0');
        fscanf(lcvrObj);
        
    case 'lcvrModV2'
        fprintf(lcvrObj,'mode=2');
        fscanf(lcvrObj);
        fprintf(lcvrObj,'extern=0');
        fscanf(lcvrObj);
           
    case 'lcvrModInt'
        fprintf(lcvrObj,'mode=0');
        fscanf(lcvrObj);
        fprintf(lcvrObj,'extern=0');
        fscanf(lcvrObj);
        
    case 'lcvrModExt'
        fprintf(lcvrObj,'extern=1');
        fscanf(lcvrObj);

end


% --- Executes on button press in arduinoTalkBtn.
function arduinoTalkBtn_Callback(hObject, eventdata, handles)
% hObject    handle to arduinoTalkBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

arduinoObj=getappdata(handles.vCamGui,'arduinoObj');
% fprintf(arduinoObj,'run');
% output=fscanf(arduinoObj);
% disp(output)
% output=fscanf(arduinoObj);
% disp(output)
fprintf(arduinoObj,'upd t_int 0.02');
%fprintf(arduinoObj,'upd n_int 1');
output=fscanf(arduinoObj); %Actual output returned
disp(output)

conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
fprintf(conex1Obj,'1ZT?');
output=fscanf(conex1Obj); %Actual output returned
disp(output)



function lcvrTempBox_Callback(hObject, eventdata, handles)
% hObject    handle to lcvrTempBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcvrTempBox as text
%        str2double(get(hObject,'String')) returns contents of lcvrTempBox as a double
tcObj=getappdata(handles.vCamGui,'tcObj');
setTemp=str2double(get(hObject,'String'));
fprintf(tcObj,strcat('tset=',num2str(setTemp))); fscanf(tcObj);
logging(strcat('LCVR temp set to:',32,num2str(setTemp)));

% --- Executes during object creation, after setting all properties.
function lcvrTempBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcvrTempBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in TCCPanel.
function TCCPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in TCCPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
tcObj=getappdata(handles.vCamGui,'tcObj');
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'tcOnBtn'
        enableTC(handles);
        logging('LCVR temp on');
    case 'tcOffBtn'
        disableTC(handles);
        logging('LCVR temp off');
end
        

function enableTC(handles)
% Enable the TC
tcObj=getappdata(handles.vCamGui,'tcObj');
% Check status byte
fprintf(tcObj,'stat?'); a=fscanf(tcObj);
tcStatusByte=fscanf(tcObj,'%c',2);
tcStatusByte=hex2dec(tcStatusByte);
enStat=bitget(tcStatusByte,1);
if enStat == 0
    fprintf(tcObj,'ens'); %Toggle enable state
    fscanf(tcObj);
end

function disableTC(handles)
% Enable the TC
tcObj=getappdata(handles.vCamGui,'tcObj');
% Check status byte
fprintf(tcObj,'stat?'); a=fscanf(tcObj);
tcStatusByte=fscanf(tcObj,'%c',2);
tcStatusByte=hex2dec(tcStatusByte);
enStat=bitget(tcStatusByte,1);
if enStat == 1
    fprintf(tcObj,'ens'); %Toggle enable state
    fscanf(tcObj);
end


% --- Executes on button press in calibrateLCVRBtn.
function calibrateLCVRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to calibrateLCVRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stop video if necessary
wasRunning = 0;
if strcmp(get(handles.vidTimer, 'Running'), 'on')
    stop(handles.vidTimer)
    calllib('libandor','AbortAcquisition');
    set(handles.textStatusBox,'string','Idle')
    wasRunning = 1;
end

set(handles.textStatusBox,'string','Click center of V1-bright image and press enter.')
[x,y]=getpts(handles.axesMainVideo);
set(handles.textStatusBox,'string','Performing LCVR Calibration')

logging('Start cal LCVR')

% Call the LCVR Cal function
% This will find the voltage and save it to the appropriate field in
% filterTable.
vControl_LCVRCalFn(handles,x,y,wasRunning,handles.vCamGui);




% set(handles.textStatusBox,'string','Idle')
% %Go back to live video if necessary
% if wasRunning == 1
%     calllib('libandor','StartAcquisition');
%     start(handles.vidTimer)
%     set(handles.textStatusBox,'string','Displaying live video')
% end



function conex1AngleBox_Callback(hObject, eventdata, handles)
% hObject    handle to conex1AngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of conex1AngleBox as text
%        str2double(get(hObject,'String')) returns contents of conex1AngleBox as a double
conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
newAngle=str2double(get(hObject,'String')) + getappdata(handles.vCamGui,'pqwp2CalOffset');
cmndString=strcat('1PA',num2str(newAngle));
%cmndString=strcat('1PR',num2str(newAngle));
fprintf(conex1Obj,cmndString);
logging(strcat('Conex 1 (QWP1) moving to:',32,num2str(newAngle)))

% cmndString=strcat('1TP?');
% fprintf(conex1Obj,cmndString);
% output=fscanf(conex1Obj)


% --- Executes during object creation, after setting all properties.
function conex1AngleBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conex1AngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function conex4AngleBox_Callback(hObject, eventdata, handles)
% hObject    handle to conex4AngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of conex4AngleBox as text
%        str2double(get(hObject,'String')) returns contents of conex4AngleBox as a double
conex4Obj=getappdata(handles.vCamGui,'conex4Obj');
newAngle=str2double(get(hObject,'String')) + getappdata(handles.vCamGui,'pqwp1CalOffset');
cmndString=strcat('1PA',num2str(newAngle));
%cmndString=strcat('1PR',num2str(newAngle));
fprintf(conex4Obj,cmndString);
logging(strcat('Conex 4 (QWP1) moving to:',32,num2str(newAngle)))


% --- Executes during object creation, after setting all properties.
function conex4AngleBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conex4AngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function conex2AngleBox_Callback(hObject, eventdata, handles)
% hObject    handle to conex2AngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of conex2AngleBox as text
%        str2double(get(hObject,'String')) returns contents of conex2AngleBox as a double
conex2Obj=getappdata(handles.vCamGui,'conex2Obj');
newAngle=str2double(get(hObject,'String'));
cmndString=strcat('1PA',num2str(newAngle));
fprintf(conex2Obj,cmndString);
logging(strcat('Conex 2 (MaskW) moving to:',32,num2str(newAngle)))

% --- Executes during object creation, after setting all properties.
function conex2AngleBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conex2AngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timingFileBox_Callback(hObject, eventdata, handles)
% hObject    handle to timingFileBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timingFileBox as text
%        str2double(get(hObject,'String')) returns contents of timingFileBox as a double
logging(strcat('Timing file set to:',32,get(hObject,'String')))


% --- Executes during object creation, after setting all properties.
function timingFileBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timingFileBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exAcqBtn.
function exAcqBtn_Callback(hObject, eventdata, handles)
% hObject    handle to exAcqBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the timing setup and send to Arduino:
%addpath ./TimingSetups
%eval(get(handles.timingFileBox,'string'))
logging(strcat('Execute acquisition start, loops:',32,get(handles.loopBox,'String')))

tFile=fopen(['./TimingSetups/',get(handles.timingFileBox,'string'),'.m']);
t_HLo = textscan(tFile,'t_HLo = %f %*[^\n] ',1);
t_LoH = textscan(tFile,'t_LoH = %f %*[^\n] ',1);
t_int = textscan(tFile,'t_int = %f %*[^\n] ',1);
t_RdO = textscan(tFile,'t_RdO = %f %*[^\n] ',1);
n_int = textscan(tFile,'n_int = %f %*[^\n] ',1);
n_cyc = textscan(tFile,'n_cyc = %f %*[^\n] ',1);
fclose(tFile);
arduinoObj=getappdata(handles.vCamGui,'arduinoObj');
t_HLoStr=['upd t_HLo ',num2str(t_HLo{1})];
fprintf(arduinoObj,t_HLoStr);
fscanf(arduinoObj);
t_LoHStr=['upd t_LoH ',num2str(t_LoH{1})];
fprintf(arduinoObj,t_LoHStr);
fscanf(arduinoObj);
t_intStr=['upd t_int ',num2str(t_int{1})];
fprintf(arduinoObj,t_intStr);
fscanf(arduinoObj);
t_RdOStr=['upd t_RdO ',num2str(t_RdO{1})];
fprintf(arduinoObj,t_RdOStr);
fscanf(arduinoObj);
n_intStr=['upd n_int ',num2str(n_int{1})];
fprintf(arduinoObj,n_intStr);
fscanf(arduinoObj);
n_cycStr=['upd n_cyc ',num2str(n_cyc{1})];
fprintf(arduinoObj,n_cycStr);
fscanf(arduinoObj);


% Set up camera
% Stop video if necessary
wasRunning = 0;
if strcmp(get(handles.vidTimer, 'Running'), 'on')
    stop(handles.vidTimer)
    calllib('libandor','AbortAcquisition');
    set(handles.textStatusBox,'string','Idle')
    wasRunning = 1;
end

% Set the filename
FWNames=get(handles.filterWheelMenu,'string');
maskNames=get(handles.maskNameMenu,'string');
filename=[getappdata(handles.vCamGui,'savefolder') get(handles.fileNameBox,'String') '_' FWNames{get(handles.filterWheelMenu,'Value')} '_' maskNames{get(handles.maskNameMenu,'Value')} '_'];
incr=0;
while 1
    if exist(strcat(filename,num2str(incr),'.fits')) == 0
        break
    end
    incr = incr + 1;
end
filename = strcat(filename,num2str(incr));

% Perform Kinetic Series acquisition, spool to file, ext trigger.
error=calllib('libandor','SetAcquisitionMode',3);
error=calllib('libandor','SetSpool',1,5,filename,10);
error=calllib('libandor','SetTriggerMode',1);
%error=calllib('libandor','SetTriggerMode',7);
%error=calllib('libandor','SetFrameTransferMode',1);
error=calllib('libandor','SetExposureTime',0);

% Set appropriate readout mode
acqRO = getappdata(handles.vCamGui,'acqReadoutMode');
%error=calllib('libandor','SetFrameTransferMode',acqRO);
if acqRO == 0
    error=calllib('libandor','SetFrameTransferMode',0);
    error=calllib('libandor','SetTriggerMode',7);
else
    error=calllib('libandor','SetFrameTransferMode',1);
end
    
%numFrames=10%getappdata(handles.vCamGui,'numKinetics');
numFrames = (n_cyc{1})*(n_int{1})*2;
calllib('libandor','SetNumberKinetics',numFrames);


% Set LCVR to external mode (and turn on)
lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
fprintf(lcvrObj,'enable=1');
fscanf(lcvrObj);
fprintf(lcvrObj,'extern=1');
fscanf(lcvrObj);

%%%% Start acquisition
error=calllib('libandor','StartAcquisition');

fprintf(arduinoObj,'run');
output=fscanf(arduinoObj); %Actual output returned
%disp(output);

status = 20072; %Initialise with state 'DRV_ACQUIRING'
        while status == 20072
            statptr=libpointer('int32Ptr',0);
            error=calllib('libandor','GetStatus',statptr);
            status=statptr.value;
            
            imsacqptr=libpointer('int32Ptr',0);
            error=calllib('libandor','GetTotalNumberImagesAcquired',imsacqptr);
            statString=['Acquiring cube - ' num2str(imsacqptr.value) ...
                 ' images acquired.'];
            set(handles.textStatusBox,'string',statString)
            
            if getappdata(handles.vCamGui,'abortStatus') == 1
                status = 0;
                error=calllib('libandor','AbortAcquisition');
                setappdata(handles.vCamGui,'abortStatus',0)
            end
            
            pause(0.1)
        end

fscanf(arduinoObj); % Arduino reports 'Complete'    
        
error=calllib('libandor','SetSpool',0,5,'fitsspoolfile',10);
error=calllib('libandor','SetAcquisitionMode',5);
error=calllib('libandor','SetTriggerMode',0);
error=calllib('libandor','SetExposureTime',str2num(get(handles.expTimeBox,'string'))); %#ok<*ST2NM>
set(handles.textStatusBox,'string','Idle')

%Go back to live video if necessary
if wasRunning == 1
    start(handles.vidTimer)
    set(handles.textStatusBox,'string','Displaying live video')
    calllib('libandor','StartAcquisition');
end
logging('Execute Acquisition finished')
%Do:
% Restore FT mode
% Restore LCVR mod mode



function camTempBox_Callback(hObject, eventdata, handles)
% hObject    handle to camTempBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of camTempBox as text
%        str2double(get(hObject,'String')) returns contents of camTempBox as a double
setTemp=str2double(get(hObject,'String'));
error=calllib('libandor','SetTemperature',setTemp);
logging(strcat('Camera temp set to:',32,get(hObject,'String')))


% --- Executes during object creation, after setting all properties.
function camTempBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camTempBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in CamCoolPanel.
function CamCoolPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in CamCoolPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'ccOnBtn'
        calllib('libandor','CoolerON');
        setTemp=str2double(get(handles.camTempBox,'String'));
        error=calllib('libandor','SetTemperature',setTemp);
        logging('Camera cooling on');
    case 'ccOffBtn'
        calllib('libandor','CoolerOFF');
        logging('Camera cooling off');
end



function wheelPresetsBox_Callback(hObject, eventdata, handles)
% hObject    handle to wheelPresetsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wheelPresetsBox as text
%        str2double(get(hObject,'String')) returns contents of wheelPresetsBox as a double
wheelFile=get(handles.wheelPresetsBox,'string');
wFile=fopen(['./WheelPresets/',wheelFile,'.txt']);
%maskNames=textscan(wFile,'MaskNames: %s %s %s %s %s %s %*[^\n] ',1);
%maskNames=[maskNames{:}];
textscan(wFile,'%*[^\n] ',1);
nMasks=textscan(wFile,'nmasks: %d %*[^\n] ',1);
nMasks=nMasks{1};
wheelAngs=zeros(nMasks,1);
pupilXs = zeros(nMasks,1);
pupilYs = zeros(nMasks,1);
for ii = 1:nMasks
    %rd=textscan(wFile,'%s %f %f %f %f %f %f %*[^\n] ',1);
    rd=textscan(wFile,'%f %s %f %f %f %*[^\n] ',1);
    %maskNames{ii}=rd{1}{1};
    maskNames{ii}=rd{2}{1};
    wheelAngs(ii)=rd{3};
    pupilXs(ii)=rd{4};
    pupilYs(ii)=rd{5};
end
fclose(wFile);

setappdata(handles.vCamGui,'wheelAngs',wheelAngs);
setappdata(handles.vCamGui,'pupilXs',pupilYs);
setappdata(handles.vCamGui,'pupilYs',pupilYs);
%set(handles.filterWheelMenu,'string',filtNames);
set(handles.maskNameMenu,'string',maskNames);


% --- Executes during object creation, after setting all properties.
function wheelPresetsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wheelPresetsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filterWheelMenu.
function filterNameMenu_Callback(hObject, eventdata, handles)
% hObject    handle to filterWheelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filterWheelMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filterWheelMenu


% --- Executes during object creation, after setting all properties.
function filterNameMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterWheelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in maskNameMenu.
function maskNameMenu_Callback(hObject, eventdata, handles)
% hObject    handle to maskNameMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns maskNameMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from maskNameMenu


% --- Executes during object creation, after setting all properties.
function maskNameMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maskNameMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in moveWheelBtn.
function moveWheelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to moveWheelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%filterVal=get(handles.filterWheelMenu,'Value');
set(handles.moveWheelBtn,'BackgroundColor',[1 0 0])
pause(0.1)

maskVal=get(handles.maskNameMenu,'Value');
wheelAngs=getappdata(handles.vCamGui,'wheelAngs');
newAngle=wheelAngs(maskVal);
conex2Obj=getappdata(handles.vCamGui,'conex2Obj');
cmndString=strcat('1PA',num2str(newAngle));
fprintf(conex2Obj,cmndString);

%filterNames=get(handles.filterWheelMenu,'string');
maskNames=get(handles.maskNameMenu,'string');
%curFilterName=filterNames{filterVal};
curMaskName=maskNames{maskVal};
%setappdata(handles.vCamGui,'curFilterName',curFilterName);
setappdata(handles.vCamGui,'curMaskName',curMaskName);

%Move pupil Zabers
pupilXs=getappdata(handles.vCamGui,'pupilXs');
pupilYs=getappdata(handles.vCamGui,'pupilYs');
pupOffsetLR=getappdata(handles.vCamGui,'globalPupOffsetLR');
pupOffsetUD=getappdata(handles.vCamGui,'globalPupOffsetUD');
pupilX=pupilXs(maskVal) + pupOffsetLR;
pupilY=pupilYs(maskVal) + pupOffsetUD;
moveZabersAbs(handles,4,pupilX);
pause(0.5);
moveZabersAbs(handles,5,pupilY);
pause(0.1);
set(handles.moveWheelBtn,'BackgroundColor',[0.702 0.702 0.702]);
logging(strcat('Moved mask wheel to:',32,curMaskName));



% --- Executes on button press in nudgePlusBtn.
function nudgePlusBtn_Callback(hObject, eventdata, handles)
% hObject    handle to nudgePlusBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nudgeAmt=str2num(get(handles.nudgeAmtBox,'String'));
conex2Obj=getappdata(handles.vCamGui,'conex2Obj');
cmndString=strcat('1PR',num2str(nudgeAmt));
fprintf(conex2Obj,cmndString);


% --- Executes on button press in nudgeMinusBtn.
function nudgeMinusBtn_Callback(hObject, eventdata, handles)
% hObject    handle to nudgeMinusBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nudgeAmt=str2num(get(handles.nudgeAmtBox,'String'));
nudgeAmt=nudgeAmt*-1;
conex2Obj=getappdata(handles.vCamGui,'conex2Obj');
cmndString=strcat('1PR',num2str(nudgeAmt));
fprintf(conex2Obj,cmndString);


function nudgeAmtBox_Callback(hObject, eventdata, handles)
% hObject    handle to nudgeAmtBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nudgeAmtBox as text
%        str2double(get(hObject,'String')) returns contents of nudgeAmtBox as a double


% --- Executes during object creation, after setting all properties.
function nudgeAmtBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nudgeAmtBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function exSeriesBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exSeriesBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exSeriesBtn.
function exSeriesBtn_Callback(hObject, eventdata, handles)
% hObject    handle to exSeriesBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% % Parse the hwp position series
% hwpPosns=str2num(get(handles.exSeriesBtn,'string'));
% nPos=length(hwpPosns);
%%%%%% Currently, manually specify qwp series here %%%%%%%
%%%%% Order is equivalent to HWP = 0, 22.5, 45, 67.5 %%%%%

set(handles.vCamGui,'Color',[0.148 0.031 0.5])

logging(strcat('Execute series start, loops:',32,get(handles.loopBox,'String'),32,'multiangle:',32,get(handles.multiangletxt,'string')));

% Set up camera
% Stop video if necessary
wasRunning = 0;
if strcmp(get(handles.vidTimer, 'Running'), 'on')
    stop(handles.vidTimer)
    calllib('libandor','AbortAcquisition');
    wasRunning = 1;
end

set(handles.textStatusBox,'string','Preparing')
multiangle=str2num(get(handles.multiangletxt,'string'));
nPos=multiangle*4;
ao188hwpPosns=reshape(repmat([0, 22.5, 45, 67.5],multiangle,1),1,nPos);

conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
conex4Obj=getappdata(handles.vCamGui,'conex4Obj');
pqwpTol=getappdata(handles.vCamGui,'pqwpTol');


switch getappdata(handles.vCamGui,'FWName')
    case '775-50'
        qwp1Posns=reshape(repmat([18, 129, 19, 56],multiangle,1),1,nPos);
        qwp2Posns=reshape(repmat([151, 131, 71, 113],multiangle,1),1,nPos);
        qwp1Posnsoptimal=129;
        qwp2Posnsoptimal=131;
    case '625-50'
        qwp1Posns=reshape(repmat([92, 166, 29, 12],multiangle,1),1,nPos);
        qwp2Posns=reshape(repmat([171, 129, 49, 16],multiangle,1),1,nPos);
        qwp1Posnsoptimal=92;
        qwp2Posnsoptimal=171;
    case '725-50'
        qwp1Posns=reshape(repmat([154, 130, 146, 27],multiangle,1),1,nPos);
        qwp2Posns=reshape(repmat([173, 59, 106, 58],multiangle,1),1,nPos);
        qwp1Posnsoptimal=154;
        qwp2Posnsoptimal=173;
end

if getappdata(handles.vCamGui,'polzsource') == 'HWP' % set qwp to good angles if polsource is HWP
    caldAngle1=qwp1Posnsoptimal;
    newAngle=qwp1Posnsoptimal + getappdata(handles.vCamGui,'pqwp1CalOffset');
    cmndString=strcat('1PA',num2str(newAngle));
    fprintf(conex4Obj,cmndString);
    newAngle1=newAngle;
    
    caldAngle2=qwp2Posnsoptimal;
    newAngle=qwp2Posnsoptimal + getappdata(handles.vCamGui,'pqwp2CalOffset');
    cmndString=strcat('1PA',num2str(newAngle));
    fprintf(conex1Obj,cmndString);
    newAngle2=newAngle;
    
    curAngle1=9999;
    curAngle2=9999;
    while ((newAngle1 <= curAngle1-pqwpTol) || (newAngle1 >= curAngle1+pqwpTol)) ...
            || ((newAngle2 <= curAngle2-pqwpTol) || (newAngle2 >= curAngle2+pqwpTol))
        pause(0.5)
 
        fprintf(conex4Obj,'1TP?');
        output=fscanf(conex4Obj);
        output=strrep(output,'1TP','');
        curAngle1=str2num(output);
        
        fprintf(conex1Obj,'1TP?');
        output=fscanf(conex1Obj);
        output=strrep(output,'1TP','');
        curAngle2=str2num(output);
    end

    pause(1)
end


%%%%%% Values for bench testing in August 2014 %%%%
%qwp1Posns=[0, 0, 0, 0];
%qwp2Posns=[0, 0, 0, 0];
%nPos=4;
%qwp1Posns=[0, 22.5, 45, 67.5];
%qwp2Posns=[0, 22.5, 45, 67.5];


% Get the timing setup and send to Arduino:
%addpath ./TimingSetups
%eval(get(handles.timingFileBox,'string'))
tFile=fopen(['./TimingSetups/',get(handles.timingFileBox,'string'),'.m']);
timingFile=get(handles.timingFileBox,'string');
t_HLo = textscan(tFile,'t_HLo = %f %*[^\n] ',1);
t_LoH = textscan(tFile,'t_LoH = %f %*[^\n] ',1);
t_int = textscan(tFile,'t_int = %f %*[^\n] ',1);
t_RdO = textscan(tFile,'t_RdO = %f %*[^\n] ',1);
n_int = textscan(tFile,'n_int = %f %*[^\n] ',1);
n_cyc = textscan(tFile,'n_cyc = %f %*[^\n] ',1);
fclose(tFile);
arduinoObj=getappdata(handles.vCamGui,'arduinoObj');
t_HLoStr=['upd t_HLo ',num2str(t_HLo{1})];
fprintf(arduinoObj,t_HLoStr);
fscanf(arduinoObj);
t_LoHStr=['upd t_LoH ',num2str(t_LoH{1})];
fprintf(arduinoObj,t_LoHStr);
fscanf(arduinoObj);
t_intStr=['upd t_int ',num2str(t_int{1})];
fprintf(arduinoObj,t_intStr);
fscanf(arduinoObj);
t_RdOStr=['upd t_RdO ',num2str(t_RdO{1})];
fprintf(arduinoObj,t_RdOStr);
fscanf(arduinoObj);
n_intStr=['upd n_int ',num2str(n_int{1})];
fprintf(arduinoObj,n_intStr);
fscanf(arduinoObj);
n_cycStr=['upd n_cyc ',num2str(n_cyc{1})];
fprintf(arduinoObj,n_cycStr);
fscanf(arduinoObj);


% Perform Kinetic Series acquisition, spool to file, ext trigger.
error=calllib('libandor','SetAcquisitionMode',3);
filename='dummy';
error=calllib('libandor','SetSpool',1,5,filename,10);
error=calllib('libandor','SetTriggerMode',1);
%error=calllib('libandor','SetTriggerMode',7);
%error=calllib('libandor','SetFrameTransferMode',1);
error=calllib('libandor','SetExposureTime',0);

% Set appropriate readout mode
acqRO = getappdata(handles.vCamGui,'acqReadoutMode');
error=calllib('libandor','SetFrameTransferMode',acqRO);

%numFrames=10%getappdata(handles.vCamGui,'numKinetics');
numFrames = (n_cyc{1})*(n_int{1})*2;
calllib('libandor','SetNumberKinetics',numFrames);


% Set LCVR to external mode (and turn on)
lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
fprintf(lcvrObj,'enable=1');
fscanf(lcvrObj);
fprintf(lcvrObj,'extern=1');
fscanf(lcvrObj);

comm=getappdata(handles.vCamGui,'comments');
scomm=size(comm);
scomm=scomm(1);

%%%% Start series
nLoops=str2num(get(handles.loopBox,'String'));
FWNames=get(handles.filterWheelMenu,'string');
maskNames=get(handles.maskNameMenu,'string');
[dummy,time]=system('echo $(date -u +''%Y%m%dT%H%M%S'')');
origfilename=[getappdata(handles.vCamGui,'savefolder') get(handles.fileNameBox,'String') '_' time(1:15) '_' FWNames{get(handles.filterWheelMenu,'Value')} '_' maskNames{get(handles.maskNameMenu,'Value')} '_'];
file_num=0;

for sloop=1:nLoops
for posn = 1:nPos
    
    % Set the filename
    filename = strcat(origfilename, num2str(file_num));
    file_num = file_num + 1;
    
    error=calllib('libandor','SetSpool',1,5,filename,10);
    
    %%%%%%%%%%%%%%%%% Commented out when QWPs installed %%%%%%%%
    % Set HWP
%     caldAngle=hwpPosns(posn);
%     newAngle=hwpPosns(posn) + getappdata(handles.vCamGui,'hwpCalOffset');
%     cmndString=strcat('1PA',num2str(newAngle));
%     fprintf(conex1Obj,cmndString);
%     
%     curAngle=9999;
%     while (newAngle <= curAngle-hwpTol) || (newAngle >= curAngle+hwpTol)
%         pause(0.5)
%         fprintf(conex1Obj,'1TP?');
%         output=fscanf(conex1Obj);
%         output=strrep(output,'1TP','');
%         curAngle=str2num(output);
%     end
%     pause(1)
    if getappdata(handles.vCamGui,'polzsource') == 'QWP'
        % Set QWP1
        caldAngle1=qwp1Posns(posn);
        newAngle=qwp1Posns(posn) + getappdata(handles.vCamGui,'pqwp1CalOffset');
        cmndString=strcat('1PA',num2str(newAngle));
        fprintf(conex4Obj,cmndString);
        newAngle1=newAngle;

    %     curAngle=9999;
    %     while (newAngle <= curAngle-pqwpTol) || (newAngle >= curAngle+pqwpTol)
    %         pause(0.5)
    %         fprintf(conex4Obj,'1TP?');
    %         output=fscanf(conex4Obj);
    %         output=strrep(output,'1TP','');
    %         curAngle=str2num(output);
    %     end
        pause(1)

        % Set QWP2
        caldAngle2=qwp2Posns(posn);
        newAngle=qwp2Posns(posn) + getappdata(handles.vCamGui,'pqwp2CalOffset');
        cmndString=strcat('1PA',num2str(newAngle));
        fprintf(conex1Obj,cmndString);
        newAngle2=newAngle;

    %    curAngle=9999;
    %     while (newAngle <= curAngle-pqwpTol) || (newAngle >= curAngle+pqwpTol)
    %         pause(0.5)
    %         fprintf(conex1Obj,'1TP?');
    %         output=fscanf(conex1Obj);
    %         output=strrep(output,'1TP','');
    %         curAngle=str2num(output);
    %     end

       curAngle1=9999;
       curAngle2=9999;
        while ((newAngle1 <= curAngle1-pqwpTol) || (newAngle1 >= curAngle1+pqwpTol)) ...
                || ((newAngle2 <= curAngle2-pqwpTol) || (newAngle2 >= curAngle2+pqwpTol))
            pause(0.5)


            fprintf(conex4Obj,'1TP?');
            output=fscanf(conex4Obj);
            output=strrep(output,'1TP','');
            curAngle1=str2num(output);

            fprintf(conex1Obj,'1TP?');
            output=fscanf(conex1Obj);
            output=strrep(output,'1TP','');
            curAngle2=str2num(output);
        end


        pause(1)
    end

    if getappdata(handles.vCamGui,'polzsource') == 'HWP'
        dummy=system(['ssh ircs@garde.sum.naoj.org "echo hwp move ' num2str(ao188hwpPosns(posn)) ' | nc localhost 18902"']);
        if posn == 1
            pause(3+1) % already in place, 3 max wait +1 security
        else
            pause(abs(ao188hwpPosns(posn-1)-ao188hwpPosns(posn))/67.5*3+1) % optimized waiting time, assuming linear movement of 67.5 degrees in 3 seconds +1 security
        end
    end    
    
    
    % Start Acqusition
    error=calllib('libandor','StartAcquisition');

    fprintf(arduinoObj,'run');
    output=fscanf(arduinoObj); %Actual output returned
    %disp(output);

    currvaliteration = -1;
    status = 20072; %Initialise with state 'DRV_ACQUIRING'
            while status == 20072
                statptr=libpointer('int32Ptr',0);
                error=calllib('libandor','GetStatus',statptr);
                status=statptr.value;

                imsacqptr=libpointer('int32Ptr',0);
                error=calllib('libandor','GetTotalNumberImagesAcquired',imsacqptr);
                if currvaliteration == imsacqptr.value && imsacqptr.value ~= numFrames   % if the loop is stuck, switch to blood color background
                    set(handles.vCamGui,'Color',[0.539 0.027 0.027]);
                end
                statString=['Loop ' num2str(sloop) '/' num2str(nLoops) ' - Pos ' num2str(floor((posn-1)/multiangle)+1) '/' num2str(nPos/multiangle) ' - Cube ' num2str(mod(posn-1,multiangle)+1) '/' num2str(multiangle) ' - Frame ' num2str(imsacqptr.value) '/' num2str(numFrames)];
                currvaliteration = imsacqptr.value;
                set(handles.textStatusBox,'string',statString)

                if getappdata(handles.vCamGui,'abortStatus') == 1
                    status = 0;
                    error=calllib('libandor','AbortAcquisition');
                end
                
                pause(0.1)
            end

    fscanf(arduinoObj); % Arduino reports 'Complete'
    set(handles.textStatusBox,'string',comm{ceil(rand()*scomm)})
    
    % Make log entry
    %curFilterName=getappdata(handles.vCamGui,'curFilterName');
    curMaskName=getappdata(handles.vCamGui,'curMaskName');
    FWName = getappdata(handles.vCamGui,'FWName');
    emGainS=num2str(getappdata(handles.vCamGui,'emGain'));
    logString=[datestr(now) ' ' filename,'.fits' ' ' timingFile ' ' emGainS ' ' ...
        num2str(caldAngle1) ' ' num2str(caldAngle2) ' ' FWName  ' ' curMaskName];
    logging(strcat('Written file:',32,filename,'.fits'));
    writeToLog(handles,logString);
    % Write telstatus to file
    metPath=['./Metadata'];
    metFile=[filename '_metadata.txt'];
    %metKeywords='UT RA2000 DEC2000 PAP PAD IMRA ALT AZ SEEING TRANSP AIRMASS';
    metKeywords='UT RA2000 DEC2000 PAP PAD IMRA SEEING TRANS AIRMASS';
    metString=['telstatus' ' -r -p=' metPath ' -s=' metFile ' ' metKeywords];
    [status,output]=system(metString);
    disp(output)
    logging(strcat('telstatus:',32,output));
    if getappdata(handles.vCamGui,'abortStatus') == 1
        %setappdata(handles.vCamGui,'abortStatus',0)
        break
    end

end
    if getappdata(handles.vCamGui,'abortStatus') == 1
        setappdata(handles.vCamGui,'abortStatus',0)
        break
    end
end

error=calllib('libandor','SetSpool',0,5,'fitsspoolfile',10);
error=calllib('libandor','SetAcquisitionMode',5);
error=calllib('libandor','SetTriggerMode',0);
error=calllib('libandor','SetExposureTime',str2num(get(handles.expTimeBox,'string'))); %#ok<*ST2NM>
set(handles.textStatusBox,'string','Idle')

%Go back to live video if necessary
if wasRunning == 1
    start(handles.vidTimer)
    set(handles.textStatusBox,'string','Displaying live video')
    calllib('libandor','StartAcquisition');
end
if getappdata(handles.vCamGui,'polzsource') == 'HWP' % set to 0 back
    dummy=system(['ssh ircs@garde.sum.naoj.org "echo hwp move 0 | nc localhost 18902"']);
end
logging('Execute series finished')
set(handles.vCamGui,'Color',get(0,'defaultUicontrolBackgroundColor'))
%Do:
% Restore FT mode
% Restore LCVR mod mode


function writeToLog(handles, string)
logFileName=get(handles.logFileBox,'String');
logFid=fopen(logFileName,'a');
fprintf(logFid,'%s \n',string);
fclose(logFid);



function logFileBox_Callback(hObject, eventdata, handles)
% hObject    handle to logFileBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of logFileBox as text
%        str2double(get(hObject,'String')) returns contents of logFileBox as a double


% --- Executes during object creation, after setting all properties.
function logFileBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logFileBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in storeImageBtn.
function storeImageBtn_Callback(hObject, eventdata, handles)
% hObject    handle to storeImageBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imWidth=getappdata(handles.vCamGui,'imWidth');
imHeight=getappdata(handles.vCamGui,'imHeight');
nPixels=imWidth*imHeight;
imPtr = libpointer('int32Ptr',zeros(imWidth,imHeight));
calllib('libandor','GetMostRecentImage',imPtr,nPixels);
im=imPtr.value;
setappdata(handles.vCamGui,'storedImage',im);


% --- Executes on button press in subtimChk.
function subtimChk_Callback(hObject, eventdata, handles)
% hObject    handle to subtimChk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of subtimChk


% --- Executes on button press in setBoxBtn.
function setBoxBtn_Callback(hObject, eventdata, handles)
% hObject    handle to setBoxBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.vidTimer)
oldStatus=get(handles.textStatusBox,'string');
set(handles.textStatusBox,'string','Click TWO box centers, then press ENTER')
[x,y]=getpts(handles.axesMainVideo);
setappdata(handles.vCamGui,'boxCenter',[y(1),x(1)])
setappdata(handles.vCamGui,'boxCenter2',[y(2),x(2)])
set(handles.textStatusBox,'String',oldStatus)
start(handles.vidTimer)


% --- Executes on button press in HWPPosnBtn.
% function HWPPosnBtn_Callback(hObject, eventdata, handles)
% % hObject    handle to HWPPosnBtn (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % Stop video if necessary
% wasRunning = 0;
% if strcmp(get(handles.vidTimer, 'Running'), 'on')
%     stop(handles.vidTimer)
%     calllib('libandor','AbortAcquisition');
%     set(handles.textStatusBox,'string','Idle')
%     wasRunning = 1;
% end
% 
% set(handles.textStatusBox,'string','Click center of image and press enter.')
% [x,y]=getpts(handles.axesMainVideo);
% set(handles.textStatusBox,'string','Performing HWP Positioning')
% 
% % Call the LCVR Cal function
% % This will find the voltage and save it to the appropriate field in
% % filterTable.
% vControl_HWPPosFn(handles,x,y,wasRunning,handles.vCamGui);



function filterPresetsBox_Callback(hObject, eventdata, handles)
% hObject    handle to filterPresetsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterPresetsBox as text
%        str2double(get(hObject,'String')) returns contents of filterPresetsBox as a double
logging(strcat('FilterW preset file set to:',32,get(hObject,'String')))


% --- Executes during object creation, after setting all properties.
function filterPresetsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterPresetsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filterWheelMenu.
function filterWheelMenu_Callback(hObject, eventdata, handles)
% hObject    handle to filterWheelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filterWheelMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filterWheelMenu


% --- Executes during object creation, after setting all properties.
function filterWheelMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterWheelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in moveFilterWheelBtn.
function moveFilterWheelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to moveFilterWheelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fwVal=get(handles.filterWheelMenu,'Value');
fwObj=getappdata(handles.vCamGui,'fwObj');
cmnd=strcat('pos=',num2str(fwVal));
fprintf(fwObj,cmnd); fscanf(fwObj);
FWNames=get(handles.filterWheelMenu,'string');
FWName=FWNames{fwVal};
setappdata(handles.vCamGui,'FWName',FWName);
logging(strcat('Filter wheel moved to:',32,FWName));



function polaAngleBox_Callback(hObject, eventdata, handles)
% hObject    handle to polaAngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of polaAngleBox as text
%        str2double(get(hObject,'String')) returns contents of polaAngleBox as a double
conex3Obj=getappdata(handles.vCamGui,'conex3Obj');
newAngle=str2double(get(hObject,'String')) + getappdata(handles.vCamGui,'polaCalOffset');
cmndString=strcat('1PA',num2str(newAngle));
fprintf(conex3Obj,cmndString);
logging(strcat('Conex 3 (POL) moving to:',32,num2str(newAngle)))


% --- Executes during object creation, after setting all properties.
function polaAngleBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to polaAngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function calibSeqBox_Callback(hObject, eventdata, handles)
% hObject    handle to calibSeqBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calibSeqBox as text
%        str2double(get(hObject,'String')) returns contents of calibSeqBox as a double


% --- Executes during object creation, after setting all properties.
function calibSeqBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calibSeqBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in acqROMode.
function acqROMode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in acqROMode 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'acqNFTBtn'
        setappdata(handles.vCamGui,'acqReadoutMode',0)
    case 'acqFTBtn'
        setappdata(handles.vCamGui,'acqReadoutMode',1)
end
disp(getappdata(handles.vCamGui,'acqReadoutMode'))


% --- Executes on button press in abortBtn.
function abortBtn_Callback(hObject, eventdata, handles)
% hObject    handle to abortBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.vCamGui,'abortStatus',1)



function loopBox_Callback(hObject, eventdata, handles)
% hObject    handle to loopBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loopBox as text
%        str2double(get(hObject,'String')) returns contents of loopBox as a double
logging(strcat('Loops Num set to:',32,get(hObject,'String')))


% --- Executes during object creation, after setting all properties.
function loopBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loopBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in depolBtn.
function depolBtn_Callback(hObject, eventdata, handles)
% hObject    handle to depolBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%system('ssh scexao@133.40.160.213 /home/scexao/bin/devices/depolarizer');
disp('Depolariser flip mount no longer used.')

% --- Executes on button press in polaInBtn.
function polaInBtn_Callback(hObject, eventdata, handles)
% hObject    handle to polaInBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SCExAOIP=getappdata(handles.vCamGui,'SCExAOIP');
%system('ssh scexao@133.40.160.213 /home/scexao/bin/devices/polarizer goto 3000000');
polzInPos=getappdata(handles.vCamGui,'polzInPos');
system(['ssh scexao@' SCExAOIP ' /home/scexao/bin/devices/polarizer goto ' polzInPos]);

% --- Executes on button press in polaOutBtn.
function polaOutBtn_Callback(hObject, eventdata, handles)
% hObject    handle to polaOutBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SCExAOIP=getappdata(handles.vCamGui,'SCExAOIP');
system(['ssh scexao@' SCExAOIP ' /home/scexao/bin/devices/polarizer home']);


% --- Executes on button press in runCalBtn.
function runCalBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runCalBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Folder to save calfiles
calFolder = '/data/2014June05_polzCalData/';

% Choose configurations - eventually load this from external file
%filts=[1 2 3 4 5];
filts=[4];
HWPs=[0 22.5 45 67.5];
%polas=[0 45 90 135];
%QWPs=[0 20 40 60 80 100 120 140 160 180 200 220 240 260 280 300 320];

%filts=[2 3];
%QWPs=[0 20 40 60 80 100 120 140 160];

% Specify waiting times (seconds)
filtWait = 3;
HWPWait = 7; % For 22.5 degrees
polaWait = 14; % for 45 degrees
polaInWait = 5; % Guess - measure this!
depolWait = 3; % Guess - measure this!
QWPWait = 5; % Guess - measure this!


% Dummy settings for testing
% filtWait = 1;
% HWPWait = 1; % For 22.5 degrees
% polaWait = 1; % for 45 degrees
% polaInWait = 1;
% depolWait = 1; 
% QWPWait = 1;
% filts=[1 2];
% HWPs=[0 22.5];
% polas=[0 45];
% QWPs=[0 20];

% C = 3P numbers:
%QWPs=[0 20 40 60 80 100 120 140 160 180 200 220 240 260 280 300 320];
%polas=QWPs/3;
QWPs=linspace(0,1020,20);
polas=QWPs/3;

fwObj=getappdata(handles.vCamGui,'fwObj');
conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
conex3Obj=getappdata(handles.vCamGui,'conex3Obj');
prmObj=getappdata(handles.vCamGui,'prmObj');

dateLabel=datestr(now,30);

tic
for filt_ind = 1:length(filts)    
    fwVal=filts(filt_ind);
    disp(['Filter: ' num2str(fwVal)])
    cmnd=strcat('pos=',num2str(fwVal));
    fprintf(fwObj,cmnd); fscanf(fwObj);
    pause(filtWait)
    if filt_ind == 1 
        pause(filtWait*(length(filts)-1))
    end
    
    for HWP_ind = 1:length(HWPs)  
        HWPAngle = HWPs(HWP_ind) + getappdata(handles.vCamGui,'hwpCalOffset');
        disp(['HWP: ' num2str(HWPs(HWP_ind))])  
        cmndString=strcat('1PA',num2str(HWPAngle));
        fprintf(conex1Obj,cmndString);
        pause(HWPWait)
        if HWP_ind == 1
            pause(HWPWait*(length(HWPs)-1))
        end
        
        for pola_ind = 1:2     %(length(polas)+1)
            if pola_ind == 1
                disp('Polariser in')
                %system('ssh scexao@133.40.160.213 /home/scexao/bin/devices/polarizer goto 2600000');
                SCExAOIP=getappdata(handles.vCamGui,'SCExAOIP');
                polzInPos=getappdata(handles.vCamGui,'polzInPos');
                system(['ssh scexao@' SCExAOIP ' /home/scexao/bin/devices/polarizer goto ' polzInPos]);
                pause(polaInWait)
            end
            if pola_ind == 2    %(length(polas)+1)
                disp('Polariser out')
                %system('ssh scexao@133.40.160.213 /home/scexao/bin/devices/polarizer home');
                SCExAOIP=getappdata(handles.vCamGui,'SCExAOIP');
                system(['ssh scexao@' SCExAOIP ' /home/scexao/bin/devices/polarizer home']);
                pause(polaInWait)
                %disp('Depolariser in')
                %system('ssh scexao@133.40.160.213 /home/scexao/bin/devices/depolarizer');
                %pause(depolWait)
            end
%             if pola_ind <= length(polas)
%                 polAngle=polas(pola_ind) + getappdata(handles.vCamGui,'polaCalOffset');
%                 disp(['Polariser: ' num2str(polas(pola_ind))])
%                 cmndString=strcat('1PA',num2str(polAngle));
%                 fprintf(conex3Obj,cmndString);
%                 pause(polaWait)
%                 if pola_ind == 1
%                     pause(polaWait*(length(polas)-1))
%                 end
%             end
                        
            for QWP_ind = 1:length(QWPs)
                QWPAngle = QWPs(QWP_ind) + getappdata(handles.vCamGui,'qwpCalOffset');
                disp(['QWP: ' num2str(QWPs(QWP_ind))])
                movePRM(prmObj,QWPAngle,0)
                pause(QWPWait)
                if QWP_ind == 1
                    pause(QWPWait*(length(QWPs)-1))
                end
                
                polAngle=polas(QWP_ind) + getappdata(handles.vCamGui,'polaCalOffset');
                disp(['Polariser: ' num2str(polas(QWP_ind))])
                cmndString=strcat('1PA',num2str(polAngle));
                fprintf(conex3Obj,cmndString);
                pause(polaWait)
                if QWP_ind == 1
                    pause(polaWait*(length(polas)-1))
                end

                
                
                
                % Now actually take data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                disp('Saving data')
                if pola_ind == 1
                    polStatus='PolaIn';
                else
                    polStatus='PolaOut';
                end

                
                filename=[calFolder 'polzCal_' dateLabel '_' num2str(fwVal) '_' num2str(HWPs(HWP_ind)) ...
                    '_' polStatus '_' num2str(polAngle) '_' num2str(QWPs(QWP_ind))];
                % Above line is ok if polCalOffset = 0, otherwise fix
                % this). ????

                    % Set up camera
                    % Stop video if necessary
                    wasRunning = 0;
                    if strcmp(get(handles.vidTimer, 'Running'), 'on')
                        stop(handles.vidTimer)
                        calllib('libandor','AbortAcquisition');
                        set(handles.textStatusBox,'string','Idle')
                        wasRunning = 1;
                    end
                
                    tFile=fopen(['./TimingSetups/',get(handles.timingFileBox,'string'),'.m']);
                    t_HLo = textscan(tFile,'t_HLo = %f %*[^\n] ',1);
                    t_LoH = textscan(tFile,'t_LoH = %f %*[^\n] ',1);
                    t_int = textscan(tFile,'t_int = %f %*[^\n] ',1);
                    t_RdO = textscan(tFile,'t_RdO = %f %*[^\n] ',1);
                    n_int = textscan(tFile,'n_int = %f %*[^\n] ',1);
                    n_cyc = textscan(tFile,'n_cyc = %f %*[^\n] ',1);
                    fclose(tFile);
                    arduinoObj=getappdata(handles.vCamGui,'arduinoObj');
                    t_HLoStr=['upd t_HLo ',num2str(t_HLo{1})];
                    fprintf(arduinoObj,t_HLoStr);
                    fscanf(arduinoObj);
                    t_LoHStr=['upd t_LoH ',num2str(t_LoH{1})];
                    fprintf(arduinoObj,t_LoHStr);
                    fscanf(arduinoObj);
                    t_intStr=['upd t_int ',num2str(t_int{1})];
                    fprintf(arduinoObj,t_intStr);
                    fscanf(arduinoObj);
                    t_RdOStr=['upd t_RdO ',num2str(t_RdO{1})];
                    fprintf(arduinoObj,t_RdOStr);
                    fscanf(arduinoObj);
                    n_intStr=['upd n_int ',num2str(n_int{1})];
                    fprintf(arduinoObj,n_intStr);
                    fscanf(arduinoObj);
                    n_cycStr=['upd n_cyc ',num2str(n_cyc{1})];
                    fprintf(arduinoObj,n_cycStr);
                    fscanf(arduinoObj);
                    
                    % Perform Kinetic Series acquisition, spool to file, ext trigger.
                    error=calllib('libandor','SetAcquisitionMode',3);
                    error=calllib('libandor','SetSpool',1,5,filename,10);
                    error=calllib('libandor','SetTriggerMode',1);
                    %error=calllib('libandor','SetTriggerMode',7);
                    %error=calllib('libandor','SetFrameTransferMode',1);
                    error=calllib('libandor','SetExposureTime',0);

                    % Set appropriate readout mode
                    acqRO = getappdata(handles.vCamGui,'acqReadoutMode');
                    %error=calllib('libandor','SetFrameTransferMode',acqRO);
                    if acqRO == 0
                        error=calllib('libandor','SetFrameTransferMode',0);
                        error=calllib('libandor','SetTriggerMode',7);
                    else
                        error=calllib('libandor','SetFrameTransferMode',1);
                    end

                    %numFrames=10%getappdata(handles.vCamGui,'numKinetics');
                    numFrames = (n_cyc{1})*(n_int{1})*2;
                    calllib('libandor','SetNumberKinetics',numFrames);

                    % Set LCVR to external mode (and turn on)
                    lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
                    fprintf(lcvrObj,'enable=1');
                    fscanf(lcvrObj);
                    fprintf(lcvrObj,'extern=1');
                    fscanf(lcvrObj);

                    %%%% Start acquisition
                    error=calllib('libandor','StartAcquisition');

                    fprintf(arduinoObj,'run');
                    output=fscanf(arduinoObj); %Actual output returned
                    %disp(output);

                    status = 20072; %Initialise with state 'DRV_ACQUIRING'
                            while status == 20072
                                statptr=libpointer('int32Ptr',0);
                                error=calllib('libandor','GetStatus',statptr);
                                status=statptr.value;

                                imsacqptr=libpointer('int32Ptr',0);
                                error=calllib('libandor','GetTotalNumberImagesAcquired',imsacqptr);
                                statString=['Acquiring cube - ' num2str(imsacqptr.value) ...
                                     ' images acquired.'];
                                set(handles.textStatusBox,'string',statString)

                                if getappdata(handles.vCamGui,'abortStatus') == 1
                                    status = 0;
                                    error=calllib('libandor','AbortAcquisition');
                                    %setappdata(handles.vCamGui,'abortStatus',0)
                                end

                                pause(0.1)
                            end

                    fscanf(arduinoObj); % Arduino reports 'Complete'    

                    error=calllib('libandor','SetSpool',0,5,'fitsspoolfile',10);
                    error=calllib('libandor','SetAcquisitionMode',5);
                    error=calllib('libandor','SetTriggerMode',0);
                    error=calllib('libandor','SetExposureTime',str2num(get(handles.expTimeBox,'string'))); %#ok<*ST2NM>
                    set(handles.textStatusBox,'string','Idle')
            
                if getappdata(handles.vCamGui,'abortStatus') == 1
                    break
                end                   
            end
%             if pola_ind == (length(polas)+1)  
%                 disp('Depolariser out')
%                 system('ssh scexao@133.40.160.213 /home/scexao/bin/devices/depolarizer');
%                 pause(depolWait)
%             end
            if getappdata(handles.vCamGui,'abortStatus') == 1
                break
            end 
        end
        if getappdata(handles.vCamGui,'abortStatus') == 1
            break
        end 
    end
    if getappdata(handles.vCamGui,'abortStatus') == 1
        setappdata(handles.vCamGui,'abortStatus',0)
        break
    end 
end
toc


% --- Executes on button press in snapshotBtn.
function snapshotBtn_Callback(hObject, eventdata, handles)
% hObject    handle to snapshotBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.vCamGui,'snapshotStatus',1)


% --- Executes when selected object is changed in fanRadioBtns.
function fanRadioBtns_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in fanRadioBtns 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'fanOnBtn'
        error=calllib('libandor','SetFanMode',0);
    case 'fanOffBtn'
        error=calllib('libandor','SetFanMode',2);
end


% --- Executes on button press in steerImPup.
function steerImPup_Callback(hObject, eventdata, handles)
% hObject    handle to steerImPup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vControl_steerImPup(handles,handles.vCamGui);


function moveZabersAbs(handles,device,position)
% valTimer callback
% Update text values
zabersObj=getappdata(handles.vCamGui,'zabersObj');
newPosn = position;
cmd = 20; %Move absolute
[d3 d4 d5 d6] = entryToBits(newPosn);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8');
pos = fread(zabersObj,6);
logging(strcat('Zaber:',32,num2str(device), 32,'moved to:',32, num2str(newPosn)));
% posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
% setappdata(handles.steerGUI,'pupLRPosn',posNum)
% set(handles.pupLRTextBox,'String',num2str(posNum))

%%%% Used Functions %%%%
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


function [data] = bitsToNumber(d3,d4,d5,d6)
    data = (d6*256^3)+(d5*256^2)+(d4*256)+d3;
%%%%


% --- Executes on button press in runPqwpGridBtn.
function runPqwpGridBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runPqwpGridBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This will go into a separate GUI eventually.
polaPosns=[0 22.5 45 67.5 90 112.5 135 157.5];
nQWPPosns=20;
nPolas=length(polaPosns);
qwpPosns1=0:(180/(nQWPPosns-1)):180;
qwpPosns2=0:(180/(nQWPPosns-1)):180;

%Testing
% polaPosns=[0 12.5 24];
% nQWPPosns=3;
% nPolas=length(polaPosns);
% qwpPosns=0:(40/(nQWPPosns-1)):40
%

polaPosns=[0 22.5 45 67.5 90 112.5 135 157.5];
nQWPPosns=20;
nPolas=length(polaPosns);
qwpPosns1=110:(60/(nQWPPosns-1)):170;
qwpPosns2=110:(60/(nQWPPosns-1)):170;
% qwpPosns1=75:(30/(nQWPPosns-1)):105;
% qwpPosns2=75:(30/(nQWPPosns-1)):105;

%%%%% Single scan %%%%%
% polaPosns=[0 22.5 45 67.5 90 112.5 135 157.5];
% nQWPPosns=1;
% nPolas=length(polaPosns);
% qwpPosns1=84
% qwpPosns2=88


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
conex3Obj=getappdata(handles.vCamGui,'conex3Obj');
conex4Obj=getappdata(handles.vCamGui,'conex4Obj');
allImages=zeros(512,512,nQWPPosns,nQWPPosns,nPolas);
Tol=getappdata(handles.vCamGui,'pqwpTol');
error=calllib('libandor','SetAcquisitionMode',1); %Single scan
imWidth=getappdata(handles.vCamGui,'imWidth');
imHeight=getappdata(handles.vCamGui,'imHeight');
nPixels=imWidth*imHeight;
imPtr = libpointer('int32Ptr',zeros(imWidth,imHeight));

tic
for p = 1:nPolas
    
    % Set Pola
    newAngle=polaPosns(p) + getappdata(handles.vCamGui,'polaCalOffset');
    cmndString=strcat('1PA',num2str(newAngle));
    fprintf(conex3Obj,cmndString);
    curAngle=9999;
    while (newAngle <= curAngle-Tol) || (newAngle >= curAngle+Tol)
        pause(0.2)
        fprintf(conex3Obj,'1TP?');
        output=fscanf(conex3Obj);
        output=strrep(output,'1TP','');
        curAngle=str2num(output);
    end
    pause(0.1)
    disp('')
    disp('')
    disp(['Pola: ' num2str(curAngle-getappdata(handles.vCamGui,'polaCalOffset'))])
   
    
    for q1 = 1:nQWPPosns
        % Set QWP1
        newAngle=qwpPosns1(q1) + getappdata(handles.vCamGui,'pqwp1CalOffset');
        cmndString=strcat('1PA',num2str(newAngle));
        fprintf(conex4Obj,cmndString);
        curAngle=9999;
        while (newAngle <= curAngle-Tol) || (newAngle >= curAngle+Tol)
            pause(0.2)
            fprintf(conex4Obj,'1TP?');
            output=fscanf(conex4Obj);
            output=strrep(output,'1TP','');
            curAngle=str2num(output);
        end
        pause(0.1)
        disp('')
        disp(['QWP1: ' num2str(curAngle-getappdata(handles.vCamGui,'pqwp1CalOffset'))])
        
 
        for q2 = 1:nQWPPosns
            % Set QWP2
            newAngle=qwpPosns2(q2) + getappdata(handles.vCamGui,'pqwp2CalOffset');
            cmndString=strcat('1PA',num2str(newAngle));
            fprintf(conex1Obj,cmndString);
            curAngle=9999;
            while (newAngle <= curAngle-Tol) || (newAngle >= curAngle+Tol)
                pause(0.2)
                fprintf(conex1Obj,'1TP?');
                output=fscanf(conex1Obj);
                output=strrep(output,'1TP','');
                curAngle=str2num(output);
            end
            pause(0.1)
            disp(['QWP2: ' num2str(curAngle-getappdata(handles.vCamGui,'pqwp2CalOffset'))])
    
                disp('--- Acquiring image ---')
            
                calllib('libandor','StartAcquisition');
                calllib('libandor','WaitForAcquisition');
                calllib('libandor','GetAcquiredData',imPtr,nPixels);
                im=imPtr.value;
                
                figure(1)
                imagesc(im)
                allImages(:,:,q1,q2,p)=im;
        end
    end
end
toc

%save('pqwpGrid_allImages_Output','allImages')
save('pqwpGrid_allImages_Output_v73','allImages','polaPosns','qwpPosns1','qwpPosns2','-v7.3')
disp('Hello')
calllib('libandor','SetAcquisitionMode',5);


% --- Executes on button press in runAO188pQWPGridBtn.
function runAO188pQWPGridBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runAO188pQWPGridBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This will go into a separate GUI eventually.
% aoHwpPosns=[0 22.5 45 67.5 90 112.5 135 157.5]/2;
% nQWPPosns=15;
% nPolas=length(aoHwpPosns);
% qwpPosns1=0:(180/(nQWPPosns-1)):180;
% qwpPosns2=0:(180/(nQWPPosns-1)):180;
% %imrPosns=[90, 67.5, 112.5, 45, 22.5, 135, 0];
% %imrPosns=[67.5, 112.5, 45, 22.5, 135, 0];
% imrPosns=[90];
% nimrPosns=length(imrPosns);


%aoHwpPosns=[0 22.5 45 67.5 90 112.5 135 157.5]/2
%aoHwpPosns=[0 45 90 135]/2
aoHwpPosns=[  0   30  60   90  120  150]/2
nQWPPosns=10;
QWP1Posmin=0;
QWP1Posmaw=180;
QWP2Posmin=0;
QWP2Posmaw=180;

nPolas=length(aoHwpPosns)
qwpPosns1=QWP1Posmin:(180/(nQWPPosns-1)):QWP1Posmaw
qwpPosns2=QWP2Posmin:(180/(nQWPPosns-1)):QWP2Posmaw
imrPosns=[90];
nimrPosns=length(imrPosns);


% %%%%% Single scan %%%%%
% aoHwpPosns=[0 22.5 45 67.5 90 112.5 135 157.5]/2;
% nQWPPosns=1;
% nPolas=length(aoHwpPosns);
% qwpPosns1=56
% qwpPosns2=113
% imrPosns=[90];
% nimrPosns=length(imrPosns);

%Testing
% aoHwpPosns=[0 12.5 24];
% nQWPPosns=15;
% nPolas=length(aoHwpPosns);
% qwpPosns1=0:(180/(nQWPPosns-1)):180;
% qwpPosns2=0:(180/(nQWPPosns-1)):180;
% % qwpPosns1=0:(40/(nQWPPosns-1)):40;
% % qwpPosns2=0:(40/(nQWPPosns-1)):40;
% imrPosns=[67.5, 90, 112.5];
% nimrPosns=length(imrPosns);
%

outfilepref='ao188cal_725_grid_';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conex1Obj=getappdata(handles.vCamGui,'conex1Obj');
conex3Obj=getappdata(handles.vCamGui,'conex3Obj');
conex4Obj=getappdata(handles.vCamGui,'conex4Obj');
allImages=zeros(512,512,nQWPPosns,nQWPPosns,nPolas);
Tol=getappdata(handles.vCamGui,'pqwpTol');
error=calllib('libandor','SetAcquisitionMode',1); %Single scan
imWidth=getappdata(handles.vCamGui,'imWidth');
imHeight=getappdata(handles.vCamGui,'imHeight');
nPixels=imWidth*imHeight;
imPtr = libpointer('int32Ptr',zeros(imWidth,imHeight));

tic
for imr = 1:nimrPosns
    newImrAngle=imrPosns(imr);
    outfile=[outfilepref '_IMR' num2str(newImrAngle) '_'];

%NB - to use single quote in Matalb do ''
%system('ssh ao@ao188.sum.naoj.org ''source ~/.profile ; imr ma 30''')
% Insert polariser and HWP
disp('Moving in LP and HWP, takes 20 seconds...')
system('ssh ircs@garde.sum.naoj.org "echo spp move 55.2 | nc localhost 18902"'); % Polariser
system('ssh ircs@garde.sum.naoj.org "echo shw move 56 | nc localhost 18902"'); % HWP
pause(20)
disp('Set LP to 0 degrees...'); %QUESTION: Is this horizontal or vertical?
system('ssh ircs@garde.sum.naoj.org "echo qwp move 0 | nc localhost 18902"');
pause(3)

    disp('Moving k-mirror')
    system(['ssh ao@ao188.sum.naoj.org "source ~/.profile ; imr ma ' num2str(newImrAngle) '"']);
    disp('Moved.')

for p = 1:nPolas
    
    % Set Pola
    newAngle=aoHwpPosns(p);% + getappdata(handles.vCamGui,'polaCalOffset');
 
%     cmndString=strcat('1PA',num2str(newAngle));
%     fprintf(conex3Obj,cmndString);
%     curAngle=9999;
%     while (newAngle <= curAngle-Tol) || (newAngle >= curAngle+Tol)
%         pause(0.2)
%         fprintf(conex3Obj,'1TP?');
%         output=fscanf(conex3Obj);
%         output=strrep(output,'1TP','');
%         curAngle=str2num(output);
%     end
    
    system(['ssh ircs@garde.sum.naoj.org "echo hwp move ' num2str(newAngle) ' | nc localhost 18902"']);
    %disp(['Pola: ' num2str(curAngle)])
    pause(3) % only takes 3 sec to move the biggest move from 0 to 67.5 degrees
    
    for q1 = 1:nQWPPosns
        % Set QWP1
        newAngle=qwpPosns1(q1) + getappdata(handles.vCamGui,'pqwp1CalOffset');
        cmndString=strcat('1PA',num2str(newAngle));
        fprintf(conex4Obj,cmndString);
        curAngle=9999;
        while (newAngle <= curAngle-Tol) || (newAngle >= curAngle+Tol)
            pause(0.2)
            fprintf(conex4Obj,'1TP?');
            output=fscanf(conex4Obj);
            output=strrep(output,'1TP','');
            curAngle=str2num(output);
        end
        pause(0.1)
        disp('')
        disp(['QWP1: ' num2str(curAngle-getappdata(handles.vCamGui,'pqwp1CalOffset'))])
        
 
        for q2 = 1:nQWPPosns
            % Set QWP2
            newAngle=qwpPosns2(q2) + getappdata(handles.vCamGui,'pqwp2CalOffset');
            cmndString=strcat('1PA',num2str(newAngle));
            fprintf(conex1Obj,cmndString);
            curAngle=9999;
            while (newAngle <= curAngle-Tol) || (newAngle >= curAngle+Tol)
                pause(0.2)
                fprintf(conex1Obj,'1TP?');
                output=fscanf(conex1Obj);
                output=strrep(output,'1TP','');
                curAngle=str2num(output);
            end
            pause(0.1)
            disp(['QWP2: ' num2str(curAngle-getappdata(handles.vCamGui,'pqwp2CalOffset'))])
    
                disp('--- Acquiring image ---')
            
                calllib('libandor','StartAcquisition');
                calllib('libandor','WaitForAcquisition');
                error=calllib('libandor','GetAcquiredData',imPtr,nPixels);
                im=imPtr.value;
                
                figure(1)
                imagesc(im)
                allImages(:,:,q1,q2,p)=im;
                
pause(1)
                
        end
    end
end
toc

disp('Homing LP and HWP, takes 20 seconds...')
system('ssh ircs@garde.sum.naoj.org "echo spp init | nc localhost 18902"'); % Polariser
system('ssh ircs@garde.sum.naoj.org "echo shw init | nc localhost 18902"'); % HWP
pause(20)

%%% Now do one without a polariser
allNoPolImages=zeros(512,512,nQWPPosns,nQWPPosns);
   for q1 = 1:nQWPPosns
        % Set QWP1
        newAngle=qwpPosns1(q1) + getappdata(handles.vCamGui,'pqwp1CalOffset');
        cmndString=strcat('1PA',num2str(newAngle));
        fprintf(conex4Obj,cmndString);
        curAngle=9999;
        while (newAngle <= curAngle-Tol) || (newAngle >= curAngle+Tol)
            pause(0.2)
            fprintf(conex4Obj,'1TP?');
            output=fscanf(conex4Obj);
            output=strrep(output,'1TP','');
            curAngle=str2num(output);
        end
        pause(0.1)
        disp('')
        disp(['QWP1: ' num2str(curAngle-getappdata(handles.vCamGui,'pqwp1CalOffset'))])
        
 
        for q2 = 1:nQWPPosns
            % Set QWP2
            newAngle=qwpPosns2(q2) + getappdata(handles.vCamGui,'pqwp2CalOffset');
            cmndString=strcat('1PA',num2str(newAngle));
            fprintf(conex1Obj,cmndString);
            curAngle=9999;
            while (newAngle <= curAngle-Tol) || (newAngle >= curAngle+Tol)
                pause(0.2)
                fprintf(conex1Obj,'1TP?');
                output=fscanf(conex1Obj);
                output=strrep(output,'1TP','');
                curAngle=str2num(output);
            end
            pause(0.1)
            disp(['QWP2: ' num2str(curAngle-getappdata(handles.vCamGui,'pqwp2CalOffset'))])
    
                disp('--- Acquiring image ---')
            
                calllib('libandor','StartAcquisition');
                calllib('libandor','WaitForAcquisition');
                calllib('libandor','GetAcquiredData',imPtr,nPixels);
                im=imPtr.value;
                
                figure(1)
                imagesc(im)
                %allImages=zeros(512,512,nQWPPosns,nQWPPosns,nPolas);
                allNoPolImages(:,:,q1,q2)=im;
                metPath=['./Metadata_cals'];
                metFile=[filename '_metadata.txt'];
                metKeywords='UT RA2000 DEC2000 PAP PAD IMRA SEEING TRANS AIRMASS';
                metString=['telstatus' ' -r -p=' metPath ' -s=' metFile ' ' metKeywords];
                [status,output]=system(metString);
        end
   end
   save([outfile '_allImages'],'allImages','allNoPolImages','aoHwpPosns','qwpPosns1','qwpPosns2','imrPosns','-v7.3')

end

toc

disp('Hello')
calllib('libandor','SetAcquisitionMode',5);


% --- Executes when user attempts to close vCamGui.
function vCamGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to vCamGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
btn_Exit_Callback(hObject, eventdata, handles)



function multiangletxt_Callback(hObject, eventdata, handles)
% hObject    handle to multiangletxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of multiangletxt as text
%        str2double(get(hObject,'String')) returns contents of multiangletxt as a double
logging(strcat('Multi-angle set to:',32,get(hObject,'String')));


% --- Executes during object creation, after setting all properties.
function multiangletxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to multiangletxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in logviewcheck.
function logviewcheck_Callback(hObject, eventdata, handles)
% hObject    handle to logviewcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of logviewcheck


% --- Executes during object creation, after setting all properties.
function hwpSeriesBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hwpSeriesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textClipHi_Callback(hObject, eventdata, handles)
% hObject    handle to textClipHi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textClipHi as text
%        str2double(get(hObject,'String')) returns contents of textClipHi as a double


% --- Executes on button press in qwppolradio.
function qwppolradio_Callback(hObject, eventdata, handles)
% hObject    handle to qwppolradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of qwppolradio


% --- Executes on button press in hwppolradio.
function hwppolradio_Callback(hObject, eventdata, handles)
% hObject    handle to hwppolradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of hwppolradio


% --- Executes when selected object is changed in polz.
function polz_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in polz 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'qwppolradio'
        setappdata(handles.vCamGui,'polzsource','QWP');
        set(handles.textStatusBox,'string','Idle')
        logging('Polz source set to internal QWPs');
    case 'hwppolradio'
        setappdata(handles.vCamGui,'polzsource','HWP');
        set(handles.textStatusBox,'string','MAKE SURE THE HWP IS IN THE BEAM BEFORE SERIES')
        logging('Polz source set to AO188 HWP');
end
