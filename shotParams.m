function [Idis, Icoil, timeCoil, Vdis,photodiode, timePD] = shotParams( shot ) 
%function [Idis, Icoil, timeCoil, Vdis,photodiode, timePD, PPDIntensity, PPDposition, timePPD] = shotData( shot ) 

% A script to extract shot data with MDSPlus.
% Elizabeth H. Tan, 15 May 2019.

% FUTURE WORK:
% Add calculations of key plasma parameters?
% Copy code from PPD_horizontal to extract PPD data
% Eventually when ICCD Images are added to wirxtree, add a function to extract the arrays for ICCD images.

% EXAMPLE:
% [Idis,Icoil,time,Vdis,photodiode,timePD,PPDIntensity,PPDposition,timePPD] = shotParams(1190409005);

% Extract MDS data
mdsconnect('WIRX07');
mdsopen('wirxtree', shot); %Open the tree for the desired shot

Idis = mdsvalue('DTACQ.acq216_270:ch15/.5'); % extract plasma current (kA) from digitizers
Icoil = mdsvalue('DTACQ.acq216_270:ch16/20*1000'); % extract coil current (kA) from digitizers
Vdis = mdsvalue('iv_meas.processed:vdis*1000');
timeCoil = mdsvalue('dim_of(DTACQ.acq216_270:ch15)'); % time from Rogowski coils

photodiode = mdsvalue('DTACQ.acq216_254:ch16'); % single photodiode intensity
timePD = mdsvalue('dim_of(DTACQ.acq216_254:ch16)'); % photodiode time


%% Extract PPD data (Uncomment if needed)
% PPDtimes = [1:80000]; %time points selected for analysis by user where 1 is at plasma start and 80000 is maximum
% timePPD = PPDtimes.*1e-7; % convert ticks to seconds
% 
% smoothing = 5;   %Number of points to smooth the PPD data
% cont_data = []; %empty array to put PPD data into
% 
% disp('Extracting data from \wirxtree::TOP.DTACQ.ACQ216_252...')
% for i = 1:16  % loop over PPD digitizer channels, read data, subtract offset, smooth, and load into cont_data
%     raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_252:CH'], [sprintf('%02.2i', i)]]);
%     offset_data = raw_data - mean(raw_data(16000:16385));
%     offset_data = fastsmooth(offset_data, smoothing, 3, 1);
%     smoothed_data = interp1(offset_data,min(PPDtimes):smoothing:max(PPDtimes),'linear');
%     cont_data = cat(2, cont_data, smoothed_data');    
% end
% 
% disp('Extracting data from \wirxtree::TOP.DTACQ.ACQ216_253...')
% for i = 1:4 % do the same for last 4 channels of the 20 element PPD
%         
%     raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_253:CH'], [sprintf('%02.2i', i)]]);
%     %raw_data = raw_data(45000:length(raw_data));
%     %offset_data = raw_data - mean(raw_data(1:4000));
%     offset_data = raw_data - mean(raw_data(16000:16385));
%     offset_data = fastsmooth(offset_data, smoothing, 3, 1);
%     %smoothed_data = offset_data(time);
%     smoothed_data = interp1(offset_data,min(PPDtimes):smoothing:max(PPDtimes),'linear');
%     cont_data = cat(2, cont_data, smoothed_data');
% end
% 
% disp('Reordering order of horizontal PPD elements...')
% 
% %fix the order of PPD elements so they go from one end to other correctly
% cont_data =  cont_data(:, [2, 1, 4, 3, 6, 5, 8, 7, 10, 9, 12, 11, 14, 13, 16, 15, 18, 17, 20, 19]);
% cont_data = fliplr(cont_data);
% PicOut = flipdim(cont_data, 1);
% PPDIntensity = flipud(PicOut); 
% 
% % PPD Viewing locations in cm
% PPDposition = (-9.5:9.5).*1.14; %Future: check this if this is PPD spacing or spacing between view points

mdsclose();
mdsdisconnect();

end
