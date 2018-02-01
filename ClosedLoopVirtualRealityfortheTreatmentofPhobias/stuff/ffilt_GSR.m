function [ sequence_filt] = ffilt_GSR(ipsi_chan)

%%definition of constants for the data type defined with dtype
%ALR's
        sampling_frequency  = 512; %sampling frequency 
        number_fir_coefs = 1000; %number of filter coefficients
        fir_lbound = 0.05; %lower filter bound
        fir_ubound = 10; %upper filter bound

sequ_length = length(ipsi_chan);

sequence = ipsi_chan;%2



%% FILTER THE DATA
fir_band = [(fir_lbound/(sampling_frequency/2)),(fir_ubound/(sampling_frequency/2))];      
fir_coef = fir1(number_fir_coefs,fir_band);
fir_stop = [(49.5/(sampling_frequency/2)),(50.5/(sampling_frequency/2))]; 
fir_coef_stop = fir1(number_fir_coefs,fir_stop, 'stop');
if fir_lbound<50 && fir_ubound>50
sequence_notch = filtfilt(fir_coef_stop,1,sequence);
sequence_filt  = filtfilt(fir_coef,1,sequence_notch);
else
 sequence_filt  = filtfilt(fir_coef,1,sequence);
end


% trigpos(end)
end
