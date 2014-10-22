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


%% Initialization
% Use these next sections of code to initialize the required variables and
% System objects.
NumPts = 250;   % Maximum number of boundary pixels.
tolerance = 1;  % tolerance for distance.
NumTimes = 8;

%%
% Create a |VideoFileReader| System object to read a video file.
hmfr = vision.VideoFileReader('test.wmv', ...
                              'PlayCount', NumTimes);

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
% Create two |VideoPlayer| System objects to display the input and output
% videos.
hVideo1 = vision.VideoPlayer('Name', 'Original');

hVideo2 = vision.VideoPlayer('Name', 'Results');
hVideo2.Position(1) = hVideo1.Position(1)+450;

%% Stream Processing Loop
% Create a processing loop to perform concentricity inspection in the input
% video. This loop uses the System objects you instantiated above.
count = 1;
while (count < NumTimes)
    if isDone(hmfr)
        count = count+1;         
    end
    I = step(hmfr);
    image = step(hcsc, I);          % Convert Image to Intensity format.

    BW = image < 0.6*mean(mean(image));              % Convert image to binary.
    centroid = step(hblob, BW);     % Compute centroid of the blobs.

    
    Idx = floor(centroid(1));
    max_idx = find(BW(:, Idx), 1);
    StartPts = [Idx, single(max_idx)]; % Compute the starting points.

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
    y1 = insertMarker(I, centroid, '+', 'Color', 'red');
    y2 = insertShape(y1, 'Circle', [center, radius],'Color', 'cyan');
    y3 = insertMarker(y2, center, '*', 'Color', 'green'); 
    
    % insert text
%     qualitySet =  {'Bad', 'Good'};
%     textIdx = (dist <= tolerance) + 1;
%     textQuality = ['Concentricity: ' qualitySet{textIdx}];
%     textDist = sprintf('Distance in pixels: %d', uint8(dist));
    textX = sprintf ('X : %d',uint8(centroid(1)));
    textY = sprintf ('Y : %d',uint8(centroid(2)));    
%     textAll = sprintf([textQuality '\n' textDist]);
    textAll = sprintf ([textX '\n' textY]);
    image_out = insertText(y3, [1 1], textAll, 'FontSize', 14);
    % Display the results.
    step(hVideo2, image_out);
    step(hVideo1, I);
end

%% Release
% Call the release method on the System objects to close any open files and
% devices.
release(hmfr);

%% Summary
% In the Results window, you can see the cladding's centroid marked with a
% red '+'. The center of the cladding's outer boundary is marked with a
% green '*'. When the distance between these two markers is within an
% acceptable tolerance, the cross-section of the fiber optic cable is
% labeled "Concentricity: Good". Otherwise, it is labeled "Concentricity:
% Bad". We also display the distance, in pixels, between the cladding's
% centroid and the center of the cladding's outer boundary.


displayEndOfDemoMessage(mfilename)