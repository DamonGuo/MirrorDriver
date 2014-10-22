% Create video input object. 
vid = videoinput('gige',1,'Mono8');
src.PacketDelay = 2;
% Set video input object properties for this application.
% Note that example uses both SET method and dot notation method.
set(vid,'TriggerRepeat',100);
vid.FrameGrabInterval = 5;

% Set value of a video source object property.
vid_src = getselectedsource(vid);
set(vid_src,'Tag','motion detection setup');

% Create a figure window.
figure; 

% Start acquiring frames.
start(vid)

% Calculate difference image and display it.
while(vid.FramesAvailable >= 2)
    data = getdata(vid,2); 
    diff_im = imabsdiff(data(:,:,:,1),data(:,:,:,2));
    imshow(diff_im);
    drawnow     % update figure window
end

stop(vid)