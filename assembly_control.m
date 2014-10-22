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
%                                                      'ROI', [0 0 1080 1280], ...

%% Initialization of the DAQ
devices = daq.getDevices;
s=daq.createSession('ni');
s.addAnalogOutputChannel('Dev2','ao0','voltage');
s.addAnalogOutputChannel('Dev2','ao1','voltage');
%s.Rate = 5000;
s.outputSingleScan ([4 2]);

%preview(vidDevice);
%% initialization for the starting position
xaxis = 4;
yaxis = 2;
STEP = 0.05;
scrsz = get(0,'ScreenSize');
f = figure('Position',[1 scrsz(4)/3 scrsz(3)/4 scrsz(4)/4]);
waitforbuttonpress;
key = get(f, 'CurrentCharacter');

while key ~= 'z'
	[xaxis, yaxis, STEP] = key_move(xaxis, yaxis, key, s, STEP)
	waitforbuttonpress;
	key = get(f, 'CurrentCharacter');
    %handle = uicontrol('Style','pushbutton');
end
close(f);