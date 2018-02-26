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

% % dialogbox settings
% prompt = {'Enter signal vector:','Enter Sampling Frequency:','Enter Channel Number:','Enter saving path:'};
% dlg_title = 'Input';
% num_lines = 1;
% answer = inputdlg(prompt,dlg_title,num_lines);
% 
% Note: maybe implementation of the baseline signal needed

% fprintf('Processing...\n');
% 
% % answers
% signalname = answer{1,1};
% Fs = str2double(answer{2,1});
% channel = str2double(answer(3,1));
% filepath = answer{4,1};
% 
% % load
% % dlmread needs a filename, the delimiter, the number of rows of the
% % header, and the starting row to read
% eda_data = dlmread(signalname,'\t', 3, 0);
% % the signal is extracted from the data matrix, channel number needed
% signal = eda_data(:,channel);
% signalLength = length(data);
% signalTime = signalLength/Fs;
% % create a timeline starting at 0 and with the length of the signal
% time = linspace(0,signalTime,signalLength);


% input for matlab test files
signal = load('gsr_example.mat');
signal = struct2cell(signal);
signal = signal{1,1};
time = load('time_example.mat');
time = struct2cell(time);
time = time{1,1};
Fs = 512;
filepath = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\EDA_Analysis\Save folder';

figure;
plot(time,signal)
title('EDA signal (raw)');
%% Processing Data

% Nyquist frequency
FN = Fs/2;
% detrend eda
% will be replaced by baseline substraction
dt_eda = detrend(signal);

% check detrended signal
figure;
plot(time,dt_eda);
title('EDA signal (detrended)');

% frequency analysis
% N is the number of samples in the signal
N = length(dt_eda);
% signal starts now at 0 instead of 1
fax_bins = (0 : N-1);     
                         
% changing  x-axis values from fax_bins to fax_Hz
fax_Hz = fax_bins*Fs/N;

% create a single sided Plot ( in Hz )
X_mags = abs(fft(dt_eda));
N_2 = ceil(N/2); % rounds each element of X to the nearest integer 
                 % greater than or equal to that element.
                                
figure;
plot (fax_Hz(1:N_2), X_mags(1:N_2))
ylabel 'Magnitude'
xlabel 'Frequency [Hz]'
title 'single-sided magnitude spectrum(Hz)'
axis tight
ylim ([0 1*10^6]);

%% Downsampling

% from Fs to Fs_down e.g. for Fs_down 16 Hz 
Fs_down = 8;
factor_down= Fs / Fs_down;
 
signal_down = downsample(signal,factor_down);
time_down = downsample(time,factor_down);
% check downsampled signal
figure;
plot(time_down,signal_down);
title('EDA signal (downsampled)');

%% Filtering EDA data

%  bandpass filter
% [b, a] = butter(4, [5 50]/FN, 'bandpass');
% gsrfilt = filtfilt(b, a,notch_gsr);    
% low pass filter
% [z,p,k] = butter(9,2/FN,'low');
% sos = zp2sos(z,p,k);
% gsrfilt = filtfilt(sos,10,notch_gsr);
% fvtool(b,a);

signal_filt = lp1Hz(signal_down,Fs_down);

% check filtered signal
figure;
plot(time_down,signal_filt);
title 'EDA signal (1Hz Lowpass)';
xlabel 'time [sec]';
ylabel 'voltage [\muV]';


%% Decomposition into SCR and SCL

% different methods to fiter out scl
dt_scl = detrend(signal_filt);

med_scl = medfilt1(signal_filt,4);
% depending on the filter factor of medfilt1 med_scl and dt_scl are equally
% good

% own way, building the mean of a certain intervall and moving this intervall
% along the signal
data = signal_filt;
% number of samples
eda_samples = length(data);
% array for phasic component
eda_scr = zeros(1,eda_samples);
% array for tonic component
% gsr_scl = zeros(1,gsr_samples);
% array to store time interval mean
eda_scl_mean = zeros(1,eda_samples);
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

for counter = 1:eda_samples
    if counter <= tDelta_mean
        eda_scl = data(1:counter+counter-1);
        eda_scl_mean(counter) = mean(eda_scl);
        
        eda_scr(counter) = data(counter) - eda_scl_mean(counter);
      
    elseif counter >= eda_samples-tDelta_mean
        eda_scl = data(counter-tDelta_mean:end);
        eda_scl_mean(counter) = mean(eda_scl);
        
        eda_scr(counter) = data(counter) - eda_scl_mean(counter);
    
    else 
        eda_scl = data((counter-tDelta_mean)+1 :counter + tDelta_mean);
        eda_scl_mean(counter) = mean(eda_scl);
        
        eda_scr(counter) =  data(counter) - eda_scl_mean(counter);
    end
end

% plot all 3 scl
figure;
hold on;
plot(time_down,med_scl);
plot(time_down,dt_scl);
plot(time_down,eda_scr);
hold off;
title 'EDA signal (dt,med,mean)';
xlabel 'time [sec]';
ylabel 'voltage [\muV]';
ylim ([-5 5]);
legend('medfilt1','detrend','mean');

%% NR-SCR, non event related skin conductance responses (find peaks)
                                                                                      
% [pks,pl,pw,pp] = findpeaks(eda_scr,'MinPeakProminence',0.05);
[pks,pl,pw,pp] = findpeaks(eda_scr,'MinPeakHeight',0.05);

figure;
hold on;
plot(eda_scr);
plot(pl,pks,'rv','MarkerFaceColor','r');
xlabel('Samples')
ylabel('NR-SCR')
title('NR-SCR in EDA')
legend('EDA Signal',' NR-SCR')
hold off;

% locs_wave in time domain
locs_time = pl ./ Fs_down;

% calculate the distances between the peaks in Samples
peakInterval = diff(pl);
peakInterval_time = diff(locs_time);

% create a vector with peak rate data
pr_calc = zeros(1,length(peakInterval));

% calculate the peak rate
for u = 1:length(peakInterval)
    
    pr_calc(u) = (Fs_down/peakInterval(u))*60;
end

% create a vector peak rate Sample
prSample  = zeros(1,length(peakInterval));

% position the calculated peakrate value to the right sample
for v = 1:length(peakInterval)    
    prSample(v) = ceil(pl(v) + (peakInterval(v)/2));
end


% create vector with the same length as trial with the peak rate data
% fill it with the peakrate values at the right sample points

 counter = 1;
 pr_int = zeros(1,length(eda_scr));
 
 
 for z = 1:max(prSample)
     
    if (prSample(counter) == z)
     
       pr_int(z) = pr_calc(counter);
       counter = counter +1;
        
    end   
 end
 
 valuepositions = find(pr_int > 0);
 first_position = valuepositions(1);
 last_position  = valuepositions(end);
 
 % Fill the rest of the vector with interpolated values for displaying
for l =  first_position : last_position

    % values smaller than 50 b/m  -> bradykardie (heart_int(l) < 50)
    if pr_int(l+1) == 0   
        
        pr_int(l+1) = pr_int(l);
    end

end


peakrate = pr_int;

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
tPRV = locs_time(2:end);
PRV = 1./peakInterval_time;


% Plot the signals
figure;
a1 = subplot(2,1,1); 
plot(time_down,eda_scr,'b',locs_time,pks,'*r')
grid
a2 = subplot(2,1,2);
plot(tPRV,PRV)
grid
xlabel(a2,'Time(s)')
ylabel(a1,'EDA')
ylabel(a2,'PRV (Hz)')


% savefig([filepath filesep 'HRV,ECG']);
% saveas(gcf, [filepath filesep 'HRV,ECG'], 'eps');

figure;
hist(peakInterval_time);
title 'histogram of the peak separations in seconds';
grid on;
xlabel('Sampling interval (s)');
ylabel('PI distribution');


savefig([filepath filesep 'Histogram']);
saveas(gcf, [filepath filesep 'Histogram'], 'eps');

figure;
plomb(PRV,tPRV,'Pd',[0.95, 0.5]);


savefig([filepath filesep 'Lomb Analyse']);
saveas(gcf, [filepath filesep 'Lomb Analyse'], 'eps');

% The dashed lines denote 95
% and 50% detection probabilities.
%These thresholds measure the statistical significance of peaks. 
%The spectrum shows peaks in all three bands of interest listed above.



%% statistic values RR Interval

% heartrate mean value and standard deviation of NN(RR) intervals(SDNN)
MeanRR = mean(peakInterval);
SDNN = std(peakInterval);

% root mean square of successive differences (RMSSD)
% big variation of HR often shows artefacts, so the HR changes much 
% from beat to beat
% the RMSSD is very sensitive for artefacts. If the standard deviation is
% low but the RMSSD is high, you better check your signal for artefacts.

N = length(peakInterval)-1 ;

RMSSD = 0;
for k = 1:N
    
    RMSSD = RMSSD + (peakInterval(k+1) - peakInterval(k))^2; 
    
end

RMSSD =sqrt( (1/N) * RMSSD);



% plotting heartrate of the required trial
% -----------------------------------------

start_stop = find(peakrate >0);
start = start_stop(3)/512;
stop = start_stop(end-2)/512;

% % heartrate befor median filtering
% figure;
% plot(trial_time,heartrate);
% title 'heartrate variability';
% xlabel 'time [sec]';
% ylabel 'heartrate [beats/min]';
% xlim([start stop]);


% filtered heartrate with median filter 

figure;
% median filtering  1500 ca 3 sec.
heartrate = medfilt1(peakrate,1500);
plot(time_down,peakrate);
title 'peakrate variability';
xlabel 'time [sec]';
ylabel 'peakrate [beats/min]';
xlim([start stop]);



savefig([filepath filesep 'peakrate']);
saveas(gcf, [filepath filesep 'peakrate'], 'eps');

%% statistic values heartrate
% calculate the variation coefficient,mean value and standard deviation of the heartrate
mean_peakrate = mean(heartrate);
std_peakrate = std(heartrate);
peakrate_coe = (std_peakrate * 100) /mean_peakrate;


% Saving workspace
resultsFilename = 'results';

% clear runtime variables
clear dlg_title num_lines prompt 
fprintf('Saving analysis results to file ... ');

save([filepath filesep resultsFilename '.mat'], '-v7.3');
fprintf('Done.\n');