function conditions = get_conditions(experiment)
	switch experiment
		case 'floc'
			conditions={'characters','bodyparts','faces','places','objects','word','number','body','limb','adult','child','corridor','house','car','instrument'};
		otherwise
			error('Experiment not recognized. Add it to the list!');
	end
end
