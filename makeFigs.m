function [rgbimg, L, S] = makeFigs(sub, betas, se, viewmetric, cmap, contrastName, metric_min, metric_max, L, layer, S, HRF)

% Assign contrast 1 based on lowercase input
con1 = getCon(lower(contrastName));

% Get correct HRF string for results directory based on input
if (~isempty(HRF))
	hrfstr = '_IC12';
else
	hrfstr = '';
end

% Set the colormap
cmap = eval([cmap, '(', num2str(100), ')']);

% if cached values are passed in, use those. Otherwise, calculate from scratch
if (isempty(S))
	% get number of vertices in inflated DENSETRUNCpt
	numVerticesInflated = cvnreadsurface(sub,{'lh','rh'},'inflated','DENSETRUNCpt','justcount',true);
	numlh = numVerticesInflated(1);
	numrh = numVerticesInflated(2);

	% get ventral viewpoint
	viewpt = cvnlookupviewpoint(sub,{'rh','lh'},'ventral','inflated');

else
	dumpstruct(S);
end

% setup image params
metric = compute_glm_metric(betas,se,con1,[],viewmetric,2);
dataStruct = struct('data',metric,'numlh',numlh,'numrh',numrh);
thresh = metric > metric_min;
clim = [metric_min metric_max];

% draw image and create RGB
[img, L, rgbimg] = cvnlookupimages(sub,dataStruct,{'rh','lh'},viewpt,L,'xyextent',[1 1],'surftype','inflated','imageres',1000,'overlayalpha',thresh,'cmap',cmap,'clim',clim, 'background', 'curv');
if (isempty(S)) % first call to func
	S = fillstruct(numlh,numrh,viewpt);
end
end %end fx

function con = getCon(contrastName)
	contrastName = lower(contrastName);
	switch contrastName
		case 'characters'
			con = [1 2];
		case 'bodies'
			con = [3 4];
		case 'faces'
			con = [5 6];
		case 'places'
			con = [7 8];
		case 'objects'
			con = [9 10];
		case 'word'
			con = [1];
		case 'number'
			con = [2];
		case 'body'
			con = [3];
		case 'limb'
			con = [4];
		case 'adult'
			con = [5];
		case 'child'
			con = [6];
		case 'corridor'
			con = [7];
		case 'house'
			con = [8];
		case 'car'
			con = [9];
		case 'instrument'
			con = [10];
		otherwise
			error(sprintf('%s not recognized. Please choose from:\ncharacters\nbodies\nfaces\nplaces\nobjects\nword\nnumber\nbody\nlimb\nadult\nchild\ncorridor\nhouse\ncar\ninstrument',contrastName));
	end
end
