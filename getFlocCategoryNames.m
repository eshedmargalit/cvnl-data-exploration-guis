function names = getFlocCategoryNames(subset)
	switch subset
		case 'all'
			names = {'word','number','body','limb','adult','child','corridor','house','car','instrument'};
		case 'collapsed'
			names = {'characters','bodies','faces','places','objects'};
	end
end
