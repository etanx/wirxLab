function [pix2nm,offset, HBetaFWHM] = calibrate(grating, targetnm, doPlot, HImgPath, HeImgPath)
% a function to analyze spectrometer images to get calibration values.
% Returns the slope (pix2nm) and intercept (offset) of the spectrometer's
% pixel-to-wavelength conversion line. Also determines the instrument error
% by finding the FWHM of the H-beta line.
%
% Based on scripts: Temp.m, spectraFWHM, fwhm2Ne, RawSpectra.m by Michael Morken, David Blasing, and Isaac fugate.
%
% Revised: Ellie Tan, Jodie McLennan, Stephen McKay. May 2019.


% INPUTS
% grating = 150, 1800, or 3600 grooves/nm grating.
% targetnm = wavelength that the grating is looking at (nm) 
        %not used at the moment but will be in future work
% 
% HImgPath = hydrogen calibration filepath
% HeImgPath = helium cal. image filepath
%       If no file path input, prompt user to select file in GUI window

% OUTPUTS 
%
% pix2nm = Conversion factor of pixels to nm 
% offset = wavelength/pixel offset in nm (since 0 pixels corresponds to a nonzero value of
% wavelength on the spectrometer)



% FUTURE WORK:
%    add functionality for selecting different areas of the spectrum with
%    targetnm


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% user-inputted image parameters
threshold = 25; % threshold intensity to identify peaks
lineHeight =(303:653); % Vertical start-end location of line (pixels). If too large, may include optical aberrations of spectrometer such as curvatures.
lineWidth = (685-630); % line width to take into account. Make sure it is not too small to keep the curve shape.

HBetanm = 486.1; % constant value of H-Beta line in nm
He492nm = 492.231; % constant value of He-492 line in nm (make more precise later)
%% READ IN IMAGE FILES
% if input filepaths exist
if nargin == 5
    % read in files from filepaths
    HImgData = rot90(readB16(HImgPath),2); % rotate 180 since pic is upside down and backwards
    HeImgData = rot90(readB16(HeImgPath),2);

else % if user does not supply BOTH Hydrogen and Helium path
    % user GUI to choose images from file
    [HFile, HPathname] = uigetfile('.b16', 'Pick a hydrogen spectra image'); % title does not appear on macOS
        if isequal(HFile,0) || isequal(HPathname,0)
           error('User pressed cancel')
        else
           disp(['User selected ', fullfile(HPathname, HFile)])
        end

    [HeFile, HePathname] = uigetfile('.b16', 'Pick a helium spetra image');  % title does not appear on macOS
        if isequal(HeFile,0) || isequal(HePathname,0)
           error('User pressed cancel')
        else
           disp(['User selected ', fullfile(HePathname, HeFile)])
        end    
    
    HImgData = rot90(readB16(fullfile(HPathname, HFile)),2);  % rotate 180 since pic is upside down and backwards
    HeImgData = rot90(readB16(fullfile(HePathname, HeFile)),2);
end


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





%% Average intensity vertically for height of line

combImage = HImgOffset + HeImgOffset; % combined image using both hydrogen and helium images

img_avg = mean( combImage(lineHeight,:),1 ); % take vertical average of the image (within lineHeight range).

% If user wants plot
if doPlot == 1
    % Plot 1D average intensity
    figure;
    plot(img_avg)
    xlabel('Width (pixels)')
    ylabel('Line-Averaged Intensity')
    grid on
end

%% Find Peaks
pixels = 1:length(img_avg);
[peakInten, peakPos] = findpeaks(img_avg,pixels,'MinPeakHeight',threshold,...
'SortStr','descend','NPeaks',5); 
peakPos = sort(peakPos); % sort in ascending order of pixel location (from left to right on graph)



%% CONVERSION: Pixels to nanometers
% find parameters a and b that corespond to conversion of nm/pix (a) and nm offset (b): lambda_nm = a*pixels + b
% 

switch grating
    case 150
        % future work: assign peakPos array to definite variables
        % showing which peak each one represents (for readability)
        Hdistnm = 486-434; % known Hydrogen wavelengths of H beta and H gama
        Hdistpix = peakPos(3)-peakPos(1); % since we know relative position of peaks we can pick up the Hbeta and Hgama positions
        a1 = Hdistnm/Hdistpix; % one nm/pix value
        HeDist12nm = 588-501; % distance in nm between two know He wavlengths
        HeDist12pix = peakPos(5)-peakPos(4);  % can pick out these wavelengths since we know the relative positions
        HeDist23nm = 501-447; %same steps
        HeDist23pix = peakPos(4)-peakPos(2);
        He12 = HeDist12nm/HeDist12pix; % find two more nm/pix values
        He23 = HeDist23nm/HeDist23pix;
        pix2nm = 1/3*(He12+He23+a1); % average these values to find one nm/pix value
        offset = HBetanm - pix2nm * peakPos(3); % to find nm offset, plug in pixel and known nm value for H-beta line (derviation in McLennan or McKay notebook)
    case 1800
        HBetaPix = peakPos(1); % pixel location of H-Beta line
        He492Pix = peakPos(2); % pixel location of 492 nm He line
        distnm = He492nm-HBetanm; % known wavelengths of Hbeta and He line
        distpix = He492Pix - HBetaPix; % distance in pixels
        pix2nm = distnm/distpix; % nm/pixel value
        offset = HBetanm - pix2nm * HBetaPix; % to find nm offset, plug in pixel and known nm value for H-beta line (derviation in McLennan or McKay notebook
end

%% FWHM of H-beta line for calibration of spectrometer

% Extract width of tallest (H-beta) line
[HBetaVal, HBetaLoc, HBetaFWHM] = findpeaks(img_avg,pixels,'WidthReference', 'halfheight','SortStr','descend','NPeaks',1); % pull out max peak location in pixels, assuming this is H-Beta




