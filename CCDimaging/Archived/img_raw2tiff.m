clear all, close all
file = '1190305008b.b16';
%file = '1190305000H1800_486.b16'; %calibration file special name
folder = 'C:\Users\Plasma\Box\elizabethtan\2018-19 WIRX Honors Thesis\Images and Figures\ccd_raw\';
img = readB16([folder file]);



% Check Histogram
figure;
single = reshape(img,[numel(img),1]);
histogram(single);
title([file])
xlabel('Values to Determine clim')
ylabel('Brightness')
set(gca,'YScale','log')
grid on

figure('Position',[0 0 1280 1024]);
clims = [70,2500];
fig = imagesc(img,clims)
colormap(gray)
% colorbar
set(gca, 'Visible', 'off')

%%
folder2 = 'C:\Users\Plasma\Box\elizabethtan\2018-19 WIRX Honors Thesis\Images and Figures\spectra\';
savename = file(1:end-5);
saveas(gcf,[folder2 'spec_' savename '.tif'],'tiffn')
disp(['Image saved ' folder2 savename])
