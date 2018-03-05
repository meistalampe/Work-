% title:    workingClient
% author:   Dominik Limbach
%           Htw Saar

% last edited: 7.2.18
% description:  program allows value changes of key variables to control
%               vr and sends data to unity

% ideas:        implement bitalino control
%               start rec , stop record - see bitalino functions 
%               implement a choice for: baseline measurement, connect a
%               
%               1. change height
%               2. stop program
%               3. auto mode (set borders)
%               - after 4 loops a 15s ask if abort or cont
%               4. trigger light event
%               after a option has been selected run specific program path
%               and close the loop
%              
% therapy loop

clc;
clear;


% create tcp object, set Port,assign Networkrole Client 
tcpipClient = tcpip('localhost',8632,'NetworkRole','Client');
set(tcpipClient,'Timeout',30);

% input prompts
prompt = 'Take your pick. Confirm by pressing [Enter].\n';
prompt_light = 'Turn Lights ON/OFF by pressing [L].\n';
prompt_light_color = 'Change color to red [3], blue [2], green [1], white [0] \n';
prompt_auto_exit = 'Do you want to continue auto mode? [Y]/[N] \n';
prompt_auto1 = 'Enter upper border. \n';
prompt_auto2 = 'Enter lower border. \n';
prompt_height = 'Enter height value of type double. \n';
prompt_start = 'To start the therapy please press [G].\n';
prompt_stop = 'Do you want to stop the therapy? [Y]/[N]\n';
prompt_set_trigger = 'Trigger has been set.';

% input verification
valid_input = false;

% start sequence
playSequence = false;

% trigger
trigger_start = 10.0;
trigger_stop = 9.0;
trigger_height = 6.0;
trigger_mode = 5.0;
% trigger will be put every time there is a manual height change
trigger_light = 2.5;
% light trigger will be put when light is put out/on
trigger_white = 2.0;
trigger_green = 2.1;
trigger_blue = 2.2;
trigger_red = 2.3;

trigger_position = 4.0;
% position trigger will be set manually in the following cases:
% 1. subject reaches the edge
% 2. subject reaches the middle of the bridge
% 3. subject reaches opposite side
% 4. subject reaches the middle again
% 5. subject reaches goal

% sending data
% data has to be sent in the following order
% data[0] = bool physicianActivity
% data[1] = Int32 range  
% data[2] = float depth
% data[3] = int reaction
% data[4] = float UB
% data[5] = float LB
% data[6] = Int32 speed
% data[7] = bool lightEvent
% data[8] = int lightColor

time_delta = zeros(1,250);
trigger_store = zeros(1,250);
input_count = 1;
 
% main program loop
% stop condition
therapyStop = false;
% speed intialization;
speed = 0.5;

tStart = tic;


while therapyStop == false
    
    if playSequence == false
        
        valid_input = false;
        
       while valid_input == false
       fprintf('VRET control program \n' );
       fprintf('******************** \n');

       inp_start = input(prompt_start,'s');

           if inp_start == 'g'
               playSequence = true;
               
               valid_input = true;
               
               time_delta(input_count) = toc(tStart);
               trigger_store(input_count) = trigger_start;
               fprintf('TRIGGER: START  \n');
               
%              input_count = input_count +1;
               
               physicianActivity = true;
               speed = 2;
           else
               playSequence = false;
               valid_input = false;
               fprintf('Invalid input. Please try again. \n');
           end
            
       end
        
    
     % initialize VR
     
     range = 0;
     physicianDepth = 0.0;
     reaction = 0;
     physicianUB = 1.0;
     physicianLB = 40.0;
     
     lightEvent = false;
     lightColor = 0;
     
     
     data = [physicianActivity range physicianDepth reaction physicianUB ...
        physicianLB speed lightEvent lightColor playSequence];

     fopen(tcpipClient);
     fwrite(tcpipClient,data);
     fclose(tcpipClient);
     
    end
    %opt
    physicianActivity = false;
    
    % display program text
    fprintf('VRET control program \n' );
    fprintf('******************** \n');
    fprintf('Choose one of the following: \n');
    fprintf('1. Change height [H]\n');
    fprintf('2. Change mode [M] \n');
    fprintf('3. Turn light on/off [L] \n');
    fprintf('4. Change light Color [C] \n');
    fprintf('6. Set position trigger [T] \n');
    fprintf('5. Stop therapy [S] \n');  
    fprintf('******************** \n');
    

    inp = input(prompt,'s');
    input_count = input_count +1;
    
    switch inp
        case 'h'
            fprintf('Your choice h. \n');
           
            physicianActivity = true;
            physicianLB = 40.0;
            physicianUB = 1.0;
            reaction = 3;
            speed = 0.7;
            
            valid_input = false;
            
            while valid_input == false
            inp_height = input(prompt_height);
            
                if inp_height >= 1.0 && inp_height <= 40.0
                    
                    fprintf('Height will be changed to:');
                    disp(inp_height);
                    physicianDepth = inp_height;
                    valid_input = true;
                    %trigger
                    time_delta(input_count) = toc(tStart);
                    trigger_store(input_count) = trigger_height;
                    fprintf('TRIGGER: HEIGHT  \n');
                else 
                    fprintf('Invalid input. Please try again.\n')
                    valid_input = false;
                    
                end
            end
            
        case 'm'
            fprintf('Your choice m. \n');
            
            if physicianActivity == false
                physicianActivity = true;
                range = 1;
                speed = 0.5;
            end  
            
                valid_input = false;
    
                while valid_input == false
                   
                inp_auto = zeros(1,2);
                inp_auto(1) = input(prompt_auto1);
                inp_auto(2) = input(prompt_auto2);
                
                    if inp_auto(1) >= 1.0 && inp_auto(2) <= 40.0 && inp_auto(1) < inp_auto(2)  
                    physicianUB = inp_auto(1);
                    physicianLB = inp_auto(2);
                    fprintf('Upper border will be changed to:');
                    disp(inp_auto(1));
                    fprintf('Lower border will be changed to:');
                    disp(inp_auto(2));
                    valid_input = true;
                    
                    %trigger
                    time_delta(input_count) = toc(tStart);
                    trigger_store(input_count) = trigger_mode;
                    fprintf('TRIGGER: MODE  \n');
                    
                    else 
                    physicianUB = 1.0;
                    physicianLB = 40.0;
                    fprintf('Invalid entry. Borders set to default. Please try again. \n');
                    valid_input = false;
                    end
                    
                end
                
                counter = 5;
                loop_auto = true;
      
                while loop_auto == true
                    reaction = randi([1,2],1,1);

                    data = [physicianActivity range physicianDepth reaction physicianUB ...
                    physicianLB speed lightEvent lightColor playSequence];

                    fopen(tcpipClient);
                    fwrite(tcpipClient,data);
                    fclose(tcpipClient);

                    counter = counter +1;
                    pause(5);


                    if mod(counter,5) == 0
                        inp_auto_exit = input(prompt_auto_exit,'s');

                        switch inp_auto_exit
                            case 'n'
                                loop_auto = false;
                                %trigger
                                time_delta(input_count) = toc(tStart);
                                trigger_store(input_count) = trigger_mode;
                                fprintf('TRIGGER: MODE  \n');

                            case 'y' 
                                loop_auto = true;

                            otherwise
                                fprintf('Invalid Choice. Auto mode aborted.');
                                loop_auto = false;

                        end
                    
                    end
                end
                % leave auto mode, stay on current height
                physicianActivity = 0;
                range = 0;
                reaction = 0;
            
        case 'l'
            fprintf('Your choice l. \n');
            %trigger
            time_delta(input_count) = toc(tStart);
            trigger_store(input_count) = trigger_light;
            fprintf('TRIGGER: LIGHT  \n');
            
            if lightEvent == true
                lightEvent = false;
                 
            else
            lightEvent = true;
            end
            
        case 'c'
            fprintf('Your choice c. \n');
  
            inp_light = input(prompt_light_color);
            %trigger
            time_delta(input_count) = toc(tStart);
            
            switch inp_light
                case 0
                    lightColor = 0; 
                    trigger_store(input_count) = trigger_white;
                    fprintf('TRIGGER: WHITE  \n');
                    
                case 1
                    lightColor = 1; 
                    trigger_store(input_count) = trigger_green;
                    fprintf('TRIGGER: GREEN  \n');
                    
                case 2
                    lightColor = 2;
                    trigger_store(input_count) = trigger_blue;
                    fprintf('TRIGGER: BLUE  \n');
                    
                case 3
                    lightColor = 3;
                    trigger_store(input_count) = trigger_red;
                    fprintf('TRIGGER: RED  \n');
                    
                otherwise
                    fprintf('Invalid choice.')                
                    lightColor = 0;  
            
            end
            
        case 't'
            %trigger
            time_delta(input_count) = toc(tStart);
            trigger_store(input_count) = trigger_position;
           
        case 's'
            fprintf('Your choice s. \n');
            fprintf('Abort therapy. \n ');          
             
            %trigger
            time_delta(input_count) = toc(tStart);
            trigger_store(input_count) = trigger_stop;
            fprintf('TRIGGER: STOP  \n');
            
            physicianActivity = true;
            range = 0;
            physicianUB = 1.0;
            physicianLB = 40.0;
            reaction = 4;
            physicianDepth = 1.0;
            speed = 2.0;
            lightEvent = false;
            lightColor = 0;
            
            playSequence = false;
               
            data = [physicianActivity range physicianDepth reaction physicianUB ...
                physicianLB speed lightEvent lightColor playSequence];
        
            fopen(tcpipClient);
            fwrite(tcpipClient,data);
            fclose(tcpipClient);
            
            valid_input = false;
  
            while valid_input == false
                
                inp_stop = input(prompt_stop,'s');

                    if inp_stop == 'y'
                        therapyStop = true;
                        valid_input = true;
                        %save data time_delta,trigger_store,input_count
                        save('log_file.mat','time_delta','trigger_store', 'input_count')
                    elseif inp_stop == 'n'
                        therapyStop = false;
                        valid_input = true;
                    else
                        valid_input = false;
                        fprintf('Invalid input. Please try again. \n');
                    end
            end
            
        otherwise
            fprintf('Invalid choice. Please try again. \n');
            
    end
    
    data = [physicianActivity range physicianDepth reaction physicianUB ...
        physicianLB speed lightEvent lightColor playSequence];
        
    fopen(tcpipClient);
    fwrite(tcpipClient,data);
    fclose(tcpipClient);
    clc;
end

% clc;
% clear;
% 
% create tcp object, set Port,assign Networkrole Client 
% tcpipClient = tcpip('localhost',8632,'NetworkRole','Client');
% set(tcpipClient,'Timeout',30);
% 
%   data has to be sent in the following order
%   data[0] = bool physicianActivity
%   data[1] = Int32 range  
%   data[2] = float depth
%   data[3] = int reaction
%   data[4] = float UB
%   data[5] = float LB
%   data[6] = Int32 speed
%   data[7] = bool lightEvent
%   data[8] = int lightColor
% 
% 
% physicianActivity = false;
% range = 0;
%   range can have the following values
%   0 = default range
%   1 = variable range (between 1.0 - 30.0)
% border values in case range = 1
% physicianUB = 10.0;
% physicianLB = 20.0;
% 
% reaction = 0;
%   reaction can have the following values
%   0 = stop
%   1 = go deeper
%   2 = go higher
%   3 = specific value
%   4 = abort
% 
% depth value in case reaction = 3
% physicianDepth = 25.0;
% movement speed of the floor in case physicianActivity = true
% speed = 0.7;
% if lightEvent == true then the lights will go out
% lightEvent = false;
% lighting color can be set
% 0 = default, white light
% 1 = good, green
% 2 = neutral, blue
% 3 = bad, red
% lightColor = 0;
% creating data array
% data = [physicianActivity range physicianDepth reaction physicianUB ...
%         physicianLB speed lightEvent lightColor];
% open tcp object
% fopen(tcpipClient);
% fwrite(tcpipClient,data);
% fclose(tcpipClient);