function varargout = vControl_LCVRCalFn(varargin)
% VCONTROL_LCVRCALFN MATLAB code for vControl_LCVRCalFn.fig
%      VCONTROL_LCVRCALFN, by itself, creates a new VCONTROL_LCVRCALFN or raises the existing
%      singleton*.
%
%      H = VCONTROL_LCVRCALFN returns the handle to a new VCONTROL_LCVRCALFN or the handle to
%      the existing singleton*.
%
%      VCONTROL_LCVRCALFN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VCONTROL_LCVRCALFN.M with the given input arguments.
%
%      VCONTROL_LCVRCALFN('Property','Value',...) creates a new VCONTROL_LCVRCALFN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vControl_LCVRCalFn_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vControl_LCVRCalFn_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vControl_LCVRCalFn

% Last Modified by GUIDE v2.5 04-Apr-2013 11:20:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vControl_LCVRCalFn_OpeningFcn, ...
                   'gui_OutputFcn',  @vControl_LCVRCalFn_OutputFcn, ...
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


% --- Executes just before vControl_LCVRCalFn is made visible.
function vControl_LCVRCalFn_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vControl_LCVRCalFn (see VARARGIN)

%%%%%%%%%%%% Settings %%%%%%%%%%%%%%
delayTime = 1; % Time to wait between iterations
startVolt = 1.0; % Voltage to start scan at
endVolt = 2.0;   % Voltage to finish scan at
nSteps = 30;    % Number of voltage steps
boxSize = 50;   % Size of measurement box (pixels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setappdata(handles.lcvrCalGui,'delayTime',delayTime)
setappdata(handles.lcvrCalGui,'startVolt',startVolt)
setappdata(handles.lcvrCalGui,'endVolt',endVolt)
setappdata(handles.lcvrCalGui,'boxSize',boxSize)
setappdata(handles.lcvrCalGui,'nSteps',nSteps)

% Choose default command line output for vControl_LCVRCalFn
handles.output = hObject;

% Get data from parent function
handlesParent=varargin{1};
xpos=varargin{2};
ypos=varargin{3};
wasRunning=varargin{4};
handles.vCamGui=varargin{5};
handles.vidTimer=handlesParent.vidTimer;
handles.textStatusBox=handlesParent.textStatusBox;
handles.lcvrV1Box=handlesParent.lcvrV1Box;

setappdata(handles.lcvrCalGui,'wasRunning',wasRunning)
setappdata(handles.lcvrCalGui,'position',[xpos,ypos])
kinCycleTime=getappdata(handles.vCamGui,'kinCycleTime');
setappdata(handles.lcvrCalGui,'kinCycleTime',kinCycleTime)
clipHi=str2num(get(handlesParent.textClipHi,'string'));
setappdata(handles.lcvrCalGui,'clipHi',clipHi)
maxVolt=1.0;
setappdata(handles.lcvrCalGui,'maxVolt',maxVolt)

%%%%% Insert check that box is not too near edge %%%%%%



% Set up the camera for doing calibration
error=calllib('libandor','SetAcquisitionMode',1); %Single scan

hold(handles.axesCalPlot,'on')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vControl_LCVRCalFn wait for user response (see UIRESUME)
% uiwait(handles.lcvrCalGui);


% --- Outputs from this function are returned to the command line.
function varargout = vControl_LCVRCalFn_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in exitBtn.
function exitBtn_Callback(hObject, eventdata, handles)
% hObject    handle to exitBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
error=calllib('libandor','SetAcquisitionMode',5);
cycTime=getappdata(handles.lcvrCalGui,'kinCycleTime');
calllib('libandor','SetKineticCycleTime',cycTime);

if getappdata(handles.lcvrCalGui,'wasRunning') == 1
    calllib('libandor','StartAcquisition');
    start(handles.vidTimer)
    set(handles.textStatusBox,'string','Displaying live video')
end

% Set new V1
maxVolt=getappdata(handles.lcvrCalGui,'maxVolt');
set(handles.lcvrV1Box,'string',num2str(maxVolt))
lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
fprintf(lcvrObj,strcat('volt1=',num2str(maxVolt)));
fscanf(lcvrObj);

delete(handles.lcvrCalGui);


% --- Executes on button press in runCalBtn.
function runCalBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runCalBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delayTime=getappdata(handles.lcvrCalGui,'delayTime');
startVolt=getappdata(handles.lcvrCalGui,'startVolt');
endVolt=getappdata(handles.lcvrCalGui,'endVolt');
boxSize=getappdata(handles.lcvrCalGui,'boxSize');
nSteps=getappdata(handles.lcvrCalGui,'nSteps');
pos=getappdata(handles.lcvrCalGui,'position');
clipHi=getappdata(handles.lcvrCalGui,'clipHi');

lcvrObj=getappdata(handles.vCamGui,'lcvrObj');
imWidth=getappdata(handles.vCamGui,'imWidth');
imHeight=getappdata(handles.vCamGui,'imHeight');
nPixels=imWidth*imHeight;
imPtr = libpointer('int32Ptr',zeros(imWidth,imHeight));

stepSize=(endVolt-startVolt)/(nSteps-1);
count=1;
for volt = startVolt:stepSize:endVolt
    allVolts(count)=volt;
    lcvrV1=volt;
    fprintf(lcvrObj,strcat('volt1=',num2str(lcvrV1)));
    fscanf(lcvrObj);
    
    pause(delayTime)
      
%             disp('Before Acqusition:')
%             newimindstartptr=libpointer('int32Ptr',0);
%             newimindendptr=libpointer('int32Ptr',0);
%             calllib('libandor','GetNumberNewImages',newimindstartptr,newimindendptr);
%             disp(newimindstartptr.value)
%             disp(newimindendptr.value)
               
    calllib('libandor','StartAcquisition');
    calllib('libandor','WaitForAcquisition');
    pause(1)
    calllib('libandor','GetMostRecentImage',imPtr,nPixels);
    im=imPtr.value;
    
%             disp('After Acqusition:')
%             newimindstartptr=libpointer('int32Ptr',0);
%             newimindendptr=libpointer('int32Ptr',0);
%             calllib('libandor','GetNumberNewImages',newimindstartptr,newimindendptr);
%             disp(newimindstartptr.value)
%             disp(newimindendptr.value)
    
    imZm=im((pos(2)-boxSize/2):(pos(2)+boxSize/2-1), ...
        (pos(1)-boxSize/2):(pos(1)+boxSize/2-1));
    
    curInt=sum(sum(imZm));
    allInts(count)=curInt;
    
    if clipHi ~= 0
        imZm = min(imZm,clipHi);
    end
    imagesc(imZm,'Parent',handles.axesPrev)
    
    plot(allVolts,allInts,'Parent',handles.axesCalPlot)
    axis(handles.axesCalPlot,[startVolt,endVolt,0,1e7])
    axis(handles.axesCalPlot,'auto y')
    xlabel(handles.axesCalPlot,'Voltage')
    count = count+1;
end

% Smooth and find maximum
sigma=10;
ksize=30;
xind=(0:(ksize-1)) - ((ksize-1)/2);
kernel=exp(-(xind/sigma).^2);% * 1/(sigma*sqrt(2*pi));

allVoltsFine = startVolt:0.01:endVolt;
allIntsFine = interp1(allVolts,allInts,allVoltsFine,'spline');
%plot(allVoltsFine,allIntsFine,'r--','Parent',handles.axesCalPlot)

allIntsSmooth = conv(allIntsFine,kernel,'same');
allIntsSmooth = allIntsSmooth / max(allIntsSmooth) * max(allInts);
plot(allVoltsFine,allIntsSmooth,'r--','Parent',handles.axesCalPlot)

[maxVal,maxInd] = max(allIntsSmooth);
plot(allVoltsFine(maxInd),maxVal,'go','Parent',handles.axesCalPlot)
maxVolt=allVoltsFine(maxInd);
title(handles.axesCalPlot,['Max at Voltage: ' num2str(maxVolt)])
setappdata(handles.lcvrCalGui,'maxVolt',maxVolt)
