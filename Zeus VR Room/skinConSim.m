clc;
clear;
% variables
% seconds delayed
n = 6;
% loop condition
stop = false;
% connection information
txt = textread('config.txt','%s','delimiter','\n');
ipAdress = txt{1,1};
portNumber = str2num(['uint32(',txt{2,1},')']);

% create tcp object, set Port,assign Networkrole Client 
tcpIpClient = tcpip(ipAdress,portNumber,'NetworkRole','Client');
set(tcpIpClient,'Timeout',30);


% loop start
while stop == false
    
    % open tcp object
    fopen(tcpIpClient);
    % variables to transmit
    skinConductence = randi([1,25],1,1);
    
    
    fwrite(tcpIpClient,skinConductence)
    fclose(tcpIpClient);

    %delay intervall
    pause(n);
end