function [SDNN,RMSSD] = statistics(RR_int,RR_mean,HRV,tHRV,iHR,iHR_mean,Fs)

% ########################################################################
%statistics
% ########################################################################

% Standard deviation of all NN intervals [ms]
SDNN = std(RR_int);

RR_square = RR_int .^2;
RR_square_avg = mean(RR_square);
RMSSD = sqrt(RR_square_avg);
% 
% % prepare for ttest
% % sort RR_int vectors
% ln = length(nRR_int);
% lb = length(bRR_int);
% 
% l_diff = ceil(abs(ln-lb)/2);
% 
% if ln ~= lb
% nRR_sort = sort(nRR_int);
% bRR_sort = sort(bRR_int);
% 
%     if ln < lb
%     bRR_sort(floor(lb/2)-l_diff:floor(lb/2) + l_diff) = [];
%     end
%     
%     if ln > lb
%     nRR_sort(ceil(ln/2)-l_diff:ceil(ln/2)-2 + l_diff) = [];
%     
%     end
% end
% calculate factor to bring them to same length
% build mean between 2 adjacent values until RR_ints are the same length


[h,p] = ttest(bRR_sort,nRR_sort,'Alpha',0.05);
end

