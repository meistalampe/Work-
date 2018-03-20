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
%s1 = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\ECG_Analysis\Raw Data Archive\';
s1 = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\ECG_Analysis\Raw Data Archive\';
s2 = answer{1,1};
signalname = strcat(s1,s2);

Fs = str2double(answer{2,1});
channel = str2double(answer(3,1));
% filepath = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\ECG_Analysis\Save folder';
filepath = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\ECG_Analysis\Save folder';
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
signal_adj = ((((signal./(2.^10))-0.5) .* 3.3)./ 1100) .* 1000;

% ########################################################################
% cutoff
% ########################################################################

% calculate number of samples to remove
ct = 3;
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

figure;
zplane(notchZeros.', notchPoles.');

b = poly( notchZeros ); % Get moving average filter coefficients
a = poly( notchPoles ); % Get autoregressive filter coefficients

figure;
freqz(b,a,32000,Fs)

% apply notch filter
signal_notch = filter(b,a,signal_dt);

% create bandpass filter
[b, a] = butter(4, [5 26]/Fn);
% fvtool(b,a);

% apply bandpass filter
signal_filt = filtfilt(b, a,signal_notch);

% plot filtered signal

figure;
hold on;
plot(time_co,signal_filt);
title 'bit ecg: filtered';
xlabel 'time [s]';
ylabel 'voltage [mV] ';
hold off;

% Filter the scaled signal using a Savitzky-Golay filter
ECG_data = sgolayfilt(signal_co, 7, 35);


%% Feature extraction Bit way
t = 1:length(ECG_data);
[~,locs_Rwave] = findpeaks(ECG_data,'MinPeakHeight',0.9,...
                                    'MinPeakDistance',500);

% Remove Edge Wave Data
locs_Rwave(locs_Rwave < 150 | locs_Rwave > (length(ECG_data) - 150)) = [];
locs_Qwave = zeros(length(locs_Rwave),1);
locs_Swave = zeros(length(locs_Rwave),1);
locs_Qpre  = zeros(length(locs_Rwave),1);
locs_Spost = zeros(length(locs_Rwave),1);
QRS = zeros(length(locs_Rwave),1);

% Find Q and S waves in the signal
for ii = 1:length(locs_Rwave)
    window = ECG_data((locs_Rwave(ii)-80):(locs_Rwave(ii)+80));
    [d_peaks, locs_peaks] = findpeaks(-window, 'MinPeakDistance',40);
    [d,i] = sort(d_peaks, 'descend');
    locs_Qwave(ii) = locs_peaks(i(1))+(locs_Rwave(ii)-80);
    locs_Swave(ii) = locs_peaks(i(2))+(locs_Rwave(ii)-80);
    [d_QRS, locs_QRS] = findpeaks(window, 'MinPeakDistance', 10);
    [max_d, max_i] = max(d_QRS);
    locs_Q_flat = locs_QRS(max_i-1);
    locs_S_flat = locs_QRS(max_i+1);
    locs_Qpre(ii)  = locs_Q_flat+(locs_Rwave(ii)-80);
    locs_Spost(ii) = locs_S_flat+(locs_Rwave(ii)-80);
    QRS(ii) = locs_S_flat - locs_Q_flat;
end

% Calculate the heart rate
myqrs = median(QRS);
myheartrate = 60 ./ (median(diff(locs_Rwave)) ./ 1000);

locs_all = [locs_Qwave; locs_Rwave; locs_Swave; locs_Qpre; locs_Spost];
ECG_all  = ECG_data(locs_all);

[d,i] = sort(locs_all);
ECG_sort = ECG_all(i);

%Visualize the Raw Data and Measured Heart Rate

figure
hold on
plot(t,ECG_data);
plot(locs_Qwave,ECG_data(locs_Qwave),'rs','MarkerFaceColor','g');
plot(locs_Rwave,ECG_data(locs_Rwave),'rv','MarkerFaceColor','r');
plot(locs_Swave,ECG_data(locs_Swave),'rs','MarkerFaceColor','b');
plot(locs_Qpre, ECG_data(locs_Qpre), 'r>','MarkerFaceColor','c');
plot(locs_Spost,ECG_data(locs_Spost),'r<','MarkerFaceColor','m');
grid on
% Adjust the plot to show 8 seconds worth of measurements
ylim([-1 2]);
title(sprintf('QRS = %f ms,  Heart Rate = %f / min', myqrs, myheartrate));
xlabel('Samples'); ylabel('Voltage(mV)')
legend('ECG signal','Q-wave','R-wave','S-wave','Q-pre','S-post');

%% Feature extraction own

[pks,locs,w,p] = findpeaks(signal_filt,'MinPeakHeight',0.9,...
                                    'MinPeakDistance',500);

figure;
hold on;
plot(signal_filt);
plot(locs,pks,'+');
title 'pks'
xlabel 'samples'
ylabel 'amp'
hold off;



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
