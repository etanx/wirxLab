% a master script to analyse spectrometer images to get temperature (not implemented yet) and
% density of plasma emission
% Based on scripts: Temp.m, spectraFWHM, fwhm2Ne, RawSpectra.m by Michael
% Morken, David Blasing, and Isaac Fugate.
%
% Revised: Ellie Tan, Jodie McLennan, Stephen McKay. May 2019.

% FUTURE WORK:
% expand code to include Argon line ratios and broadening
% expand code to use Doppler shift to get plasma velocity
% test code with other gratings

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, close all

% user inputs
shot = 1190517010;
grating = 1800; % user defined grating spacing grooves/nm (150, 1800, or 3600)

threshold = 150; % threshold intensity to identify peaks (will vary depending on line)
lineHeight =(320:645); % Vertical range of line (pixels). If too large, might introduce optical aberrations of spectrometer such as curvatures.
lineWidth = (685-630); % broadened line width to take into account. Make sure it is not too small to keep the curve shape.

Hbeta2density = 1; % Use 1 for 'YES', 2 for 'NO'. Will calculate n_e if yes.
localFile = 0; % Use 1 for 'YES' 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EXTRACT IMAGE DATA FROM WIRX TREE OR LOCAL FILE

if localFile == 1
    % do you have a local file? Load it! File must be in same path as workspace
    filePath = uigetfile(path); % select .b16 raw image file in GUI window
    imgData = flipud(readB16(filePath)); % flip upside down image?  
else
% If no local file, extract from tree
% NOTE: Make sure data has been written to tree with ccd2tre.m! Using this method 
% reduces the hassle of saving specific file types and locating where they are in Box. 
% If there's no data in the tree, Traverser will show the value font in purple. And you will get errors, of course.
mdsconnect('WIRX07');
mdsopen('wirxtree',shot);
imgData = flipud(mdsvalue( 'ICCD.DICAM2:FRAME1' )); % raw image was upside down
mdsclose;
mdsdisconnect;

end

%% DISPLAY RAW SPECTRA IMAGE
% show original greyscale figure
figure
fig = imagesc(imgData); 
colormap 'gray'; %Convert figure into a RGB 'jet' or grayscale 'gray' image.
set(gca, 'Visible', 'off')
text(5,40,num2str(shot),'Color','white') % label shot number on image

% Show 3D figure
height = 1:1:size(imgData,1);
width = 1:1:size(imgData,2);
figure;
[X, Y] = meshgrid(width, height);
Z = imgData;
fig = surf(X,Y,Z);
colormap 'jet'; %Use 'jet' for more interesting looking pictures.
set(fig, 'EdgeColor', 'none');
xlabel('Width (px)')
ylabel('Height (px)')
zlabel('Intensity')
title('Raw Image')


%% CLEAN UP DATA
% Find background average minus the peak
disp('Estimating background...')
background_estimate = mean(mean(imgData,1)); % average intensity including peaks
imgBackground = imgData; % create copy of image 
imgBackground(imgBackground > background_estimate) = background_estimate; % replace peaks in copy with background estimate average
background = mean(mean(imgBackground,1)); % average intensity excluding peaks

% subtract background
disp('Subtracting background...')
imgOffset = imgData - imgBackground; 

% Show 3D figure without background offset subtracted
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

% Average intensity vertically for height of line
img_avg = mean( imgOffset(lineHeight,:),1 ); % take vertical average of the line.

% Plot 1D average intensity
figure;
plot(img_avg)
xlabel('Width (pixels)')
ylabel('Line-Averaged Intensity')
grid on


%%There is an optional section you can include here. Code at the end of script.
%It can clean up data, but is difficult to deal with multiple peaks!


%% get FWHM from spectra for density if there's a Hbeta line

pixels = 1:length(img_avg);
intensity = img_avg;
fwhmPixels = fwhm(pixels,intensity); 
% ^check if this is actualyl correct since I didn't crop to the peak region only
% currently only works for one peak (H-beta line)

% CONVERSION: Pixels to nanometers
% Spectrometer CCD Pixel Conversion notes:
% For 3600 grating, 0.115 nm per pixel - Blasing Lab notebook 3
% For 1800 grating, 0.014 nm per pixel - Fugate in Craig's logbook
% For 150 grating, 0.177 nm per pixel - Morken log book

% In future, we want to create a calibration script/function to analyze a spectrometer image
% from a lamp and determine a linear calibration relationship for each
% grating. Then the hardcoded conversion factors can be replaced by this
% function.

switch grating
    case 3600
        disp("Using conversion for 3600 grating.")
        px2nmFactor = 0.115;
    case 1800
        disp("Using conversion for 1800 grating.")
        px2nmFactor = 0.014;
    case 150
        disp("Using conversion for 150 grating.")
        px2nmFactor = 0.115;     
end

fwhm_nm = fwhmPixels*px2nmFactor;

if Hbeta2density == 1
    
%%load calibration image if any (future work)
fwhm_lamp = 4.*px2nmFactor; % This value is from Morken's code, best to get new calibration for each run day (see comment above)
fwhm_calibrated = sqrt((fwhm_nm)^2 - (fwhm_lamp)^2); % difference of squares for convolution of Gaussian distributions

% electron density based on FWHM (ultimately from Plasma Diagnostics book,
% used in Morken and Blasing's theses)
n_e =  1e20 .* (sqrt(fwhm_calibrated)./0.04).^(3/2);
fprintf('Electron density n_e = %4.2e /m^3\n',n_e)
end


%%     
% Plot spectra in nanometers
% EDIT: This doesn't work cuz conversion is relative spacing, not absolute!
% intensity = img_avg;
% wavelengths = [1:length(img_avg)].*gratingFactor;
% figure;
% plot(wavelengths,intensity)
% xlabel('Wavelength (nm)')
% ylabel('Radiance/Intensity (some unit)')
% grid on



%%Optional data processing section
% % set background to zero to reduce non-peak noise?
% disp('Setting background to 0 intensity...')
% imgPeaks = img_avg;
% 
% % roughly locate not-peak areas based on intensity ratio
% disp('Locating peaks...')
% peaksYes = find(img_avg >= threshold);
% peakMiddle = median(peaksYes);
% peaksNope = find(img_avg < threshold);

%%modify peak area to include user-defined line width
% makeWider = not(ismember(peaksNope,lineWidth)); % areas to keep
% peaksNopeWide = peaksNope(makeWider);
% imgPeaks(peaksNopeWide) = 0; % set non-peak area to zero
%%NOTE: Not satisfied with the above because then code can only deal with
% one peak. What about cases where there are multiple ones?

% peakWidthHalf = round(lineWidth./2);
% peaksRight = peakMiddle + peakWidthHalf;
% peaksLeft = peakMiddle - peakWidthHalf;


%imgPeaks(peaksNopeWide) = 0;


% % Plot 1D vertically-averaged intensity
% figure;
% plot(imgPeaks)
% xlabel('Width (pixels)')
% ylabel('Peak Intensity')
% title('Peak Only')
% grid on



disp(" ")

