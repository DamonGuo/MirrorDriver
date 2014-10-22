function [xaxis,yaxis,STEP] = key_move( xaxis, yaxis, type, s, STEP )

%fig_h = figure; % Open the figure and put the figure handle in fig_h
%set(fig_h,'KeyPressFcn',@(fig_obj,eventDat) disp(['You just pressed: ' eventDat.Key])); 
% or again use the whole eventDat.Character or eventDat.Modifier if you want.

%% 
%% took off the semi-colon for non suppressed output
%move laser to the right
if strcmpi(type,'d') == 1
    if (xaxis < 4.8)
    xaxis = xaxis+STEP;
    s.outputSingleScan([xaxis,yaxis])
    elseif ((xaxis > 4.8) && (xaxis < 5)) && (STEP < 0.02)
    xaxis = xaxis+STEP;
    s.outputSingleScan([xaxis,yaxis])
    end
    
%move laser down
elseif strcmpi(type,'s') == 1
    if (yaxis < 4.8)
    yaxis=yaxis+STEP;
    s.outputSingleScan([xaxis,yaxis])
    end
    %move the laser to the left    
elseif strcmpi(type,'a') == 1
    if (xaxis > 0.5)
    xaxis=xaxis-STEP;
    s.outputSingleScan([xaxis,yaxis])
    end
    
%move the laser up
elseif strcmpi(type,'w') == 1   
    if (yaxis > 0.2)
    yaxis=yaxis-STEP;
    s.outputSingleScan([xaxis,yaxis])
    end
%decrement stepping of the laser
elseif strcmpi(type,'q') == 1
    if STEP > 0.01
    STEP = STEP-0.01;
    end
    
%incrementing stepping of the laser
elseif strcmpi(type,'e') == 1
    if STEP < 0.2
    STEP=STEP+0.01;
    end
end
end


