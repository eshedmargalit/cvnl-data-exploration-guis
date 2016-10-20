--10/18/2016
First version done. Future changes:
	-> Instead of loading map, pre-save maps for metrics for each layer in a separate spot. When running the GUI, load the map for the given layerfor each HRF (IC1, IC2, Optimized). That is, load 3 maps at once. GUI should allow user to cycle between those maps and to change metric display threshold.
	-> Add option to choose colormap from GUI
	-> Allow user to draw polygon on pixels and extract betas (mean +/- SEM). Display betas in separate window as bar chart. Pixel boundary should be consistent across all layers, so that when user switches layers, the beta chart updates.
	-> Comment, rename, and integrate with cvnlab github

--10/20/2016
Features added:
	-> Any metric can now be used
	-> Any colormap can now be used
	-> ROIs can be drawn and cleared using roipoly()
	-> ROIs can be analyzed (in terms of mean beta across ROI), which involved new GUI roi_bar_gui
To do:
	-> Clean up excess code and push to github
