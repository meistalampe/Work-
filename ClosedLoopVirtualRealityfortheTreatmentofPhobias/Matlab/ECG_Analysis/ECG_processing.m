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
prompt = {'Enter signal name:','Enter Sampling Frequency:','Enter Channel Number:'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);

% answers
s1 = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\ECG_Analysis\Raw Data Archive\';
%s1 = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\ECG_Analysis\Raw Data Archive\';
s2 = answer{1,1};
signalname = strcat(s1,s2);

Fs = str2double(answer{2,1});
channel = str2double(answer(3,1));
 filepath = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\ECG_Analysis\Save folder';
%filepath = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\ECG_Analysis\Save folder';
% load
% dlmread needs a filename, the delimiter, the number of rows of the
% header, and the starting row to read
% data = dlmread(signalname,'\t', 3, 0);
 data = dlmread(signalname,',', 3, 0);
% the signal is extracted from the data matrix, channel number needed
signal = data(:,channel);
nSamples = length(data);
signalTime = nSamples/Fs;
% create a timeline starting at 0 and with the length of the signal
time = linspace(0,signalTime,nSamples);
% time = 0:1/Fs:signalTime;
%% PreProcessing Data
 
% ########################################################################
% data adjustment
% ########################################################################

% Scale the signal per the specifications of the sensor
%signal_adj = ((((signal./((2.^10)-1))-0.5) .* 3.3)./ 1100) .* 1000;
signal_adj = ((((signal./(2.^10))-0.5) .* 3.3)./ 1100) .* 1000;

% ########################################################################
% cutoff
% ########################################################################

% calculate number of samples to remove
ct = 15;
cSamples = ct*Fs;
% remove cSamples from both ends
signal_co = signal_adj(cSamples:(end-cSamples));
time_co = time(cSamples:(end-cSamples));

% plot adjusted and cut signal

figure;
plot(time_co,signal_co);
title('ECG Time Domain')
xlabel('Time (t)')
ylabel('X(t)')

% ########################################################################
% fft
% ########################################################################

L = length(time_co);
n = 2^nextpow2(L);
% Convert the Signal to the frequency domain.
Y = fft(signal_co,n);
% Define the frequency domain and plot the unique frequencies.
f = Fs*(0:(n/2))/n;
P = abs(Y/n);

% plot frequency domain representation Y

figure;
plot(f,P(1:n/2+1)) 
title('ECG in Frequency Domain')
xlabel('Frequency (f)')
ylabel('|P(f)|')

% ########################################################################
% detrend
% ########################################################################

signal_dt = detrend(signal_co);

% ########################################################################
% filtering
% ########################################################################

% Nyquist frequency
Fn = Fs/2;

% create 50 Hz filter to counter the line interference

f0 = 50;                % notch frequency

freqRatio = f0/Fn;      % ratio of notch freq. to Nyquist freq.

notchWidth = 0.1;       % width of the notch

% Compute zeros
notchZeros = [exp( sqrt(-1)*pi*freqRatio ), exp( -sqrt(-1)*pi*freqRatio )];

% Compute poles
notchPoles = (1-notchWidth) * notchZeros;
% 
% figure;
% zplane(notchZeros.', notchPoles.');

b = poly( notchZeros ); % Get moving average filter coefficients
a = poly( notchPoles ); % Get autoregressive filter coefficients
% 
% figure;
% freqz(b,a,32000,Fs)

% apply notch filter
signal_notch = filter(b,a,signal_dt);

% signal_notch = notch50Hz(signal_dt);
% create bandpass filter
[b, a] = butter(4, [5 24]/Fn);
% fvtool(b,a);

% apply bandpass filter
signal_filt = filtfilt(b, a,signal_notch);
% signal_filt = sgolayfilt(signal_notch, 7, 41);
%plot filtered signal

figure;
hold on;
plot(time_co,signal_filt);
title 'bit ecg: filtered';
xlabel 'time [s]';
ylabel 'voltage [mV] ';
hold off;

% ########################################################################
% normalize
% ########################################################################

% cut artifacts that fake maxima
signal_filt(550*Fs:end) = [];
time_co(550*Fs:end) = [];

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
title 'R-spikes'
xlabel 'samples'
ylabel 'normalized amplitude'
hold off;

%% RR-distance

signal_diff = diff(locs);
signal_diff = signal_diff ./Fs ;


%% instantaneous HR
iHR = zeros(1,length(signal_diff));
for i = 1:length(signal_diff)
iHR(i) = 60 / signal_diff(i);
end

figure;
hold on;
plot(iHR);
title 'iHR'
xlabel 'samples'
ylabel 'iHR'
hold off;

% locs in time domain
locs_time = locs ./ Fs;

% calculate the distances between the R waves in Samples
peakInterval = diff(locs);
peakInterval_time = diff(locs_time);

% create a vector with heartrate data
heartrate_calc = zeros(1,length(peakInterval));

% calculate the heartrate
for u = 1:length(peakInterval)
    
    heartrate_calc(u) = (Fs/peakInterval(u))*60;
end

% create a vector heartrateSample
heartrateSample  = zeros(1,length(peakInterval));

% position the calculated heartarte value to the right sample
for v = 1:length(peakInterval)
    
    heartrateSample(v) = ceil(locs(v) + (peakInterval(v)/2));
end


% create vector with the same length as trial with the heartrate data
% fill it with the heartrate values at the right sample points

 counter = 1;
 heart_int = zeros(1,length(signal_norm));
 
 
 for z = 1:max(heartrateSample)
     
    if (heartrateSample(counter) == z)
     
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
HRV = 1./peakInterval_time;

% Plot the signals
figure;
plot(tHRV,HRV)
xlabel('Time(s)')
ylabel('HRV (Hz)')

figure;
hist(peakInterval_time);
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
