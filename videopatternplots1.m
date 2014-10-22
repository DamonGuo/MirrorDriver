function hPlot = videopatternplots1(mode, varargin)
%VIDEOPATTERNPLOTS Helper function to setup plots in videopatternmatching
%demo

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/08/30 02:59:42 $

persistent numTargets firstTime;

switch mode
  case 'setup'
    figure('Name', 'Match Metric', 'Color', 'white', ...
      'Visible','off', 'NumberTitle', 'off');
    hold  on;
    col = ['r','g','c','m','k','y'];
    numTargets = varargin{1};
    threshold = varargin{2};
    hPlot = zeros(1, numTargets);
    for ii = 1:1:numTargets,
      hPlot(ii) = plot(ii, NaN, col(mod(ii, 6) + 1));
    end
    line([0 400], threshold*[1 1]);
    grid on;
    firstTime = true;
  case 'update'
    hPlot = varargin{1};
    norm_Corr_value = varargin{2};
    if firstTime
      set(get(get(hPlot(1),'Parent'),'Parent'), 'Visible', 'on');
      firstTime = false;
    end
     % Plot normalized cross correlation
    for j = 1:numTargets
        ydata = [get(hPlot(j), 'YData') norm_Corr_value(j)];
        set(hPlot(j), 'YData', ydata, 'XData', 1:length(ydata));
    end
    drawnow;
end