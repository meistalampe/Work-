clc;
clear all;

addpath(genpath('../'));
simTime = sim('testSignal');
figure;
plot(testOut);
title('GSR Sim');
xlabel('time [s]');
ylabel('amplitude [µV]');