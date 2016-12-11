
% This script reproduces the intermittent problem of tryign to retrieve
% data form multiple cameras performing kinetic series. When tested with
% two Ixon Ultra 897 cameras, the problem occured about 1 in 50
% acqusitions, each being 200 frames long. 
% When this occurs, the two sets of data are of uneven length, with one
% containing, e.g., 199 frames, and the otehr 201. In that example, the
% first data set contains images from camera 1 (but is missing one), and
% the second set contains images from camera 2, as well as the missing
% image from camera 1.
%
% In other words, despite the appropriate SetCurrentCamera call beforehand, 
% occasionally GetOldestImage gets the image from the wrong camera.



% This fails intermittently. When tested with two Ixon Ultra 897 cameras,
% if 50 kinetic series are acquired, each of 200 frames, you normally get
% at least one failure.
numLoops = 200;
path = '';
path = '/data/testing/';
%%%%%%%%%%%%%%%%%%%%%%%% Default Settings %%%%%%%%%%%%%%%%%%%%%%%%%
expTime = 0.002;      % Exposure time
emGain = 0;          % EM gain
HSSpeed = 0;         % Horizontal shift speed (index)
VSSpeed = 0;         % Vertical shift speed (index)
VSVolts = 2;         % Vertical shift voltage (index)

kinCycleTime = 0;    % Kinetic Cycle Time (0 sets it to minimum possible)
numKinetics = 200;   % Numer of frames in kinetic series
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
statptr=libpointer('int32Ptr',0);

% For debug:
getCamptr=libpointer('int32Ptr',0);
allGetCams = zeros(2, numKinetics, 'int32');

for loops = 1:numLoops

    for k = 1:length(camHandles)
        curCamHandle = camHandles(k);
        error=calllib('libandor','SetCurrentCamera',curCamHandle); 
        curFilename = ['testfile_cam' num2str(k)];

        % Perform Kinetic Series acquisition, spool to file
        error=calllib('libandor','SetAcquisitionMode',3);
        error=calllib('libandor','SetSpool',1,5,curFilename,10);
        calllib('libandor','SetNumberKinetics',numKinetics);

        % Don't spool
        error=calllib('libandor','SetSpool',0,5,'',10);

        error=calllib('libandor','StartAcquisition');  

        %pause(0.001)
    end

    allStatuses = ones(1, numCams) * 20072; %Initialise with state 'DRV_ACQUIRING'
    allAcquringStatus = allStatuses;
    % Note, 20073 is 'idle' status

    % Note - when there are  no more images in buffer, GetOldestImage will
    % return DRV_NO_NEW_DATA (20024)
    allGetimErr = ones(1, numCams) * 20002; %Initialise with state 'DRV_SUCCESS'
    allGetimSuccess = allGetimErr;

    allCounts = ones(1, numCams); % Frame-number count for indexing allImages
    allImages = zeros(imWidth, imHeight, numKinetics, numCams, 'int32');
    nPixels = imWidth*imHeight;
    imPtr = libpointer('int32Ptr',zeros(imWidth,imHeight));


    % Loop until all images have been retrieved and acquisition has finished
    while any(allStatuses == allAcquringStatus) || ...
            any(allGetimErr == allGetimSuccess)
        for k = 1:numCams
            curCamHandle = camHandles(k);
            error=calllib('libandor','SetCurrentCamera',curCamHandle); 
            error=calllib('libandor','GetStatus',statptr);
            allStatuses(k)=statptr.value;
            allGetimErr(k)=calllib('libandor','GetOldestImage',imPtr,nPixels);

            % Add image to array if new one was retrieved
            if allGetimErr(k) == 20002
                allImages(:, :, allCounts(k), k) = imPtr.value;
                allCounts(k) = allCounts(k) + 1;
                %disp(allCounts) % for debug
            end

            % For debug:
            error=calllib('libandor','GetCurrentCamera',getCamptr);
            allGetCams(k, allCounts(k)) = getCamptr.value;

            % pause(0.001)    
        end
    end

    
    % Check that all acqusitions have completed (i.e. camera is idle)
    for k = 1:length(camHandles)
        status = 0;
        curCamHandle = camHandles(k);
        error=calllib('libandor','SetCurrentCamera',curCamHandle);
        statptr=libpointer('int32Ptr',0);
         while status ~= 20073
            error=calllib('libandor','GetStatus',statptr);
            status=statptr.value
            pause(0.1)
         end
        disp(['Acqusition complete for camera ' num2str(k)])
    end

    % For debug, show the number of images actually acquired for each camera.
    % When it goes wrong, these will be unequal.
    disp(['allCounts: ' num2str(allCounts)])
    % Useful to set a contional breakpoint for okCounts == 0 to debug
    okCounts = all(allCounts == [201, 201])
    disp('')
    
    % Write to files
    for k = 1:length(camHandles)
        curFilename = [path 'testfile' num2str(loops) '_cam' num2str(k) '.fits'];
        disp(['Writing to file ' curFilename])
        fitswrite(allImages(:,:,:,k), curFilename)
    end

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










