function [cam1_img, cam1_settings, cam2_img, cam2_settings, PPDIntensity, PPDposition, timePPD] = shotImaging( shot ) 

% A script to extract shot imaging data with MDSPlus.
% Elizabeth H. Tan, 15 May 2019.

% EXAMPLE:
% [cam1_img, cam1_settings, cam2_img, cam2_settings, PPDIntensity, PPDposition, timePPD] = shotImaging( 1190409005 ) ;

mdsconnect('WIRX07');
mdsopen('wirxtree', shot); %Open the tree for the desired shot

%% Extract ICCD Dicam1 Image Data
try
    cam1_img = mdsvalue('ICCD.DICAM1:FRAME1');
    cam1_delay = mdsvalue('ICCD.DICAM1.SETTINGS:FRAME1_TIME');
    cam1_exposure = mdsvalue('ICCD.DICAM1.SETTINGS:FRAME1_EXPO');
    cam1_gain = mdsvalue('ICCD.DICAM1.SETTINGS:GAIN');
    cam1_settings = table(cam1_exposure,cam1_delay,cam1_gain);
catch
    cam1_img = 0;
    cam1_delay = 0;
    cam1_exposure = 0;
    cam1_gain = 0;
    cam1_settings = table(cam1_exposure,cam1_delay,cam1_gain);
end


try
    cam2_img = mdsvalue('ICCD.DICAM2:FRAME1');
    cam2_delay = mdsvalue('ICCD.DICAM2.SETTINGS:FRAME1_TIME');
    cam2_exposure = mdsvalue('ICCD.DICAM2.SETTINGS:FRAME1_EXPO');
    cam2_gain = mdsvalue('ICCD.DICAM2.SETTINGS:GAIN');
    cam2_settings = table(cam2_exposure,cam2_delay,cam2_gain);
catch
    warning('Error reading Cam2 image of emission spectra. No image data extracted.')
    cam2_img = 0;
    cam2_delay = 0;
    cam2_exposure = 0;
    cam2_gain = 0;
    cam2_settings = table(cam2_exposure,cam2_delay,cam2_gain);
end


%% Extract PPD data (Uncomment if needed)
PPDtimes = [1:80000]; %time points selected for analysis by user where 1 is at plasma start and 80000 is maximum
timePPD = PPDtimes.*1e-7; % convert ticks to seconds

smoothing = 5;   %Number of points to smooth the PPD data
cont_data = []; %empty array to put PPD data into

for i = 1:16  % loop over PPD digitizer channels, read data, subtract offset, smooth, and load into cont_data
    raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_252:CH'], [sprintf('%02.2i', i)]]);
    offset_data = raw_data - mean(raw_data(16000:16385));
    offset_data = fastsmooth(offset_data, smoothing, 3, 1);
    smoothed_data = interp1(offset_data,min(PPDtimes):smoothing:max(PPDtimes),'linear');
    cont_data = cat(2, cont_data, smoothed_data');    
end

for i = 1:4 % do the same for last 4 channels of the 20 element PPD
        
    raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_253:CH'], [sprintf('%02.2i', i)]]);
    %raw_data = raw_data(45000:length(raw_data));
    %offset_data = raw_data - mean(raw_data(1:4000));
    offset_data = raw_data - mean(raw_data(16000:16385));
    offset_data = fastsmooth(offset_data, smoothing, 3, 1);
    %smoothed_data = offset_data(time);
    smoothed_data = interp1(offset_data,min(PPDtimes):smoothing:max(PPDtimes),'linear');
    cont_data = cat(2, cont_data, smoothed_data');
end

%fix the order of PPD elements so they go from one end to other correctly
cont_data =  cont_data(:, [2, 1, 4, 3, 6, 5, 8, 7, 10, 9, 12, 11, 14, 13, 16, 15, 18, 17, 20, 19]);
cont_data = fliplr(cont_data);
PicOut = flipdim(cont_data, 1);
PPDIntensity = flipud(PicOut); 

% PPD Viewing locations in cm
PPDposition = (-9.5:9.5).*1.14; %Future: check this if this is PPD spacing or spacing between view points

mdsclose();
mdsdisconnect();

end
