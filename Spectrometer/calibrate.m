%[] = calibrate(grating, gratingPosition, imagefile )

% INPUTS
% grating = 150, 1800, or 3600 grating.
% gratingPosition = wavelength that the grating is looking at
% filepath = If no file path input, prompt user to select file in GUI window

% OUTPUTS
% px2nm = Conversion factor of pixels to nm
% px2nmFunction = Calibration function of pixels to nanometer (FUTURE WORK)








% Copied from density.m, to edit~


% a funcction to analyse spectrometer images to get calibration values
% Based on scripts: Temp.m, spectraFWHM, fwhm2Ne, RawSpectra.m by Michael Morken, David Blasing, and Isaac fugate.
%
% Revised: Ellie Tan, Jodie McLennan, Stephen McKay. May 2019.

% FUTURE WORK:


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, close all

% user inputs
shot = 1190517010;
grating = 1800; % user defined grating spacing grooves/nm (150, 1800, or 3600)

threshold = 150; % threshold intensity to identify peaks
lineHeight =(303:653); % Vertical start-end location of line (pixels). If too large, may include optical aberrations of spectrometer such as curvatures.
lineWidth = (685-630); % line width to take into account. Make sure it is not too small to keep the curve shape.

Hbeta2density = 1; % Use 1 for 'YES', 2 for 'NO'. Will calculate n_e if yes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EXTRACT IMAGE DATA FROM WIRX TREE
% NOTE: Make sure data has been written to tree with ccd2tre.m! Using this method 
% reduces the hassle of saving specific file types and locating where they are in Box. 
% If there's no data in the tree, Traverser will show the value font in purple. And you will get errors, of course.
mdsconnect('WIRX07');
mdsopen('wirxtree',shot);
imgData = flipud(mdsvalue( 'ICCD.DICAM2:FRAME1' )); % raw image was upside down
mdsclose;
mdsdisconnect;


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
imgBackground = imgData;
imgBackground(imgBackground > background_estimate) = background_estimate; % replace peaks with background estimate average
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

% CONVERSION: Pixels to nanometers
% Spectrometer CCD Pixel Conversion notes:
% For 3600 grating, 0.115 nm per pixel - Blasing Lab notebook 3
% For 1800 grating, 0.014 nm per pixel - Fugate in Craig's logbook
% For 150 grating, 0.177 nm per pixel - Morken log book
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
    
%%load claibration image if any (future work)
fwhm_lamp = 4.*px2nmFactor; % This value is form Morken's code, best to get new calibration for each run day
fwhm_calibrated = sqrt((fwhm_nm)^2 - (fwhm_lamp)^2); % somehow this 

n_e =  1e20 .* (sqrt(fwhm_calibrated)./0.04).^(3/2);
fprintf('Electron density n_e = %4.2e /m^3\n',n_e)
end





disp(" ")

