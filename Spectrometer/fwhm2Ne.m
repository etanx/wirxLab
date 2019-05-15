function [ Ne ] = fwhm2Ne( fwhm_raw )
%Converting the fwhm quickly to density
%   hydrogenlamp
hydrogenLamp = 5.76;

Ne =  1e20 * ((( 0.014 * sqrt(  fwhm_raw.^2 - hydrogenLamp^2  ) ) ./ 0.04).^(3/2))

end

