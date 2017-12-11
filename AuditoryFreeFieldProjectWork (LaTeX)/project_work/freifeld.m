% filename: freifeld.m
% Saarland University of Applied Sciences
% author: Dominik Limbach
% date: 01.11.2017
% 
% description:  program that reads the connection information from the target
%               pc, establishes a tcp/ip connection, requests
%               input (user data,exam parameter), creates a exam protokoll
%               and then saves the data before sending it to the
%               destination

clc;
clear;

% acquire connection information
txt = textread('configFF.txt','%s','delimiter','\n');
ipAdress = txt{1,1};
portNumber = str2num(['uint32(',txt{2,1},')']);

% create tcp object, set Port,assign Networkrole Client 
tcpIpClient = tcpip(ipAdress,portNumber,'NetworkRole','Client');


% input messages
lastname_prompt ='Enter a last name. \n';
name_prompt = 'Enter a name. \n';
birthdate_prompt = 'Enter a birth date. (DD.MM:YYYY) \n';
examdate_prompt = 'Enter a date. (DD.MM:YYYY) \n';
arrow_prompt = 'Do you want the signal position and the sign position to match? (yes = true , no = false)\n';
signal_prompt = 'How many repetitions would you like to run? Please enter integer value.\n';
Error_prompt = 'Wrong input.Please enter a value of the correct type.\n';

% number of available Speakerpositions
speakerPositions = 4;

% input: user information
last_name = input(lastname_prompt,'s');
name = input(name_prompt,'s');
date_birth = input(birthdate_prompt,'s');
date_exam = input(examdate_prompt,'s');

% break variable for the input check
ok = false;

while ok == false
% linked is the variable which defines the paradigm
% linked = true => audio position and sign position match
% linked = false => audio position and sign position dont match    
linked = input(arrow_prompt);
if isa(linked,'logical') == true
    ok = true;
else
   disp(Error_prompt)
   disp(' ')
   ok = false;
end
end

% break variable for the input check
ok = false;

while ok == false
% number of Signals per Set    
numberSignals = input(signal_prompt);
if isa(numberSignals,'numeric') && (numberSignals >= 1) == true
    ok = true;
else
   disp(Error_prompt)
   disp(' ')
   ok = false;
end
end

% initialize position arrays
arrowPosition = zeros(1,numberSignals);
audioPosition = zeros(1,numberSignals);
counter = 1;

while counter <= numberSignals
    
if linked == true    
    audioPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);    
    arrowPosition(1,counter) = audioPosition(1,counter);
    counter = counter+1;
else
    audioPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);
    arrowPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);
    counter = counter+1;
end
end

%save user_file
filename = 'auditoryExam.mat';
save(filename,'last_name','name','date_birth','date_exam','numberSignals',...
'linked','audioPosition','signPosition');

% prepare data to send
data = [numberSignals ,audioPosition ,arrowPosition];
% open tcp object, send to target and close tcp object 
fopen(tcpIpClient);
fwrite(tcpIpClient,data) 
fclose(tcpIpClient);
% end of program

