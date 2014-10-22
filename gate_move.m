function [xaxis,yaxis] = gate_move( xaxis,yaxis,xend,yend, type, s)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%% 
SPEED = 0; %0  for slow motion: 0.01
STEP = 0.025; % for slow motion: 0.03


if strcmpi(type,'init') == 1
    for xaxis = xaxis:-STEP:xend
    s.outputSingleScan ([xaxis,yaxis]);
    pause(SPEED);
    end
    if yaxis > yend
        for yaxis = yaxis:-STEP:yend
        s.outputSingleScan ([xaxis,yaxis]);
        pause(SPEED);
        end
    else 
        for yaxis = yaxis:+STEP:yend
        s.outputSingleScan ([xaxis,yaxis]);
        pause(SPEED);
        end
    end    
     
    
    
elseif strcmpi(type,'right') == 1
    for xaxis = xaxis:STEP:xend
    s.outputSingleScan([xaxis,yaxis])
    pause(SPEED);
    end 
    
elseif strcmpi(type,'up') == 1
    for yaxis = yaxis:-STEP:yend
    s.outputSingleScan([xaxis,yaxis]);
    pause(SPEED);
    end
elseif strcmpi(type,'left') == 1   
    for xaxis = xaxis:-STEP:xend
    s.outputSingleScan([xaxis,yaxis])
    pause(SPEED);
    end 
elseif strcmpi(type,'down') == 1   
    for yaxis = yaxis:STEP:yend
    s.outputSingleScan([xaxis,yaxis])
    pause(SPEED);
    end 

elseif strcmpi(type,'diag') == 1
    if yend > yaxis %implies movement down
        for yaxis = yaxis:STEP:yend
            if xend > xaxis % implies movement right
                if xaxis ~= xend
                    xaxis = xaxis + 0.005;
                end
                s.outputSingleScan([xaxis,yaxis]);
                pause(SPEED);
            else % xend <= xaxis, so left movement
                if xaxis ~= xend
                    xaxis = xaxis - 0.005;
                end
                s.outputSingleScan([xaxis,yaxis]);
                pause(SPEED);
            end
        end
    else %yend <= yaxis, implies movement up
        for yaxis = yaxis:-STEP:yend
            if xend > xaxis % implies movement right
                if xaxis ~= xend
                    xaxis = xaxis + 0.005;
                end
                s.outputSingleScan([xaxis,yaxis]);
                pause(SPEED);
            else % xend <= xaxis, so left movement
                if xaxis ~= xend
                    xaxis = xaxis - 0.005;
                end
                s.outputSingleScan([xaxis,yaxis]);
                pause(SPEED);
            end
        end
    end
    if xaxis ~= xend % finish x movememnt if y movement happens to complete before x completes
        if xaxis < xend
            for xaxis = xaxis:STEP:xend
            s.outputSingleScan([xaxis,yaxis]);
            pause(SPEED);
            end
        else
            for xaxis = xaxis:-STEP:xend
                s.outputSingleScan([xaxis,yaxis]);
                pause(SPEED);
            end
        end
    end
end

end


