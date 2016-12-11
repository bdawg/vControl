%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define parameters
%
NumFrames = 100;     % Number of scans in kinetic series
ExpTime = 0.0005;      % Exposure time
                    % Note - in Ext Trigger mode, exposure controlled by
                    % time between triggers, but exposure window is moved
                    % by ExpTime.

Mode =4;           % Mode of this script
                    % 1 - Acquire images into memory
                    % 2 - Spool to fits file
                    % 3 - Acquire single sets and show (testing)
                    % 4 - Show 'video' via Run Till Abort
                    
numVidFrames = 1000; % Number of frames to show in video mode before exiting
showFramenum = true;

emGain = 0;          % EM gain
HSSpeed = 0;         % Horizontal shift speed (index)
VSSpeed = 0;         % Vertical shift speed (index)
VSVolts = 3;         % Vertical shift voltage (index)

kinCycleTime = 0;    % Kinetic Cycle Time (0 sets it to minimum possible)
%numKinetics = 16;   % Numer of frames in kinetic series
triggerMode = 1;     % 0 = internal, 1 = external
readoutMode = 1;     % 0 = NFT, 1 = FT
%setTemp = -65;

camToUse = 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning off
header='/usr/local/include/atmcdLXd.h';
[notfound, warnings] = loadlibrary('/usr/local/lib/libandor.so', header);
warning on


% How many cameras are there?
numCamsPtr=libpointer('int32Ptr',0);
error = calllib('libandor','GetAvailableCameras',numCamsPtr);
numCams = numCamsPtr.value

% Get handles for each camera
cam1HandlePtr=libpointer('int32Ptr',0);
error=calllib('libandor','GetCameraHandle',1,cam1HandlePtr);
cam1Handle = cam1HandlePtr.value
cam2HandlePtr=libpointer('int32Ptr',0);
error=calllib('libandor','GetCameraHandle',2,cam2HandlePtr);
cam2Handle = cam2HandlePtr.value
    

% Initalise cameras
disp('Initaliasing Cameras...')
error=calllib('libandor','SetCurrentCamera',cam1Handle);
error=calllib('libandor','Initialize','/usr/local/etc/andor');
if error == 20002
    disp('Initialisation Succesful')
else
    disp('Initialisation Error')
end

error=calllib('libandor','SetCurrentCamera',cam2Handle);
error=calllib('libandor','Initialize','/usr/local/etc/andor');
if error == 20002
    disp('Initialisation Succesful')
else
    disp('Initialisation Error')
end



% For now, use one camera
if camToUse == 1
    camHandle = cam1Handle;
else
    camHandle = cam2Handle;
end
error=calllib('libandor','SetCurrentCamera',camHandle);


% Set read mode to Image
error=calllib('libandor','SetReadMode',4);

% Set acquisition mode to Kinetic Series and related settings
error=calllib('libandor','SetAcquisitionMode',3);
error=calllib('libandor','SetExposureTime',ExpTime);
error=calllib('libandor','SetNumberAccumulations',1);
error=calllib('libandor','SetNumberKinetics',NumFrames);
% Following line redundant in FT mode (depends on exptime, cannot set this in software)
%error=calllib('libandor','SetKineticCycleTime',0); %Use shortest possible cycle time
% Use GetAcquisitionTimings to find actual timings...
error=calllib('libandor','SetKineticCycleTime',0.1);


% Set trigger mode to internal
error=calllib('libandor','SetTriggerMode',triggerMode);

% Set shift speeds (to do)
error=calllib('libandor','SetEMGainMode',2); % Believed to be 'real', docs wrong.
error=calllib('libandor','SetEMAdvanced',0); %%%% Set to 1 at your peril!!! (RTFM) %%%%
error=calllib('libandor','SetEMCCDGain',emGain);
error=calllib('libandor','SetHSSpeed',0,HSSpeed); %Also sets to EM output amp
error=calllib('libandor','SetVSSpeed',VSSpeed);
error=calllib('libandor','SetVSAmplitude',VSVolts);

error=calllib('libandor','SetFrameTransferMode',readoutMode);

error=calllib('libandor','SetKineticCycleTime',kinCycleTime);

% Set shutter to open
error=calllib('libandor','SetShutter',0,1,50,50);

% Setup image size
imw=libpointer('int32Ptr',0);
imh=libpointer('int32Ptr',0);
error=calllib('libandor','GetDetector',imw,imh);
imwidth=imw.value;
imheight=imw.value;
error=calllib('libandor','SetImage',1,1,1,imwidth,1,imheight);


%     %Temp code to enable binning and cropping:
%     hbin=4;
%     vbin=4;
%     hstart=175;
%     hend=274;
%     vstart=180;
%     vend=279;
%     hstart=187;
%     hend=hstart+15;
%     vstart=190;
%     vend=vstart+15;
%     imwidth=(hend-hstart+1) / hbin
%     imheight=(vend-vstart+1) / vbin
%     errorSetImage=calllib('libandor','SetImage',hbin,vbin,hstart,hend,vstart,vend);


actualExp=libpointer('singlePtr',0);
actualAcc=libpointer('singlePtr',0);
actualCyc=libpointer('singlePtr',0);
error=calllib('libandor','GetAcquisitionTimings',actualExp,actualAcc,actualCyc);
disp(strcat('Actual cycle time: ',num2str(actualCyc.value)))
%pause


switch Mode
    
    case 1
     %for test = 1:10
        npixels=imwidth*imheight;
        imCube = zeros(imwidth,imheight,NumFrames);
        imPtr = libpointer('int32Ptr',zeros(imwidth,imheight));
        count=1;    
    
        error=calllib('libandor','StartAcquisition');
     
        % Loop until all image have been retrieved and acquisition has finished
        status = 20072; %Initialise with state 'DRV_ACQUIRING'
        getimerr = 20002; %Initialise with state 'DRV_SUCCESS'
        while ((status == 20072) || (getimerr == 20002))
            statptr=libpointer('int32Ptr',0);
            error=calllib('libandor','GetStatus',statptr);
            status=statptr.value;       
            getimerr=calllib('libandor','GetOldestImage',imPtr,npixels);
            if getimerr == 20002
                imCube(:,:,count) = imPtr.value;
                if showFramenum
                    disp(count)
                end
            count=count+1;
            end
            
%             newimindstartptr=libpointer('int32Ptr',0);
%             newimindendptr=libpointer('int32Ptr',0);
%             calllib('libandor','GetNumberNewImages',newimindstartptr,newimindendptr);
%             disp(newimindstartptr.value)
%             disp(newimindendptr.value)

%               nImAcq=libpointer('int32Ptr',0);
%               error=calllib('libandor','GetTotalNumberImagesAcquired',nImAcq);
%               disp(nImAcq.value)
        end
        
        %end
        %error=calllib('libandor','WaitForAcquisition');
        %%%%%%%% Can't get 'GetAcquiredData to work (always complains wrong
        %%%%%%%% array size).
        % Get number of images acquired
        %nImAcq=libpointer('int32Ptr',0);
        %error=calllib('libandor','GetTotalNumberImagesAcquired',nImAcq);
        
        
    case 2
        error=calllib('libandor','SetSpool',1,5,'fitsspool',10);
        error=calllib('libandor','StartAcquisition');
        % WaitForAcquisition doesn't seem to wait long enough? Use a loop:
        status = 20072; %Initialise with state 'DRV_ACQUIRING'
        count=1;
        while status == 20072
            statptr=libpointer('int32Ptr',0);
            error=calllib('libandor','GetStatus',statptr);
            status=statptr.value
            pause(0.01)
            %count=count+1
        end
        disp('done')
        error=calllib('libandor','SetSpool',0,5,'fitsspool',10);

   
        
    case 3
        % This is a slow way of doing 'video'
        error=calllib('libandor','SetNumberKinetics',1);
        npixels=imwidth*imheight;
        imPtr = libpointer('int32Ptr',zeros(imwidth,imheight));
        for ii = 1:numVidFrames
            calllib('libandor','StartAcquisition');
            %calllib('libandor','WaitForAcquisition');
            calllib('libandor','WaitForAcquisitionTimeOut',1000);
            
            statptr=libpointer('int32Ptr',0);
            error=calllib('libandor','GetStatus',statptr);
            disp(statptr.value)
            
            %getimerr=calllib('libandor','GetOldestImage',imPtr,npixels);
            % Get all images before moving on
            getimerr=2002;
            while getimerr == 2002
                getimerr=calllib('libandor','GetOldestImage',imPtr,npixels);
            end
            
            imagesc(imPtr.value)
            axis square
            pause(0.01)
        end
            disp('Got out of loop')
    
            
            
    case 4
        % Better video method
        npixels=imwidth*imheight;
        imPtr = libpointer('int32Ptr',zeros(imwidth,imheight));
        calllib('libandor','SetAcquisitionMode',5); %run till abort
        calllib('libandor','StartAcquisition');
        figure;
        h=axes;
        for ii = 1:numVidFrames
            getimerr=calllib('libandor','GetMostRecentImage',imPtr,npixels);
            imagesc(imPtr.value,'Parent',h)
            axis square
            
%             statptr=libpointer('int32Ptr',0);
%             error=calllib('libandor','GetStatus',statptr);
%             disp(statptr.value)
%             ii
            
            pause(0.01)
        end
        calllib('libandor','AbortAcquisition');
        
end
        
        
% Close shutter and shut down cameras
error=calllib('libandor','SetCurrentCamera',cam1Handle);
error=calllib('libandor','SetShutter',0,2,10,10);
error=calllib('libandor','ShutDown');
error=calllib('libandor','SetCurrentCamera',cam2Handle);
error=calllib('libandor','SetShutter',0,2,10,10);
error=calllib('libandor','ShutDown');

unloadlibrary libandor;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






