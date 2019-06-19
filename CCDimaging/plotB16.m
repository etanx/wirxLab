function [] = plotB16(shot)
% plotB16: This function plots content of raw .b16 files, from wirxtree
% Adapted from the work of Ellie Tan, April 2019. (see showB16.m)
% Stephen McKay, June 2019


 % input your shot number/run day/ other text for display

% Get image file from tree
mdsconnect('WIRX07');
mdsopen('wirxtree',shot);
img = flipud(mdsvalue('ICCD.DICAM1:FRAME1')); % upside down image
%(uncomment to use)
%img = mdsvalue('ICCD.DICAM1:FRAME1'); % normal image (comment out if upside down)

% get time, Ip, and B
time = mdsvalue('ICCD.DICAM1:SETTINGS.FRAME1_TIME')
ticcd=mdsvalue('\top.iccd.dicam1.settings:frame2_time');
dticcd=mdsvalue('\top.iccd.dicam1.settings:frame2_expo');
irange=round((50000+ticcd*10)):round((50000+ticcd*10+dticcd*10)); %range of digitizer time points to use
d=mdsvalue('\top.iv_meas.processed:idis'); %get plasma current
Ip=mean(d(irange),1) %store average Ip during time of interest
d=mdsvalue('\top.iv_meas.processed.icoil'); %get coil current
B=mean(d(49000:49999),1) %store average coil current prior to shot

mdsclose();
mdsdisconnect();
%% Plot 
f = figure;
f = imagesc(img);
colormap 'gray'; %Use 'jet' for more interesting looking pictures.
set(gca, 'Visible', 'off')
text(5,40,num2str(shot),'Color','white')

end

