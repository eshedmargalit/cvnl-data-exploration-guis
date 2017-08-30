function cmap = coolhot(n)
	cyan =   [145 218 255]./255;
	blue =   [  0   0 255]./255;
	red =    [255   0   0]./255;
	yellow = [255 246 153]./255;
	black =  [  0   0   0]./255;

	cmap = GenerateColormap([0, 0.25, 0.5, 0.75, 1],...
		[cyan; blue; black; red; yellow], n);
end

function cmap = GenerateColormap(p, colors, n)
	if(nargin < 3)
	    n = 100;
	end

	if(isempty(p))
		p = linspace(0,1,size(colors,1));
	end

	p = p/max(p);

	cmap = [interp1(p,colors(:,1),linspace(0,1,n));
		interp1(p,colors(:,2),linspace(0,1,n));
		interp1(p,colors(:,3),linspace(0,1,n))]';
end
