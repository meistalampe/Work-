%% file header

% filename:     eda_statistics
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
subject_names = strings(1,8);
subject_names(1) = 'aliVR' ;
subject_names(2) = 'doroVR' ;
subject_names(3) = 'louisaVR' ;
subject_names(4) = 'frankVR' ;
subject_names(5) = 'gautamVR' ;
subject_names(6) = 'kimVR' ;
subject_names(7) = 'manuelaVR' ;
subject_names(8) = 'silviaVR' ;
  
% file name
filepath = 'F:\GitHubRepositories\Work-\ClosedLoopVirtualRealityfortheTreatmentofPhobias\Matlab\StatisticsRawData\EDA\';
filetype = '.mat';
surname = 'EDA_';

% create cell to store the structures
res_EDA = cell(1,length(subject_names));
% fill the cell
for i = 1: length(subject_names)
name = subject_names(i);
file_name = strcat(filepath,surname,name,filetype);
res_EDA{i} = load(file_name);
end
% transform ro struct
res_EDA_mat = cell2mat(res_EDA);

% statistic variables 
bPR_avg = zeros(1,length(subject_names));
nPR_avg = zeros(1,length(subject_names));

nP_mean = zeros(1,length(subject_names));
bP_mean = zeros(1,length(subject_names));

bSCL_delta = zeros(1,length(subject_names));
nSCL_delta = zeros(1,length(subject_names));

bSCL_mean = zeros(1,length(subject_names));
nSCL_mean = zeros(1,length(subject_names));
SCL_diff = zeros(1,length(subject_names));

% bRMSSD = zeros(1,length(subject_names));
% nRMSSD = zeros(1,length(subject_names));

% length of the longest P_int vector
bl = 104;
ba_P_int = zeros(length(subject_names),bl);
% length of the longest P_int vector
nl = 134;
na_P_int = zeros(length(subject_names),nl);
% extract variables

for i = 1:length(subject_names)
% average peak rate
bPR_avg(i) = res_EDA_mat(i).bPR_avg;
nPR_avg(i) = res_EDA_mat(i).nPR_avg;
% average peak interval
nP_mean(i) = res_EDA_mat(i).nP_mean;
bP_mean(i) = res_EDA_mat(i).bP_mean;
% difference SCl_min and SCL_max
bSCL_delta(i) = res_EDA_mat(i).bSCL_diff;
nSCL_delta(i) = res_EDA_mat(i).nSCL_diff;
% average SCL
bSCL_mean(i) = res_EDA_mat(i).bSCL_mean;
nSCL_mean(i) = res_EDA_mat(i).nSCL_mean;

% difference in average peak int between exp and bl
SCL_diff(i) = abs(nSCL_mean(i)-bSCL_mean(i));

ba_P_int(i,1:length(res_EDA_mat(i).bP_int))=res_EDA_mat(i).bP_int;
na_P_int(i,1:length(res_EDA_mat(i).nP_int))=res_EDA_mat(i).nP_int;
% %RMSSD
% bP_square = res_EDA_mat(i).bP_int .^2;
% bP_square_avg = mean(bP_square);
% bRMSSD(i) = sqrt(bP_square_avg);
% 
% nP_square = res_EDA_mat(i).nP_int .^2;
% nP_square_avg = mean(nP_square);
% nRMSSD(i) = sqrt(nP_square_avg);

end

% fill empty slots with NaN
ba_P_int(ba_P_int == 0) = NaN;
ba_P_int = ba_P_int';
% fill empty slots with NaN
na_P_int(na_P_int == 0) = NaN;
na_P_int = na_P_int';

% plot peak interval distribution

figure;
hold on;
title('peak interval distribution')
subplot(2,1,1);
boxplot(ba_P_int);
grid on;
ylim([0 15]);
title('Baseline')
ylabel('peak interval [s]')

subplot(2,1,2); 
boxplot(na_P_int);
grid on;
ylim([0 15]);
title('Exposure')
ylabel('peak interval [s]')
xlabel('Subject')
hold off;

s1 = 'peak interval distribution';
s3 = '_VR';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')

% plot scl magnitudes 

figure;
hold on;
subplot(1,3,1);
boxplot(bSCL_mean);
grid on;
title('Avg. SCL ')
ylabel('avg. SCL [\mu S]')
xlabel('Baseline')

subplot(1,3,2); 
boxplot(nSCL_mean);
grid on;
ylim([0 8]);
xlabel('Exposure')
title('Avg. SCL ')
hold off;

subplot(1,3,3); 
boxplot(SCL_diff);
grid on;
ylim([0 8]);
xlabel('Subject Group')
title('avg. delta SCL ')
hold off;

s1 = 'Average SCL';
s3 = '_VR';
savename = strcat(s1,s3);
savefig([filepath filesep savename]);
saveas(gcf, [filepath filesep savename], 'png')

% ########################################################################
%statistics
% ########################################################################

% for peak intervals
[nH,bH,Ht,dt,t,d,r,pv,bW,nW] = stat_test(nP_mean,bP_mean,subject_names);
% for scl increases
[scl_bH,scl_nH,scl_Ht,scl_dt,scl_t,scl_d,scl_r,scl_pv,bsclW,nsclW] = stat_test(bSCL_mean,nSCL_mean,subject_names);

%% Saving Data

% Saving workspace
s2 = 'stat_results';
saveFilename = 'EDA_';
saveFilename = strcat(saveFilename,s2);

save([filepath filesep saveFilename '.mat'], '-v7.3');
fprintf('Done.\n');
