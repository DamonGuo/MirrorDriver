%% Concentricity Inspection
% XXXX

%% Introduction
% First, the example uses the |BlobAnalysis| System object to determine the
% centroid of the cladding. It uses this centroid to find a point on the
% cladding's outer boundary. Using this as a starting point, the
% |BoundaryTracer| System object defines the cladding's outer boundary. Then
% the example uses these boundary points to compute the cladding's center and
% radius using a least-square, circle-fitting algorithm. If the distance
% between the cladding's centroid and the center of its outer boundary is
% within a certain tolerance, the fiber optic cable is in acceptable
% condition.




imaqreset;

%% Initialization
% Create the Video Device System object.
vidDevice = imaq.VideoDevice('gige', 1, 'Mono8', ...
                             'ROI', [400 250 1280 800],...
                             'ReturnedColorSpace', 'rgb', ...
                             'DeviceProperties.ExposureTimeAbs', 15000);

%                                                      'ROI', [0 0 1080 1280], ...

%% Initialization of the DAQ
devices = daq.getDevices;
s=daq.createSession('ni');
s.addAnalogOutputChannel('Dev1','ao0','voltage');
s.addAnalogOutputChannel('Dev1','ao1','voltage');
s.Rate = 5000;
s.outputSingleScan ([0 0]);

%%
% Create two |VideoPlayer| System objects to display the input and output
% videos.
%SAMMY COMMENTED THIS OUT
%hVideoIn = vision.VideoPlayer('Name', 'Original');
%hVideoOut = vision.VideoPlayer('Name', 'Results');
%hVideoOut.Position(1) = hVideoIn.Position(1)+450;

%%
%Calibration
calArray =[0 0; 0.1 0.1; 0.2 0.2; 0.3 0.3];
pixelToVolt = zeros(size(calArray));
nFrames = 0;
preview(vidDevice);
while (nFrames < size(pixelToVolt, 1))
    s.outputSingleScan (calArray(nFrames+1,:));%CalAOutput the calibration value
    pause(1);
    [centroid, center, rgbData, image_out] = xyValue( vidDevice );    
    pixelToVolt(nFrames+1,:)=centroid;
 %   step(hVideoOut, image_out);
 %   step(hVideoIn, rgbData);
    nFrames = nFrames+1;
end
%Maybe the following combination need to be swifted
temp1=flipud([calArray(1,1)-calArray(:,1),calArray(1,2)-calArray(:,2)]);
calArray = [temp1(1:size(calArray,1)-1,:); calArray];
temp2 = flipud([pixelToVolt(1,1)-pixelToVolt(:,1),pixelToVolt(1,2)-pixelToVolt(:,2)]);
pixelToVolt = [temp2(1:size(pixelToVolt,1)-1,:); pixelToVolt];
%%
%Matching and sorting
tempx=[pixelToVolt(:,1),calArray(:,1)];
tempx=sortrows(tempx,1);
tempy=[pixelToVolt(:,2),calArray(:,2)];
tempy=sortrows(tempy,2);
%Interpolation
%Fx=griddedInterpolant(tempx(:,1),tempx(:,1));
%Fy=griddedInterpolant(tempy(:,2),tempy(:,2));
%%
%value = Fx({(???),1});
%Step sequence in piexl
% pixelPoint=[200 200; 200 400; 400 400; 400 200; 200 200];
% realPoint=[Fx(pixelPoint(:,1)),Fy(pixelPoint(:,2))];
% count = 0;
% dist= 100000;
% while(count<size(pixelPoint,1))
%     s.outputSingleScan (realPoint(count+1,:));
%     dist = sqrt((centroid(1)-pixelPoint(count+1,1))^2+(centroid(2)-pixelPoint(count+1,2))^2);
%     while dist > 100
%     [centroid, center, rgbData, image_out] = xyValue( vidDevice );
%     dist = sqrt((centroid(1)-pixelPoint(count+1,1))^2+(centroid(2)-pixelPoint(count+1,2))^2);
%     end
%     step(hVideoIn, rgbData);
%     count=count+1;
% end

%%
%This chunk of code uses voltage to set the bubble into the starting region
%more specifically the top left region (about -0.1,0 voltage)
for xaxis = 0.3:-0.01:-0.1 
s.outputSingleScan ([xaxis,0.3]);
pause(0.05);
end
for yaxis = 0.3:-0.01:0.0
s.outputSingleScan ([xaxis,yaxis]);
pause(0.05);
end

%%
% course run for example trial 1
%% 
gate_string = input('Enter the gate numbers: ', 's')
gate_int = str2num(gate_string);

% % position at starting region before gate 2
% for yaxis = yaxis:0.01:0.28
%     s.outputSingleScan([xaxis,yaxis])
%     pause(0.05);
% end
% % move into gate 2
% for xaxis = xaxis:0.01:0.05
%     s.outputSingleScan([xaxis,yaxis])
%     pause(0.05);
% end

%% Starting region to first 3 gates
% move from start, through gate 1
stage = 0;
while stage == 0
if gate_int(1,1) == 1;
    for xaxis = xaxis:0.01:0.15
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
% move from start, through gate 2
if gate_int(1,1) == 2;
    for yaxis = yaxis:0.01:0.28
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
    for xaxis = xaxis:0.01:0.15
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
% move from start, through gate 3
if gate_int(1,1) == 3;
    for yaxis = yaxis:0.01:0.52
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
    for xaxis = xaxis:0.01:0.15
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
stage = 1; 
end
%% move from first region to second region
while stage == 1
% move through gate 4    
if gate_int(1,2) == 4;
    for yaxis = yaxis:0.01:0.0
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
    for xaxis = xaxis:0.01:0.4
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
% move through gate 5
if gate_int(1,2) == 5;
    for yaxis = yaxis:0.01:0.25
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
    for xaxis = xaxis:0.01:0.4
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
% move through gate 6
if gate_int(1,2) == 6;
    for yaxis = yaxis:0.01:0.52
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
    for xaxis = xaxis:0.01:0.4
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
stage = 2;
end
%% move from second region to turn around region
while stage == 2
% move through gate 7    
if gate_int(1,3) == 7;
    for yaxis = yaxis:0.01:0.0
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
    for xaxis = xaxis:0.01:0.65
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
% move through gate 8
if gate_int(1,3) == 8;
    for yaxis = yaxis:0.01:0.25
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
    for xaxis = xaxis:0.01:0.65
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
% move through gate 9
if gate_int(1,3) == 9;
    for yaxis = yaxis:0.01:0.52
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
    for xaxis = xaxis:0.01:0.65
    s.outputSingleScan([xaxis,yaxis])
    pause(0.05);
    end 
end
stage = 3;
end


%% Release
% Call the release method on the System objects to close any open files and
% devices.
release(vidDevice);
%release(hVideoOut);
%release(hVideoIn);

