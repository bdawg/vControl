
% This script reproduces the problem with trying to spool from multiple
% cameras at once. 
% When tested with two Ixon Ultra 897 cameras, it produces two FITS files
% as expected, but the first one is small and corrupted, and the second
% contains the full frame count but with most of the frames corresponding
% to one camera while other frames correspond to the other camera.


%%%%%%%%%%%%%%%%%%%%%%%% Default Settings %%%%%%%%%%%%%%%%%%%%%%%%%
expTime = 0.01;      % Exposure time
emGain = 0;          % EM gain
HSSpeed = 0;         % Horizontal shift speed (index)
VSSpeed = 0;         % Vertical shift speed (index)
VSVolts = 2;         % Vertical shift voltage (index)

kinCycleTime = 0;    % Kinetic Cycle Time (0 sets it to minimum possible)
numKinetics = 800;   % Numer of frames in kinetic series
triggerMode = 0;     % 0 = internal, 1 = external
readoutMode = 0;     % 0 = NFT, 1 = FT

numCams = 2; % Number of Andor cameras connected

%%%%%%%%%%%%%%%% Initialise Camera %%%%%%%%%%%%%%%%%%%%%%%%
warning off
header='/usr/local/include/atmcdLXd.h';
[notfound, warnings] = loadlibrary('/usr/local/lib/libandor.so', header);
warning on


% Get handles for each camera and initialise
camHandles = zeros(numCams,1,'int32');

for k = 1:numCams
    camSerialPtr=libpointer('int32Ptr',0);
    camHandlePtr=libpointer('int32Ptr',0);
    error=calllib('libandor','GetCameraHandle',k,camHandlePtr);
    camHandles(k) = camHandlePtr.value;
    
    curCamHandle = camHandles(k);
    error=calllib('libandor','SetCurrentCamera',curCamHandle);
    disp(['Initaliasing Camera ' num2str(k) '...'])
    error=calllib('libandor','Initialize','/usr/local/etc/andor');
    if error == 20002
        disp('Initialisation Succesful')
        error2 = calllib('libandor','GetCameraSerialNumber', camSerialPtr);
        disp(['Serial number ' num2str(camSerialPtr.value)])
    else
        disp('Initialisation Error')
    end
end


% Set various camera settings
for k = 1:numCams
    curCamHandle = camHandles(k);
    error=calllib('libandor','SetCurrentCamera',curCamHandle);
    
    % Set read mode to Image
    error=calllib('libandor','SetReadMode',4);

    % Set acquisition mode to Run Till Abort and related settings
    error=calllib('libandor','SetAcquisitionMode',5);
    error=calllib('libandor','SetExposureTime',expTime);
    error=calllib('libandor','SetNumberAccumulations',1);
    error=calllib('libandor','SetNumberKinetics',numKinetics);
    error=calllib('libandor','SetTriggerMode',triggerMode);
    error=calllib('libandor','SetEMGainMode',2);
    error=calllib('libandor','SetEMAdvanced',1);
    error=calllib('libandor','SetEMCCDGain',emGain);
    error=calllib('libandor','SetHSSpeed',0,HSSpeed); %Also sets to EM output amp
    error=calllib('libandor','SetVSSpeed',VSSpeed);
    error=calllib('libandor','SetVSAmplitude',VSVolts);
    error=calllib('libandor','SetFrameTransferMode',readoutMode);
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
end


%%%%%%%%%%%%%%%%%%%%%%% Setup and start acquisition %%%%%%%%%%%%%%%%%%%%%%%
% Set-up and start the acquisition

for k = 1:length(camHandles)
    curCamHandle = camHandles(k);
    error=calllib('libandor','SetCurrentCamera',curCamHandle); 
    curFilename = ['testfile_cam' num2str(k)];

    % Perform Kinetic Series acquisition, spool to file
    error=calllib('libandor','SetAcquisitionMode',3);
    error=calllib('libandor','SetSpool',1,5,curFilename,10);
    calllib('libandor','SetNumberKinetics',numKinetics);

    error=calllib('libandor','StartAcquisition');  
    
    %pause(0.001)
end

% Retrieve data (spooling)
statptr=libpointer('int32Ptr',0);
imsacqptr=libpointer('int32Ptr',0);
imsacq = 0;
status = 20072; %Initialise with state 'DRV_ACQUIRING'
while status == 20072

    for k = 1:length(camHandles)
        curCamHandle = camHandles(k);
        error=calllib('libandor','SetCurrentCamera',curCamHandle);  
        error=calllib('libandor','GetStatus',statptr);
        status=statptr.value;

        error=calllib('libandor','GetTotalNumberImagesAcquired',imsacqptr);
        imsacq = imsacqptr.value;

        % For debuging:
        %disp(imsacq)
    
        %pause(0.001)
    end
 
end


% Check that all acqusitions have completed (i.e. camera is idle)
for k = 1:length(camHandles)
    status = 0;
    curCamHandle = camHandles(k);
    error=calllib('libandor','SetCurrentCamera',curCamHandle);
     while status ~= 20073
        error=calllib('libandor','GetStatus',statptr);
        status=statptr.value
        pause(0.1)
     end
    disp(['Acqusition complete for camera ' num2str(k)])
    
    % Turn off spooling
    error=calllib('libandor','SetSpool',0,5,'fitsspoolfile',10);
    error=calllib('libandor','SetAcquisitionMode',5);
end


% Shut down cameras
for k = 1:length(camHandles)
    curCamHandle = camHandles(k);
    error=calllib('libandor','SetCurrentCamera',curCamHandle);
    
    error=calllib('libandor','SetShutter',0,2,10,10);
    calllib('libandor','CoolerOFF');
    error=calllib('libandor','ShutDown');
end
unloadlibrary libandor;










