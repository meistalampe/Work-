% filename: freifeld.m
% Saarland University of Applied Sciences
% author: Dominik Limbach
% date: 01.11.2017
% description: program that reads the connection information 
% from the target pc, establishes a tcp/ip connection, requests
% input (user data,exam parameter), creates a exam protokoll
% and then saves the data before sending it to the destination

clc;
clear;

%% acquire connection information
txt = textread('configFF.txt','%s','delimiter','\n');
ipAdress = txt{1,1};
portNumber = str2num(['uint32(',txt{2,1},')']);

% create tcp object, set Port,assign Networkrole Client 
tcpIpClient = tcpip(ipAdress,portNumber,'NetworkRole','Client');

%% dialogbox settings
prompt = {'Enter a last name:','Enter a name:','Enter a birth date:','Enter a date:'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);

% input messages
% arrow_prompt = 'Do you want the signal position and the sign position to match? (yes = true , no = false)\n';
signal_prompt = 'Set the set size? Please enter integer value.\n';
stop_prompt = 'Do you want to stop the program? [Y]/[N]\n';
input_prompt = 'Take your pick. Confirm by pressing [Enter].\n';
% Error_prompt = 'Wrong input.Please enter a value of the correct type.\n';

%% Variables

% number of available Speakerpositions
speakerPositions = 4;

% input verification
valid_input = false;

% user information
last_name = answer{1,1};
name = answer{2,1};
date_birth = answer{3,1};
date_exam = answer{4,1};


% storing variables
linked_store = zeros(1,250);
numberSignals_store = 0;
arrow_store = zeros(1,500);
audio_store = zeros(1,500);

%% Loop

    % stop condition
    programStop = false;

    % initialize VR 
    playSound = false;
    linked = true;
    numberSignals = 1;
    audioPosition = 0;
    arrowPosition = 0;
    input_count = 1;
    
  
    % prepare data to send
    data = [numberSignals ,audioPosition ,arrowPosition, playSound];
    % open tcp object, send to target and close tcp object 
    fopen(tcpIpClient);
    fwrite(tcpIpClient,data) 
    fclose(tcpIpClient);
    
while programStop == false
    
    %reset
    playSound = false;
%     numberSignals = 1;
     
     % prepare data to send
    data = [numberSignals ,audioPosition ,arrowPosition, playSound];
    % open tcp object, send to target and close tcp object 
    fopen(tcpIpClient);
    fwrite(tcpIpClient,data) 
    fclose(tcpIpClient);
    
    % display program text
    fprintf('VR control program \n' );
    fprintf('******************** \n');
    fprintf('Choose one of the following: \n');
    fprintf('1. link/unlink sound and location [l]\n');
    fprintf('2. trigger sound [s] \n');
    fprintf('3. play set [p] \n');
    fprintf('4. Stop therapy [e] \n');
    fprintf('******************** \n');
    

    inp = input(input_prompt,'s');
    
    
    switch inp
        case 'p'
            fprintf('Your choice has been submitted. \n');
                      
            valid_input = false;
            
            while valid_input == false
            inp_set = input(signal_prompt);
            
                if inp_set >= 1.0 
                    
                    fprintf('Set size has been set to:');
                    disp(inp_set);
                    fprintf('processing...\n')
                    numberSignals = inp_set;
                    
                    input_count = input_count + numberSignals;
                    playSound = true;
                    valid_input = true;
                else 
                    fprintf('Invalid input. Please try again.\n')
                    valid_input = false;
                    
                end
            end
            
        case 's'
            fprintf('Your choice has been submitted. \n');
            fprintf('processing...\n')
            %trigger sound 
            numberSignals = 1;
            playSound = true;
            input_count = input_count +1;
            
            
            
        case 'l'
            fprintf('Your choice has been submitted. \n');
            fprintf('processing...\n')
            if linked == true
                linked = false;
                fprintf('mode: unlinked. \n');
            else
            linked = true;
            fprintf('mode: linked. \n');
            end
            
            
        case 'e'
            fprintf('Your choice has been submitted. \n');
            fprintf('Abort program. \n');
            
            linked = true;
            playSound = false; 
            
            fprintf('processing...\n')
            % prepare data to send
            data = [numberSignals ,audioPosition ,arrowPosition, playSound];
            % open tcp object, send to target and close tcp object 
            fopen(tcpIpClient);
            fwrite(tcpIpClient,data) 
            fclose(tcpIpClient);
            
            valid_input = false;
  
            while valid_input == false
                
                inp_stop = input(stop_prompt,'s');

                    if inp_stop == 'y'
                        programStop = true;
                        valid_input = true;
                        
                        %save user_file
                        fprintf('saving...\n');
                        filename = 'auditoryExam.mat';
                        save(filename,'last_name','name','date_birth','date_exam','numberSignals_store',...
                        'linked_store','audio_store','arrow_store');
                        fprintf('done.\n');
                    elseif inp_stop == 'n'
                        programStop = false;
                        valid_input = true;
                    else
                        valid_input = false;
                        fprintf('Invalid input. Please try again. \n');
                    end
            end
            
        otherwise
            fprintf('Invalid choice. Please try again. \n');
            
    end
    
    % initialize position arrays
    arrowPosition = zeros(1,numberSignals);
    audioPosition = zeros(1,numberSignals);
    counter = 1;

    while counter < numberSignals

    if linked == true    
        audioPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);    
        arrowPosition(1,counter) = audioPosition(1,counter);
        
    else
        audioPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);
        arrowPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);
        
    end
    counter = counter+1; 
    end
    
    % prepare data to send
    data = [numberSignals ,audioPosition ,arrowPosition, playSound];
    % open tcp object, send to target and close tcp object 
    fopen(tcpIpClient);
    fwrite(tcpIpClient,data) 
    fclose(tcpIpClient);

    % updating stores
    linked_store(input_count) = linked;
    numberSignals_store = input_count;
    if input_count <= 500
        for i = numberSignals 
        arrow_store(input_count+i) = arrowPosition(i);
        audio_store(input_count+i) = audioPosition(i);
        end
    end
    
    
    wait = 2*numberSignals;
    pause(wait);
    clc;
end



%% old program
% % break variable for the input check
% ok = false;
% 
% while ok == false
% % linked is the variable which defines the paradigm
% % linked = true => audio position and sign position match
% % linked = false => audio position and sign position dont match    
% linked = input(arrow_prompt);
% if isa(linked,'logical') == true
%     ok = true;
% else
%    disp(Error_prompt)
%    disp(' ')
%    ok = false;
% end
% end

% % break variable for the input check
% ok = false;

% while ok == false
% % number of Signals per Set    
% numberSignals = input(signal_prompt);
% if isa(numberSignals,'numeric') && (numberSignals >= 1) == true
%     ok = true;
% else
%    disp(Error_prompt)
%    disp(' ')
%    ok = false;
% end
% end
% 
% % initialize position arrays
% arrowPosition = zeros(1,numberSignals);
% audioPosition = zeros(1,numberSignals);
% counter = 1;
% 
% while counter <= numberSignals
%     
% if linked == true    
%     audioPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);    
%     arrowPosition(1,counter) = audioPosition(1,counter);
%     counter = counter+1;
% else
%     audioPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);
%     arrowPosition(1,counter) = randi([0,(speakerPositions-1)],1,1);
%     counter = counter+1;
% end
% end

% %save user_file
% filename = 'auditoryExam.mat';
% save(filename,'last_name','name','date_birth','date_exam','numberSignals',...
% 'linked','audioPosition','arrowPosition');
% 
% % prepare data to send
% data = [numberSignals ,audioPosition ,arrowPosition];
% % open tcp object, send to target and close tcp object 
% fopen(tcpIpClient);
% fwrite(tcpIpClient,data) 
% fclose(tcpIpClient);
% % end of program

