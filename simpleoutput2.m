clc;clear;
devices = daq.getDevices;
s=daq.createSession('ni');
s.addAnalogOutputChannel('Dev1','ao0','voltage');
s.addAnalogOutputChannel('Dev1','ao1','voltage');
s.Rate = 5000;
waittime=0.5;

s.outputSingleScan ([0.35 0.3]);
temp=fliplr(0.2:0.01:0.35);
s.outputSingleScan ([(temp)' (0.3*ones(size(temp)))']);
pause(waittime);



% for n = drange (1:20)
% outputSignal=2*sin(linspace(0,pi*2,s.Rate)');
% plot(outputSignal);
% xlabel('Time');
% ylabel('voltage');
% s.queueOutputData([outputSignal outputSignal]);
% end