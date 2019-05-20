function [v, v_avg, dv_avg] = PPDvelDistribution( folderpath )

% script combines all the extracted velocities in a selected folder. Velocities must be
% first extracted and saved with PPD2vel.m, PPDvelExtract2, or equiv. and
% start with 'vel' in the filename.

% Elizabeth H. Tan, 17 May 2019.

% example: 
% [v, v_avg, dv_avg] = PPDvelDistribution('C:\Users\Plasma\Box\elizabethtan\2018-19 WIRX Honors Thesis\Code\Argon')

% navigate to location of top folder containing velocity data
FileList = dir([folderpath '\vel*.mat']); % list all files with pattern

%create empty variable arrays
velocities = []; 
v_avg = [];
dv_avg = [];

% loop through all files in list
for i = 1:length(FileList)

filepath = [FileList(i).folder '\' FileList(i).name];    
clear vel
load(filepath)
% average all events in one shot
v_avg(i) = mean(vel);
dv_avg(i) = std(vel./1e5)./sqrt(length(FileList));

% FUTURE: make function save other parameters also
mean(Icoil);
mean(Idis);
mean(Vdis);


% FUTURE: Compile list of shots and other parameters from all the files
% too?

% combine new data into array
velocities = cat(1,velocities,vel);

end

% Arrange in increasing order
v = sort(velocities);
v_avg = sort(abs(v_avg./100))';
dv_avg = abs(dv_avg)';


