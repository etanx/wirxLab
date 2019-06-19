
% showB16.m: This function shows content of raw .b16 files
% Ellie Tan, April 2019.

clear all, close all

shot = 1190000000; % input your shot number/run day/ other text for display

% Get location of image file from user
[fileName,fileFolder] = uigetfile(path); % select .b16 raw image file in GUI window
filePath = [fileFolder fileName];
img = readB16(filePath); % flip upside down image?  

%% Plot 
f = figure;
%clims = [50,300];
%fig = imagesc(flipud(img),clims)
fig = imagesc(flipud(img));

colormap 'gray'; %Use 'jet' for more interesting looking pictures.
im=getframe; %Convert figure into a RGB image.
filename=strcat(shot,'.png'); %Store picture 
set(gca, 'Visible', 'off')
text(5,40,num2str(shot),'Color','white')

% add slider and labels to figure
hClims = gca;
originalCLim = hClims.CLim;
uicontrol('Style', 'slider', 'Min',60,'Max',5000,'Value',originalCLim(2), ...
          'Position', [40 20 500 20], ...
          'Callback', @(src,evt) hax( src, hClims ) ); 

%% update the clim of plot
originalCLim = hClims.CLim;

function hax( src, hClims )
    hClims.CLim = ([50 get( src, 'Value' )])
end

%% Save new png file
%imwrite(im.cdata,[foldersave filename],'Quality',100); % save JPEG
%saveas(gca,[foldersave filename]) % save png














%% Check Histogram to see brightness or clim setting
% figure;
% single = reshape(img,[numel(img),1]);
% histogram(single);
% title([shot])
% xlabel('Values to Determine clim')
% ylabel('Brightness')
% set(gca,'YScale','log')
% grid on

