% A script to extract shot data with MDSPlus
% Elizabeth H. Tan, 15 May 2019.

% example usage: 

% FUTURE WORK:
% Change this to a function that simply extracts data with MDSPlus once we input a shot number.
% Maybe combine or make it used by PPD2vel.m?
% Add a 'save' feature to save MDSPlus data as mat files
% Add calculations of key plasma parameters?
% Copy code from PPD_horizontal to extract PPD data
% Eventually when ICCD Images are added to wirxtree, add a function to extract the arrays for ICCD images.

clear all

shot = 1190305020;

% Extract MDS data
mdsconnect('WIRX07');
mdsopen('wirxtree', shot); %Open the tree for the desired shot
%Idischarge = mdsvalue('IV_MEAS.PROCESSED:IDIS');
Idis = mdsvalue('DTACQ.acq216_270:ch15/.5');
%Icoil = mdsvalue('IV_MEAS.PROCESSED:ICOIL');
Icoil = mdsvalue('DTACQ.acq216_270:ch16/20*1000')

timecoil = mdsvalue('dim_of(IV_MEAS.PROCESSED:ICOIL)');
%Vdischarge = mdsvalue('IV_MEAS.PROCESSED:VDIS');
Vdis = mdsvalue('iv_meas.processed:vdis*1000');
photodiode = mdsvalue('DTACQ.acq216_254:ch16');
timePD = mdsvalue('dim_of(DTACQ.acq216_254:ch16)');
mdsclose();
mdsdisconnect();

%% Calculate average Icoil (and B)
I_avg = mean(Icoil(find(timecoil >= 0.5e-3 & timecoil <= 5.5e-3)))
B_avg = 7.7*I_avg% convert kiloAmpere to Gauss
Ip_avg = mean(Idis(find(timecoil >= 0.5e-3 & timecoil <= 5.5e-3)))

%% Extract PPD data
[PicOut, times, position] = PPD_horizontal(shot, [1:80000], [0 0.36846]);
timePPD = times.*1e-7; % convert ticks to seconds
sumPPD = rssq(PicOut,2);
