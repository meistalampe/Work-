
%% file header

% filename:     gsr_processing
% author:       dominik limbach
% date:         08.02.18

% description:  this program does the following
%               1. denoising, filtering, baseline sub,ffs
%               2. seperates scl and scr based on ffs
%               

%%  Load Data
clc;
clear;
close all;  
addpath(genpath('../'));


prompt = {'Enter signal vector:','Enter signal time vector',...
          'Enter Sampling Frequency:','Enter path to saving figures'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);

fprintf('Processing...\n');
% answers
signalname = answer{1,1};
time = answer{2,1};
Fs = str2double(answer{3,1});
filepath = answer{4,1};

% load data
signal = load(signalname);
signal = struct2cell(signal);
signal = signal{1,1};
time = load(time);
time = struct2cell(time);
time = time{1,1};

%% Filter Signal

% filtering gsr
gsrfilter = filterGSR( signal,time ,Fs,filepath);






%% 
% %% Old part .... Load Data
% 
% load('gsr_example.mat');
% load('time_example.mat');
% 
% %% Signal information
% 
% % sampling frequency
% Fs = 512;
% 
% %% Downsampling
% 
% % from Fs = 512 Hz to Fs_down e.g. for Fs_down 16 Hz 
% Fs_down = 32;
% factor_down= Fs / Fs_down;
%  
% gsr_down = downsample(gsr_spec,factor_down);
% time_down = downsample(time,factor_down);
% 
% %% Decomposition
% 
% data = gsr_down;
% % number of samples
% gsr_samples = length(data);
% % array for phasic component
% gsr_scr = zeros(1,gsr_samples);
% % array for tonic component
% % gsr_scl = zeros(1,gsr_samples);
% % array to store time interval mean
% gsr_scl_mean = zeros(1,gsr_samples);
% % tDelta in seconds
% tDelta = 4;
% % tDelta_mean is an array that holds a nummer of samples according to
% % tDelta
% tDelta_mean = Fs_down * tDelta;
% % gsr_scl_mean is formed over an intervall of 2*tDelta, tDelta from 
% % either side of current value 
% tDelta_mod = mod(tDelta_mean,2);
% if tDelta_mod == 0
%     tDelta_mean = tDelta_mean+1;
% end
% % own way
% 
% clock_1 = tic;
% for counter = 1:gsr_samples
%     if counter <= tDelta_mean
%         gsr_scl = data(1:counter+counter-1);
%         gsr_scl_mean(counter) = mean(gsr_scl);
%         
%         gsr_scr(counter) = data(counter) - gsr_scl_mean(counter);
%       
%     elseif counter >= gsr_samples-tDelta_mean
%         gsr_scl = data(counter-tDelta_mean:end);
%         gsr_scl_mean(counter) = mean(gsr_scl);
%         
%         gsr_scr(counter) = data(counter) - gsr_scl_mean(counter);
%     
%     else 
%         gsr_scl = data((counter-tDelta_mean)+1 :counter + tDelta_mean);
%         gsr_scl_mean(counter) = mean(gsr_scl);
%         
%         gsr_scr(counter) =  data(counter) - gsr_scl_mean(counter);
%     end
% end
% toc(clock_1);
% 
% % matlab functions
% clock_2 = tic;
% gsr_med_scl = medfilt1(data,tDelta_mean);
% gsr_med_scr = data - gsr_med_scl;
% toc(clock_2);
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
% [pks_O,locs_O,widths_O] = findpeaks(gsr_scr,'MinPeakProminence',0.98);
% [pks,locs,widths] = findpeaks(gsr_med_scr,'MinPeakProminence',0.98);
% 
% msr_time = gsr_samples / Fs_down;
% 
% % define measurement interval in sec
% msr_int = 30;
% msr_samples_per_int = Fs_down * msr_int;
% % divide the data in n*msr_int
% n = floor(msr_time / msr_int);
% % msr_data = gsr_med_scr(1,1:(msr_samples_per_int*n));
% msr_data = gsr_scr(1,1:(msr_samples_per_int*n));
% msr_samples = reshape(msr_data,[msr_samples_per_int,n]);
% 
% msr_pks = zeros(1,n);
% msr_pks_widths = zeros(30,n);
% msr_pks_locs = msr_pks_widths;
% msr_pks_prominence = msr_pks_widths;
% data_int = zeros(msr_samples_per_int,1);
% t_0 = 1:msr_samples_per_int;
% t_0 = t_0.';
% 
% figure;
% hold on;
% 
% for i= 1:n
% data_int = msr_samples(:,i);
% [pks,pl,pw,pp] = findpeaks(data_int,'MinPeakProminence',0.05); 
% msr_pks(i) = length(pks);
% msr_pks_widths(1:length(pw),i) = pw;
% msr_pks_locs(1:length(pl),i) = pl;
% msr_pks_prominence(1:length(pp),i) = pp;
% % plot
% if i<10
% subplot(10,2,i);
% plot(t_0,data_int,pl,pks,'*');
% %plot(l,pks,'*');
% title('Subplot');
% 
% end
% end
% 
% 
% % plot pks/msr
% figure;
% hold on;
% t_pks = 1:n;
% bar(t_pks,msr_pks);
% title('gsr pks per 30s interval');
% xlabel('interval');
% ylabel('number of pks');
% hold off;

%% Onset,Amplitude and Rising time

% flip intervall data and find pks, plotte max und min locs gg zeit

%% Statistics
% if length(locs) >= length(locs2)
%     c = length(locs);
%     locs2_new = [locs2 zeros(1,(c - length(locs2)))];
%     locs_new = locs;
%     delta_locs = zeros(1,c);
%     peak_number_perc = abs(length(locs) - length(locs2)) * 100/ length(locs);
% else
%     c = length(locs2);
%     locs_new = [locs zeros(1,(c - length(locs)))];
%     locs2_new = locs2;
%     delta_locs = zeros(1,c);
%     peak_number_perc = abs(length(locs2) - length(locs)) * 100/ length(locs2);
% end
% 
% match = 0;
% for i = 1:c
%     delta_locs(i) = abs(locs_new(i) - locs2_new(i));
%     if delta_locs(i) == 0
%     match = match+1;    
%     end
% end
% 
% 
% match_per = match*100/c;

%% Plot
% figure;
% hold on;
% plot(gsr_scr);
% plot(locs,pks,'*');
% plot(gsr_med_scr);
% plot(locs2,pks2,'+');
% legend('Phasic_own','Peaks_own','Phasic_m','Peaks_m')
% legend('boxoff')
% hold off;
% % 
% %
% figure;
% subplot(2,1,1)       
% plot(time,gsr_spec)
% title('Subplot 1')
% 
% subplot(2,1,2)       
% plot(time_down,gsr_down)       
% title('Subplot 2')


% figure;
% hold on;
% plot(time_down,data);
% plot(time_down,gsr_med_scl);
% plot(time_down,gsr_med_scr);
% legend('Original','Filtered','Phasic')
% legend('boxoff')
% hold off;

=======
>>>>>>> e2c633de908f55818ecb5ca09472fad30775baf2
