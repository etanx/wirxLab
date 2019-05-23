function [a,b] = calibrate(grating, targetnm, HImgPath, HeImgPath)
% a function to analyze spectrometer images to get calibration values
% Based on scripts: Temp.m, spectraFWHM, fwhm2Ne, RawSpectra.m by Michael Morken, David Blasing, and Isaac fugate.
%
% Revised: Ellie Tan, Jodie McLennan, Stephen McKay. May 2019.


% INPUTS
% grating = 150, 1800, or 3600 grooves/nm grating.
% targetnm = wavelength that the grating is looking at (nm) 
        %not used at the moment but will be in future work
% HImgPath = hydrogen calibration filepath
% HeImgPath = helium cal. image filepath
%       If no file path input, prompt user to select file in GUI window

% OUTPUTS 
%
% constants in equation lambda_nm = a*pixel + b
% a = Conversion factor of pixels to nm 
% b = Offset in nm (since 0 pixels corresponds to a nonzero value of
% wavelength on the spectrometer)



% FUTURE WORK:
%    add functionality for selecting different areas of the spectrum with
%    targetnm


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% user inputs
threshold = 25; % threshold intensity to identify peaks
lineHeight =(303:653); % Vertical start-end location of line (pixels). If too large, may include optical aberrations of spectrometer such as curvatures.
lineWidth = (685-630); % line width to take into account. Make sure it is not too small to keep the curve shape.


% if input filepaths exist
if nargin == 4
    % read in files from filepaths
    HImgData = flipud(readB16(HImgPath));
    HeImgData = flipud(readB16(HeImgPath));

else % if user does not supply BOTH Hydrogen and Helium path
    % user GUI to choose images from file
    [HFile, HPathname] = uigetfile('.b16', 'Pick a hydrogen spectra image'); % title does not appear on macOS
        if isequal(HFile,0) || isequal(HPathname,0)
           disp('User pressed cancel')
        else
           disp(['User selected ', fullfile(HPathname, HFile)])
        end

    [HeFile, HePathname] = uigetfile('.b16', 'Pick a helium spetra image');  % title does not appear on macOS
        if isequal(HeFile,0) || isequal(HePathname,0)
           disp('User pressed cancel')
        else
           disp(['User selected ', fullfile(HePathname, HeFile)])
        end    
    
    HImgData = flipud(readB16(fullfile(HPathname, HFile)));
    HeImgData = flipud(readB16(fullfile(HePathname, HeFile)));
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


% combined image using both spectra
combImage = HImgOffset + HeImgOffset;


%% Average intensity vertically for height of line
img_avg = mean( combImage(lineHeight,:),1 ); % take vertical average of the line.

% Plot 1D average intensity
figure;
plot(img_avg)
xlabel('Width (pixels)')
ylabel('Line-Averaged Intensity')
grid on


%% Find Peaks
pixels = 1:length(img_avg);
[peakInten, peakPos] = findpeaks(img_avg,pixels,'MinPeakHeight',threshold,...
'SortStr','descend','NPeaks',5); 
peakPos = sort(peakPos);



%% CONVERSION: Pixels to nanometers
% find parameters a and b that corespond to conversion of nm/pix (a) and nm offset (b): lambda_nm = a*pixels + b
% 

switch grating
    case 150
        Hdistnm = 486-434; % known Hydrogen wavelengths of H beta and H gama
        Hdistpix = peakPos(3)-peakPos(1); % since we know relative position of peaks we can pick up the Hbeta and Hgama positions
        a1 = Hdistnm/Hdistpix; % one nm/pix value
        HeDist12nm = 588-501; % distance in nm between two know He wavlengths
        HeDist12pix = peakPos(5)-peakPos(4);  % can pick out these wavelengths since we know the relative positions
        HeDist23nm = 501-447; %same steps
        HeDist23pix = peakPos(4)-peakPos(2);
        He12 = HeDist12nm/HeDist12pix; % find two more nm/pix values
        He23 = HeDist23nm/HeDist23pix;
        a = 1/3*(He12+He23+a1); % average these values to find one nm/pix value
        b = 486 - a * peakPos(3); % to find nm offset, always have H beta line so use that...derviation in McLennan or MacKay notebook
    case 1800
        distnm = 492-486; % known wavelengths of Hbeta and He line
        distpix = peakPos(2)-peakPos(1); % distance in pixels
        a = distnm/distpix; % nm/pixel value
        b = 486 - a * peakPos(1); % to find nm offset, always have H beta line so use that...derviation in McLennan or MacKay notebook
end


%% DISPLAY RAW SPECTRA IMAGE (Denisty.m code, probably not needed)
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

% Show 3D figure without background offset subtracted
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

%There is an optional section you can include here. Code at the end of script.
%It can clean up data, but is difficult to deal with multiple peaks!

% get FWHM from spectra for density if there's a Hbeta line

%intensity = img_avg;
%fwhmPixels = fwhm(pixels,intensity); 
% ^check if this is actualyl correct since I didn't crop to the peak region only

