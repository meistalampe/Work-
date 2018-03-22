%% file header

% filename:     ECG_processing
% author:       dominik limbach
% date:         08.02.18

% description:  this program does the following
%               

%% Load Data
clc;
clear;
close all;  

% dialogbox settings
prompt = {'Enter signal name:','Enter Sampling Frequency:','Enter Channel Number:','Enter baseline name:'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);

% answers
s1 = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Raw Data Archive\';
%s1 = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Raw Data Archive\';
s2 = answer{1,1};
signalname = strcat(s1,s2);

b1 ='F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Raw Data Archive\';
%b1 = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Raw Data Archive\';
b2 = answer{4,1};
baselinename = strcat(b1,b2);

Fs = str2double(answer{2,1});
channel = str2double(answer(3,1));
filepath = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Save folder';
%filepath = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Save folder';


% load raw data
% dlmread needs a filename, the delimiter, the number of rows of the
% header, and the starting row to read

% tab separated read
% signal_data = dlmread(signalname,'\t', 3, 0);
% baseline_data = dlmread(baselinename,'\t', 3, 0);

% comma separated read
signal_data = dlmread(signalname,',', 3, 0);
baseline_data = dlmread(baselinename,',', 3, 0);

% the signal is extracted from the data matrix, channel number needed
signal = signal_data(:,channel);
nSamples = length(signal_data);

baseline = baseline_data(:,7);
bSamples = length(baseline_data);

nSignalTime = nSamples/Fs;
bSignalTime = bSamples/Fs;  % baseline must be sampled with the same frequency

% create a timeline starting at 0 and with the length of the signal
ntime = linspace(0,nSignalTime,nSamples);
btime = linspace(0,bSignalTime,bSamples);

[signal_filt, ntime_co] = ecg_filter(signal,ntime,Fs,filepath);
[baseline_filt, btime_co] = ecg_filter(baseline,btime,Fs,filepath);

% ########################################################################
% normalize
% ########################################################################

% cut artifacts that fake maxima
signal_filt(550*Fs:end) = [];
ntime_co(550*Fs:end) = [];

signal_min = min(signal_filt);
signal_max = max(signal_filt);
signal_mag = abs(signal_min-signal_max);
signal_norm = (signal_filt - signal_min)./signal_mag;

% square
% signal_square = signal_norm .^2;

%% Feature extraction own

[pks,locs,w,p] = findpeaks(signal_norm,'MinPeakHeight',0.6);

figure;
hold on;
plot(signal_norm);
plot(locs,signal_norm(locs),'rv','MarkerFaceColor','r');
%plot(locs,pks,'o');
title 'R-Peaks'
xlabel 'samples'
ylabel 'normalized amplitude'
hold off;

%% RR-distance

signal_diff = diff(locs);
RR_int = signal_diff ./Fs ; % time
RR_mean = mean(RR_int);     % time

%% instantaneous HR
iHR = zeros(1,length(RR_int));
for i = 1:length(RR_int)
iHR(i) = 60 / RR_int(i);
end

iHR_mean = mean(iHR);
figure;
hold on;
plot(iHR);
title 'iHR (bpm)'
xlabel 'samples'
ylabel 'iHR'
hold off;


% create a vector heartrateSample
HR_sample  = zeros(1,length(signal_diff));

% position the calculated heartarte value to the right sample
for v = 1:length(signal_diff)
    
    HR_sample(v) = ceil(locs(v) + (signal_diff(v)/2));
end


% create vector with the same length as trial with the heartrate data
% fill it with the heartrate values at the right sample points

 counter = 1;
 heart_int = zeros(1,length(signal_norm));
 
 
 for z = 1:max(HR_sample)
     
    if (HR_sample(counter) == z)
     
       heart_int(z) = heartrate_calc(counter);
       counter = counter +1;
        
    end   
 end
 
 valuepositions = find(heart_int > 0);
 first_position = valuepositions(1);
 last_position  = valuepositions(end);
 
 % Fill the rest of the vector with interpolated values for displaying
for l =  first_position : last_position

    % values smaller than 50 b/m  -> bradykardie (heart_int(l) < 50)
    if heart_int(l+1) == 0   
        
        heart_int(l+1) = heart_int(l);
    end

end


heartrate = heart_int;



%% lomb scargle power plot
% of the RR Interval data with gaps
% The typical frequency bands of interest in HRV spectra are:
% 
% Very Low Frequency (VLF), from 3.3 to 40 mHz,
% Low Frequency (LF), from 40 to 150 mHz,
% High Frequency (HF), from 150 to 400 mHz.

% These bands approximately confine the frequency ranges of the distinct 
% biological regulatory mechanisms that contribute to HRV.
% Fluctuations in any of these bands have biological significance.


% Derive the HRV signal
tHRV = locs_time(2:end);
HRV = 1./RR_int;


% Plot the signals
figure;
hold on;
plot(tHRV,HRV)
xlabel('Time(s)')
ylabel('HRV (Hz)')

figure;
hist(RR_int);
title 'histogram of the peak separations in seconds';
grid on;
xlabel('Sampling interval (s)');
ylabel('RR distribution');

figure;
plomb(HRV,tHRV,'Pd',[0.95, 0.5]);

% The dashed lines denote 95
% and 50% detection probabilities.
%These thresholds measure the statistical significance of peaks. 
%The spectrum shows peaks in all three bands of interest listed above.

%% Code Storage
% % filtering ecg
% ecgfilter = filterECG(signal,timeline ,Fs,filepath);
% % call function heartrate 
% [heartrate,MeanRR,SDNN,RMSSD,mean_heartrate,std_heartrate,heartrate_coe,peakInterval,peakInterval_time] = heartrate(ecgfilter,timeline,Fs,filepath);
% % call function ellipse
% ellipse(peakInterval_time,filepath);

%% Saving Data

% Saving workspace
resultsFilename = 'results';

% clear runtime variables
clear dlg_title num_lines prompt 
fprintf('Saving analysis results to file ... ');

save([filepath filesep resultsFilename '.mat'], '-v7.3');
fprintf('Done.\n');
