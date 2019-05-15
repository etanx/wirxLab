function [vel,linex, lineticks] = PPD2vel(shot, TimePoints)

% A function to extract the event velocity from a PPD image.
% example:
% [vel,linex, lineticks] = PPD2vel(1190219019, [48000:53000]);
% Elizabeth H. Tan, 15 May 2019.

%% LOG AND FUTURE WORK:
% Maybe simplify to only the click-extract section? Getting PPD data out of MDPlus tree can be delegated to shotData.m -ET
% Script may have problems dealing with PPD arrays from older shots (pre-2015). Same as problem from PPD_view program.
% Figure how to extract multiple timepoint sections from same shot, since you can't just zoom in on a figure to select events.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


TimePoints = TimePoints; %time points selected for analysis by user where 1 is at plasma start and 8000 is maximum
smoothing = 5;   %Number of points to smooth the PPD data

cont_data = []; %empty array to put PPD data into
mdsclose();
mdsopen('wirxtree', shot); %Open the tree for the desired shot

disp('Extracting data from \wirxtree::TOP.DTACQ.ACQ216_252...')
for i = 1:16  % loop over PPD digitizer channels, read data, subtract offset, smooth, and load into cont_data
        
    raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_252:CH'], [sprintf('%02.2i', i)]]);
    offset_data = raw_data - mean(raw_data(16000:16385));
    offset_data = fastsmooth(offset_data, smoothing, 3, 1);
    smoothed_data = interp1(offset_data,min(TimePoints):smoothing:max(TimePoints),'linear');
    cont_data = cat(2, cont_data, smoothed_data');
    
end

disp('Extracting data from \wirxtree::TOP.DTACQ.ACQ216_253...')
for i = 1:4 % do the same for last 4 channels of the 20 element PPD
        
    raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_253:CH'], [sprintf('%02.2i', i)]]);
    %raw_data = raw_data(45000:length(raw_data));
    %offset_data = raw_data - mean(raw_data(1:4000));
    offset_data = raw_data - mean(raw_data(16000:16385));
    offset_data = fastsmooth(offset_data, smoothing, 3, 1);
    %smoothed_data = offset_data(time);
    smoothed_data = interp1(offset_data,min(TimePoints):smoothing:max(TimePoints),'linear');
    cont_data = cat(2, cont_data, smoothed_data');
    
end

disp('Reordering order of horizontal PPD elements...')
%fix the order of PPD elements so they go from one end to other correctly
cont_data =  cont_data(:, [2, 1, 4, 3, 6, 5, 8, 7, 10, 9, 12, 11, 14, 13, 16, 15, 18, 17, 20, 19]);
cont_data = fliplr(cont_data);
PicOut = flipdim(cont_data, 1);
dataX = flipud(PicOut);

%%
% Viewing locations in cm
x = (-9.5:9.5).*1.14;

%contour(z,times/10.,PicOut,'LineColor','black','LevelList',conts);
times = min(TimePoints):smoothing:max(TimePoints);

% plot processed data
f = figure;
s = pcolor(x,times'.*1e-7,dataX);
set(s, 'EdgeColor', 'none');
%set(gca, 'clim', clims);
colorbar;
colormap(jet)

xlabel('Displacement, z (cm)','FontName','Times')
ylabel('Time (Seconds)','FontName','Times')
title(['Shot #' num2str(shot)],'FontName','Times')
set(gca,'XGrid','on');
set(gca,'YGrid','on');
set(gca,'XTick',linspace(-10,10,5));
ytck=get(gca,'YTick');
set(gca,'YTick',linspace(min(min(ytck)),max(max(ytck)),6));
set(gca,'FontName','Times')

%%
disp('Left click to select point pairs, right click twice to finish.')
    
button = 1;
i=1;
 
 disp('Collecting slope points...')
 while max(button) <3   % read ginputs until a mouse right-button to stop
   
   [linex(i,1),lineticks(i,1),button(i,1)] = ginput(1);
   [linex(i,2),lineticks(i,2),button(i,2)] = ginput(1);
   
   disp(i)
   
   if max(button)< 3
    hold on;
    f=plot([linex(i,:)],[lineticks(i,:)],'kx-','LineWidth',1.2);
   end
   i = i+1;
 end

disp('Calculating velocity...')
dx = linex(:,1)-linex(:,2);
dt = (lineticks(:,1)-lineticks(:,2)); % ticks to seconds
vel = dx./dt;

%remove last line which is the 'right click to end' pair
vel = vel(1:end-1);
lineticks = lineticks(1:end-1,:);
linex = linex(1:end-1,:);

fprintf('Average velocity %4.1f km/s \n',mean(vel)/1000)

end
