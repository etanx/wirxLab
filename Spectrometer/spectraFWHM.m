function [ width ] = spectraFWHM( firstSpectraPaths )
%Gets the FWHM in pixels... This is a very imperfect rough check with the
%model
% Gets FWHM at all costs
numImages = length(firstSpectraPaths);
width = zeros(1,numImages,1);
for i = 1:numImages
    imageData = imread(firstSpectraPaths{i},'tiff');
    raw_spectra = mean(imageData(369:725,:));
    width(i) = fwhm(1:length(raw_spectra),raw_spectra);
end
end

