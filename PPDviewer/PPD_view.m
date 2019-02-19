function varargout = PPD_view(varargin)

% NOTE: Function requires PPD_view.fig and fastsmooth.m to work.

% PPD_VIEW M-file for PPD_view.fig
%      PPD_VIEW, by itself, creates a new PPD_VIEW or raises the existing
%      singleton*.
%
%      H = PPD_VIEW returns the handle to a new PPD_VIEW or the handle to
%      the existing singleton*.
%
%      PPD_VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PPD_VIEW.M with the given input arguments.
%
%      PPD_VIEW('Property','Value',...) creates a new PPD_VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PPD_view_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PPD_view_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Edit the above text to modify the response to help PPD_view
% Last Modified by GUIDE v2.5 21-Apr-2011 14:25:01
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PPD_view_OpeningFcn, ...
                   'gui_OutputFcn',  @PPD_view_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function PPD_view_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PPD_view (see VARARGIN)

% Choose default command line output for PPD_view
handles.output = hObject;
handles.shot = 2110706015;
set( handles.shot_num, 'String', int2str( handles.shot) );
% mdsclose();
% mdsopen('wirxtree', handles.shot);
handles.endpt = 52000;
handles.stpt = 50000;
handles.clims = [0, 1];
handles.ncntrs = 10;
colormap('jet');
handles.dtpts = 5;
set(hObject, 'Units', 'normalized','outerposition',[0 0 0.95 0.95]);
% Update handles structure
guidata(hObject, handles);
replot(hObject, eventdata, handles);

function varargout = PPD_view_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function imdraw(pic, hObject, eventdata, handles)

clims = (max([max(max(handles.pic1)), max(max(handles.pic2))])).*(handles.clims);
ccntr = linspace(clims(1), clims(2), handles.ncntrs);

switch pic
    case 1
        try imagesc( handles.pic3_z, -fliplr(handles.pic3_x), handles.pic1, clims ), end
    case 2
        try imagesc( handles.pic4_z, -fliplr(handles.pic4_x), handles.pic2, clims ), end
    case 3
        try contour( handles.pic3_z, handles.pic3_x, handles.pic3_dat, ccntr ), end
    case 4
        try contour( handles.pic4_z, handles.pic4_x, handles.pic4_dat, ccntr ), end
end


function replot(hObject, eventdata, handles)

m = handles.dtpts;
ep = handles.endpt;
st = handles.stpt;
xx = [];
zz = [];

cont_data = [];
mdsclose();
mdsopen('wirxtree', handles.shot);
for i = 1:16
    
    
    raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_252:CH'], [sprintf('%02.2i', i)]]);
    offset_data = raw_data - mean(raw_data(16000:16384));
    offset_data = fastsmooth(offset_data, m, 3, 1);
    smoothed_data = interp1(offset_data, st:m:ep, 'linear');
    n = length(smoothed_data);
    time = mdsvalue('dim_of(\top.dtacq.acq216_252:ch01)').*1000000;
    xx = interp1(time, st:m:ep, 'linear');
    zz = [zz, i];
    cont_data = cat(2, cont_data, smoothed_data');
        
end
for i = 1:4
    
    
    raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_253:CH'], [sprintf('%02.2i', i)]]);
    offset_data = raw_data - mean(raw_data(16000:16384));
    offset_data = fastsmooth(offset_data, m, 3, 1);
    smoothed_data = interp1(offset_data, st:m:ep, 'linear');
    n = length(smoothed_data);
    time = mdsvalue('dim_of(\top.dtacq.acq216_252:ch01)').*1000000;
    xx = interp1(time, st:m:ep, 'linear');
    zz = [zz, i + 16];
    cont_data = cat(2, cont_data, smoothed_data');
        
end

cont_data =  cont_data(:, [2, 1, 4, 3, 6, 5, 8, 7, 10, 9, 12, 11, 14, 13, 16, 15, 18, 17, 20, 19]);
cont_data = fliplr(cont_data);
handles.pic1 = flipdim(cont_data, 1);
handles.pic3_x = xx;
handles.pic3_z = zz;
handles.pic3_dat = cont_data;



xx = [];
zz = [];

cont_data = [];

for i = 5:16
    
    
    raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_253:CH'], [sprintf('%02.2i', i)]]);
    offset_data = raw_data - mean(raw_data(16000:16384));
    offset_data = fastsmooth(offset_data, m, 3, 1);
    smoothed_data = interp1(offset_data, st:m:ep, 'linear');
    n = length(smoothed_data);
    time = mdsvalue('dim_of(\top.dtacq.acq216_252:ch01)').*1000000;
    xx = interp1(time, st:m:ep, 'linear');
    zz = [zz, i - 4];
    cont_data = cat(2, cont_data, smoothed_data');
        
end
for i = 1:8
    
    
    raw_data = mdsvalue([['\wirxtree::TOP.DTACQ.ACQ216_254:CH'], [sprintf('%02.2i', i)]]);
    offset_data = raw_data - mean(raw_data(16000:16384));
    offset_data = fastsmooth(offset_data, m, 3, 1);
    smoothed_data = interp1(offset_data, st:m:ep, 'linear');
    n = length(smoothed_data);
    time = mdsvalue('dim_of(\top.dtacq.acq216_252:ch01)').*1000000;
    xx = interp1(time, st:m:ep, 'linear');
    zz = [zz, i + 12];
    cont_data = cat(2, cont_data, smoothed_data');
        
end
mdsclose();

%cont_data =  cont_data(:, [2, 1, 4, 3, 6, 5, 8, 7, 10, 9, 12, 11, 14, 13, 16, 15, 18, 17, 20, 19]);
%Values below are from trying to make data look smoother. Real channel
%order is uncertain.  DC Dec 2014
cont_data = cont_data(:,[1,4,2,3,6,8,5,7,10,9,12,11,14,13,16,15,18,17,20,19]);
handles.pic2 = flipdim(cont_data, 1);
handles.pic4_x = xx;
handles.pic4_z = zz;
handles.pic4_dat = cont_data;


pos1 = [0.030630484988452657, 0.579454253611557, 0.44226327944572746, 0.39967897271268055];
pos2 = [0.50036951501154734, 0.579454253611557, 0.44226327944572746, 0.39967897271268055];
pos3 = [0.030630484988452657, 0.1492776886035313, 0.44226327944572746, 0.39967897271268055];
pos4 = [0.50036951501154734, 0.1492776886035313, 0.44226327944572746, 0.39967897271268055];

try delete(handles.im1), end
try delete(handles.im2), end
try delete(handles.im3), end
try delete(handles.im4), end


handles.im3 = axes('FontSize', 5, 'Position', pos3, 'Visible', 'off');
imdraw(3, hObject, eventdata, handles);

handles.im4 = axes('FontSize', 5, 'Position', pos4, 'Visible', 'off');
imdraw(4, hObject, eventdata, handles);

handles.im1 = axes('FontSize', 5, 'Position', pos1, 'Visible', 'off');
imdraw(1, hObject, eventdata, handles);

handles.im2 = axes('FontSize', 5, 'Position', pos2, 'Visible', 'off');
imdraw(2, hObject, eventdata, handles);


clims = (max([max(max(handles.pic1)), max(max(handles.pic2))])).*(handles.clims);

set(handles.clims_high_text, 'String', ['clim High:  ', num2str(clims(2))]);
set(handles.clims_low_text, 'String', ['clim Low:  ', num2str(clims(1))]);


guidata(hObject, handles);

function clims_high_Callback(hObject, eventdata, handles)
handles.clims(2) = get(hObject, 'Value');
guidata(hObject, handles);
replot(hObject, eventdata, handles);

function clims_high_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function clims_low_Callback(hObject, eventdata, handles)
handles.clims(1) = get(hObject, 'Value');
guidata(hObject, handles);
replot(hObject, eventdata, handles);

function clims_low_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function shot_num_Callback(hObject, eventdata, handles)
handles.shot = str2double(get(hObject,'String'));
% mdsclose();
% mdsopen('wirxtree', handles.shot);
guidata(hObject, handles);
replot(hObject, eventdata, handles);

function shot_num_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function color_map_Callback(hObject, eventdata, handles)
colormapeditor;

function prev_shot_Callback(hObject, eventdata, handles)

try
    handles.shot = mdsPrevPicShot( handles.shot );
catch
    handles.shot = 2090608003;
end

set( handles.shot_num, 'String', int2str( handles.shot) );
% mdsclose();
% mdsopen('wirxtree', handles.shot);

guidata(hObject, handles);
replot(hObject, eventdata, handles);

function next_shot_Callback(hObject, eventdata, handles)

try
    handles.shot = mdsNextPicShot( handles.shot );
catch
    handles.shot = 2090608003;
end

set( handles.shot_num, 'String', int2str( handles.shot) );
% mdsclose();
% mdsopen('wirxtree', handles.shot);

guidata(hObject, handles);
replot(hObject, eventdata, handles);

function next_shot = mdsNextPicShot( current_shot )

next_shot=current_shot+1;
% mdsclose();
% mdsopen('wirxtree',next_shot);
% b=mdsvalue('tcl($)',['set tree wirxtree/shot=',num2str(next_shot)]);
% if b==265392042
%     a='%';
% else
%     a=mdsvalue('.ICCD.DICAM1:FRAME1');
% end
% while  b==265392042 || (a(1)=='%')%TREE-E-TreeNODATA, No data available for this node')
%     code=num2str(next_shot);
%     year=str2double(code(2:3));
%     month=str2double(code(4:5));
%     day=str2double(code(6:7));
%     shot=str2double(code(8:10));
%     if shot+1>=251
%         shot=1;
%         if day+1>=32
%             day=1;
%             if month+1>=8
%                 month=1;
%                 if year+1>=11;
%                     exception=MException('NoNextShot','There is no next shot');
%                     throw(exception);
%                 else
%                     year=year+1;
%                 end
%             else
%                 month=month+1;
%             end
%         else
%             day=day+1;
%         end
%     else
%         shot=shot+1;
%     end
%     next_shot=2000000000+year*10000000+month*100000+day*1000+shot;
%     %next_shot=str2double(['2',num2str(year),num2str(month),num2str(day),num2str(shot)]);
%     %mdsopen('wirxtree',next_shot);
%     b=mdsvalue('tcl($)',['set tree wirxtree/shot=',num2str(next_shot)]);
%     if b==265392042
%         a='%';
%     else
%         a=mdsvalue('.ICCD.DICAM1:FRAME1');
%     end
%     mdsclose();
% end

function next_shot = mdsPrevPicShot( current_shot )

next_shot=current_shot-1;
% mdsclose();
% mdsopen('wirxtree',next_shot);
% b=mdsvalue('tcl($)',['set tree wirxtree/shot=',num2str(next_shot)]);
% if b==265392042
%     a='%';
% else
%     a=mdsvalue('.ICCD.DICAM1:FRAME1');
% end
% while  b==265392042 || (a(1)=='%')%TREE-E-TreeNODATA, No data available for this node')
%     code=num2str(next_shot);
%     year=str2double(code(2:3));
%     month=str2double(code(4:5));
%     day=str2double(code(6:7));
%     shot=str2double(code(8:10));
%     if shot-1<=0
%         shot=250;
%         if day-1<=0
%             day=31;
%             if month-1<=0
%                 month=7;
%                 if year-1<=8;
%                     exception=MException('NoNextShot','There is no next shot');
%                     throw(exception);
%                 else
%                     year=year-1;
%                 end
%             else
%                 month=month-1;
%             end
%         else
%             day=day-1;
%         end
%     else
%         shot=shot-1;
%     end
%     next_shot=2000000000+year*10000000+month*100000+day*1000+shot;
%     %next_shot=str2double(['2',num2str(year),num2str(month),num2str(day),num2str(shot)]);
%     %mdsopen('wirxtree',next_shot);
%     b=mdsvalue('tcl($)',['set tree wirxtree/shot=',num2str(next_shot)]);
%     if b==265392042
%         a='%';
%     else
%         a=mdsvalue('.ICCD.DICAM1:FRAME1');
%     end
%     mdsclose();
% end

function datapoints_Callback(hObject, eventdata, handles)
handles.dtpts = str2double(get(hObject,'String'));
guidata(hObject, handles);
replot(hObject, eventdata, handles);

function datapoints_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function end_pt_Callback(hObject, eventdata, handles)
handles.endpt = str2double(get(hObject,'String'));
guidata(hObject, handles);
replot(hObject, eventdata, handles);

function end_pt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function num_cntrs_Callback(hObject, eventdata, handles)
handles.ncntrs = str2double(get(hObject,'String'));
guidata(hObject, handles);
replot(hObject, eventdata, handles);

function num_cntrs_CreateFcn(hObject, ~, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function clims_low_text_CreateFcn(hObject, eventdata, handles)

function clims_high_text_CreateFcn(hObject, eventdata, handles)

function start_pt_Callback(hObject, eventdata, handles)
handles.stpt = str2double(get(hObject,'String'));
guidata(hObject, handles);
replot(hObject, eventdata, handles);

function start_pt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
