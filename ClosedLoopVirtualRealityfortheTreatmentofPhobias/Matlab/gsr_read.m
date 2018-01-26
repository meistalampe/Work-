function [ y ] = gsr_read( 'x' )
%   gsr_read: 
%   reads the simulink file x
%   and saves the output in y 
y = sim('x');

end

