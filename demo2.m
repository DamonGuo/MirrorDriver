clc;clear;
devices = daq.getDevices;
s=daq.createSession('ni');
s.addAnalogOutputChannel('Dev1','ao0','voltage');
s.addAnalogOutputChannel('Dev1','ao1','voltage');
s.Rate = 5000;
waittime=0.2;
s.outputSingleScan ([0 0]);


% test=(0:0.15:0.35);
% 
% for m = drange(1:10)
%     [x, y]=size(test);
%     for n = drange (1:y)
%         s.outputSingleScan ([0 test(n)]);
%         pause(waittime);
%     end
%     s.outputSingleScan ([0 0.5]);
%     pause(1);
% end