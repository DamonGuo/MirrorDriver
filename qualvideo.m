clc;clear;
devices = daq.getDevices;
s=daq.createSession('ni');
s.addAnalogOutputChannel('Dev1','ao0','voltage');
s.addAnalogOutputChannel('Dev1','ao1','voltage');
s.Rate = 5000;
waittime=0.025;
s.outputSingleScan ([-0.35 -0.3]);

loc=[-0.35,  -0.3 ;
     -0.15,  -0.3 ;
     -0.15,   0   ;
      0.15,   0   ;
      0.15,   0.27;
      0.35,   0.27;
      0.35,  -0.3 ;
      0.15,  -0.3 ;
      0.15,   0.27;
     -0.15,   0.27;
     -0.15,  -0.3 ;
     -0.35,  -0.3];
flag=1;
count=1;
[a,b]= size (loc);
while (count<a)
temp=loc(count,flag);
if temp < loc(count+1,flag)
    while (temp<loc(count+1,flag))
        if flag==1
            s.outputSingleScan ([temp loc(count,2)]);
        else
            s.outputSingleScan ([loc(count,1) temp]);
        end
        pause(waittime);
        temp=temp+0.01;
    end
else
    while (temp>loc(count+1,flag))
        if flag==1
            s.outputSingleScan ([temp loc(count,2)]);
        else
            s.outputSingleScan ([loc(count,1) temp]);
        end
        pause(waittime);
        temp=temp-0.01;
    end
end

if flag==1
    flag=2;
elseif flag==2
    flag=1;
end

count=count+1;
end


% for n = drange (1:20)
% outputSignal=2*sin(linspace(0,pi*2,s.Rate)');
% plot(outputSignal);
% xlabel('Time');
% ylabel('voltage');
% s.queueOutputData([outputSignal outputSignal]);
% end