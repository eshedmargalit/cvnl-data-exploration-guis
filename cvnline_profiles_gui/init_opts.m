function betaopts = init_opts(subject, procsuffix, experiment, datadir, do_evenodd)

% Based on the experiment, set the category names and category numbers
switch experiment
    case 'floc'
        categorynames = {'characters','bodyparts','faces','places','objects'};
        subcategorynames = {'word','number','body','limb','adult','child','corridor','house','car','instrument'};
        categories = {[1 2],[3 4],[5 6],[7 8],[9 10]};
    case 'floc-10cat'
        do_10cat = true;
        categorynames = {'word','number','body','limb','adult','child','corridor','house','car','instrument'};
        categories = num2cell(1:10);
    case 'categoryC11';
         categorynames = {'R30','R60','R90','R120','L30','L60','L90','L120','F0','B180'};
         categories = num2cell(1:10);
         contrastnames = {'faces'};
         contrasts={ {[1 2 5 6 9],[3 4 7 8 10]} };
    otherwise
end

% Count how many categories we have in total
numcategories = numel(categorynames);

%% Viewpoint related settings
% Which hemispheres should we look up?
hemis = {'lh','rh'};

% What kind of surface are we using? Probably DENSETRUNCpt (dense, truncated, posterotemporal)
surfsuffix = 'DENSETRUNCpt';

% Get the viewpoint (azimuth, elevation, tilt) for the surface we want
%viewpt = cvnlookupviewpoint(subject, hemis, 'ventral','inflated');
viewpt = {[-210 -90 -90],[-150 -90 -90]};

% Count number of vertices in left and right hemispheres
[numlh, numrh] = cvnreadsurface(subject, hemis, 'inflated', surfsuffix, 'justcount',true);

% Construct cvn-like struct for later use (?)
valstruct = struct('data',[],'numlh',numlh,'numrh',numrh);

%% Pre-loading directory settings
% Where are the GLM results?
resultdir = sprintf('%s/glmdenoise_results', datadir);

% Which directory should be used for decomposition (?)
veindir = datadir;

% Where is bias-corrected/homogenized mean EPI?
meanhom = load(sprintf('%s/preprocessSURF/meanbiascorrected04.mat',veindir));

% Shuffle dimensions around so TR is first (?)
meanhom = permute(meanhom.data,[3 1 2]);

%% Load Data
% Prep empty cell arrays
layers = 1:6;
R2 = {};
modelmd = {};
modelse = {};
modelmd_even = {};
modelmd_odd = {};
modelse_even = {};
modelse_odd = {};
meanvol = {};

% Each layer is processed separately
for i = 1:numel(layers)
    % Grab string for given layer's glm results
    resultfile = sprintf('%s/glmdenoise_results%s_layer%d.mat',resultdir,procsuffix,layers(i));

    % load glm results in matfile for low-cost reads
    M = matfile(resultfile);

    % pull R2, median, standard error from model, also get mean EPI
    R2{i} = M.R2;
    md = M.modelmd;
    se = M.modelse;
    meanvol{i} = M.meanvol;

    % if md and se are cells, grab the second argument (first is HRF)
    if(iscell(md))
        modelmd{i} = md{2};
        modelse{i} = se{2};
    else
        %how to handle FIR?
        modelmd{i} = permute(md,[1 2 4 3]);
        modelse{i} = permute(se,[1 2 4 3]);
    end
    
    % deal specifically with even/odd case
    resultfile_even = sprintf('%s/glmdenoise_results%s_runEven_layer%d.mat',resultdir,procsuffix,layers(i));
    
    if(do_evenodd && exist(resultfile_even,'file'))
        resultfile = resultfile_even;
        M = matfile(resultfile);
        md = M.modelmd;
        se = M.modelse;
        if(iscell(md))
            modelmd_even{i} = md{2};
            modelse_even{i} = se{2};
        else
            %how to handle FIR?
            modelmd_even{i} = permute(md,[1 2 4 3]);
            modelse_even{i} = permute(se,[1 2 4 3]);
        end

        resultfile = sprintf('%s/glmdenoise_results%s_runOdd_layer%d.mat',resultdir,procsuffix,layers(i));
        M = matfile(resultfile);
        md = M.modelmd;
        se = M.modelse;
        if(iscell(md))
            modelmd_odd{i} = md{2};
            modelse_odd{i} = se{2};
        else
            %how to handle FIR?
            modelmd_odd{i} = permute(md,[1 2 4 3]);
            modelse_odd{i} = permute(se,[1 2 4 3]);
        end
    else
        do_evenodd = false;
    end
end

%% Concatenate GLM estimates from each layer along third dimension (which is what?)
layerR2 = cat(3,R2{:});
layerbeta = cat(3,modelmd{:});
layerse = cat(3,modelse{:});

layerbeta_even = [];
layerse_even = [];
layerbeta_odd = [];
layerse_odd = [];

if(do_evenodd)
    layerbeta_odd = cat(3,modelmd_odd{:});
    layerse_odd = cat(3,modelse_odd{:});
    layerbeta_even = cat(3,modelmd_even{:});
    layerse_even = cat(3,modelse_even{:});
end

meanepi = cat(3,meanvol{:});
layeric=[];

% Clear up memory
clear modelmd modelse modelmd_even modelmd_odd modelse_even modelse_odd 

%% Pull ICA fits for each layer

modelic={};
for i = 1:numel(layers)
    % Grab filename
    icfile = sprintf('%s/icafit_results_FIR_layer%d.mat',resultdir,layers(i));
    if(~exist(icfile,'file'))
        break;
    end

    % Read in file
    I = matfile(icfile);

    % Get the model data for that layer
    modelic{i} = I.modeldata(:,:,1:5);
end

% Get the HRF independent components (what is this?)
hrfic = I.hrf;
layeric = permute(cat(4,modelic{:}),[1 2 4 3]);

clear modelic;

%% Populate beta_opts
% Set TR and error to be graphed (se = standard error)
tdim = 2;
errormode = 'se';

% Set line colors
catcolors = get(0,'defaultaxescolororder');

% Which layer is the reference for Euclidean distance between vertices?
reflayer = 6;

% Set background data (vertical bars) Options are usually meanepi and meanhom 
bgdata=meanhom;

% Set plot title and ylimit if necessary
plottitle='';
ylimit=[];

% Finally, populate betaopts structure
betaopts=fillstruct(subject, numlh, numrh, layerbeta, layerse, meanepi, tdim, ...
   layerbeta_even, layerse_even, layerbeta_odd, layerse_odd, ...
   categorynames,categories,bgdata,errormode,surfsuffix,catcolors,reflayer,...
   plottitle,ylimit,layeric, viewpt);
end %end fx
