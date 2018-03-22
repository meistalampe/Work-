function [ signal_filt , time_co ] = ecg_filter(signal,time,Fs,filepath )

%% PreProcessing Data
 
% ########################################################################
% data adjustment
% ########################################################################

% Scale the signal per the specifications of the sensor
% signal_adj = ((((signal./((2.^10)-1))-0.5) .* 3.3)./ 1100) .* 1000;

signal_adj = ((((signal./(2.^10))-0.5) .* 3.3)./ 1100) .* 1000;

% ########################################################################
% cutoff
% ########################################################################

% calculate number of samples to remove
ct = 5;
cSamples = ct*Fs;
% remove cSamples from both ends
signal_co = signal_adj(cSamples:(end-cSamples));
time_co = time(cSamples:(end-cSamples));

% plot adjusted and cut signal

figure;
hold on;
plot(time_co,signal_co);
title('ECG Time Domain')
xlabel('Time (t)')
ylabel('X(t)')
hold off;

% ########################################################################
% detrend
% ########################################################################

signal_dt = detrend(signal_co);

% ########################################################################
% fft
% ########################################################################

L = length(time_co);
n = 2^nextpow2(L);
% Convert the Signal to the frequency domain.
Y = fft(signal_dt,n);
% Define the frequency domain and plot the unique frequencies.
f = Fs*(0:(n/2))/n;
P = abs(Y/n);

% plot frequency domain representation Y

figure;
plot(f,P(1:n/2+1)) 
title('ECG in Frequency Domain')
xlabel('Frequency (f)')
ylabel('|P(f)|')

savefig([filepath filesep 'ECG in Frequency Domain']);
saveas(gcf, [filepath filesep 'ECG in Frequency Domain'], 'png');

% %own way, building the mean of a certain intervall and moving this intervall
% % along the signal
% % load signal into seperate variable 
% mov_data = signal_co;
% % number of samples to average
% avg_samples = length(mov_data);
% % initialize array for results 
% mov_avg = zeros(1,avg_samples);
% % array for tonic component
% % gsr_scl = zeros(1,gsr_samples);
% % array to store time interval mean
% avg_mean = zeros(1,avg_samples);
% % tDelta in seconds 
% tDelta = 4;
% % tDelta_mean is an array that holds a nummer of samples according to
% % tDelta
% tDelta_mean = Fs * tDelta;
% % avg_mean is formed over an intervall of 2*tDelta, tDelta from 
% % either side of current value 
% tDelta_mod = mod(tDelta_mean,2);
% if tDelta_mod == 0
%     tDelta_mean = tDelta_mean+1;
% end
% 
% for counter = 1:avg_samples
%     if counter <= tDelta_mean
%         avg_int = mov_data(1:counter+counter-1);
%         avg_mean(counter) = mean(avg_int);
%         
%         mov_avg(counter) = mov_data(counter) - avg_mean(counter);
%       
%     elseif counter >= avg_samples-tDelta_mean
%         avg_int = mov_data(counter-tDelta_mean:end);
%         avg_mean(counter) = mean(avg_int);
%         
%         mov_avg(counter) = mov_data(counter) - avg_mean(counter);
%     
%     else 
%         avg_int = mov_data((counter-tDelta_mean):counter + tDelta_mean);
%         avg_mean(counter) = mean(avg_int);
%         
%         mov_avg(counter) =  mov_data(counter) - avg_mean(counter);
%     end
% end

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
[b, a] = butter(4, [5 24]/Fn, 'bandpass');
% fvtool(b,a);

% apply bandpass filter
signal_filt = filtfilt(b, a,signal_notch);
% signal_filt = sgolayfilt(signal_notch, 7, 41);
%plot filtered signal

figure;
hold on;
plot(time_co,signal_filt);
title 'ECG filtered';
xlabel 'time [s]';
ylabel 'voltage [mV] ';
hold off;

savefig([filepath filesep 'ECG filtered']);
saveas(gcf, [filepath filesep 'ECG filtered'], 'png');

end

