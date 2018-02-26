function [ ] = ellipse( peakInterval_time,filepath )

% geometric analyse of heatrate data

% create data
L = length(peakInterval_time);
if rem(L,2) 
   peakInterval_time=peakInterval_time(1:1:L-1);  % if length is odd delete last element 
   L=L-1; 
end 
odd = peakInterval_time(1:2:L);
even = peakInterval_time(2:2:L);
data =[ odd' even'];



% Calculate the eigenvectors and eigenvalues
covariance = cov(data);
[eigenvec, eigenval ] = eig(covariance);

% Get the index of the largest eigenvector
[largest_eigenvec_ind_c, r] = find(eigenval == max(max(eigenval)));
largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);

% Get the largest eigenvalue
largest_eigenval = max(max(eigenval));

% Get the smallest eigenvector and eigenvalue

    smallest_eigenval = max(eigenval(:,1));
    smallest_eigenvec = eigenvec(1,:);


% Calculate the angle between the x-axis and the largest eigenvector
angle = atan2(largest_eigenvec(2), largest_eigenvec(1));

% This angle is between -pi and pi.
% Let's shift it such that the angle is between 0 and 2pi
if(angle < 0)
    angle = angle + 2*pi;
end

% Get the coordinates of the data mean
avg = mean(data);

% Get the 95% confidence interval error ellipse
chisquare_val = 2.4477;
theta_grid = linspace(0,2*pi);
phi = angle;
X0=avg(1);
Y0=avg(2);
a=chisquare_val*sqrt(largest_eigenval);
b=chisquare_val*sqrt(smallest_eigenval);

% the ellipse in x and y coordinates 
ellipse_x_r  = a*cos( theta_grid );
ellipse_y_r  = b*sin( theta_grid );

%Define a rotation matrix
R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];

%let's rotate the ellipse to some angle phi
r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;


figure;
% Draw the error ellipse
plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-')
hold on;

% Plot the original data
plot(data(:,1), data(:,2), '.');
% mindata = min(min(data));
% maxdata = max(max(data));
% xlim([mindata-3, maxdata+3]);
% ylim([mindata-3, maxdata+3]);
title 'Poincare plot';

hold on;

% Plot the eigenvectors
quiver(X0, Y0, largest_eigenvec(1)*sqrt(largest_eigenval), largest_eigenvec(2)*sqrt(largest_eigenval), '-m', 'LineWidth',2);
quiver(X0, Y0, smallest_eigenvec(1)*sqrt(smallest_eigenval), smallest_eigenvec(2)*sqrt(smallest_eigenval), '-g', 'LineWidth',2);
hold on;

% % plot first bisector
% bisector = ones(1,ceil(max(peakInterval_time))+100);
% bisector = (1:ceil(max(peakInterval_time))+100);
% plot(bisector,bisector);
% xlim ([min(peakInterval_time)-100 max(peakInterval_time)+100]);

% Set the axis labels
 xlabel('RR_i');
 ylabel('RR_i+1');
xlim ([min(odd)-0.2 max(odd)+0.2]);
ylim ([min(even)-0.2 max(even)+0.2]);


savefig([filepath filesep 'poincare']);
saveas(gcf, [filepath filesep 'poincare'], 'eps');
end

