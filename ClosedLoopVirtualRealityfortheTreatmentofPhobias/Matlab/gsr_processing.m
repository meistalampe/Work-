% 1. Downsampling
% 2. Eliminate tonic part
% 3. Identify peaks

clc;
clear;
close all;

%% Load Data

load('gsr_example.mat');
load('time_example.mat');

%% Signal information

% sampling frequency
Fs = 512;

%% Downsampling

% from Fs = 512 Hz to Ts_down e.g. for Fs_down 16 Hz factor_down = 32
factor_down = 32;
Fs_down = Fs / factor_down;
 
gsr_down = downsample(gsr_spec,factor_down);
time_down = downsample(time,factor_down);

%% Decomposition

data = gsr_down;
% number of samples
gsr_samples = length(data);
% array for phasic component
gsr_scr = zeros(1,gsr_samples);
% array for tonic component
% gsr_scl = zeros(1,gsr_samples);
% array to store time interval mean
gsr_scl_mean = zeros(1,gsr_samples);
% tDelta in seconds
tDelta = 4;
% tDelta_mean is an array that holds a nummer of samples according to
% tDelta
tDelta_mean = Fs_down * tDelta;
% gsr_scl_mean is formed over an intervall of 2*tDelta, tDelta from 
% either side of current value 
tDelta_mod = mod(tDelta_mean,2);
if tDelta_mod == 0
    tDelta_mean = tDelta_mean+1;
end
% own way
for counter = 1:gsr_samples
    if counter <= tDelta_mean
        gsr_scl = data(1:counter+counter-1);
        gsr_scl_mean(counter) = mean(gsr_scl);
        
        gsr_scr(counter) = data(counter) - gsr_scl_mean(counter);
      
    elseif counter >= gsr_samples-tDelta_mean
        gsr_scl = data(counter-tDelta_mean:end);
        gsr_scl_mean(counter) = mean(gsr_scl);
        
        gsr_scr(counter) = data(counter) - gsr_scl_mean(counter);
    
    else 
        gsr_scl = data((counter-tDelta_mean)+1 :counter + tDelta_mean);
        gsr_scl_mean(counter) = mean(gsr_scl);
        
        gsr_scr(counter) =  data(counter) - gsr_scl_mean(counter);
    end
end

% matlab functions

gsr_med_scl = medfilt1(data,50);
gsr_med_scr = data - gsr_med_scl;

% gsr_lla = zeros(1,gsr_samples);
% 
% for counter = 1:gsr_samples
% 
%     if gsr_scl_mean(counter) <= data(counter)
%         gsr_lla(counter) = gsr_scl_mean(counter);
%     else
%         gsr_lla(counter) = data(counter);
%     end
% end
% 

%% Find Peaks
[pks,locs,widths] = findpeaks(gsr_scr,'MinPeakProminence',0.98);
[pks2,locs2,widths2] = findpeaks(gsr_med_scr,'MinPeakProminence',0.98);

if length(locs) >= length(locs2)
    c = length(locs);
    locs2_new = [locs2 zeros(1,(c - length(locs2)))];
    locs_new = locs;
    delta_locs = zeros(1,c);
    peak_number_perc = abs(length(locs) - length(locs2)) * 100/ length(locs);
else
    c = length(locs2);
    locs_new = [locs zeros(1,(c - length(locs)))];
    locs2_new = locs2;
    delta_locs = zeros(1,c);
    peak_number_perc = abs(length(locs2) - length(locs)) * 100/ length(locs2);
end

match = 0;
for i = 1:c
    delta_locs(i) = abs(locs_new(i) - locs2_new(i));
    if delta_locs(i) == 0
    match = match+1;    
    end
end


match_per = match*100/c;

%% Plot
figure;
hold on;
plot(gsr_scr);
plot(locs,pks,'*');
plot(gsr_med_scr);
plot(locs2,pks2,'+');
legend('Phasic_own','Peaks_own','Phasic_m','Peaks_m')
legend('boxoff')
hold off;
% 
% %
% figure;
% subplot(2,1,1)       
% plot(time,gsr_spec)
% title('Subplot 1')
% 
% subplot(2,1,2)       
% plot(time_down,gsr_down)       
% title('Subplot 2')


figure;
hold on;
plot(time_down,data);
plot(time_down,gsr_med_scl);
plot(time_down,gsr_med_scr);
legend('Original','Filtered','Phasic')
legend('boxoff')
hold off;

