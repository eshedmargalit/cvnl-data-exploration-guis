function [con1,con2] = getCon1Con2(experiment,inputStr)
% INPUTS
%	inputStr like 'faces_placesVSall', or 'R30_R60VSL30_L60'
%	experiment like 'floc'

strparts = strsplit(inputStr,'VS');
con1str = strparts{1};
con2str = strparts{2};

con1strs = strsplit(con1str,'_');
con2strs = strsplit(con2str,'_');

con1 = [];
con2 = [];

for i =1:numel(con1strs)
	con1 = [con1 getCon(experiment,con1strs{i})];
end

for i =1:numel(con2strs)
	con2 = [con2 getCon(experiment,con2strs{i})];
end

% get rid of duplicates in con2
con1 = unique(con1);
con2 = unique(con2);
con2 = setdiff(con2,con1);

end

function con = getCon(experiment, contrastName)
	contrastName = lower(contrastName);

	switch experiment
		case 'floc'
			if (strcmp(contrastName,'all'))
				con = 1:10;
				return;
			end

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
		case 'C11'
			if (strcmp(contrastName,'all'))
				con = 1:10;
				return;
			end

			switch contrastName
				case 'right'
					con = [1 2 3 4];
				case 'left'
					con = [5 6 7 8];
				case 'r30'
					con = [1];
				case 'r60'
					con = [2];
				case 'r90'
					con = [3];
				case 'r120'
					con = [4];
				case 'l30'
					con = [5];
				case 'l60'
					con = [6];
				case 'l90'
					con = [7];
				case 'l120'
					con = [8];
				case 'front'
					con = [9];
				case 'back'
					con = [10];
				otherwise
					error(sprintf('%s not recognized. Please choose from:\nright\nleft\nr30\nr60\nr90\nr120\nl30\nl60\nl90\nl120\nfront\nback\n',contrastName));
			end
		otherwise
	end	

end
