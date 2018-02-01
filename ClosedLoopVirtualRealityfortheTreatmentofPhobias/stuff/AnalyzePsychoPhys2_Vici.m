close all;
clear all;
clc;
%--------------------------------------------------------------------------
%definitions
%--------------------------------------------------------------------------
subjects =[2 4 5 6 7 8 9 10 11 12 13 14]; % numbers of included subjects
condition = {(strcat('easysn'));(strcat('easycfn'));(strcat('easycin'));...
    (strcat('diffsn'));(strcat('diffcfn'));(strcat('diffcin'));...
 (strcat('diffsnd'));(strcat('diffcfnd'));(strcat('diffcind'))}; %9
%path of the raw data
path1 = 'E:\AEV\A Results\';
%path where to save the processed data
path2 = 'E:\AEV\A Results\';
fs = 512; % sampling frequency
% pupil = 1; % 1 = Right pupil diameter, everything else = left pupil diameter;
% analyseTimePup = 2; % time in which the Pupil Signal is analyzed
% waitingTimePup = 0;% t-ime after stimulus/trigger onset that is not analyzed
% baselineTimePup = 1; % time for baseline measurements
% analyseTimePA = 4; % time in which the Pulse and ECG Signal is analyzed
% waitingTimePA = 0; % time after stimulus/trigger onset that is not analyzed
% baselinetimePA = 1; % time for baseline measurements
analyseTimeEDA = 2; % time in which the EDA Signal is analyzed
waitingTimeEDA = 0.5; % time after stimulus/trigger onset that is not analyzed
baselineTimeEDA = 1; % time for baseline measurements
normalization = 1; % 0 = no normalsization at EDA, 1 = normalization against the baseline
% normalizationType=1; % calculates one RR-interval befor trigger onset
window =5;  % time window for averaging the GSR
diffCondition = 1; % amount of different Triggersignals/different conditions
countTrigger = 10; % amount of Triggersignals that are the same condition

%definition of a variable for all subjects
ALLSubsMeanSCL = zeros(length(subjects),diffCondition); %skin conductance level
ALLSubsMeanSCR = zeros(length(subjects),diffCondition); % skin conductance response
% ALLSubsMeanPA = zeros(length(subjects),diffCondition); %pulse amplitude/blood volume
% ALLSubsMeanRR = zeros(length(subjects),diffCondition); % RR-interval
% ALLSubsMeanMaxPup = zeros(length(subjects),diffCondition); % max pupil amplitude
% ALLSubsMeanMidPup = zeros(length(subjects),diffCondition); % mid pupil dilation


for counter1 = 1:length(subjects)

    if subjects(counter1)>9
        subnum=num2str(subjects(counter1)); %subs 10 - end
    else
        subnum=[ '0' num2str(subjects(counter1))]; % subs 1-9
    end
    
    for bedingung = 1:9
    % change name if neccessary
    load([path1   'Subject' subnum '\Original\'  subnum condition{bedingung}]);
    disp([ subnum condition{bedingung}])
    
    
trigger248 = find(diff(triggerSignal) > 0.19) + 1; 
trigger48 = find(diff(triggerSignal) > 0.39) + 1;
trigger8 = find(diff(triggerSignal) > 0.79) + 1;

for counterv2 = 1:length(trigger48)
    for counterv1 = 1:length(trigger248)
        if trigger248(1,counterv1) == trigger48(1,counterv2) %Wenn Trig48 in Trig 248 enthalten 
            trigger248(1,counterv1) = 0;  % löschen
            break;
        end
    end
end
trigger2 = trigger248(trigger248 > 0); %Nur noch Trig2 übrig, gespeichert als Samples

    
    
    % which pupil diameter is used
%     if pupil == 1 
%         Pupil = R_pupil_dia;
%     else
%         Pupil = L_pupil_dia;
%     end   
    % define the time windows that are analyzed
    timeWindowEDA = waitingTimeEDA+analyseTimeEDA;
%     timeWindowPA = waitingTimePA+analyseTimePA;
%     timeWindowPup = waitingTimePup+analyseTimePup;
    
    for counter2 = 1:diffCondition % Analysis for each condition
%         diffTrigg = trigger(counter2,:); 
        diffTrigg = trigger2;
        GSR = y(132,:);
        
        %filtering---------------------------------------------------------
%         [ sequence_filt_PA] = ffilt_PPG(Pulse, fs);
%         [ sequence_filt_RR] = ffilt_ECG(ECG, fs);
        [ sequence_filt_GSR] = ffilt_GSR(GSR);
        %interpolation pupil
%         [pupilDiameter,interpolationRate] = fpupilInterpolation(Pupil);
        %segmentation------------------------------------------------------
       [segmentedDataEDA,triggerSegmentsEDA]=fSegmentation1(sequence_filt_GSR,diffTrigg,...
           timeWindowEDA,baselineTimeEDA, fs);
%        [segmentedDataRR,segmentedDataPulse,triggerSegments,normValueRR,normValuePA]= ...
%            fSegmentation2(sequence_filt_RR,sequence_filt_PA,diffTrigg,...
%            timeWindowPA,normalizationType, fs);
%        [segmentedDataPup,triggerSegmentsPup]=fSegmentation1(Pupil,diffTrigg,...
%            timeWindowPup,baselineTimePup, fs);
       
      
%        midPupWholeCond = zeros(countTrigger,(analyseTimeEDA*fs)+1);
%        maxPupWholeCond = [];
       SCLWholeCond = zeros (countTrigger,(analyseTimeEDA*fs)+1);
       SCRWholeCond = [];
%        PAWholeCond = [];
%        RRWholeCond = [];
       
       for counter3 = 1:countTrigger % Analysis of each Triggersignal for each condition
           triggerSequenceEDA = triggerSegmentsEDA(counter3,:);
%            triggerSequencePup = triggerSegmentsPup(counter3,:);
%            sequenceSegmentPup = segmentedDataPup(counter3,:);
           sequenceSegmentEDA = segmentedDataEDA(counter3,:);
%            sequenceECG = segmentedDataRR(counter3,:);
%            sequencePulse = segmentedDataPulse(counter3,:);
           %---------------------------------------------------------------
           %EDA
           [SCL,SCRamplitude,locationPeak,peaks] = ...
            fGSR (sequenceSegmentEDA, fs,normalization, ...
            baselineTimeEDA, triggerSequenceEDA,window,waitingTimeEDA,analyseTimeEDA);
            %PA and ECG
%             [~,RLocation,~]=pan_tompkin(sequenceECG,fs,0);
%             [Pulse_smoothed, pulseRate, pulseAmplitude, meanPulseAmplitude, RRintervals]...
%                 = fPPG (sequencePulse, RLocation, fs);
%             pulseAmplitude = pulseAmplitude-normValuePA(counter3);
%             RRintervals = RRintervals -normValueRR(counter3);
%             %pupil dilation
%            [pupDia] = fpupilNorm (sequenceSegmentPup, fs, baselineTimePup, triggerSequencePup,waitingTimePup,analyseTimePup);
            %--------------------------------------------------------------
            SCLWholeCond (counter3,:) = SCL; 
            SCRWholeCond  = [SCRWholeCond SCRamplitude];
%             midPupWholeCond(counter3,:) = pupDia;
%             maxPupWholeCond = [maxPupWholeCond max(pupDia)];
%             PAWholeCond = [PAWholeCond pulseAmplitude];
%             RRWholeCond = [RRWholeCond RRintervals];
            
            clear RRintervals SCRamplitude pupDia pulseAmplitude ...
                SCL triggerSequenceEDA triggerSequencePup sequenceECG...
                sequencePulse sequenceSegmentEDA sequenceSegmentPup...
                sequence_filt_GSR sequence_filt_PA sequence_filt_RR;
            
       end
       %Trennung der Trigger (gleiche Höhe)
       eval(['SCLCond' num2str(counter2) '= SCLWholeCond;' ]);
       eval (['SCRCond' num2str(counter2) '=SCRWholeCond;']);
%        eval (['midPupWholeCond' num2str(counter2) '=midPupWholeCond;']);
%        eval (['maxPupWholeCond' num2str(counter2) '=maxPupWholeCond;']);
%        eval (['PAWholeCond' num2str(counter2) '=PAWholeCond;']);
%        eval (['RRWholeCond' num2str(counter2) '=RRWholeCond;']);
       
       %change name if neccessary
       save([ path2 subnum '_PsychoPhys_' difficulty '_' sound]);
       
       %get everything together for all subjects/ calculation of the means
       %for all subjects
        ALLSubsMeanSCL(counter1,counter2) = mean(SCLWholeCond(:));
        ALLSubsMeanSCR(counter1,counter2)=mean(SCRWholeCond);
        ALLSubsMeanPA(counter1,counter2)  = mean(PAWholeCond);
        ALLSubsMeanRR(counter1,counter2)  = mean (RRWholeCond);
        ALLSubsMeanMaxPup(counter1,counter2)  = mean(maxPupWholeCond);
        ALLSubsMeanMidPup(counter1,counter2)  = mean(midPupWholeCond(:));
    end 
    end
end

% meanAllSubsSCL = mean(ALLSubsMeanSCL);
% stdAllSubsSCL = std (ALLSubsMeanSCL);
% figure; plot(1.2,ALLSubsMeanSCL(:,1),'g*');hold on;plot(2.2,ALLSubsMeanSCL(:,2),'b*');hold on; plot(3.2,ALLSubsMeanSCL(:,3),'r*');hold on;
% errorbar(meanAllSubsSCL,stdAllSubsSCL,'ko','LineWidth',2);
% set (gca, 'fontsize', 12,'FontName', 'arial','fontweight','b');
% xlabel('conditions');
% ylabel('SCL in µS');
% 
% 
% meanAllSubsSCR = mean(ALLSubsMeanSCR);
% stdAllSubsSCR = std (ALLSubsMeanSCR);
% figure; plot(1.2,ALLSubsMeanSCR(:,1),'g*');hold on;plot(2.2,ALLSubsMeanSCR(:,2),'b*');hold on; plot(3.2,ALLSubsMeanSCR(:,3),'r*');hold on;
% errorbar(meanAllSubsSCR,stdAllSubsSCR,'ko','LineWidth',2);
% set (gca, 'fontsize', 12,'FontName', 'arial','fontweight','b');
% xlabel('conditions');
% ylabel('SCR in µS');
% 
% meanAllSubsPA = mean(ALLSubsMeanPA);
% stdAllSubsPA = std (ALLSubsMeanPA);
% figure; plot(1.2,ALLSubsMeanPA(:,1),'g*');hold on;plot(2.2,ALLSubsMeanPA(:,2),'b*');hold on; plot(3.2,ALLSubsMeanPA(:,3),'r*');hold on;
% errorbar(meanAllSubsPA,stdAllSubsPA,'ko','LineWidth',2);
% set (gca, 'fontsize', 12,'FontName', 'arial','fontweight','b');
% xlabel('conditions');
% ylabel('Pulse amplitude in V');
% 
% meanAllSubsRR = mean(ALLSubsMeanRR);
% stdAllSubsRR = std (ALLSubsMeanRR);
% figure; plot(1.2,ALLSubsMeanRR(:,1),'g*');hold on;plot(2.2,ALLSubsMeanRR(:,2),'b*');hold on; plot(3.2,ALLSubsMeanRR(:,3),'r*');hold on;
% % % errorbar(meanAllSubsRR,stdAllSubsRR,'ko','LineWidth',2);
% set (gca, 'fontsize', 12,'FontName', 'arial','fontweight','b');
% xlabel('conditions');
% ylabel('RR-intervals in ms');
% 
% meanAllSubsMaxPup = mean(ALLSubsMeanMaxPup);
% stdAllSubsMaxPup = std (ALLSubsMeanMaxPup);
% figure; plot(1.2,ALLSubsMeanMaxPup(:,1),'g*');hold on;plot(2.2,ALLSubsMeanMaxPup(:,2),'b*');hold on; plot(3.2,ALLSubsMeanMaxPup(:,3),'r*');hold on;
% % % errorbar(meanAllSubsMaxPup,stdAllSubsMaxPup,'ko','LineWidth',2);
% set (gca, 'fontsize', 12,'FontName', 'arial','fontweight','b');
% xlabel('conditions');
% ylabel('max pupil diameter in mm');
%
% meanAllSubsMidPup = mean(ALLSubsMeanMidPup);
% stdAllSubsMidPup = std (ALLSubsMeanMidPup);
% figure; plot(1.2,ALLSubsMeanMidPup(:,1),'g*');hold on;plot(2.2,ALLSubsMeanMidPup(:,2),'b*');hold on; plot(3.2,ALLSubsMeanMidPup(:,3),'r*');hold on;
% % % errorbar(meanAllSubsMidPup,stdAllSubsMidPup,'ko','LineWidth',2);
% set (gca, 'fontsize', 12,'FontName', 'arial','fontweight','b');
% xlabel('conditions');
% ylabel('mid pupil diameter in mm');

%change name if neccessary
 save(['voc' difficulty '_' sound],'ALLSubsMeanSCR','ALLSubsMeanSCL','ALLSubsMeanPA','ALLSubsMeanRR','ALLSubsMeanMaxPup','ALLSubsMeanMidPup')
