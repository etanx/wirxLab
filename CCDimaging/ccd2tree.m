function [] = ccd2tree(shot)
% ccd2tree: a script (or function) to upload ICCD image arrays to tree. Old
% version of this script is MoveICCDdata.m and camSetMDS.m which can be
% found in Box.
% Elizabeth H. Tan, 16 May 2019.

% NOTES:
% - Future development can combine this with readb16.m code and use a smart
%   slgorithm to determine which are images and which are spectra.
%
% - If PCO software is replaced with a camera script, it will be good to
%   re-write this code in python and merge it with the pco script so that 
%   the code can auto capture, save, and write files to tree.

%clear all, close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOTE: Raw image files must be saved in specific folder (see flder path below) 
% with filename format like 1190409005a.b16 where the alphabet a or b at the end 
% indicates cam1 (electrode) or cam2 (spectrometer).

% Input camera settings and shot number
%shot = 1190617011;

% DICAM1 info
expo_cam1 = 500; % exposure of electrode camera1 (ns)
delay_cam1 = 100e3; % Delay time (ns)
gain_cam1 = 40; % camera gain usually not changed

% second frame of camera1
expo_cam1_a2 = 500;
delay_cam1_a2 = 102e3;

% DICAM2 info
expo_cam2 = 500; % exposure of camera2 (ns) 
delay_cam2 = 100e3; % Delay time (ns)
gain_cam2 = gain_cam1;

% second frame of camera2
expo_cam2_b2 = 500;
delay_cam2_b2 = 102e3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set folderpath of image
shotstr = num2str(shot);
folder = 'C:\Users\Plasma\Box\plasmacommon\WIRX\Pictures\ccd_raw\';


disp(['Writing shot ' num2str(shot) '...'])
mdsconnect('WIRX07');
mdsopen('wirxtree',shot);

%% Write Dicam1 data to tree
% try read image data from raw .b16 files for the shot and write to tree
frames=0;
try
    imgCam1 = readB16([folder shotstr 'a.b16']);
    a = mdsput('ICCD.DICAM1:FRAME1','$',imgCam1);
    disp('Electrode image written to tree at ICCD.DICAM1:FRAME1.')
    
    % write other parameters to tree
    setTimeA = mdsput('ICCD.DICAM1.SETTINGS:FRAME1_TIME','$',delay_cam1);
    setExpoA = mdsput('ICCD.DICAM1.SETTINGS:FRAME1_EXPO','$',expo_cam1);
    setGainA = mdsput('ICCD.DICAM1.SETTINGS:GAIN','$',gain_cam1);
    disp('Dicam1 data saved.')
    frames =1;
catch
    warning('Error reading Cam1 image1 of emission spectra. No image data saved.');
end

% try reading second frame's image
try
    img2Cam1 = readB16([folder shotstr 'a2.b16']);
    a = mdsput('ICCD.DICAM1:FRAME2','$',img2Cam1);
    disp('Electrode image written to tree at ICCD.DICAM1:FRAME2.')
    disp('Dicam1 second frame data saved.')
    
    % write other parameters to tree
    setTimeA2 = mdsput('ICCD.DICAM1.SETTINGS:FRAME2_TIME','$',delay_cam1_a2);
    setExpoA2 = mdsput('ICCD.DICAM1.SETTINGS:FRAME2_EXPO','$',expo_cam1_a2);
    disp('Dicam1 second frame data saved.')
    
    frames=2;
catch
    warning('Error reading second frame of Dicam1. No image data saved.');
end

% plot Cam1 images if read succesful 
if frames == 1
    figure
    fig = imagesc(flipud(imgCam1));
    colormap 'jet'; %Use 'jet' for more interesting looking pictures.
    im=getframe; %Convert figure into a RGB image.
    set(gca, 'Visible', 'off')
    text(5,40,[shotstr])
elseif frames == 2 
    fig1 = imagesc(flipud(imgCam1));
    colormap 'jet'; %Use 'jet' for more interesting looking pictures.
    im1=getframe; %Convert figure into a RGB image.
    set(gca, 'Visible', 'off')
    text(5,40,shotstr)
    
    figure
    fig2 = imagesc(flipud(img2Cam1));
    colormap 'jet'; %Use 'jet' for more interesting looking pictures.
    im2=getframe; %Convert figure into a RGB image.
    set(gca, 'Visible', 'off')
    text(5,40,shotstr)
end



%% Dicam2 Data
try % if cam2 data was also taken
    imgCam2 = readB16([folder shotstr 'b.b16']);
    b = mdsput('ICCD.DICAM2:FRAME1','$',imgCam2);
    disp('DiCam2 image written to tree at ICCD.DICAM2:FRAME1.')
        
    setTimeB = mdsput('ICCD.DICAM2.SETTINGS:FRAME1_TIME','$',delay_cam2);
    setExpoB = mdsput('ICCD.DICAM2.SETTINGS:FRAME1_EXPO','$',expo_cam2);
    setGainB = mdsput('ICCD.DICAM2.SETTINGS:GAIN','$',gain_cam2);
    
    disp('Dicam2 image data saved.')

    figure
    fig = imagesc(flipud(imgCam2));
    colormap 'jet'; %Use 'jet' for more interesting looking pictures.
    im=getframe; %Convert figure into a RGB image.
    set(gca, 'Visible', 'off')
    text(5,40,[shotstr])

catch
    warning('Error reading Cam2 image of emission spectra. No image data saved.');
end

% try reading second frame's image
try
    img2Cam2 = readB16([folder shotstr 'b2.b16']);
    b = mdsput('ICCD.DICAM2:FRAME2','$',img2Cam2);
    disp('Image written to tree at ICCD.DICAM2:FRAME2.')
    disp('Dicam2 second frame data saved.')
    
    % write other parameters to tree
    setTimeB2 = mdsput('ICCD.DICAM2.SETTINGS:FRAME2_TIME','$',delay_cam2_a2);
    setExpoB2 = mdsput('ICCD.DICAM2.SETTINGS:FRAME2_EXPO','$',expo_cam2_a2);
    disp('Dicam2 second frame data saved.')
    
    frames=2;
catch
    warning('Error reading second frame of Dicam2. No image data saved.');
end

mdsclose;
mdsdisconnect;

disp(['Shot ' num2str(shot) ' written to tree.'])
disp(" ")

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

