function [ ecgfilt ] = filterECG( ecg_signal,time,Fs,filepath)

% this function first shows the FFT of the ecg signal. Then it
% detrends the ecg signal data. After that it filters the signal with a 
% notch IIR filter to remove the 50 Hz line noise. Finally the function
% uses a butterwoth bandpass filter to remove all unessecary frequencies

% Nyquist frequency
FN = Fs/2;

% detrend and filter ecg
%-------------------------
dt_ecg = detrend(ecg_signal);

%% frequency check

N = length(dt_ecg);
fax_bins = (0 : N-1);    % N is the number of samples in the signal, 
                         % signal starts now at 0 instead of 1

% changing  x-axis values from fax_bins to fax_Hz
fax_Hz = fax_bins*Fs/N;

% create a single sided Plot ( in Hz )
X_mags = abs(fft(dt_ecg));
N_2 = ceil(N/2); % rounds each element of X to the nearest integer 
                 % greater than or equal to that element.
                    
figure
plot (fax_Hz(1:N_2), X_mags(1:N_2))
ylabel 'Magnitude'
xlabel 'Frequency [Hz]'
title 'single-sided magnitude spectrum(Hz)'
axis tight
ylim ([0 1*10^6]);
 

savefig([filepath filesep 'FrequenzSpektrumECG']);
saveas(gcf, [filepath filesep 'FrequenzSpektrumECG'], 'eps');
% close;  

savefig([filepath filesep 'FrequenzSpektrumECG']);
saveas(gcf, [filepath filesep 'FrequenzSpektrumECG'], 'eps');

% create notch filter 50 Hz
wo = 50/(512/2);  bw = wo/35;
[b,a] = iirnotch(wo,bw);
% display notch filter
% fvtool(b,a);
notch_ecg(1,:) = filtfilt(b,a,dt_ecg);


%  bandpass filter
[b, a] = butter(4, [5 50]/FN, 'bandpass');
ecgfilt = filtfilt(b, a,notch_ecg);     


% check filtered signal
figure;
plot(time,ecgfilt);
title 'ecg filtered';
xlabel 'time [sec]';
ylabel 'voltage [\muV]';
ylim ([-5000 5000]);


savefig([filepath filesep 'ecgfiltered']);
saveas(gcf, [filepath filesep 'ecgfiltered'], 'eps');
 

end

