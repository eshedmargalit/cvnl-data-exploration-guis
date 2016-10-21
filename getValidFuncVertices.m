function valid = getValidFuncVertices(betas,se,metricname,con1,con2,thresh)

	metric = compute_glm_metric(betas,se,con1,con2,metricname,2);
	valid = metric > thresh;
	
end
