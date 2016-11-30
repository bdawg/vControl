% How long will it take?

filts=[1 2 3 4 5];
%filts=[1 2];
HWPs=[0 22.5 45 67.5];
polas=[0 45 90 135];
QWPs=[0 20 40 60 80 100 120 140 160 180 200 220 240 260 280 300 320];
%QWPs=[0 20 40 60 80 100 120 140 160];
    
% Specify waiting times (seconds)
filtWait = 3;
HWPWait = 7; % For 22.5 degrees
polaWait = 14; % for 45 degrees
polaInWait = 5; % Guess - measure this!
depolWait = 3; % Guess - measure this!
QWPWait = 5; % Guess - measure this!

%time for integration:
intTime = 2;
%intTime=1;


et=0;
numInts=0;

for filt_ind = 1:length(filts)    
    fwVal=filts(filt_ind);
    disp(['Filter: ' num2str(fwVal)])
    cmnd=strcat('pos=',num2str(fwVal));
    %fprintf(fwObj,cmnd); fscanf(fwObj);
    %pause(filtWait)
    et = et + filtWait;
    if filt_ind == 1 
        %pause(filtWait*(length(filts)-1))
        et = et + filtWait*(length(filts)-1);
    end
    
    for HWP_ind = 1:length(HWPs)  
        %HWPAngle = HWPs(HWP_ind) + getappdata(handles.vCamGui,'hwpCalOffset');
        %disp(['HWP: ' num2str(HWPs(HWP_ind))])  
        %cmndString=strcat('1PA',num2str(HWPAngle));
        %fprintf(conex1Obj,cmndString);
        %pause(HWPWait)
        et = et + HWPWait;
        if HWP_ind == 1
            %pause(HWPWait*(length(HWPs)-1))
            et=et+HWPWait*(length(HWPs)-1);
        end
        
        for pola_ind = 1:(length(polas)+1)
            if pola_ind == 1
                disp('Polariser in')
                %#### system('ssh scexao@133.40.160.210 /home/scexao/bin/devices/polarizer goto 3000000');
                %pause(polaInWait)
                et=et+polaInWait;
            end
            if pola_ind == (length(polas)+1)
                disp('Polariser out')
                %#### system('ssh scexao@133.40.160.210 /home/scexao/bin/devices/polarizer home');
                %pause(polaInWait)
                et=et+polaInWait;
                disp('Depolariser in')
                %#### system('ssh scexao@133.40.160.210 /home/scexao/bin/devices/depolarizer');
                %pause(depolWait)
                et=et+depolWait;
            end
            if pola_ind <= length(polas)
                %polAngle=polas(pola_ind) + getappdata(handles.vCamGui,'polaCalOffset');
                %disp(['Polariser: ' num2str(polas(pola_ind))])
                %cmndString=strcat('1PA',num2str(polAngle));
                %fprintf(conex3Obj,cmndString);
                %pause(polaWait)
                et=et+polaWait;
                if pola_ind == 1
                    %pause(polaWait*(length(polas)-1))
                    et=et+polaWait*(length(polas)-1);
                end
            end
                        
            for QWP_ind = 1:length(QWPs)
                %QWPAngle = QWPs(QWP_ind) + getappdata(handles.vCamGui,'qwpCalOffset');
                %disp(['QWP: ' num2str(QWPs(QWP_ind))])
                %movePRM(prmObj,QWPAngle,0)
                %pause(QWPWait)
                et=et+QWPWait;
                if QWP_ind == 1
                    %pause(QWPWait*(length(QWPs)-1))
                    et=et+QWPWait*(length(QWPs)-1);
                end
                
                % Now actually take data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %disp('Saving data')
                et=et+intTime;
                numInts=numInts+1;
            end
            if pola_ind == (length(polas)+1)  
                disp('Depolariser out')
                %#### system('ssh scexao@133.40.160.210 /home/scexao/bin/devices/depolarizer');
                %pause(depolWait)
                et=et+depolWait;
            end
            %if getappdata(handles.vCamGui,'abortStatus') == 1
            %    break
            %end 
        end
        %if getappdata(handles.vCamGui,'abortStatus') == 1
        %    break
        %end 
    end
    %if getappdata(handles.vCamGui,'abortStatus') == 1
    %    setappdata(handles.vCamGui,'abortStatus',0)
    %    break
    %end 
end


disp(['Estimated time (hours): ' num2str(et/60/60)])
disp(['NumInts: ' num2str(numInts)])