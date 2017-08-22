function [rgbimg, L] = make_figs(sub, betas, se, viewmetric, cmap, con1, con2, metric_min, metric_max, L, HRF, bg, overlay_visibility, view_number)
% MAKE_FIGS creates the rgb image and lookup for the given inputs 
	% Get correct HRF string for results directory based on input
	if (~isempty(HRF))
		hrfstr = '_IC12';
	else
		hrfstr = '';
	end

	% Set the colormap
	cmap = eval([cmap, '(', num2str(100), ')']);

	hemis = {'lh', 'rh'};
	surfsuffix = 'DENSETRUNCpt';

	% load views, specify correct params
	views = get_views();
	view = views{view_number};
	area = view{1};
	surftype = view{2};
	hemiflip = view{3};
	imageres = view{4};
	fsaverage0 = view{5};
	xyextent = view{6};

	% get number of vertices in inflated DENSETRUNCpt
	[numlh, numrh] = cvnreadsurface(sub,hemis,'sphere',surfsuffix,...
		'justcount',true);

	% get viewpoint
	if hemiflip 
		hemis = fliplr(hemis);
	end

	viewpt = cvnlookupviewpoint(sub,hemis,area,surftype);

	% setup image params
	metric = compute_glm_metric(betas,se,con1,con2,viewmetric,2);
	dataStruct = struct('data',metric,'numlh',numlh,'numrh',numrh);

	if overlay_visibility
		thresh = metric > metric_min;
	else
		thresh = zeros(length(metric),1);
	end
		
	clim = [metric_min metric_max];

	% draw image and create RGB
	[img, L, rgbimg] = cvnlookupimages(sub,dataStruct,hemis,viewpt,L,'xyextent',xyextent,...
		'surftype',surftype,'imageres',imageres,'overlayalpha',thresh,'cmap',cmap,...
		'clim',clim, 'background', bg,'surfsuffix',surfsuffix);

end %end fx

% from cvnvisualizeanatomicalresults.m
function allviews = get_views()
	allviews = { ...
	  {'ventral'        'sphere'                   0 1000    0         [1 1]} ...
	  {'occip'          'sphere'                   0 1000    0         [1 1]} ...
	  {'occip'          'inflated'                 0  500    0         [1 1]} ...
	  {'ventral'        'inflated'                 1  500    0         [1 1]} ...
	  {'parietal'       'inflated'                 0  500    0         [1 1]} ...
	  {'medial'         'inflated'                 0  500    0         [1 1]} ...
	  {'lateral'        'inflated'                 0  500    0         [1 1]} ...
	  {'medial-ventral' 'inflated'                 0  500    0         [1 1]} ...
	  {'occip'          'sphere'                   0 1000    1         [1 1]} ...
	  {'ventral'        'inflated'                 1  500    1         [1 1]} ...
	  {'ventral'        'gVTC.flat.patch.3d'       1 2000    0         [160 0]} ...   % 12.5 pixels per mm
	  {''               'gEVC.flat.patch.3d'       0 1500    0         [120 0]} ...   % 12.5 pixels per mm
	};
end

