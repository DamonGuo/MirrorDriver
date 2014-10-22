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
clear;
clc;

%% Initialization
% Create the Video Device System object.
vidDevice = imaq.VideoDevice('gige', 1, 'Mono8', ...
                             'ROI', [400 250 800 800],...
                             'ReturnedColorSpace', 'rgb', ...
                             'DeviceProperties.ExposureTimeAbs', 15000);
%ROI used to be [400 250 1280 800]
%                                                      'ROI', [0 0 1080 1280], ...

%% Initialization of the DAQ
devices = daq.getDevices;
s=daq.createSession('ni');
% changed from Dev1 to Dev2
s.addAnalogOutputChannel('Dev2','ao0','voltage');
s.addAnalogOutputChannel('Dev2','ao1','voltage');
%s.Rate = 5000;
s.outputSingleScan ([-0.26 -0.26]);
%s.outputSingleScan([2.5 2.5]);
%%
% Create two |VideoPlayer| System objects to display the input and output
% videos.
%COMMENTED THIS OUT
%hVideoIn = vision.VideoPlayer('Name', 'Original');
%hVideoOut = vision.VideoPlayer('Name', 'Results');
%hVideoOut.Position(1) = hVideoIn.Position(1)+450;

%%


%Calibration
% calArray =[2.5 2.5; 2.6 2.6; 2.7 2.7; 2.8 2.8];
% pixelToVolt = zeros(size(calArray));
% nFrames = 0;
 preview(vidDevice);
% while (nFrames < size(pixelToVolt, 1))
%     s.outputSingleScan (calArray(nFrames+1,:));%CalAOutput the calibration value
%     pause(1);
%     [centroid, center, rgbData, image_out] = xyValue( vidDevice );    
%     pixelToVolt(nFrames+1,:)=centroid;
%  %   step(hVideoOut, image_out);
%  %   step(hVideoIn, rgbData);
%     nFrames = nFrames+1;
% end
% %Maybe the following combination need to be swifted
% temp1=flipud([calArray(1,1)-calArray(:,1),calArray(1,2)-calArray(:,2)]);
% calArray = [temp1(1:size(calArray,1)-1,:); calArray];
% temp2 = flipud([pixelToVolt(1,1)-pixelToVolt(:,1),pixelToVolt(1,2)-pixelToVolt(:,2)]);
% pixelToVolt = [temp2(1:size(pixelToVolt,1)-1,:); pixelToVolt];
% %%
% %Matching and sorting
% tempx=[pixelToVolt(:,1),calArray(:,1)];
% tempx=sortrows(tempx,1);
% tempy=[pixelToVolt(:,2),calArray(:,2)];
% tempy=sortrows(tempy,2);




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
xaxis=-0.26;
yaxis=-0.26;
[xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,yaxis,'init',s);


%%VIDEO SHAPE MATCHING THINGY
threshold = single(0.96);
level = 2;

%%
% Create System object to read a video.
% "grayscale" should be used.

%%
% Create three gaussian pyramid System objects for decomposing the target
% template and decomposing the Image under Test(IUT). The decomposition is
% done so that the cross correlation can be computed over a small region
% instead of the entire original size of the image.
hGaussPymd1 = vision.Pyramid('PyramidLevel',level);
hGaussPymd2 = vision.Pyramid('PyramidLevel',level);
hGaussPymd3 = vision.Pyramid('PyramidLevel',level);

%%
% Create a System object to rotate the image by angle of pi before
% computing multiplication with the target in the frequency domain which is
% equivalent to correlation.
hRotate1 = vision.GeometricRotator('Angle', pi);

%% 
% Create two 2-D FFT System objects one for the image under test and the
% other for the target. 
hFFT2D1 = vision.FFT;
hFFT2D2 = vision.FFT;

%% 
% Create a System object to perform 2-D inverse FFT after performing
% correlation (equivalent to multiplication) in the frequency domain. 
hIFFFT2D = vision.IFFT;

%% 
% Create 2-D convolution System object to average the image energy in tiles
% of the same dimension of the target.
hConv2D = vision.Convolver('OutputSize','Valid');

%%
% Here you implement the following sequence of operations.

% Specify the target image and number of similar targets to be tracked. By
% default, the example uses a predefined target and finds up to 2 similar
% patterns. Set the variable useDefaultTarget to false to specify a new
% target and the number of similar targets to match.
useDefaultTarget = true;
[Img, numberOfTargets, target_image] = ...
  videopattern_gettemplate1(useDefaultTarget, vidDevice);

% Downsample the target image by a predefined factor using the
% gaussian pyramid System object. You do this to reduce the amount of
% computation for cross correlation.
target_image = single(target_image);
target_dim_nopyramid = size(target_image);
target_image_gp = step(hGaussPymd1, target_image);
target_energy = sqrt(sum(target_image_gp(:).^2));

% Rotate the target image by 180 degrees, and perform zero padding so that
% the dimensions of both the target and the input image are the same.
target_image_rot = step(hRotate1, target_image_gp);
[rt, ct] = size(target_image_rot);
Img = single(Img);
Img = step(hGaussPymd2, Img);
[ri, ci]= size(Img);
r_mod = 2^nextpow2(rt + ri);
c_mod = 2^nextpow2(ct + ci);
target_image_p = [target_image_rot zeros(rt, c_mod-ct)];
target_image_p = [target_image_p; zeros(r_mod-rt, c_mod)];

% Compute the 2-D FFT of the target image
target_fft = step(hFFT2D1, target_image_p);

% Initialize constant variables used in the processing loop.
target_size = repmat(target_dim_nopyramid, [numberOfTargets, 1]);
gain = 2^(level);
Im_p = zeros(r_mod, c_mod, 'single'); % Used for zero padding
C_ones = ones(rt, ct, 'single');      % Used to calculate mean using conv

%% 
% Create a System object to calculate the local maximum value for the
% normalized cross correlation.
hFindMax = vision.LocalMaximaFinder( ...
            'Threshold', single(-1), ...
            'MaximumNumLocalMaxima', numberOfTargets, ...
            'NeighborhoodSize', floor(size(target_image_gp)/2)*2 - 1);

%%
% Create a System object to display the tracking of the pattern.
sz = get(0,'ScreenSize');
pos = [20 sz(4)-400 400 300];
hROIPattern = vision.VideoPlayer('Name', 'Overlay the ROI on the target', ...
              'Position', pos);

%%
% Initialize figure window for plotting the normalized cross correlation
% value
hPlot = videopatternplots1('setup',numberOfTargets, threshold);




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
% Types of movement: right(r), Right up(rup), Left(l), Left up(lup)
stage = 0;
while stage == 0
    %move from start, through gate 1
    if gate_num(1,1) == 1;
        [xaxis, yaxis] = gate_move(xaxis,yaxis,0,yaxis,'right',s);
        video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
            hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, ...
            target_energy, hFindMax, threshold, gain, target_size,...
            hPlot, hROIPattern, Im_p );
        
       
    % move from start, through gate 2
    elseif gate_num(1,1) == 2;
        [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'down',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,0,yaxis,'right',s);
        video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
            hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, ...
            target_energy, hFindMax, threshold, gain, target_size,...
            hPlot, hROIPattern, Im_p );
           

    % move from start, through gate 3
    elseif gate_num(1,1) == 3;
         [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0.20,'down',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,0,yaxis,'right',s);
        video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
            hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, ...
            target_energy, hFindMax, threshold, gain, target_size,...
            hPlot, hROIPattern, Im_p );
      

    
    end
stage = 1; 
end
%% move from first region to second region
while stage == 1
    % move through gate 4    
    if gate_num(1,2) == 4;
        %if our current position is lower than next gate
             [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,-0.26,'up',s);
             [xaxis, yaxis] = gate_move(xaxis,yaxis,0.24,yaxis,'right',s);
      
    video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
            hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, ...
            target_energy, hFindMax, threshold, gain, target_size,...
            hPlot, hROIPattern, Im_p );

    % extra step here that can be removed (for moving through the gate)
        
    % move through gate 5
    elseif gate_num(1,2) == 5;
	%if our current position is greater than the next gae
    if gate_num(1,1) == 3
		 [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'up',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,0.24,yaxis,'right',s);
       
	%regular gate movment	
    elseif	gate_num(1,1) == 2
        [xaxis, yaxis] = gate_move(xaxis,yaxis,0.24,yaxis,'right',s);
   %else it's gate 1
    else
         [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'down',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,0.24,yaxis,'right',s);
        
    end
% move through gate 6
    elseif gate_num(1,2) == 6;
     [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0.20,'down',s);
     [xaxis, yaxis] = gate_move(xaxis,yaxis,0,yaxis,'right',s);
 
    end
stage = 2;
end
%% move from second region to turn around region
while stage == 2
% move through gate 7    
    if gate_num(1,3) == 7;
	% if our current position is lower than the gate
             [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,-0.26,'up',s);
             [xaxis, yaxis] = gate_move(xaxis,yaxis,0.35,yaxis,'right',s);
         
             video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
            hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, ...
            target_energy, hFindMax, threshold, gain, target_size,...
            hPlot, hROIPattern, Im_p );
             
% move through gate 8
    elseif gate_num(1,3) == 8;
    %if our current gate is lower than the next gate
        if gate_num(1,1) == 6
             [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'up',s);
            [xaxis, yaxis] = gate_move(xaxis,yaxis,0.35,yaxis,'right',s);
        %regular gate movment
        else
             [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'down',s);
             [xaxis, yaxis] = gate_move(xaxis,yaxis,0.35,yaxis,'right',s);
        end        
% move through gate 9
    elseif gate_num(1,3) == 9;
         [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0.20,'down',s);
         [xaxis, yaxis] = gate_move(xaxis,yaxis,0.35,yaxis,'right',s);
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
            [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,-0.26,'up',s);
            [xaxis, yaxis] = gate_move(xaxis,yaxis,0.24,yaxis,'left',s);
    
            video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
            hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, ...
            target_energy, hFindMax, threshold, gain, target_size,...
            hPlot, hROIPattern, Im_p );
            
% move from start, through gate 2
    elseif gate_num(1,4) == 8;
    %if our current gate is lower than the next gate
       if gate_num(1,3) == 9
           [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'up',s);
         [xaxis, yaxis] = gate_move(xaxis,yaxis,0.24,yaxis,'left',s);
        %regular gate movment
        else
            [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'down',s);
            [xaxis, yaxis] = gate_move(xaxis,yaxis,0.24,yaxis,'left',s);
        end        
 
% move from start, through gate 3
    elseif gate_num(1,4) == 9;
          [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0.20,'down',s);
          [xaxis, yaxis] = gate_move(xaxis,yaxis,0.24,yaxis,'left',s);
    end
stage = 4; 
end
%% move
while stage == 4
% move through gate 4    
    if gate_num(1,5) == 4;
        %if our current position is lower than next gate
           [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,-0.26,'up',s);
          [xaxis, yaxis] = gate_move(xaxis,yaxis,0,yaxis,'left',s);
   
          video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
            hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, ...
            target_energy, hFindMax, threshold, gain, target_size,...
            hPlot, hROIPattern, Im_p );
          
% move through gate 5
    elseif gate_num(1,5) == 5;
	%if our current position is greater than the next gae
    if gate_num(1,4) == 9
          [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'up',s);
          [xaxis, yaxis] = gate_move(xaxis,yaxis,0,yaxis,'left',s);
	%regular gate movment	
    else	
        [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'down',s);
        [xaxis, yaxis] = gate_move(xaxis,yaxis,0,yaxis,'left',s);
    end
% move through gate 6
    elseif gate_num(1,5) == 6;
       [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0.20,'down',s);
       [xaxis, yaxis] = gate_move(xaxis,yaxis,0,yaxis,'left',s);
    end
stage = 5;
end
%% move from second region to turn around region
while stage == 5
% move back through gate 1
    if gate_num(1,6) == 1;
	% if our current position is lower than the gate
  
        [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,-0.26,'up',s);
         [xaxis, yaxis] = gate_move(xaxis,yaxis,-0.26,yaxis,'left',s);
         
         video_processing( vidDevice, hGaussPymd3, ri, rt, ci, ct,...
            hFFT2D2, target_fft, hIFFFT2D, hConv2D, C_ones, ...
            target_energy, hFindMax, threshold, gain, target_size,...
            hPlot, hROIPattern, Im_p );
         
% move back through gate 2
    elseif gate_num(1,6) == 2;
    %if our current gate is lower than the next gate
        if gate_num(1,5) == 6
            [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'up',s);
          [xaxis, yaxis] = gate_move(xaxis,yaxis,-0.26,yaxis,'left',s);
        %regular gate movment
        else
            [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0,'down',s);
            [xaxis, yaxis] = gate_move(xaxis,yaxis,-0.26,yaxis,'left',s);
        end    
% move back through gate 3
    elseif gate_num(1,6) == 3;
            [xaxis, yaxis] = gate_move(xaxis,yaxis,xaxis,0.20,'down',s);
          [xaxis, yaxis] = gate_move(xaxis,yaxis,-0.26,yaxis,'left',s);
    end
stage = 8;
end
%% Release
% Call the release method on the System objects to close any open files and
% devices.
release(vidDevice);
%release(hVideoOut);
%release(hVideoIn);
