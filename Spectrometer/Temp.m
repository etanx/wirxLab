function [temp_eV,tempRange,tempUNC] = Temp( path )
%Hydrogen Plasma Temperature from Balmer Series Line Ratios
%   Essentially the temperature is determined from the ratios of the
%   different hydrogrn lines. This function takes the calibrated spectra
%   and produces temperature based on different models

%   Created by Michael Morken, 22 April 2015.

%% Selecting out each peak
[wavelen, raw_spectra] = RawSpectra(path);
%Changalbe inputs for each Run in wavelength Based on prospecting the
%raw_spectra
%Uncomment to prospect for new peaks and ranges
plot(raw_spectra)
xlabel('pixels')
ylabel('Radiance')
title('Raw spectra')
%{
hAPeak = 656.7780;
hBPeak = 485.5420;
hGPeak = 433.2100;
hALeft = 655.3540;
hBLeft = 479.6680;
hGRight = 434.2780;
%}
%Finding the indicies of the points on the spectra (Manually)
hAPeakIndex = 16;
hBPeakIndex = 977;
hGPeakIndex = 1271;
hALeftIndex = 23;
hBLeftIndex = 1010;
hGRightIndex = 1265;

%background Values
hABackground = raw_spectra(hALeftIndex);
hBBackground = raw_spectra(hBLeftIndex);
hGBackground = raw_spectra(hGRightIndex);
%Loop to subtract off the specific backgrounds for each line and set
%everything else to zero. This is in preperation form ultiplying byt he
%calibration curve.
spectra = zeros(1,length(raw_spectra),1);
for i = 1:length(raw_spectra);
    if (i >= hAPeakIndex) && (i <= hALeftIndex);
        spectra(i) = raw_spectra(i) - hABackground;
  
    elseif (i >= hBPeakIndex) && (i <= hBLeftIndex);
        spectra(i) = raw_spectra(i) - hBBackground;
    elseif (i >= hGRightIndex) && (i <= hGPeakIndex); 
        spectra(i) = raw_spectra(i) - hGBackground;
   
    else
        spectra(i) = 0;
     end
        
end
%plot(wavelen,spectra) %Uncomment to inspect adjusted spectra for counts
%% Calibrating the selected Spectra
%Setting up the calibrated spectra
%Setting up the master image
%The three images with the grating set at 550 nm are:
%"C:\Users\Student\Desktop\Data\150gmm_550nm_1.tif"   Image 1
%"C:\Users\Student\Desktop\Data\150gmm_550nm_2.tif"   Image 2
%"C:\Users\Student\Desktop\Data\150gmm_550nm_3.tif"   Image 3
%I am going to average these three images together and then use that
%"master" image for the calibration
im1 = imread('C:\Users\Plasma\Box\elizabethtan\2018-19 WIRX Honors Thesis\Images and Figures\spectra\spec_1190305000H1800_486.tif' );
im2 = [];
im3 = [];
stack = cat(3,im1,im2,im3);
master550 = mean(stack,3); %This is the master spectra for the 516 position
spectra_cal = mean(master550(369:725,:))- mean(master550(1:356,:)); %Useable Range - background

%Using data from UW-Madison's integrating sphere
Wavelengthnm = [300,310,320,330,340,350,360,370,380,390,400,410,420,430,440,450,460,470,480,490,500,510,520,530,540,550,560,570,580,590,600,610,620,630,640,650,660,670,680,690,700,710,720,730,740,750,760,770,780,790,800,810,820,830,840,850,860,870,880,890,900,910,920,930,940,950,960,970,980,990,1000,1010,1020,1030,1040,1050,1060,1070,1080,1090,1100];
RadianceWsrcm2nm = [3.47500000000000e-07,5.48500000000000e-07,8.25800000000000e-07,1.18600000000000e-06,1.66300000000000e-06,2.24600000000000e-06,3.01300000000000e-06,3.82300000000000e-06,5.05700000000000e-06,6.41500000000000e-06,8.13500000000000e-06,1.00700000000000e-05,1.22000000000000e-05,1.44200000000000e-05,1.67300000000000e-05,1.91300000000000e-05,2.17300000000000e-05,2.47300000000000e-05,2.79100000000000e-05,3.10600000000000e-05,3.45900000000000e-05,3.80000000000000e-05,4.14300000000000e-05,4.48400000000000e-05,4.84200000000000e-05,5.20500000000000e-05,5.55500000000000e-05,5.90300000000000e-05,6.24500000000000e-05,6.59100000000000e-05,6.87400000000000e-05,7.24000000000000e-05,7.58300000000000e-05,7.89600000000000e-05,8.19400000000000e-05,8.46200000000000e-05,8.71600000000000e-05,8.96400000000000e-05,9.21500000000000e-05,9.46200000000000e-05,9.70000000000000e-05,9.92700000000000e-05,0.000101500000000000,0.000103300000000000,0.000105600000000000,0.000107300000000000,0.000108800000000000,0.000110100000000000,0.000111000000000000,0.000112400000000000,0.000113300000000000,0.000114000000000000,0.000114600000000000,0.000115100000000000,0.000115800000000000,0.000116500000000000,0.000117200000000000,0.000117800000000000,0.000118500000000000,0.000119400000000000,0.000120500000000000,0.000121000000000000,0.000121300000000000,0.000121500000000000,0.000121600000000000,0.000121900000000000,0.000122500000000000,0.000123100000000000,0.000123700000000000,0.000123600000000000,0.000123500000000000,0.000123100000000000,0.000122500000000000,0.000122300000000000,0.000121900000000000,0.000121500000000000,0.000120500000000000,0.000119700000000000,0.000118900000000000,0.000118000000000000,0.000116900000000000];
figure;
plot(Wavelengthnm,RadianceWsrcm2nm)
xlabel('Wavelength (nm)')
ylabel('Radiance W sr cm^2 nm')
title('Integrating Sphere')
absolute = interp1(Wavelengthnm,RadianceWsrcm2nm,wavelen);
%Dividing the absolute data by spectral data to produce the calibration in real units

% first line is original but was not working, so commented out for now
%calib = absolute./spectra_cal; %This is the calibration function. When multiplied by spectra it gives real units
calib = absolute;

%Producing the calibrated Spectra
spectra = spectra.*calib;
plot(wavelen,spectra)
title('Processed WIRX Spectra','fontsize',24)
xlabel('Wavelength (nm)','fontsize',14)
ylabel('Radiance (W / Str cm^2 nm)','fontsize',14)
gtext('H-Alpha')
gtext('H-Beta')
gtext('H-Gamma')
%Counts were found from selecting data in the peaks. represents energies
%{
HA_counts = 2*(sum(spectra(hAPeakIndex:hALeftIndex)));
HB_counts = 2*(sum(spectra(hBPeakIndex:hBLeftIndex)));
HG_counts = 2*(sum(spectra(hGRightIndex:hGPeakIndex)));
%}
HA_counts = spectra(hAPeakIndex);
HB_counts = spectra(hBPeakIndex);
HG_counts = spectra(hGPeakIndex);
%}
%% Using the spectral data to produce the temperature values
%Calibrating the counts to photons
HA_counts = HA_counts*(1/1.889);
HB_counts = HB_counts*(1/2.551);
HG_counts = HG_counts*(1/2.856);
%{
%The energy to photon calibration factors
BoverA = 2.551/1.889; %level 3 energy divided by level 2 enrgy for calibration
GoverA = 2.856/1.889; %Level 4 energy divide3d by level 2 energy for calibration
GoverB = 2.856/2.551; %calibration for level 4 to level 3 calibreation
%}
%Producing photon flux (Not Intensity) ratios
ratioAB = (HA_counts/HB_counts);
ratioAG = (HA_counts/HG_counts);
ratioBG = (HB_counts/HG_counts);

% Calculating the Temperature from the line ratios
% some Constant values:
%Energies:
E3 = 12.08; %eV
E4 = 12.75; %ev
E5 = 13.056; %ev

%Energy Differences:
E4_3 = E4-E3;
E5_3 = E5-E3;
E5_4 = E5-E4;

%Einstein Coefficents for 2nd level transitions
sumA32 = 0.44082910e8; 
sumA42 =0.084157168e8;
sumA52 = 0.025293477e8;

%Einstein Coefficents for transtions to ALL lower levels
sumA3lr = 0.98e8;
sumA4lr = 0.2992e8;
sumA5lr = 0.144e8;

%einstein A coefficents for collisional transitions up out of the ground state
A13 = 0.55727384e8;
A14 = 0.12779603e8;
A15 = 0.041232986e8;

%Calculating temperature using the Boltzman Model and different line ratios:
%HA to HB:
ABBZ = E4_3/log((ratioAB)*(sumA42/sumA32));
%HA to HG
AGBZ = E5_3/log((ratioAG)*(sumA52/sumA32));
%HB to HG
BGBZ = E5_4/log((ratioBG)*(sumA52/sumA42));

%Calculating temperature using the Sigma-V coronal equilibrium model and different line ratios:
%HA to HB
ABCE = E4_3/log((ratioAB)*(sumA42/sumA32)*(sumA3lr/sumA4lr)*((E3/E4)^3)*(A14/A13));
%HA to HB
AGCE = E5_3/log((ratioAG)*(sumA52/sumA32)*(sumA3lr/sumA5lr)*((E3/E5)^3)*(A15/A13));
%HB to HG
BGCE = E5_4/log((ratioBG)*(sumA52/sumA42)*(sumA4lr/sumA5lr)*((E4/E5)^3)*(A15/A14));

%Super Sketchy Temp. averaging to compare to the Model
tempRange = [ABBZ,AGBZ,BGBZ,ABCE,AGCE,BGCE];
%{
%for i = 1:6
 if tempRange && tempRange(i) < 5
        TempRange(i) = tempRange(i);
    end
end
%}
TempRange = tempRange;
%temp_eV = mean(max(tempRange) + min(tempRange));
temp_eV = mean(TempRange);
tempUNC = (max(TempRange)- min(TempRange))/2; 
end

