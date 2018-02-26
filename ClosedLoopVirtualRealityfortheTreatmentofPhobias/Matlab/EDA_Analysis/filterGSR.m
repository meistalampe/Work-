function [gsrfilt] = filterGSR (gsr_signal, time, Fs, filepath)

% Nyquist frequency
FN = Fs/2;

% detrend and filter gsr

dt_gsr = detrend(gsr_signal);

%% frequency check

N = length(dt_gsr);
fax_bins = (0 : N-1);    % N is the number of samples in the signal, 
                         % signal starts now at 0 instead of 1

% changing  x-axis values from fax_bins to fax_Hz
fax_Hz = fax_bins*Fs/N;

% create a single sided Plot ( in Hz )
X_mags = abs(fft(dt_gsr));
N_2 = ceil(N/2); % rounds each element of X to the nearest integer 
                 % greater than or equal to that element.
                    
figure;
plot (fax_Hz(1:N_2), X_mags(1:N_2))
ylabel 'Magnitude'
xlabel 'Frequency [Hz]'
title 'single-sided magnitude spectrum(Hz)'
axis tight
ylim ([0 1*10^6]);

savefig([filepath filesep 'FrequenzSpektrumGSR']);
saveas(gcf, [filepath filesep 'FrequenzSpektrumGSR'], 'eps');

% create notch filter 50 Hz
wo = 50/(512/2);  bw = wo/35;
[b,a] = iirnotch(wo,bw);
% display notch filter
% fvtool(b,a);
notch_gsr(1,:) = filtfilt(b,a,dt_gsr);



%  bandpass filter
[b, a] = butter(4, [5 50]/FN, 'bandpass');
gsrfilt = filtfilt(b, a,notch_gsr);     

% check filtered signal
figure;
plot(time,gsrfilt);
title 'gsr filtered';
xlabel 'time [sec]';
ylabel 'voltage [\muV]';
ylim ([-5000 5000]);


savefig([filepath filesep 'gsrfiltered']);
saveas(gcf, [filepath filesep 'gsrfiltered'], 'eps');

end