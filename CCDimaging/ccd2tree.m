% ccd2tree: a script (or function) to upload ICCD image arrays to tree. Old
% version of this script is MoveICCDdata.m and camSetMDS.m which can be
% found in Box.
% Elizabeth H. Tan, 16 May 2019.

% NOTES:
% - Future development can combine this with readb16.m code and use a smart
%   slgorithm to determine which are images and which are spectra.
%
% - If PCO software is replaced with a camera script, it will be good to
%   re-write this code in python and merge it with the pco script.

clear all, close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOTE: Raw image files must be saved in specific folder (see flder path below) 
% with filename format like 1190409005a.b16 where the alphabet a or b at the end 
% indicates cam1 (electrode) or cam2 (spectrometer).

% Input camerasettings and shot number
shot = 1190409015;

expo_cam1 = 500; % exposure of electrode camera1 (ns)
expo_cam2 = 50e3; % exposure of spectrometer camera2 (ns) 

delay_cam1 = 50e6; % Delay time (ns)
delay_cam2 = 50e6; % Delay time (ns)

gain_cam1 = 40; % camera gain usually not changed
gain_cam2 = gain_cam1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set folderpath of image
shotstr = num2str(shot);
folder = 'C:\Users\Plasma\Box\plasmacommon\WIRX\Pictures\ccd_raw\';



%% Write data to tree
disp(['Writing shot ' num2str(shot) '...'])
mdsconnect('WIRX07');
mdsopen('wirxtree',shot);

% try read image data from raw .b16 files for the shot
imgElectrodes = readB16([folder shotstr 'a.b16']);
a = mdsput('ICCD.DICAM1:FRAME1','$',imgElectrodes);
disp('Electrode image written to tree at ICCD.DICAM1:FRAME1.')

figure
fig = imagesc(flipud(imgElectrodes));
colormap 'jet'; %Use 'jet' for more interesting looking pictures.
im=getframe; %Convert figure into a RGB image.
set(gca, 'Visible', 'off')
text(5,40,[shotstr])

try % if spectra was also taken
    imgSpectra = readB16([folder shotstr 'b.b16']);
    b = mdsput('ICCD.DICAM2:FRAME1','$',imgSpectra);
    disp('Spectra image written to tree at ICCD.DICAM2:FRAME1.')
    disp(' ')
        
    figure
    fig = imagesc(flipud(imgSpectra));
    colormap 'jet'; %Use 'jet' for more interesting looking pictures.
    im=getframe; %Convert figure into a RGB image.
    set(gca, 'Visible', 'off')
    text(5,40,[shotstr])

catch
    warning('Error reading Cam2 image of emission spectra. No image data saved.');
end

setTimeA = mdsput('ICCD.DICAM1.SETTINGS:FRAME1_TIME','$',delay_cam1);
setTimeB = mdsput('ICCD.DICAM2.SETTINGS:FRAME1_TIME','$',delay_cam2);
setExpoA = mdsput('ICCD.DICAM1.SETTINGS:FRAME1_EXPO','$',expo_cam1);
setExpoB = mdsput('ICCD.DICAM2.SETTINGS:FRAME1_EXPO','$',expo_cam2);
setGainA = mdsput('ICCD.DICAM1.SETTINGS:GAIN','$',gain_cam1);
setGainB = mdsput('ICCD.DICAM2.SETTINGS:GAIN','$',gain_cam2);

mdsclose;
mdsdisconnect;


%% Check if image written to tree by extracting it
% clearvars -except shot
% 
% mdsconnect('WIRX07');
% mdsopen('wirxtree',shot);
% imgtest = mdsvalue( 'ICCD.DICAM1:FRAME1' );
% mdsclose;
% mdsdisconnect;
% 
% 
% % show figures and close them
% figure
% fig = imagesc(flipud(imgtest));
% colormap 'jet'; %Use 'jet' for more interesting looking pictures.
% im=getframe; %Convert figure into a RGB image.
% set(gca, 'Visible', 'off')
% text(5,40,[shotstr])
% 
% 
% 

