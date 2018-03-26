function [nH,bH,Ht,dt,t,d,r,pv,bW,nW] = stat_test(mean_sample_1,mean_sample_2,subject_names)
% takes 2 samples of average values with the size subject_names (exp first
% then bl)
% performs shapiro wilk test, pair t-test and effectsize test
% output    -result of the H0 hypothesis for shapiro wilk for each sample
%            (nH,bH) and the p values
%           -result t test (Ht)
%           -result effect size test (d)
%           

% test auf normalverteilung
% sharpiro wilk test

% own
% sample size
n = length(subject_names);
% sort the sample 
nsample_sort = sort(mean_sample_1);
bsample_sort = sort(mean_sample_2);

%calculate ss
nX = zeros(1,n);

for i = 1:n
    nX(i) =  (nsample_sort(i) - mean(nsample_sort)).^2;
end
nSS = sum(nX)/(n-1);

bX = zeros(1,n);
for i = 1:n
    bX(i) =  (bsample_sort(i) - mean(bsample_sort)).^2;
end
bSS = sum(bX)/(n-1);

% calculate m
if mod(n,2) == 0
    m = n/2;
else
    m = (n-1)/2;
end

% get koefficients from table for n 
% http://www.real-statistics.com/tests-normality-and-symmetry/statistical-tests-normality-symmetry/shapiro-wilk-test/
if n == 8
a_coe = [0.6052 0.3164 0.1743 0.0561 ];
end
if n == 10
a_coe = [0.5739 0.3291 0.2141 0.1224 0.0399]; 
end
nY = zeros(1,m);
bY = zeros(1,m);
%calculate b
for i = 1:m
    nY(i) = a_coe(i)*(nsample_sort(n+1-i)-nsample_sort(i));
end
nb = sum(nY);

for i = 1:m
    bY(i) = a_coe(i)*(bsample_sort(n+1-i)-bsample_sort(i));
end
bb = sum(bY);

% calculate test statistics W
nd = nSS*(n-1);
bd = bSS*(n-1);
nW = nb.^2/nd;
bW = bb.^2/bd;


% alpha = 0.05 and therfore from the table W critical for specific n

if n == 8
W_crit = 0.818;
end

if n == 10
W_crit = 0.842;
end

if nW >= W_crit
   % 0 Hypothesis confirmed the sample has a normal distribution
   nH = 0;
else
   % 0 Hypothesis rejected the sample has no normal distribution
   nH = 1;
end

if bW >= W_crit
   % 0 Hypothesis confirmed the sample has a normal distribution
   bH = 0;
else
   % 0 Hypothesis rejected the sample has no normal distribution
   bH = 1;
end

% Zweistichproben t test (abhängig)
% H0 hypothese ist das muD = 0 dh die differenz zwischen bl und exp = 0 ist
% H0 wird nur dann verworfen wenn die differenz deutlich größer als 0 ist
% wir testen also einseitig mit p-1 = 9 freiheitsgraden und alpha von 0.05
% und erhalten eine verwerfungsgrenze von 1.8331 
% d.h. wenn t >= 1.8331 ist wird H0 verworfen 
% im falle von P = 8 ==> 7 freiheitsgrade und alpha 0.05 ergibt sich einw
% ert von 1.8946


% anzahl der test paare
p = length(subject_names);
% verwerfungswert
if p == 8
v_out = 1.895;
end

if p == 10
v_out = 1.833;
end

% test niveau
alpha = 0.05;

% angenommene Differenz
omega_0 = 0;

sample_exp = mean_sample_1;
sample_bl = mean_sample_2;

% differenz bilden , wir gehen davon aus dass die RR intervall der
% exposition kürzer sind als die der baseline
paar_diff =  sample_bl-sample_exp;

% calc avg diff
dt = mean(paar_diff);
sd = zeros(1,p);

for i=1:p
sd(i) = (paar_diff(i) - dt).^2;
end

ssd = sum(sd)/(p-1);

% t wert
t = (dt - omega_0)/ sqrt(ssd/p);

if t >= v_out
    % wenn t größer ist als der verwurfswert dann is H0 widerlegt
    Ht = 1;
else
    % wenn t kleiner ist als der verwurfswert dann ist H0 bestätigt
    Ht = 0;
end

% bravais pearson cohens r

var_sample_exp = var(sample_exp);
var_sample_bl = var(sample_bl);

% d for same sample size but different sample variances
% Nach Cohen[1] bedeutet ein  
% d zwischen 0,2 und 0,5 einen kleinen Effekt,
% zwischen 0,5 und 0,8 einen mittleren und 
% d größer als 0,8 einen starken Effekt.
pv =  sqrt((var_sample_bl + var_sample_exp)/2);
d = (mean(sample_bl)-mean(sample_exp))/ pv;

r = d/sqrt(d.^2 + ((p+p).^2)/p*p);

end

