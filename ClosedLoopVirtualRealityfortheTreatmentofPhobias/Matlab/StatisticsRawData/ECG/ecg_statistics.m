%% file header

% filename:     ecg_statistics
% author:       dominik limbach
% date:         25.03.18

% description:  
%               -load data
%               -extract variables
%               
%               
%               -save results      

% ########################################################################
% load results
% ########################################################################

clc;
clear;
close all;

% name list
subject_names = strings(1,10);
subject_names(1) = 'aliVR' ;
subject_names(2) = 'doroVR' ;
subject_names(3) = 'floVR' ;
subject_names(4) = 'frankVR' ;
subject_names(5) = 'gautamVR' ;
subject_names(6) = 'kimVR' ;
subject_names(7) = 'lucaVR' ;
subject_names(8) = 'manuelaVR' ;
subject_names(9) = 'shantanuVR' ;
subject_names(10) = 'silviaVR' ;
  
% file name
filepath = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\StatisticsRawData\ECG\';
filetype = '.mat';
surname = 'ECG_';

% create cell to store the structures
res_ECG = cell(1,length(subject_names));
% fill the cell
for i = 1: length(subject_names)
name = subject_names(i);
file_name = strcat(filepath,surname,name,filetype);
res_ECG{i} = load(file_name);
end
% transform ro struct
res_ECG_mat = cell2mat(res_ECG);

% statistic variables 
bHR_mean = zeros(1,length(subject_names));
nHR_mean = zeros(1,length(subject_names));
bRR_min = zeros(1,length(subject_names));
nRR_min = zeros(1,length(subject_names));
bRR_max = zeros(1,length(subject_names));
nRR_max = zeros(1,length(subject_names));
bRR_delta = zeros(1,length(subject_names));
nRR_delta = zeros(1,length(subject_names));
nRR_mean = zeros(1,length(subject_names));
bRR_mean = zeros(1,length(subject_names));

bRMSSD = zeros(1,length(subject_names));
nRMSSD = zeros(1,length(subject_names));

% length of the longest P_int vector
bl = 495;
ba_RR_int = zeros(length(subject_names),bl);
% length of the longest P_int vector
nl = 868;
na_RR_int = zeros(length(subject_names),nl);

% extract variables

for i = 1:length(subject_names)
bHR_mean(i) = res_ECG_mat(i).bHR;
nHR_mean(i) = res_ECG_mat(i).nHR;
bRR_min(i) = 60./res_ECG_mat(i).bHR_max;
nRR_min(i) = 60./res_ECG_mat(i).nHR_max;
bRR_max(i) = 60./res_ECG_mat(i).bHR_min;
nRR_max(i) = 60./res_ECG_mat(i).bHR_min;
bRR_delta(i) = abs(bRR_max(i)-bRR_min(i));
nRR_delta(i) = abs(nRR_max(i)-nRR_min(i));
nRR_mean(i) = 60./res_ECG_mat(i).nHR;
bRR_mean(i) = 60./res_ECG_mat(i).bHR;

ba_RR_int(i,1:length(res_ECG_mat(i).bRR_int))=res_ECG_mat(i).bRR_int;
na_RR_int(i,1:length(res_ECG_mat(i).nRR_int))=res_ECG_mat(i).nRR_int;

%RMSSD
bRR_square = res_ECG_mat(i).bRR_int .^2;
bRR_square_avg = mean(bRR_square);
bRMSSD(i) = sqrt(bRR_square_avg);

nRR_square = res_ECG_mat(i).nRR_int .^2;
nRR_square_avg = mean(nRR_square);
nRMSSD(i) = sqrt(nRR_square_avg);

end


% RR interval boxplot
% fill empty slots with NaN
ba_RR_int(ba_RR_int == 0) = NaN;
ba_RR_int = ba_RR_int';
% fill empty slots with NaN
na_RR_int(na_RR_int == 0) = NaN;
na_RR_int = na_RR_int';

% plot 

figure;
hold on;
title('RR interval distribution')
subplot(2,1,1);
boxplot(ba_RR_int);
grid on;
ylim([0.3 1.3]);
title('Baseline')
ylabel('RR interval [s]')

subplot(2,1,2); 
boxplot(na_RR_int);
grid on;
ylim([0.3 1.3]);
title('Exposure')
ylabel('RR interval [s]')
xlabel('Subject')
hold off;

s1 = 'RR interval distribution';
s3 = '_VR';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')


% ########################################################################
%statistics
% ########################################################################

 [nH,bH,Ht,dt,t,d,r,pv,bW,nW] = stat_test(nRR_mean,bRR_mean,subject_names);
 
%% Saving Data

% Saving workspace
s2 = 'stat_results';
saveFilename = 'ECG_';
saveFilename = strcat(saveFilename,s2);

save([filepath filesep saveFilename '.mat'], '-v7.3');
fprintf('Done.\n');
