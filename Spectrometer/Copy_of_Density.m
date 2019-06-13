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

%% ASK USER FOR INPUTS
% first get shot, grating, wavelength
% then load calibration images if they exist (and give user option to
% choose new ones)
% otherwise ask for new ones no matter what
numlines  = 1; % lines per answer in user input dialog
defaults = {'1190524007', '1800', '486'}; % default answers for shot, grating, wavelength
inputs = inputdlg({'Enter shot number:','Enter grating value:','Enter wavelength:'},'Inputs for Density Analysis', numlines, defaults);
	if length(inputs) < 3
        error('Not enough inputs');
    end
    shot = str2double(inputs(1)); % shot number
    grating = str2double(inputs(2)); % user defined grating spacing grooves/nm (150, 1800, or 3600)
    targetnm = str2double(inputs(3)); % wavelength spectrometer is centered on (nm)

% Get or load Calibration Images

% check to see if previous calibration image filepaths exist
try
    
    load('calImages.mat'); % try to load previous images
           % note: it's possible that previous images do exist as variables
           % in calImages.mat but are not a file name, if they were saved
           % previously as empty variables (or maybe just equal to '\' or
           % something). Delete calImages.mat and try again.
           
    % check to see if user wants to input calibration images
    answer = questdlg('New H and He Calibration Images?');

    if strcmp(answer, 'Yes') % if answer is equal to 'yes' (i.e. user wants new files) 
       
       %get Hydrogen and Helium calibration images 
       [calHFile,calHPath] = uigetfile('.b16', 'Pick a H Calibration Image');
       calHImg = fullfile(calHPath, calHFile); % full path and filename
       
       [calHeFile,calHePath] = uigetfile('.b16', 'Pick a He Calibration Image');
       calHeImg = fullfile(calHePath, calHeFile);
    end
       % save paths to file to use next time (only if filepaths are correctly
       % chosen)
       save('calImages.mat', 'calHImg', 'calHeImg');
       
catch
       % if error occured while loading file (i.e. no previous images
       % exist)
       uiwait(msgbox('Select New H and He Calibation Images','modal')); % tell user that he or she is selecting new images
       [calHFile,calHPath] = uigetfile('.b16', 'Pick a H Calibration Image'); %  same as above
       if calHPath == 0
        error('No hydrogen image to read.')
       end
       calHImg = fullfile(calHPath, calHFile);
       
       [calHeFile,calHePath] = uigetfile('.b16', 'Pick a He Calibration Image');
       if calHePath == 0
        error('No helium image to read.')
       end
       calHeImg = fullfile(calHePath, calHeFile);
       
       % only save to file if filepaths are chosen
       save('calImages.mat', 'calHImg', 'calHeImg');
  
end


% Hardcoded Inputs 

threshold = 150; % threshold intensity to identify peaks (will vary depending on line)
lineHeight =(320:645); % Vertical range of line (pixels). If too large, might introduce optical aberrations of spectrometer such as curvatures.
lineWidth = (685-630); % broadened line width to take into account. Make sure it is not too small to keep the curve shape.

Hbeta2density = 1; % Use 1 for 'YES', 2 for 'NO'. Will calculate n_e if yes.
localFile = 0; % Use 1 for 'YES' 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EXTRACT IMAGE DATA FROM WIRX TREE OR LOCAL FILE

if localFile == 1
    % do you have a local file? Load it!
    uiwait(msgbox('Select Image to be Analyzed','modal')); % tell user to select plasma spectroscopy image
    [fileName, filePath] = uigetfile('.b16'); % select .b16 raw image file in GUI window
    if filePath == 0
        error('No image to read.')
    end
    imgData = rot90(readB16(filePath, fileName),2); % flip upside down image?  
else
% If no local file, extract from tree
% NOTE: Make sure data has been written to tree with ccd2tree.m! Using this method 
% reduces the hassle of saving specific file types and locating where they are in Box. 
% If there's no data in the tree, Traverser will show the value font in purple. And you will get errors, of course.
% mdsconnect('WIRX07');
% mdsopen('wirxtree',shot);
imgDataTotal = load('C:\Users\Plasma\Box\stephenmckay\Blasing Work\PHYS 495_Matlab\Data\02.17.2011data1.txt'); % raw image was upside down
imgData = imgDataTotal(:,26);
% mdsclose;
% mdsdisconnect;

end

%% DISPLAY RAW SPECTRA IMAGE (Uncomment to show raw images)
% % show original greyscale figure
% figure
% fig = imagesc(imgData); 
% colormap 'gray'; %Convert figure into a RGB 'jet' or grayscale 'gray' image.
% set(gca, 'Visible', 'off')
% text(5,40,num2str(shot),'Color','white') % label shot number on image


% % Show 3D figure
% height = 1:1:size(imgData,1);
% width = 1:1:size(imgData,2);
% figure;
% [X, Y] = meshgrid(width, height);
% Z = imgData;
% fig = surf(X,Y,Z);
% colormap 'jet'; %Use 'jet' for more interesting looking pictures.
% set(fig, 'EdgeColor', 'none');
% xlabel('Width (px)')
% ylabel('Height (px)')
% zlabel('Intensity')
% title('Raw Image')


%% CLEAN UP DATA
% Find background average minus the peak
disp('Estimating background...')
background_estimate = mean(imgData); % average intensity including peaks
imgBackground = imgData; % create copy of image 
imgBackground(imgBackground > background_estimate) = background_estimate; % replace peaks in copy with background estimate average
background = mean(imgBackground); % average intensity excluding peaks

% subtract background
disp('Subtracting background...')
imgOffset = imgData - imgBackground; 

% % Show 3D figure without background offset subtracted (Uncomment to view)
% height = 1:1:size(imgOffset,1);
% width = 1:1:size(imgOffset,2);
% figure;
% [X, Y] = meshgrid(width, height);
% Z = imgOffset;
% fig = surf(X,Y,Z);
% colormap 'jet'; %Use 'jet' for more interesting looking pictures.
% set(fig, 'EdgeColor', 'none');
% xlabel('Width (px)')
% ylabel('Height (px)')
% zlabel('Intensity')
% title('Background-subtracted')

% Average intensity vertically for height of line
img_avg = imgOffset; % take vertical average of the line.

% Plot 1D average intensity
figure;
plot(img_avg)
xlabel('Width (pixels)')
ylabel('Intensity (from CamWare)')
title('Average Intensity over Vertical Spectral Lines')
grid on



%% get FWHM from spectra for density if there's a Hbeta line

pixels = 0:(length(img_avg)-1);
[HBetaVal, HBetaLoc, FWHMPix] = findpeaks(img_avg,pixels,'WidthReference','halfheight','SortStr','descend','NPeaks',1); % pull out max peak location in pixels, assuming this is H-Beta
% pulls out intensity, location, and width of H-Beta peak. We only use the
% width in our script (as the FWHM)

% determine calibration values for the current day:
       % first select H calibration image and then He calibration image when
       % prompted to pick files. calibrate() returns the px2nmFactor, which
       % is the ratio of pixels to nm for that particular spectrometer
       % configuration. offset is the wavelength value at the 0-pixel
       % location, and HLampFWHM is the width of the H-beta line in the
       % calibration shot.
[px2nmFactor, offset, HLampFWHM] = calibrate(grating, targetnm, 0, calHImg, calHeImg);
% px2nmFactor = .1762e-3; % from Blasing's code
fwhm_nm = FWHMPix*px2nmFactor; % find FWHM of image in nm


if Hbeta2density == 1
    
% calculate true FWHM using difference of squares
fwhm_lamp_nm = 6.5*px2nmFactor; % find calibration FWHM in nm
fwhm_calibrated = sqrt((fwhm_nm)^2 - (fwhm_lamp_nm)^2); % difference of squares for convolution of Gaussian distributions

% electron density based on FWHM (ultimately from Plasma Diagnostics book,
% used in Morken and Blasing's theses)
n_e =  1e20 .* (fwhm_calibrated./0.04).^(3/2);
fprintf('Shot number: %.0f\n',shot)
fprintf('H Calibration Image: %s\n',calHImg)
fprintf('He Calibration Image: %s\n',calHeImg)
fprintf('Electron density n_e = %4.2e /m^3\n',n_e)
end


%% Plot spectra in nanometers

% Spectra plotted with wavelengths
nanoms = pixels*px2nmFactor + offset;
intensity = img_avg;
figure
plot(nanoms,intensity) % graph of intensity vs nanometers
xlabel('Wavelength (nm)')
ylabel('Intensity')
title('Avg. Intensity vs Wavelength')
[PeakInt,PeakPos] = findpeaks(intensity,nanoms,'MinPeakHeight',500); % identifies all peaks above the threshhold value MinPeakHeight
hold on 
for i=1:length(PeakPos)
    text(PeakPos(i),PeakInt(i),num2str(PeakPos(i))) % put wavelength labels on peaks
end
hold off




disp(" ")

