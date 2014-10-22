function [ centroid, center, rgbData, image_out] = xyValue( vidDevice )

%% Initialization
% Use these next sections of code to initialize the required variables and
% System objects.
NumPts = 250;   % Maximum number of boundary pixels.
%%
% Create a |ColorSpaceConverter| System object to convert the RGB image to
% intensity format.
hcsc = vision.ColorSpaceConverter('Conversion', 'RGB to intensity');

%%
% Create a |BlobAnalysis| System object to find the centroid of the circular
% blobs in the video.
hblob = vision.BlobAnalysis( ...
                        'AreaOutputPort', false, ...
                        'BoundingBoxOutputPort', false, ...
                        'OutputDataType', 'single', ...
                        'MaximumCount', 1);
%%
% Create a |BoundaryTracer| System object to find the outer boundary of the
% cladding.
htracebound = vision.BoundaryTracer( ...
    'MaximumPixelCount', NumPts, ...
    'NoBoundaryAction', 'Fill with last point found');
%%
rgbData = step(vidDevice);
image = step(hcsc, rgbData);          % Convert Image to Intensity format.
BW = image < 0.6*mean(mean(image));   % Convert image to binary.
centroid = step(hblob, BW);           % Compute centroid of the blobs.
Idx = floor(centroid(1));
max_idx = find(BW(:, Idx), 1);
StartPts = [Idx, single(max_idx)];    % Compute the starting points.

% Find the boundary pixels of the outer cladding.
Pts = step(htracebound, BW, StartPts);
Row_bound = Pts(:, 1);
Col_bound = Pts(:, 2);
t = [Row_bound Col_bound ones(size(Pts, 1), 1)];
X = pinv(t);
X1 = Row_bound.^2 + Col_bound.^2;
x2 = X*(-X1);

% Calculate the radius and center of the circle fitting the outer
% cladding.
radius = sqrt((-0.5*x2(1)).^2 + (-0.5*x2(2)).^2 - x2(3));
center = [(-0.5*x2(1)), (-0.5*x2(2))];

% Compare the distance between the center of the circle and the
% centroid against a tolerance value.
dist = sqrt(sum(centroid - center).^2);

% Draw the circle, and mark the center and centroid on the image.
y1 = insertMarker(rgbData, centroid, '+', 'Color', 'red');
y2 = insertShape(y1, 'Circle', [center, radius],'Color', 'cyan');
y3 = insertMarker(y2, center, '*', 'Color', 'green');

% insert text
textX = sprintf ('X : %d',uint16(centroid(1)));
textY = sprintf ('Y : %d',uint16(centroid(2)));
textAll = sprintf ([textX '\n' textY]);
image_out = insertText(y3, [1 1], textAll, 'FontSize', 14);
end

