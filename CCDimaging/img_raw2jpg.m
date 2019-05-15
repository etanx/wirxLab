
% raw2jpg: This function converts raw camera files into jpg files
% Ellie Tan, April 2019.

clear all, close all

shot = '1190305006';
folder = 'C:\Users\Plasma\Box\elizabethtan\2018-19 WIRX Honors Thesis\Images and Figures\ccd_raw\';
img = readB16([folder shot 'a.b16']);

%figure('Position',[0 0 1280 1024]);
figure
clims = [50,300];
fig = imagesc(flipud(img),clims)
colormap 'jet'; %Use 'jet' for more interesting looking pictures.
im=getframe; %Convert figure into a RGB image.
filename=strcat(shot,'.png'); %Store picture 
set(gca, 'Visible', 'off')
text(5,40,[shot])

%%
foldersave = 'C:\Users\Plasma\Box\elizabethtan\2018-19 WIRX Honors Thesis\Images and Figures\ccd\';
%imwrite(im.cdata,[foldersave filename],'Quality',100); %Write picture to JPEG
saveas(gca,[foldersave filename])

%% Check Histogram for clim setting
figure;
single = reshape(img,[numel(img),1]);
histogram(single);
title([shot])
xlabel('Values to Determine clim')
ylabel('Brightness')
set(gca,'YScale','log')
grid on