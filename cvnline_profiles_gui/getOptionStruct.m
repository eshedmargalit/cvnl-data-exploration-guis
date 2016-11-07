function optionStruct = getOptionsStruct()
	% modify these settings to change the optionStruct (someday this struct could be generated elsewhere)
	optionStruct = struct();
	optionStruct.subject = 'C0041';
	optionStruct.procsuffix = '';
	optionStruct.experiment = 'floc';
	optionStruct.datadir = sprintf('%s/20160212-ST001-E002', cvnpath('fmridata'));
	optionStruct.do_evenodd = false;
	optionStruct.hemi = 'lh';
	optionStruct.viewmetric = 'tstat';
	optionStruct.viewcat = 'faces';
	optionStruct.plotmetric = 'beta';
	optionStruct.line_length = [180 400];
	optionStruct.line_spacing = [1 1];
	optionStruct.lrdirection = 'l2r';
	optionStruct.uddirection = 'u2d';
	optionStruct.nSteps = [400 180];
	optionStruct.movementDirection = {'d','r'};
end
