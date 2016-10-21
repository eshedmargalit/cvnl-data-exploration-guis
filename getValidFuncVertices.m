function valid = getValidFuncVertices(betas,se,metricname,contrast,thresh)

	con1 = getCon(lower(contrast));
	metric = compute_glm_metric(betas,se,con1,[],metricname,2);
	valid = metric > thresh;
	
end

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
