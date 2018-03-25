function [signal_filt,time_co,signal_adj] = eda_filter(signal,time,Fs,filepath,s3)

%% PreProcessing Data
 
% ########################################################################
% data adjustment
% ########################################################################

% Scale the signal per the specifications of the sensor
signal_adj = (((signal./2.^10).* 3.3)./0.132);
% 
% % alternative adjustment
% signal_adj = zeros(1,length(signal));
% for i = 1:length(signal)
% signal_adj(i) = 1 - signal(i)/2.^10;
% signal_adj(i) = 1 / signal_adj(i);
% end


% ########################################################################
% fft
% ########################################################################

L = length(time);
n = 2^nextpow2(L);
% Convert the Signal to the frequency domain.
Y = fft(signal_adj,n);
% Define the frequency domain and plot the unique frequencies.
f = Fs*(0:(n/2))/n;
P = abs(Y/n);

% plot frequency domain representation Y

figure;
plot(f,P(1:n/2+1)) 
title('EDA in Frequency Domain')
xlabel('Frequency f')
ylabel('|P(f)|')

s1 = 'EDA in Frequency Domain';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png');

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
signal_notch = filter(b,a,signal_adj);

signal_filt = eda_lp1Hz(signal_notch);
% [z,p,k] = butter(9,2/Fn,'low');
% sos = zp2sos(z,p,k);
% signal_filt = filtfilt(sos,10,signal_notch);
% fvtool(b,a)


% ########################################################################
% cutoff
% ########################################################################

% calculate number of samples to remove
ct = 10;
cSamples = ct*Fs;
% remove cSamples from both ends
signal_filt = signal_filt(cSamples:(end-cSamples));
time_co = time(cSamples:(end-cSamples));

%plot filtered and cut signal
figure;
hold on;
plot(time_co,signal_filt);
title 'EDA filtered';
xlabel 'time [s]';
ylabel 'conductance [\muS] ';
hold off;

s1 = 'EDA filtered';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png');

end
