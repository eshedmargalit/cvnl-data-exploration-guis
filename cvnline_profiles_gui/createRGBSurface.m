function [rgbimg, hmapfig, xypoints, L] = createRGBSurface(hemi, viewmetric, viewcat,S )

dumpstruct(S)

%% Set cvnlookupimages parameters
% Start with empty lookups

L = [];
lookup_params = {'xyextent', [1,1]};

% Set empty matrices for figure handle, image handle, and line points
hfig = [];
himg = [];
xypoints = [];

% Close any open figures
close all;

% Which layer should we use to draw the line on? 3 is probably okay
viewlayer = 3;

% What functional value should be visualized on the surface to help us draw the line?
viewmetric = 'tstat';

% What category should the functional measures be calculated relative to (e.g., if 'betadiff', then it should be differences between some category and all others
viewcat = 'faces';

% Show functional values from specific HRF?
useIC = 0;

% Which category number matches the string in viewcat?
viewcat_idx = find(strcmp(categorynames, viewcat));
viewmetric_name = viewmetric;

% Colormap limits
clim = []; %none

% if there is IC data for the layers and we want to use it, show that
if (~isempty(layeric) && useIC > 0)
	viewdata = layeric(:,:,viewlayer,useIC);
	viewse = [];
else %don't use specific HRF IC
	firidx = [];
	sz = size(layerbeta);

	% get appropriate layer data for viewed layer
	viewdata = layerbeta(:,:,viewlayer);
	viewse = layerse(:,:,viewlayer);
end

% Establish the contrast
con1 = categories{viewcat_idx};

% Get the actual glm metric for the data
metric_colormap = struct;
cmap = colormap_roybigbl; %Keith's custom colormap
valstruct.data = compute_glm_metric(viewdata, viewse, con1, [], viewmetric, tdim);

% Set colormap limits if it hasn't been done yet
if (isempty(clim))
	clim = prctile(abs(valstruct.data(:)),99.9) * [-1 1];
end

% Set the name of the viewmetric
viewmetric_name = sprintf('%s(%s)', viewmetric, viewcat);
valstruct.data = mean(valstruct.data,2);

switch hemi
	case 'lh'
		data = valstruct.data(1:numlh,:);
		viewpt = viewpt(2);
	case 'rh'
		data = valstruct.data(numlh+1:end,:);
		viewpt = viewpt(1);
end

viewpt = viewpt{1};

% Do the image lookup!
[img, L, rgbimg] = cvnlookupimages(subject, data, hemi, viewpt, L, lookup_params{:}, 'alpha', isfinite(valstruct.data), 'surftype', 'inflated', 'colormap', cmap, 'clim', clim);

% populate himg
if (isempty(himg) || ~ishandle(himg))
	hmapfig = figure;
	himg = imshow(rgbimg);
	set(gca, 'box', 'off');
	axis off;
else
	set(himg, 'cdata', rgbimg);
end

% Set title
titlestr = sprintf('%s layer %d', viewmetric_name, viewlayer);
title(titlestr);
end
