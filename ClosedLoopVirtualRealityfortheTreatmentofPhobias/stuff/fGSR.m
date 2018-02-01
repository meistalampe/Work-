% function : fGSR
% author: Marie-Claire Herbig
% last changed: 23.08.17
function [SCL,SCRamplitude,locationPeak,peaks] = ...
    fGSR (sequence, samplingfrequency,normalization, ...
    TimeBaseline, trigg,window)
%input:     GSR sequence, sampling frequency, normalization yes(1) or no(0),
% %           time for baseline, trigger signal, time window for averaging
%output:    skin conductance level, skin conductance responses, peaks and their loaction        


%filtering 
[ sequence_filt] = ffilt_GSR(sequence);

% skin conductance level (tonic waveform)
startAnalyse = find(trigg,1,'first');
TimeBaseline = TimeBaseline *samplingfrequency;
startBaseline = startAnalyse - TimeBaseline;
endBaseline = startAnalyse;
sequence_filt = sequence_filt(startAnalyse:end); %V:gefiltertes Signal
baselineGSR = sequence_filt(startBaseline:endBaseline); %V: gefilterte Base
if normalization == 0  % Keine NORMALIZATION: Mittelung über 5 Sekunden Intervalle
% average wave over intervalls 
startAveraging = 1;
endAveraging = (window* samplingfrequency);
SCL = zeros(1,ceil(length(sequence_filt)/(window*samplingfrequency))-1); %V: SCL so lang wie Messwerte da sind
    for count1 = 1: length(SCL)
        SCL(count1) = mean (sequence_filt(startAveraging: endAveraging)); %V: mittelwert von Wert bis Ende in SCL 
        startAveraging = startAveraging + (window*samplingfrequency);
        endAveraging = endAveraging + (window* samplingfrequency);
    end
end
if normalization == 1;
%normalization
  SCL = sequence_filt - mean(baselineGSR); 
end
%-------------------------------------------------------------------------------------
% skin coductance response (phasic waveform)
%------------------------------------------------------------------------------------
% identifying events-----------------------------------------------------------------
%locate the peaks
[peaks,locationPeak] = findpeaks(SCL);
locationBeginning = zeros (1,length(locationPeak));
SCRamplitude = zeros (1,length(locationPeak));
% extract the detail before the peak in order to find the beginning
for count2= 1:length(locationPeak)
    if count2 == 1
        detail = [1:locationPeak(count2)];
    else
        detail = [locationPeak(count2-1):locationPeak(count2)];  
    end
    % find positive divergence
    divergence = diff (detail);
    locationBeginning(count2) = find(divergence > 0.03e-6,1,'first'); %Schwellwert verlangt
    SCRamplitude(count2) = SCL(locationPeak(count2))-SCL(locationBeginning(count2));
end
%compute the maximal amplitude of the peaks
maxAmplitude = max (SCRamplitude);
%rejection of the amplitudes that are not within 10% of the maximum amplitude
%finding "true" SCR's, gegeben
for count3 = 1: length(SCRamplitude);
    if SCRamplitude(count3) < (0.9*maxAmplitude)
        locationPeak(count3) = 0;
        SCRamplitude(count3) = 0;
        peaks (count3) = 0;
    end
end
SCRamplitude(SCRamplitude == 0) = [];
locationPeak(locationPeak == 0) = [];
peaks(peaks == 0) = [];
end 

%