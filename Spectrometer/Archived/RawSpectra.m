function [ wavelen, spectra_raw ] = RawSpectra( path )
%Sets WIRX spectra to wavelength and raw un-altered counts
%   This is based on the grating set on the 150 and positioned so that
%   h-alpha, h-beta, and h-gamma are all within the view. (viewing 550 nm?- Ellie Tan)
%Changable HalphaPeak in px

%   Created by Michael Morken, 22 April 2015.

hAlphaPeak = 16; %Prospect by plotting the Raw Data (pixels)

%Pixels to nm
raw_image = imread(path,'tiff');
spectra_raw = mean(raw_image(369:725,:));%Not Background Subtracted


%plot(spectra_raw)%Uncomment to prospect
pix = 1:length(spectra_raw);
wavelen = zeros(1,length(spectra_raw));

for i = 1:length(spectra_raw)
    offset = pix(i) - hAlphaPeak; %16 in the pixel position of h-alpha
    lambda = (-1)*(offset*0.178)+ 656.6; %.178 is the nm per pixel on the 150 grating 656.6nm is h-alpha
    wavelen(i) = lambda;
end

%plot(wavelen,spectra_raw);
end

