function [ width_px, width_nm ] = spectraFWHM( firstSpectraPaths )




%UPDATE: See new script Density.m





%Gets the FWHM in pixels... This is a very imperfect rough check with the
%model
% Gets FWHM at all costs
numImages = length(firstSpectraPaths);
width_px = zeros(1,numImages,1);


for i = 1:numImages
    imageData = imread(firstSpectraPaths{i},'tiff');
    raw_spectra = mean(imageData(369:725,:)); %Finds the meain intensity of middle of vertical line I think? -Ellie
    width_px(i) = fwhm(1:length(raw_spectra),raw_spectra);
    

    % convert pixel width to nanometers' width
    width_nm = width.*0.02.*1e7;
    
    % According to Dr Craig's notes, 1 pixel is about 0.02 cm for the spectra images.
    % Probably need to verify this somehow. - Ellie
    % EDIT: This value is incorrect for spectrometer.
end
end

