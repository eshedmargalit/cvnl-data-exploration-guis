function main(optionStruct)
% INPUTS
% optionStruct, which contains:
%	subject - freesurfer subject ID
%	procsuffix - processing type, can be '', 'IC12', etc
%	experiment - name of experiment, e.g. 'floc'
%	datadir - where to find data
%	do_evenodd - boolean, set true to split data into even and odd runs
%	hemi - 'lh' or 'rh', but not both
%	viewmetric - when picking first point, what functional value should be shown?
%		'tstat','betadiff','poscon', etc
%	viewcat - which category is viewmetric based on?
%		'faces','bodies', etc
%	plotmetric - what should be plotted in the line profiles?
%		'beta','tstat', etc
%	line_length - 1x2 mat dictating how long line should be when drawn lateral <-> medial (first val) or posterior <-> anterior (second val)
%	line_spacing - 1x2 mat dictating how many pixels to move in each iteration ([LR,UD])
%	lrdirection - 'l2r' means go from left to right, 'r2l' means go from right to left
%	uddirection - same as lr but with 'u2d' and 'd2u' 
%	nSteps - 1x2 mat dictating how many steps to move in each direction
%	movementDirection - 1x2 cell mat with either 'd' or 'u' in cell1 and 'r' or 'l' in cell2 to dictate which way to sweep the lines

% Dump optionstruct into workspace
dumpstruct(optionStruct);

% Create the betaopts struct
betaopts = init_opts(subject,procsuffix,experiment,datadir,do_evenodd);

% Create the surface on which the initial line is drawn
[rgbimg,hmapfig,xypoints,L] = createRGBSurface(hemi, viewmetric, viewcat, betaopts);

% Have user define a single point to start at
gridIsGood = 0;
while (~gridIsGood)
	[x,y] = ginput(1);
	x = round(x);
	y = round(y);

	%% Preview lines-- ask for confirmation
	gridimg = previewLines(hemi,x,y,line_length,line_spacing,L,betaopts,rgbimg,lrdirection, uddirection, nSteps,movementDirection);
	%conf = input('Does this grid look correct? (yes/no)','s');
	conf = questdlg('Does this grid look correct?','Grid Confirmation','Yes','No','Yes');

	switch lower(conf)
		case 'yes'
			gridIsGood = 1;
		case 'y'
			gridIsGood = 1;
		case 'no'
		case 'n'
		otherwise
			error('Only ''yes'' and ''no'' are allowed');
	end
end %end while

%% Save grid image
% Where should figure be saved to?
figDir = sprintf('/home/stone/eshed/line_profiles/figs/%s',hemi);
mkdirquiet(figDir);
outname = sprintf('%s/grid.png',figDir);
imwrite(gridimg,outname);


%% Draw LR lines
LRLines(hemi,x,y,xypoints,line_length(1),line_spacing(1),lrdirection,plotmetric,L,betaopts,rgbimg,nSteps(1),movementDirection{1});

%% Draw UD lines
UDLines(hemi,x,y,xypoints,line_length(2),line_spacing(2),uddirection,plotmetric,L,betaopts,rgbimg,nSteps(2),movementDirection{2});

%% Export movies
createLineMovie(hemi,lrdirection,nSteps(1));
createLineMovie(hemi,uddirection,nSteps(2));
end 

function rgbimg = previewLines(hemi,x,y,line_length,line_spacing,L,betaopts,rgbimg,lrdirection, uddirection, nSteps,mDir)
	%% Set x1, x2, y1, y2
	switch(lrdirection)
		case 'l2r'
			x1 = x;
			x2 = x+line_length(1);
		case 'r2l'
			x1 = x-line_length(1);
			x2 = x;
		otherwise
			error('Please select either ''l2r'' or ''r2l'' as your lrdirection.');
	end

	switch(uddirection)
		case 'u2d'
			y1 = y;
			y2 = y+line_length(2);
		case 'd2u'
			y1 = y-line_length(2);
			y2 = y;
		otherwise
			error('Please select either ''u2d'' or ''d2u'' as your uddirection.');
	end

	% iterate through each line drawn, and overwrite those pixel values with white
	for i = 0:nSteps(1) %step line down or up

		switch(mDir{1})
			case 'd'
				y_tmp = y + (i * line_spacing(1));
			case 'u'
				y_tmp = y - (i * line_spacing(1));
			otherwise
				error('Choose ''u'' or ''d''');
		end

		xyline = int16([(x1:x2)' , repmat(y_tmp,[line_length(1)+1,1 ])]);
		rgbimg(xyline(:,2),xyline(:,1),:) = 255;
	end

	for i = 0:nSteps(2) %step line left or right
		switch(mDir{2})
			case 'l'
				x_tmp = x - (i * line_spacing(2));
			case 'r'
				x_tmp = x + (i * line_spacing(2));
			otherwise
				error('Choose ''u'' or ''d''');
		end

		xyline = int16([repmat(x_tmp,[line_length(2)+1,1]), (y1:y2)']);
		rgbimg(xyline(:,2),xyline(:,1),:) = 255;
	end
	
	imshow(rgbimg);

end

% Function to do grid of L<->R lines moving along posterior-anterior axis
function LRLines(hemi,x,y,xypoints,line_length,line_spacing,lrdirection,plotmetric,L,betaopts,rgbimg, nSteps,mDir)

	% Define start and end points of line depending on direction and line length
	switch(lrdirection)
		case 'l2r'
			x1 = x;
			x2 = x+line_length;
		case 'r2l'
			x1 = x-line_length;
			x2 = x;
		otherwise
			error('Please select either ''l2r'' or ''r2l'' as your lrdirection.');
	end

	% Given the length of the line, create the appropriate line
	xyline = int16([(x1:x2)' , repmat(y,[line_length+1,1 ])]);

	% Where should figure be saved to?
	figDir = sprintf('/home/stone/eshed/line_profiles/figs/%s/%s',hemi,lrdirection);
	mkdirquiet(figDir);

	% define xypoints as [x1 y1;x2 y2] (is this right?)
	xypoints = [x1 y;x2 y];

	% plot beta profiles and save the image!
	figline = plot_beta_profile_lines(hemi, xyline, xypoints, plotmetric, L, [], betaopts, lrdirection);
	outname = sprintf('%s/line_profile_iter0.png',figDir);
	imgprofile = export_fig(figline,'-a1');
	imwrite(imgprofile,outname);

	% plot the line we scanned (make one end green and the other red)
	tmp = rgbimg;
	tmp(xyline(:,2),xyline(:,1),:) = 255;
	if strcmp(lrdirection,'l2r')
		tmp(xyline(1:3,2),xyline(1:3,1),1) = 0; %R 
		tmp(xyline(1:3,2),xyline(1:3,1),2) = 255; %G
		tmp(xyline(1:3,2),xyline(1:3,1),3) = 0; %B

		tmp(xyline(end-3:end,2),xyline(end-3:end,1),1) = 255; %R 
		tmp(xyline(end-3:end,2),xyline(end-3:end,1),2) = 0; %G
		tmp(xyline(end-3:end,2),xyline(end-3:end,1),3) = 0; %B
	else
		tmp(xyline(1:3,2),xyline(1:3,1),1) = 255; %R 
		tmp(xyline(1:3,2),xyline(1:3,1),2) = 0; %G
		tmp(xyline(1:3,2),xyline(1:3,1),3) = 0; %B

		tmp(xyline(end-3:end,2),xyline(end-3:end,1),1) = 0; %R 
		tmp(xyline(end-3:end,2),xyline(end-3:end,1),2) = 255; %G
		tmp(xyline(end-3:end,2),xyline(end-3:end,1),3) = 0; %B
	end

	outname = sprintf('%s/surface_iter0.png',figDir);
	imwrite(tmp,outname);

	xyline_orig = xyline;

	for i=1:nSteps
		switch(mDir)
			case 'd'
				xyline(:,2) = xyline(:,2) + line_spacing; %y coord
			case 'u'
				xyline(:,2) = xyline(:,2) - line_spacing; %y coord
			otherwise
				error('Choose ''u'' or ''d''');
		end

		plot_beta_profile_lines__update(hemi, xyline, xypoints, L, figline,[], lrdirection);
		imgprofile = export_fig(figline,'-a1');
		outname = sprintf('%s/line_profile_iter%d.png',figDir,i);
		imwrite(imgprofile,outname);

		tmp = rgbimg;
		tmp(xyline(:,2),xyline(:,1),:) = 255;

		if strcmp(lrdirection,'l2r')
			tmp(xyline(1:3,2),xyline(1:3,1),1) = 0; %R 
			tmp(xyline(1:3,2),xyline(1:3,1),2) = 255; %G
			tmp(xyline(1:3,2),xyline(1:3,1),3) = 0; %B

			tmp(xyline(end-3:end,2),xyline(end-3:end,1),1) = 255; %R 
			tmp(xyline(end-3:end,2),xyline(end-3:end,1),2) = 0; %G
			tmp(xyline(end-3:end,2),xyline(end-3:end,1),3) = 0; %B
		else
			tmp(xyline(1:3,2),xyline(1:3,1),1) = 255; %R 
			tmp(xyline(1:3,2),xyline(1:3,1),2) = 0; %G
			tmp(xyline(1:3,2),xyline(1:3,1),3) = 0; %B

			tmp(xyline(end-3:end,2),xyline(end-3:end,1),1) = 0; %R 
			tmp(xyline(end-3:end,2),xyline(end-3:end,1),2) = 255; %G
			tmp(xyline(end-3:end,2),xyline(end-3:end,1),3) = 0; %B
		end
			
		outname = sprintf('%s/surface_iter%d.png',figDir,i);
		imwrite(tmp,outname);
	end
end

% Function to do grid of U<->D lines moving along medial-lateral axis
function UDLines(hemi,x,y,xypoints,line_length,line_spacing,uddirection,plotmetric,L,betaopts,rgbimg, nSteps, mDir)

	% Define start and end points of line depending on direction and line length
	switch(uddirection)
		case 'u2d'
			y1 = y;
			y2 = y+line_length;
		case 'd2u'
			y1 = y-line_length;
			y2 = y;
		otherwise
			error('Please select either ''u2d'' or ''d2u'' as your lrdirection.');
	end

	% Given the length of the line, create the appropriate line
	xyline = int16([repmat(x,[line_length+1,1]), (y1:y2)']);

	% Where should figure be saved to?
	figDir = sprintf('/home/stone/eshed/line_profiles/figs/%s/%s',hemi,uddirection);
	mkdirquiet(figDir);

	% define xypoints as [x1 y1;x2 y2] (is this right?)
	xypoints = [x y1;x y2];

	% plot beta profiles and save the image!
	figline = plot_beta_profile_lines(hemi, xyline, xypoints, plotmetric, L, [], betaopts, uddirection);
	outname = sprintf('%s/line_profile_iter0.png',figDir);
	imgprofile = export_fig(figline,'-a1');
	imwrite(imgprofile,outname);

	% plot the line we scanned (make one end green and the other red)
	tmp = rgbimg;
	tmp(xyline(:,2),xyline(:,1),:) = 255;

	if strcmp(uddirection,'u2d')
		tmp(xyline(1:3,2),xyline(1:3,1),1) = 0; %R 
		tmp(xyline(1:3,2),xyline(1:3,1),2) = 255; %G
		tmp(xyline(1:3,2),xyline(1:3,1),3) = 0; %B

		tmp(xyline(end-3:end,2),xyline(end-3:end,1),1) = 255; %R 
		tmp(xyline(end-3:end,2),xyline(end-3:end,1),2) = 0; %G
		tmp(xyline(end-3:end,2),xyline(end-3:end,1),3) = 0; %B
	else
		tmp(xyline(1:3,2),xyline(1:3,1),1) = 255; %R 
		tmp(xyline(1:3,2),xyline(1:3,1),2) = 0; %G
		tmp(xyline(1:3,2),xyline(1:3,1),3) = 0; %B

		tmp(xyline(end-3:end,2),xyline(end-3:end,1),1) = 0; %R 
		tmp(xyline(end-3:end,2),xyline(end-3:end,1),2) = 255; %G
		tmp(xyline(end-3:end,2),xyline(end-3:end,1),3) = 0; %B
	end
	outname = sprintf('%s/surface_iter0.png',figDir);
	imwrite(tmp,outname);

	xyline_orig = xyline;

	for i=1:nSteps
		switch(mDir)
			case 'r'
				xyline(:,1) = xyline(:,1) + line_spacing ; %x coord
			case 'l'
				xyline(:,1) = xyline(:,1) - line_spacing; %x coord
			otherwise
				error('Choose ''r'' or ''l''');
		end

		plot_beta_profile_lines__update(hemi, xyline, xypoints, L, figline, [], uddirection);
		imgprofile = export_fig(figline,'-a1');
		outname = sprintf('%s/line_profile_iter%d.png',figDir,i);
		imwrite(imgprofile,outname);


		tmp = rgbimg;
		tmp(xyline(:,2),xyline(:,1),:) = 255;
		if strcmp(uddirection,'u2d')
			tmp(xyline(1:3,2),xyline(1:3,1),1) = 0; %R 
			tmp(xyline(1:3,2),xyline(1:3,1),2) = 255; %G
			tmp(xyline(1:3,2),xyline(1:3,1),3) = 0; %B

			tmp(xyline(end-3:end,2),xyline(end-3:end,1),1) = 255; %R 
			tmp(xyline(end-3:end,2),xyline(end-3:end,1),2) = 0; %G
			tmp(xyline(end-3:end,2),xyline(end-3:end,1),3) = 0; %B
		else
			tmp(xyline(1:3,2),xyline(1:3,1),1) = 255; %R 
			tmp(xyline(1:3,2),xyline(1:3,1),2) = 0; %G
			tmp(xyline(1:3,2),xyline(1:3,1),3) = 0; %B

			tmp(xyline(end-3:end,2),xyline(end-3:end,1),1) = 0; %R 
			tmp(xyline(end-3:end,2),xyline(end-3:end,1),2) = 255; %G
			tmp(xyline(end-3:end,2),xyline(end-3:end,1),3) = 0; %B
		end
		outname = sprintf('%s/surface_iter%d.png',figDir,i);
		imwrite(tmp,outname);
	end
end
