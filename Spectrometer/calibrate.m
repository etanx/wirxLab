%function [a,b] = calibrate(HImage, HeImage, element)

% INPUTS
% grating = 150, 1800, or 3600 grating.
% gratingPosition = wavelength that the grating is looking at
% filepath = If no file path input, prompt user to select file in GUI window

% OUTPUTS
% px2nm = Conversion factor of pixels to nm
% px2nmFunction = Calibration function of pixels to nanometer (FUTURE WORK)




% Copied from density.m, to edit~


% a function to analyse spectrometer images to get calibration values
% Based on scripts: Temp.m, spectraFWHM, fwhm2Ne, RawSpectra.m by Michael Morken, David Blasing, and Isaac fugate.
%
% Revised: Ellie Tan, Jodie McLennan, Stephen McKay. May 2019.

% FUTURE WORK:


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, close all

% user inputs

threshold = 150; % threshold intensity to identify peaks
lineHeight =(303:653); % Vertical start-end location of line (pixels). If too large, may include optical aberrations of spectrometer such as curvatures.
lineWidth = (685-630); % line width to take into account. Make sure it is not too small to keep the curve shape.
Hbetanm = 486; % wavelength in nm
Halphanm = 656; %nm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use for when calibrate is a function
%HImgData = HImage;
%HeImgData = HeImage;


% temporary user GUI to choose images from file
[HFile, HPathname] = uigetfile('.b16', 'Pick a hydrogen spectra image');
    if isequal(HFile,0) || isequal(HPathname,0)
       disp('User pressed cancel')
    else
       disp(['User selected ', fullfile(HPathname, HFile)])
    end
    
[HeFile, HePathname] = uigetfile('.b16', 'Pick a helium spetra image');
    if isequal(HeFile,0) || isequal(HePathname,0)
       disp('User pressed cancel')
    else
       disp(['User selected ', fullfile(HePathname, HeFile)])
    end
    
    
HImgData = flipud(readB16(fullfile(HPathname, HFile)));
HeImgData = flipud(readB16(fullfile(HePathname, HeFile)));
 

% %% DISPLAY RAW SPECTRA IMAGE (Density.m code, probably not needed)
% % show original greyscale figure
% figure
% fig = imagesc(HImgData); 
% colormap 'gray'; %Convert figure into a RGB 'jet' or grayscale 'gray' image.
% set(gca, 'Visible', 'off')
% %text(5,40,num2str(shot),'Color','white') % label shot number on image
% 
% % Show 3D figure
% height = 1:1:size(HImgData,1);
% width = 1:1:size(HImgData,2);
% figure;
% [X, Y] = meshgrid(width, height);
% Z = HImgData;
% fig = surf(X,Y,Z);
% colormap 'jet'; %Use 'jet' for more interesting looking pictures.
% set(fig, 'EdgeColor', 'none');
% xlabel('Width (px)')
% ylabel('Height (px)')
% zlabel('Intensity')
% title('Raw Image')
% 

%% CLEAN UP DATA (two times, once for each image)

% Find background average minus the peak
% disp('Estimating background...')
H_bg_est = mean(mean(HImgData,1)); % average intensity including peaks
HImgBackground = HImgData;
HImgBackground(HImgBackground > H_bg_est) = H_bg_est; % replace peaks with background estimate average
HBackground = mean(mean(HImgBackground,1)); % average intensity excluding peaks

He_bg_est = mean(mean(HeImgData,1)); % repeat for helium
HeImgBackground = HeImgData;
HeImgBackground(HeImgBackground > He_bg_est) = He_bg_est; % replace peaks with background estimate average
HeBackground = mean(mean(HeImgBackground,1)); % average intensity excluding peaks

% subtract background
% disp('Subtracting background...')
HImgOffset = HImgData - HImgBackground;
HeImgOffset = HeImgData - HeImgBackground;


% combined image using both spectra
combImage = HImgOffset + HeImageOffset;

%% Show 3D figure without background offset subtracted
height = 1:1:size(imgOffset,1);
width = 1:1:size(imgOffset,2);
figure;
[X, Y] = meshgrid(width, height);
Z = imgOffset;
fig = surf(X,Y,Z);
colormap 'jet'; %Use 'jet' for more interesting looking pictures.
set(fig, 'EdgeColor', 'none');
xlabel('Width (px)')
ylabel('Height (px)')
zlabel('Intensity')
title('Background-subtracted')

%% Average intensity vertically for height of line
img_avg = mean( combImage(lineHeight,:),1 ); % take vertical average of the line.

% Plot 1D average intensity
figure;
plot(img_avg)
xlabel('Width (pixels)')
ylabel('Line-Averaged Intensity')
grid on


%%There is an optional section you can include here. Code at the end of script.
%It can clean up data, but is difficult to deal with multiple peaks!

%% Find Peaks
pixels = 1:length(img_avg);
[peakInten, peakPos] = findpeaks(img_avg,pixels,'MinPeakHeight',threshold,...
'SortStr',descend,'NPeaks',3); 



%% get FWHM from spectra for density if there's a Hbeta line


intensity = img_avg;
fwhmPixels = fwhm(pixels,intensity); 
% ^check if this is actualyl correct since I didn't crop to the peak region only


%% CONVERSION: Pixels to nanometers

switch element
    case hydrogen
        Hdistnm = 486-434;
        Hdistpix = peakPos(1)-peakPos(2);
        a = Hdistnm/Hdistpix;
    case helium
        HeDist12nm = 588-501;
        HeDist12pix = peakPos(1)-peakPos(1);
        HeDist23nm = 501-447;
        HeDist23pix = peakPos(3)-peakPos(2);
        He12 = HeDist12nm/HeDist12pix;
        He23 = HeDist23nm/HeDist23pix;
        a = .5*(He12+He23);
end
