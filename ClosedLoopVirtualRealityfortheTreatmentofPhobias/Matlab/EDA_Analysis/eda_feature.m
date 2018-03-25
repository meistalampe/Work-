function [signal_ba,mov_avg,SCL_diff,SCL_mean,SCL_med,P_int,P_mean,P_std,PR_avg,PR] = eda_feature(signal,time,baseline,Fs,s3,filepath)
%% Baseline Adjustment

% get avg of BL
bmean = mean(baseline);
% substract BL from EXP signal 
signal_ba = signal - bmean;

figure;
hold on;
plot(time,signal_ba);
title 'EDA Baseline adjusted';
xlabel 'time [s]';
ylabel 'conductance [\muS] ';
hold off;

s1 = 'EDA Baseline adjusted';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')

SCL_min = min(signal_ba);
SCL_max = max(signal_ba);

SCL_diff = abs(SCL_max - SCL_min);

SCL_mean = mean(signal_ba);
SCL_med = median(signal_ba);

% signal_trans = signal_ba';
figure;
boxplot(signal_ba);
title(sprintf('min = %f muS,max = %f muS,median = %f muS',SCL_min,SCL_max,SCL_med));
xlabel('Subject Number')
ylabel('Changes in SCL [\muS]')

s1 = 'SCL Boxplot';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')
% Decomposition into SCR and SCL

% different methods to fiter out scl
signal_dt = detrend(signal_ba);

signal_med = medfilt1(signal_ba,400);
% depending on the filter factor of medfilt1 med_scl and dt_scl are equally
% good
 
%own way, building the mean of a certain intervall and moving this intervall
% along the signal
% load signal into seperate variable 
mov_data = signal_ba;
% number of samples to average
avg_samples = length(mov_data);
% initialize array for results 
mov_avg = zeros(1,avg_samples);
% array for tonic component
% gsr_scl = zeros(1,gsr_samples);
% array to store time interval mean
avg_mean = zeros(1,avg_samples);
% tDelta in seconds 
tDelta = 4;
% tDelta_mean is an array that holds a nummer of samples according to
% tDelta
tDelta_mean = Fs * tDelta;
% avg_mean is formed over an intervall of 2*tDelta, tDelta from 
% either side of current value 
tDelta_mod = mod(tDelta_mean,2);
if tDelta_mod == 0
    tDelta_mean = tDelta_mean+1;
end

for counter = 1:avg_samples
    if counter <= tDelta_mean
        avg_int = mov_data(1:counter+counter-1);
        avg_mean(counter) = mean(avg_int);
        
        mov_avg(counter) = mov_data(counter) - avg_mean(counter);
      
    elseif counter >= avg_samples-tDelta_mean
        avg_int = mov_data(counter-tDelta_mean:end);
        avg_mean(counter) = mean(avg_int);
        
        mov_avg(counter) = mov_data(counter) - avg_mean(counter);
    
    else 
        avg_int = mov_data((counter-tDelta_mean):counter + tDelta_mean);
        avg_mean(counter) = mean(avg_int);
        
        mov_avg(counter) =  mov_data(counter) - avg_mean(counter);
    end
       
end

% plot all 3 scl
figure;
hold on;
title 'EDA signal (dt,med,mean)';
subplot(3,1,1);
plot(time,mov_avg);
grid on;
legend ('moving avg.');

subplot(3,1,2); 
plot(time,signal_dt);
grid on;
ylabel 'conductance [\muS]';
legend ('detrend');

subplot(3,1,3); 
plot(time,signal_med);
grid on;
legend ('medfilt');
xlabel 'time [s]';
hold off;

s1 = 'SCR extraction';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')

% % blend out negative signal parts for better visibility
% for ii = 1:length(mov_avg)
%    if mov_avg(ii) <= 0
%        mov_avg(ii) = 0;
%    end
% end

% find NR-SCRs in signal
[pks,locs] = findpeaks(mov_avg,'MinPeakProminence', 0.01);

figure;
hold on;
plot(mov_avg);
plot(locs,pks,'rv','MarkerFaceColor','r');
title 'NR-SCR';
xlabel 'time [s]';
ylabel 'conductance [\muS] ';
hold off;

s1 = 'NR-SCR';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')


%% Peak-distance

% calculate peak distance (samples)
signal_diff = diff(locs);
% transf. peak distance (time)
P_int = signal_diff ./Fs ; 
% avg distance and std
P_mean = mean(P_int);     
P_std = std(P_int);

% get peak times (time)
locs_time = locs ./ Fs;

% calculate instantaneous PR
tPRV = locs_time(2:end);
PRV = 1./P_int;

% Plot the signals
figure;
hold on;
plot(tPRV,PRV)
title('PRV')
xlabel('Time[s]')
ylabel('PRV [Hz]')

s1 = 'PRV Hz';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')


figure;
hist(P_int);
title 'histogram of the peak separations in seconds';
grid on;
xlabel('Sampling interval [s]');
ylabel('Peak Interval distribution');


% create a vector heartrateSample
p_rate_Sample  = zeros(1,length(signal_diff));

% position the calculated heartarte value to the right sample
for v = 1:length(signal_diff)
    
    p_rate_Sample(v) = ceil(locs(v) + (signal_diff(v)/2));
end

% create a new vector with the length of the signal to map the peaks
 counter = 1;
 signal_pk = zeros(1,length(signal));
 
 for i = 1:max(p_rate_Sample)
     
    if (p_rate_Sample(counter) == i)
     
       signal_pk(i) = PRV(counter);
       counter = counter +1;
        
    end   
 end
 
 peakPositions = find(signal_pk > 0);
 first = peakPositions(1);
 last  = peakPositions(end);
 
 % Fill the rest of the vector with interpolated values for displaying
for l =  first : last

    % values smaller than 50 b/m  -> bradykardie (heart_int(l) < 50)
    if signal_pk(l+1) == 0   
        
        signal_pk(l+1) = signal_pk(l);
    end

end

PR = signal_pk;
PR_avg = mean(PR);

figure;
plot(time,PR);
title 'PRV';
xlabel 'time [s]';
ylabel 'PR [pks/s]';

s1 = 'PRV time';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')


end

