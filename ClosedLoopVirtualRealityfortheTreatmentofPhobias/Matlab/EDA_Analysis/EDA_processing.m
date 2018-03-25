%% file header

% filename:     EDA_processing
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

st = '.txt';
% answers
s1 = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Raw Data Archive\';
%s1 = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Raw Data Archive\';
s2 = answer{1,1};
signalname = strcat(s1,s2,st);

b1 ='F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Raw Data Archive\';
%b1 = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Raw Data Archive\';
b2 = answer{4,1};
baselinename = strcat(b1,b2,st);

Fs = str2double(answer{2,1});
channel = str2double(answer(3,1));

% save to filepath
sLocal = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Save folder\';
%sLocal = 'C:\Users\Dominik\Desktop\GitRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\Save folder';
sFolder = 'Results-';
sMeas = '\EDA';
filepath = strcat(sLocal,sFolder,s2,sMeas);

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

baseline = baseline_data(:,channel);
bSamples = length(baseline_data);

nSignalTime = nSamples/Fs;
bSignalTime = bSamples/Fs;  % baseline must be sampled with the same frequency

% create a timeline starting at 0 and with the length of the signal
ntime = linspace(0,nSignalTime,nSamples);
btime = linspace(0,bSignalTime,bSamples);

s3 = '_BL';
[baseline_filt, btime_co, baseline_adj] = eda_filter(baseline,btime,Fs,filepath,s3);
% cut artifacts that fake maxima
% baseline_filt(22250:end) = [];
% btime_co(22250:end) = [];

[bsignal_ba,bmov_avg,bSCL_diff,bSCL_mean,bSCL_med,bP_int,bP_mean,bP_std,bPR_avg,bPR] = eda_feature(baseline_filt,btime_co,baseline_filt,Fs,s3,filepath);

s3 = '_VR';
[signal_filt, ntime_co, signal_adj] = eda_filter(signal,ntime,Fs,filepath,s3);

% % cut artifacts that fake maxima
signal_filt(22250:end) = [];
ntime_co(22250:end) = [];
[nsignal_ba,nmov_avg,nSCL_diff,nSCL_mean,nSCL_med,nP_int,nP_mean,nP_std,nPR_avg,nPR] = eda_feature(signal_filt,ntime_co,baseline_filt,Fs,s3,filepath);
%% EDA analysis
if max(nP_int) >= max(bP_int)
    x_max = max(nP_int);
else
    x_max = max(bP_int);
end

figure;
hold on;
subplot(2,1,1);
hist(bP_int);
grid on;
xlim([0 x_max]);
title(sprintf('avg. Peak Interval = %f s, avg. Peak Rate = %f peaks/s',bP_mean, bPR_avg));
ylabel('peak interval distribution');
legend ('Baseline');

subplot(2,1,2); 
hist(nP_int);
grid on;
xlim([0 x_max]);
title(sprintf('avg. Peak Interval = %f s, avg. Peak Rate = %f peaks/s',nP_mean, nPR_avg));
xlabel('sampling interval [s]');
ylabel('peak interval distribution');
legend ('Exposure');
hold off;

s1 = 'Peak Interval Histogram BL vs EXP';
s3 = '_VR';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')


%% Code Storage

%% Saving Data

% Saving workspace
saveFilename = 'EDA_';
saveFilename = strcat(saveFilename,s2);
% clear runtime variables
clear dlg_title num_lines prompt 

save([filepath filesep saveFilename '.mat'], '-v7.3');
fprintf('Done.\n');