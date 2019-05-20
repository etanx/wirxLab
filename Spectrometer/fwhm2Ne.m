function [ n_e ] = fwhm2Ne( fwhm_raw )
%Converting the fwhm quickly to density
%   hydrogenlamp
hydrogenLamp = 5.76; % this must be some calibration factor? - Ellie Tan
            % mqybe the number of pixels for the hydrogen lamp? - Stephen McKay
            
n_e =  1e20 * ((( 0.014 * sqrt(fwhm_raw.^2 - hydrogenLamp^2) ) ./ 0.04).^(3/2));
% See Eq. 23 and 24 in Michael Morken's thesis. The overall equation comes
% from solving for electron density n_e in the difference of squares
% between the FWHM of the H-beta line and the instrument error introduced
% by the hydrogen lamp. - Stephen McKay


% where did values 0.014 come from?
% is the fwhm in units of pixels or nm? 
% - Ellie Tan.

end

