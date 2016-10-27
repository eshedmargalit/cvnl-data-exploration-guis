function [betas, se] = init_fields(resultsdir,hrfstr,regressor_range,layer)

	a1 = matfile(sprintf([resultsdir '/glmdenoise_results%s_layer%s.mat'],hrfstr,layer));
	md = a1.modelmd;
	se = a1.modelse;

	betas = md{2}; %V x 10
	se = se{2};
	
	betas = betas(:,regressor_range);
	se = se(:,regressor_range);
end
