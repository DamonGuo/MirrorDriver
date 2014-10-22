function [img, numTargets, target_img] = videopattern_gettemplate1(useDefaultTarget, vidDevice)
%VIDEOPATTERN_GETTEMPLATE Helper function used in videopatternmatching demo
%to get the template pattern to track.

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2012/10/29 19:42:27 $

numTargets = 1;
reader = vidDevice;
% Read the first frame of the input video and display it on the screen
% vidDevice = vision.VideoFilevidDevice('RVCap.wmv',...
%     'VideoOutputDataType','uint8',...
%     'ImageColorSpace','Intensity');
%imaq.VideoDevice('gige', 1, 'Mono8', ...
%    'ROI', [300 200 800 600],...
%    'ReturnedColorSpace', 'rgb', ...
%    'DeviceProperties.ExposureTimeAbs', 15000);


img = rgb2gray(step(reader));
release(reader);
imshow(img);
d = imdistline;
% Put a break point after this line
api=iptgetapi(d);
roitemp = api.getPosition;
roi = round([roitemp(1,1) roitemp(1,2) roitemp(2,1)-roitemp(1,1) roitemp(2,2)-roitemp(1,2)]);
% delete(d);
% close(gcf);

% Pick some initial location for the target rectangle
target_img = imcrop(img,roi);

hf = figure('Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
    'Name', 'Target pattern', ...
    'NumberTitle', 'off');
imshow(img);

if useDefaultTarget
    numTargets = 1;
    % Show the pattern
    rectangle('Position', roi, 'EdgeColor',[0 1 0]);
    pause(2);
    close(hf);
    return;
else
    
    h = imrect(gca, roi);
    api = iptgetapi(h);
    api.setColor([0 1 0]);
    api.addNewPositionCallback(@(p) title(mat2str(p)));
    
    % Don't allow the rectangle to be dragged outside of image boundaries
    fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
    api.setDragConstraintFcn(fcn);
    
    yshift = 10;
    uicontrol(hf, 'style', 'text', 'Units', 'Pixels', ...
        'String', 'Number of targets:', ...
        'Fontsize', 12, ...
        'Position', [80 yshift 150 20]);
    hEditBox = uicontrol(hf, 'style', 'edit', 'Units', 'Pixels', ...
        'String', '1', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1 1 1], ...
        'Position', [230 yshift 100 20]);
    uicontrol(hf, 'style', 'pushbutton', 'Units', 'Pixels', ...
        'String', 'Submit', ...
        'Position', [340 yshift 100 20], ...
        'Callback', @submitFcn);
    uiwait;
end

    function submitFcn(varargin)
        roi = api.getPosition();
        
        % Extract the template data
        target_img = imcrop(img,roi);
        % assignin('base','target_img', target_img);
        if any(size(target_img) < 20) || any(size(target_img) > 100)
            errordlg('Target height and width must be between 20 and 100 pixels.',...
                'Invalid dimensions');
            return;
        end
        numTargets = round(str2double(get(hEditBox, 'String')));
        if numTargets < 1
            warndlg('Number of targets must be greater than or equal to 1. Setting the number of targets to 1.', 'Invalid number of targets');
            numTargets = 1;
        end
        close(hf);
    end

end


