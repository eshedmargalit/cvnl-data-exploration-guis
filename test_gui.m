function varargout = test_gui(varargin)
% TEST_GUI MATLAB code for test_gui.fig
%      TEST_GUI, by itself, creates a new TEST_GUI or raises the existing
%      singleton*.
%
%      H = TEST_GUI returns the handle to a new TEST_GUI or the handle to
%      the existing singleton*.
%
%      TEST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_GUI.M with the given input arguments.
%
%      TEST_GUI('Property','Value',...) creates a new TEST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_gui

% Last Modified by GUIDE v2.5 20-Oct-2016 19:26:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @test_gui_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before test_gui is made visible.
function test_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test_gui (see VARARGIN)

% Choose default command line output for test_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test_gui wait for user response (see UIRESUME)
% uiwait(handles.maingui);

% Start custom code here
%-----------------------%

% set up empty cells (one for each layer) for betas and se for each of the three HRFs
handles.BETAS_OPT = cell(6,1);
handles.SE_OPT = cell(6,1);
handles.BETAS_IC1 = cell(6,1);
handles.SE_IC1 = cell(6,1);
handles.BETAS_IC2 = cell(6,1);
handles.SE_IC2 = cell(6,1);

% set the data directory, results directory, and subject ID (from freesurfer)
datadir = '/home/stone-ext1/fmridata/20160212-ST001-E002';
resultsdir = sprintf('%s/glmdenoise_results',datadir);
subject = 'C0041';
layers = {'1','2','3','4','5','6'};

% Preload data from all layers and save it in handles
for layer = 1:6
	[handles.BETAS_OPT{layer}, handles.SE_OPT{layer}] = init_fields(resultsdir, '',1:10, layers{layer});
	[handles.BETAS_IC1{layer}, handles.SE_IC1{layer}] = init_fields(resultsdir, '_IC12',1:10, layers{layer});
	[handles.BETAS_IC2{layer}, handles.SE_IC2{layer}] = init_fields(resultsdir, '_IC12',11:20, layers{layer});
end

% For layer 1 (the default load) compute t-stat (default metric)
tstats = compute_glm_metric(handles.BETAS_OPT{1},handles.SE_OPT{1},[5 6],[],'tstat',2);
metricmax = max(tstats);
metricmin = min(tstats);

set(handles.tmax,'string',metricmax);
set(handles.threshField,'string',metricmin);


% Generate default image (faces tstat layer1 optimized HRF)
[im, handles.L, handles.S] = makeFigs(subject,handles.BETAS_OPT{1},handles.SE_OPT{1},'tstat','hot','faces',metricmin,metricmax,[],'1', [],'');

% Switch focus to brainax, show image
axes(handles.brainax);
imshow(im);
hold on;

% Create colorbar (default is hot) with 100 colors
colormap(hot(100));
hc = colorbar;

% Explicity set display limits to those in GUI
ylim(hc,[metricmin,metricmax]);
hcImg = findobj(hc,'type','image');
set(hcImg,'YData',[metricmin,metricmax]);
ylabel(hc, 't-stat');
hold off;

% Set defaults as handles fields to grab them easily later on
handles.layer = '1';
handles.HRF = '';
handles.roi = [];

% Update handles var for later use
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = test_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
update_axes(handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function threshField_Callback(hObject, eventdata, handles)
% hObject    handle to threshField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshField as text
%        str2double(get(hObject,'String')) returns contents of threshField as a double

update_axes(handles);

% --- Executes during object creation, after setting all properties.
function threshField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_axes(handles);


% --- Executes on selection change in contrastDrop.
function contrastDrop_Callback(hObject, eventdata, handles)
% hObject    handle to contrastDrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_axes(handles);

% Hints: contents = cellstr(get(hObject,'String')) returns contrastDrop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from contrastDrop


% --- Executes during object creation, after setting all properties.
function contrastDrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastDrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'Value',3);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function brainax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brainax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate brainax


% --- Executes when selected object is changed in uipanel2.
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel2 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
str = get(eventdata.NewValue,'Tag');
handles.layer = str(6:end); %cut off 'radio'
guidata(hObject, handles);
update_axes(handles);


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in uipanel3.
function uipanel3_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel3 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
str = get(eventdata.NewValue,'Tag');
handles.HRF = str(6:end); %cut off 'radio'
if strcmp(handles.HRF,'Optimized')
    handles.HRF = '';
end
guidata(hObject, handles);
update_axes(handles);



function tmax_Callback(hObject, eventdata, handles)
% hObject    handle to tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tmax as text
%        str2double(get(hObject,'String')) returns contents of tmax as a double
update_axes(handles);


% --- Executes during object creation, after setting all properties.
function tmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contrastNum = get(handles.contrastDrop,'Value');
contrasts = {'characters','bodies','faces','places','objects','word',...
    'number','body','limb','adult','child','corridor','house','car', ...
    'instrument'};
contrast = contrasts{contrastNum};
thresh = get(handles.threshField,'string');
tmax = get(handles.tmax,'string');
if (isempty(handles.HRF))
    hrfstr = 'optimized';
else
    hrfstr = handles.HRF;
end


defstring = sprintf('inflated_ventral_fLoc_%s_layer%s_HRF%s_t%s_%s.png',contrast, ...
    handles.layer, hrfstr, thresh, tmax);
[file,path] = uiputfile(defstring,'Save file name');
outname = [path,file];
im = export_fig(handles.brainax,'-a1');
imwrite(im,outname);

function update_axes(handles)
	set(handles.maingui, 'pointer', 'watch')
	drawnow;
	sub = get(handles.subField,'String');
	thresh = str2num(get(handles.threshField,'string'));
	tmax = str2num(get(handles.tmax,'string'));

	contrastNum = get(handles.contrastDrop,'Value');
	contrasts = get(handles.contrastDrop,'String');
	contrast = contrasts{contrastNum};

	metricNum = get(handles.metricdrop,'Value');
	metrics = get(handles.metricdrop,'String');
	metric = metrics{metricNum};

	colormapNum = get(handles.colordrop,'Value');
	colormaps = get(handles.colordrop,'String');
	cmap = colormaps{colormapNum};

   	 layerNum = str2num(handles.layer);
    
	if strcmp(handles.HRF,'IC1')
	    b = handles.BETAS_IC1{layerNum};
	    s = handles.SE_IC1{layerNum};
	elseif strcmp(handles.HRF,'IC2')
	    b = handles.BETAS_IC2{layerNum};
	    s = handles.SE_IC2{layerNum};
	else 
	    b = handles.BETAS_OPT{layerNum};
	    s = handles.SE_OPT{layerNum};
	end

	[im, ~,~] = makeFigs(sub,b,s,metric,cmap,contrast, thresh, tmax, handles.L, handles.layer, handles.S, handles.HRF);

	axes(handles.brainax);
	if ~isempty(handles.roi)
		if (~isempty(handles.perim))
			% dilate border to make it easier to see
			tmp = imdilate(handles.perim,strel('disk',1));
			r = im(:,:,1);
			g = im(:,:,2);
			b = im(:,:,3);
			r(tmp) = 0;
			g(tmp) = 0;
			b(tmp) = 0;
			im(:,:,1) = r;
			im(:,:,2) = g;
			im(:,:,3) = b;
		end
	end
	imshow(im);
	hold on;
	% if roi exists, merge roi
	if ~isempty(handles.roi)
		hp = plot(handles.roix,handles.roiy,'k.-','MarkerSize',5,'LineWidth',3);
	end
	colormap(eval([cmap, '(', num2str(100), ')']));
	hc = colorbar;
	ylabel(hc, metric);
	ylim(hc,[thresh,tmax]);
	hcImg = findobj(hc,'type','image');
	set(hcImg,'YData',[thresh,tmax]);
	hold off;

	set(handles.maingui, 'pointer', 'arrow');
	drawnow;


% --- Executes on selection change in popupmenu3.
function metricdrop_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
update_axes(handles);

% --- Executes during object creation, after setting all properties.
function metricdrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'Value',1);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function colordrop_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
update_axes(handles);


% --- Executes during object creation, after setting all properties.
function colordrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'Value',1);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function radio1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radio1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',1);



function resultsdirField_Callback(hObject, eventdata, handles)
% hObject    handle to resultsdirField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resultsdirField as text
%        str2double(get(hObject,'String')) returns contents of resultsdirField as a double


% --- Executes during object creation, after setting all properties.
function resultsdirField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resultsdirField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dataBrowseButton.
function dataBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to dataBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = uigetdir(cvnpath('fmridata'),'Choose GLM Results folder');
set(handles.resultsdirField,'String',str);
update_data_sources(handles);
guidata(hObject,handles);



function subField_Callback(hObject, eventdata, handles)
% hObject    handle to subField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subField as text
%        str2double(get(hObject,'String')) returns contents of subField as a double
update_axes(handles);

% --- Executes during object creation, after setting all properties.
function subField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function update_data_sources(handles)
    resultsdir = get(handles.resultsdirField,'String');
    layers = {'1','2','3','4','5','6'};
    for layer = 1:6

    [handles.BETAS_OPT{layer}, handles.SE_OPT{layer}] = init_fields(resultsdir, '',1:10, layers{layer});
    [handles.BETAS_IC1{layer}, handles.SE_IC1{layer}] = init_fields(resultsdir, '_IC12',1:10, layers{layer});
    [handles.BETAS_IC2{layer}, handles.SE_IC2{layer}] = init_fields(resultsdir, '_IC12',11:20, layers{layer});

    end


% --- Executes on button press in roiButton.
function roiButton_Callback(hObject, eventdata, handles)
% hObject    handle to roiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.roi = [];
handles.roix = [];
handles.roiy = [];
handles.perim = [];
update_axes(handles);

%focus on the figure axes
axes(handles.brainax);

% draw ROI
[r, x, y] = roipoly();
handles.roi = r;
handles.roix = x;
handles.roiy = y;
guidata(hObject,handles);
update_axes(handles);
set(handles.clearroiButton,'enable','on');
set(handles.analyzeroiButton,'enable','on');
set(handles.shrinkButton,'enable','on');

% draw ROI on surface until next time button is clicked

function analyze_ROI(handles)
	roi_bar_gui
	return;
	
	% pull vertices from ROI
	verticesStruct = spherelookup_image2vert(handles.roi,handles.L);
	vertices = verticesStruct.data;
	vertmask = vertices > 0;

	layer = str2num(handles.layer);
	switch handles.HRF
		case ''
			b = handles.BETAS_OPT{layer};
		case 'IC1'
			b = handles.BETAS_IC1{layer};
		case 'IC2'
			b = handles.BETAS_IC2{layer};
	end

	valid_b = b(vertmask,:);

	means = mean(valid_b,1);
	sems = std(valid_b,[],1)./sqrt(size(valid_b,1));

	categorynames = getFlocCategoryNames('all');
	im = createBarFig(means,sems,categorynames);


% --- Executes on button press in analyzeroiButton.
function analyzeroiButton_Callback(hObject, eventdata, handles)
% hObject    handle to analyzeroiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
analyze_ROI(handles);


% --- Executes during object creation, after setting all properties.
function roiButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in clearroiButton.
function clearroiButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearroiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.roi = [];
handles.roix = [];
handles.roiy = [];
guidata(hObject,handles);
set(handles.analyzeroiButton,'enable','off');
set(handles.shrinkButton,'enable','off');
set(hObject,'enable','off');
update_axes(handles);


% --- Executes during object creation, after setting all properties.
function analyzeroiButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analyzeroiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'enable','off');


% --- Executes during object creation, after setting all properties.
function clearroiButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clearroiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'enable','off');


% --- Executes on button press in shrinkButton.
function shrinkButton_Callback(hObject, eventdata, handles)
% hObject    handle to shrinkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


layer = str2num(handles.layer);
switch handles.HRF
    case ''
        b = handles.BETAS_OPT{layer};
        se = handles.SE_OPT{layer};
    case 'IC1'
        b = handles.BETAS_IC1{layer};
        se = handles.SE_IC1{layer};
    case 'IC2'
        b = handles.BETAS_IC2{layer};
        se = handles.SE_IC2{layer};
end
thresh = str2num(get(handles.threshField,'string'));

contrastNum = get(handles.contrastDrop,'Value');
contrasts = get(handles.contrastDrop,'String');
contrast = contrasts{contrastNum};

metricNum = get(handles.metricdrop,'Value');
metrics = get(handles.metricdrop,'String');
metric = metrics{metricNum};

valid_func_vertices = getValidFuncVertices(b,se,metric,contrast,thresh);

rL = handles.L{1};
lL = handles.L{2};

valstruct = struct('data',valid_func_vertices,'numrh',rL.vertsN,'numlh',lL.vertsN);
validpx = spherelookup_vert2image(valstruct,handles.L,0);
roi = handles.roi;
overlap = roi .* validpx;
handles.roi = overlap;
handles.perim = bwperim(overlap);
handles.roix = [];
handles.roiy = [];
guidata(hObject,handles);
update_axes(handles);


% --- Executes during object creation, after setting all properties.
function shrinkButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shrinkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'enable','off');
