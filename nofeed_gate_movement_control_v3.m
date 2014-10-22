
% Clear all previous commands, devices and variables
imaqreset;
clear;
clc;

%% Initialization
% Create the Video Device System object.
% vidDevice = imaq.VideoDevice('gige', 1, 'Mono8', ...
%                              'ROI', [400 250 800 800],...
%                              'ReturnedColorSpace', 'rgb', ...
%                              'DeviceProperties.ExposureTimeAbs', 15000);
%ROI used to be [400 250 1280 800]
% preview(vidDevice);
%% Initialization of the DAQ
devices = daq.getDevices;
s=daq.createSession('ni');
s.addAnalogOutputChannel('Dev2','ao0','voltage');
s.addAnalogOutputChannel('Dev2','ao1','voltage');
%s.Rate = 5000;


%% Manual Calibration

% X AXIS
START_X = 3.3;      % 3.3
REGION1_X = 3.8;   % 3.8
REGION2_X = 4.25;   % 2.75
TURN_X = 4.75;       % 3.3
% Y AXIS
TOPY = 1.5;        % 2.05    
MIDY = 2.05;        % 2.45
BOTY = 2.62;         % 2.9

%%
%This chunk of code uses voltage to set the bubble into the starting region
xaxis=TURN_X;
yaxis=MIDY;


gs_init = input('Enter starting Y:', 's');


if strcmpi(gs_init,'TOPY') == 1
        INIT_Y = TOPY;
elseif strcmpi(gs_init,'MIDY') == 1
        INIT_Y = MIDY;
elseif strcmpi(gs_init,'BOTY') == 1
        INIT_Y = BOTY;
else
        INIT_Y = TOPY;
end
    
% Change the yend to account for where we are starting (TOPY MIDY BOTY) 
[xaxis, yaxis] = gate_move(xaxis,yaxis,START_X,INIT_Y,'init',s);

%% Ask user for gate input
gate_string = input('Enter the gate numbers: ', 's');
gate_num = str2num(gate_string);

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       MOVING FROM THE STARTING REGION TO THE TURNAROUND REGION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% move from start, through gate 1

%gate_move(yend,xend,type_of_movement)
% Types of movement: up, down, left, right, 
stage = 0;
while stage == 0
    %move from start, through gate 1
    if gate_num(1,1) == 1;
        [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,yaxis,'right',s);
        
        
       
    % move from start, through gate 2
    elseif gate_num(1,1) == 2;
         [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,yaxis,'right',s);
           

    % move from start, through gate 3
    elseif gate_num(1,1) == 3;
         [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,yaxis,'right',s);
      

    
    end
stage = 1; 
end
%% move from first region to second region
while stage == 1
    % move through gate 4    
    if gate_num(1,2) == 4;
        %if our current position is lower than next gate
%              [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,TOPY,'up',s);
%              [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,yaxis,'right',s);
             [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,TOPY,'diag',s);
      
    

    % extra step here that can be removed (for moving through the gate)
        
    % move through gate 5
    elseif gate_num(1,2) == 5;
	%if our current position is greater than the next gae
    if gate_num(1,1) == 3
% 		 [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,MIDY,'up',s);
%         [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,yaxis,'right',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,MIDY,'diag',s);
       
	%regular gate movment	
    elseif	gate_num(1,1) == 2
        [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,yaxis,'right',s);
   %else it's gate 1
    else
%          [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,MIDY,'down',s);
%         [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,yaxis,'right',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,MIDY,'diag',s);
        
    end
% move through gate 6
    elseif gate_num(1,2) == 6;
%      [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,BOTY,'down',s);
%      [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,yaxis,'right',s);
    [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,BOTY,'diag',s);
 
    end
stage = 2;
end
%% move from second region to turn around region
while stage == 2
% move through gate 7    
    if gate_num(1,3) == 7;
	% if our current position is lower than the gate
%              [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,TOPY,'up',s);
%              [xaxis, yaxis] = gate_move(xaxis,yaxis,TURN_X,yaxis,'right',s);
             [xaxis, yaxis] = gate_move(xaxis,yaxis,TURN_X,TOPY,'diag',s);
         
           
             
% move through gate 8
    elseif gate_num(1,3) == 8;
    %if our current gate is lower than the next gate
        if gate_num(1,1) == 6
%              [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,MIDY,'up',s);
%             [xaxis, yaxis] = gate_move(xaxis,yaxis,TURN_X,yaxis,'right',s);
            [xaxis, yaxis] = gate_move(xaxis,yaxis,TURN_X,MIDY,'diag',s);
        %regular gate movment
        else
%              [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,MIDY,'down',s);
%              [xaxis, yaxis] = gate_move(xaxis,yaxis,TURN_X,yaxis,'right',s);
             [xaxis, yaxis] = gate_move(xaxis,yaxis,TURN_X,MIDY,'diag',s);
        end        
% move through gate 9
    elseif gate_num(1,3) == 9;
%          [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,BOTY,'down',s);
%          [xaxis, yaxis] = gate_move(xaxis,yaxis,TURN_X,yaxis,'right',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,TURN_X,BOTY,'diag',s);
    end
stage = 3;
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       MOVING BACK TO THE STARTING REGION FROM THE TURN AROUND REGION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%from turn around region to region 2

while stage == 3
    if gate_num(1,4) == 7;
	% if our current position is lower than the gate
     %        [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,TOPY,'up',s);
    %         [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,yaxis,'left',s);
    [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,TOPY,'diag',s);
    
            
            
% move from start, through gate 2
    elseif gate_num(1,4) == 8;
    %if our current gate is lower than the next gate
       if gate_num(1,3) == 9
%            [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'up',s);
%          [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,yaxis,'left',s);
         [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,MIDY,'diag',s);
        %regular gate movment
        else
%             [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'down',s);
%             [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,yaxis,'left',s);
            [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,MIDY,'diag',s);
        end        
 
% move from start, through gate 3
    elseif gate_num(1,4) == 9;
           [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,BOTY,'down',s);
           [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,yaxis,'left',s);
%          [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION2_X,BOTY,'diag',s);
    end
stage = 4; 
end
%% move
while stage == 4
% move through gate 4    
    if gate_num(1,5) == 4;
        %if our current position is lower than next gate
%            [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,TOPY,'up',s);
%           [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,yaxis,'left',s);
          [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,TOPY,'diag',s);
   
          
% move through gate 5
    elseif gate_num(1,5) == 5;
	%if our current position is greater than the next gae
    if gate_num(1,4) == 9
%           [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,MIDY,'up',s);
%           [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,yaxis,'left',s);
          [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,MIDY,'diag',s);
	%regular gate movment	
    else	
%         [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,MIDY,'down',s);
%         [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,yaxis,'left',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,MIDY,'diag',s);
    end
% move through gate 6
    elseif gate_num(1,5) == 6;
%        [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,BOTY,'down',s);
%        [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,yaxis,'left',s);
       [xaxis, yaxis] = gate_move(xaxis,yaxis,REGION1_X,BOTY,'diag',s);
    end
stage = 5;
end
%% move from second region to turn around region
while stage == 5
% move back through gate 1
    if gate_num(1,6) == 1;
	% if our current position is lower than the gate
  
%         [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,TOPY,'up',s);
%          [xaxis, yaxis] = gate_move(xaxis,yaxis,START_X,yaxis,'left',s);
         [xaxis, yaxis] = gate_move(xaxis,yaxis,START_X,TOPY,'diag',s);
         
         
         
% move back through gate 2
    elseif gate_num(1,6) == 2;
    %if our current gate is lower than the next gate
        if gate_num(1,5) == 6
%             [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,MIDY,'up',s);
%           [xaxis, yaxis] = gate_move(xaxis,yaxis,TOPY,yaxis,'left',s);
            [xaxis, yaxis] = gate_move(xaxis,yaxis,START_X,MIDY,'diag',s);
        %regular gate movment
        else
%             [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,MIDY,'down',s);
%             [xaxis, yaxis] = gate_move(xaxis,yaxis,TOPY,yaxis,'left',s);
            [xaxis, yaxis] = gate_move(xaxis,yaxis,START_X,MIDY,'diag',s);
        end    
% move back through gate 3
    elseif gate_num(1,6) == 3;
%             [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,BOTY,'down',s);
%           [xaxis, yaxis] = gate_move(xaxis,yaxis,TOPY,yaxis,'left',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,START_X,BOTY,'diag',s);
    end
stage = 8;
end
%% Release
% Call the release method on the System objects to close any open files and
% devices.
%release(vidDevice);
