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
prompt = {'Enter signal vector:','Enter Sampling Frequency:','Enter Channel Number:','Enter saving path:'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);

fprintf('Processing...\n');

% answers
signalname = answer{1,1};
Fs = str2double(answer{2,1});
channel = str2double(answer(3,1));
filepath = answer{4,1};

% load
% dlmread needs a filename, the delimiter, the number of rows of the
% header, and the starting row to read
data = dlmread(signalname,'\t', 3, 0);
% the signal is extracted from the data matrix, channel number needed
signal = data(:,channel);
signalLength = length(data);
signalTime = signalLength/Fs;
% create a timeline starting at 0 and with the length of the signal
timeline = linspace(0,signalTime,signalLength);

%% Processing Data

% filtering ecg
ecgfilter = filterECG(signal,timeline ,Fs,filepath);
% call function heartrate 
[heartrate,MeanRR,SDNN,RMSSD,mean_heartrate,std_heartrate,heartrate_coe,peakInterval,peakInterval_time] = heartrate(ecgfilter,timeline,Fs,filepath);
% call function ellipse
ellipse(peakInterval_time,filepath);

% Saving workspace
resultsFilename = 'results';

% clear runtime variables
clear dlg_title num_lines prompt 
fprintf('Saving analysis results to file ... ');

save([filepath filesep resultsFilename '.mat'], '-v7.3');
fprintf('Done.\n');
