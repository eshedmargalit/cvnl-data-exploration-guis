function cmap = blackhotcool(n)
	cmap = GenerateColormap([0, 0.5, 1],[0 0 1; 0 0 0; 1 0 0], n);
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
