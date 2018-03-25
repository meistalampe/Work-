function [ heartrate,MeanRR,SDNN,RMSSD,mean_heartrate,std_heartrate,heartrate_coe,peakInterval,peakInterval_time ] = heartrate(signal,time,Fs)
% You need the kernel.mat data to run this function!! 
% This function finds R wave peaks in ecg signal and calculates the heartrate signal.
% It analyses the RR Intervals with by doing a lomb spectral analysis.

signal  = signal_filt;
time = time_co;
Fs = 100;
% load kernel
load('kernel.mat','kernelqrs_norm');

% create logistic sigmoid function
tu = quantile(signal, 0.99);
tl = quantile(abs(signal), 0.5);
f = @(x) 1./(1 + exp(-1e-4*(tu-tl)*(x-tu)));

xx = linspace(-1000, 1000, 1000);
ff = f(xx);
figure; plot(xx, ff);
grid on;
title 'logistic function'

% use logistic sigmoid function
ecgRspikes = f(conv(signal, kernelqrs_norm, 'same'));
figure;
hold on;
plot(time,signal);
plot(time,ecgRspikes*max(signal));
title ''
xlabel 'Samples';
ylabel 'voltage [\muV]';
legend('signal','signal after using kernel and logistic fkt')
hold off;
grid on;
 
% find all R wavemagnitudes
[pks,locs_Rwave] = findpeaks(ecgRspikes,'MinPeakHeight',0.3,...
                                    'MinPeakDistance',150);
 
                                                                                       
% check if all amplitudes were found  
% -------------------------------------
figure;
hold on 
plot(ecgRspikes)
plot(locs_Rwave,ecgRspikes(locs_Rwave),'rv','MarkerFaceColor','r')
grid on
legend('ECG Signal',' R waves')
xlabel('Samples')
ylabel('R waves')
title('R waves')




end

