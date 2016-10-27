function createLineMovie(hemi,direction,nSteps)
	fps = [1 3 10];

	d = sprintf('/home/stone/generic/Dropbox/cvnlab/inout/floc_eshed/%s/%s/movies', hemi, direction);
	mkdirquiet(d);
	for rate = 1:length(fps)
		frameRate = fps(rate);

		writerObj_lprof = VideoWriter(sprintf('%s/lineprof_%dfps.avi', d, frameRate));
		writerObj_surf = VideoWriter(sprintf('%s/surfline_%dfps.avi', d, frameRate));

		writerObj_lprof.FrameRate = frameRate;
		writerObj_surf.FrameRate = frameRate;

		open(writerObj_lprof);
		open(writerObj_surf);

		for i = 0:nSteps
			imstr_line = sprintf('figs/%s/%s/line_profile_iter%d.png',hemi, direction, i);
			frame_line = imread(imstr_line);
			frame_line = imresize(frame_line,[945 509]);
			writeVideo(writerObj_lprof,frame_line);

			imstr_surf = sprintf('figs/%s/%s/surface_iter%d.png',hemi, direction, i);
			frame_surf = imread(imstr_surf);
			writeVideo(writerObj_surf,frame_surf);
		end

		close(writerObj_lprof);
		close(writerObj_surf);
	end
end
