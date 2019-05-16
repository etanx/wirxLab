function [ n_e ] = fwhm2ne( fwhm_raw )
%Converting the fwhm quickly to density
%   hydrogenlamp
hydrogenLamp = 5.76; % this must be some calibration factor? - Ellie Tan

n_e =  1e20 * ((( 0.014 * sqrt(  fwhm_raw.^2 - hydrogenLamp^2  ) ) ./ 0.04).^(3/2))

% where did values 0.014 and 0.04 come from? 3/2?
% is the fwhm in units of pixels of nm? 
% Ellie Tan.

end

