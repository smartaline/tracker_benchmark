function Display_func(tracker, display, index)

if display.figure
    imshow(tracker.img);
    [H,~] = size(tracker.img);
    if display.confident_particles 
        [~, indexp] = sort(tracker.eta, 'descend');
        confident_particles = tracker.particles(indexp(1:display.nConfident), :);
        confident_particles = aff2image(confident_particles, tracker.sz_T);
        drawBoundingBoxWrap(confident_particles, 'LineWidth', 2);
    end
    if display.outliers && ~isempty(tracker.outlier_index)
        particles_outlier = tracker.particles(tracker.outlier_index, :);
        particles_outlier = aff2image(particles_outlier, tracker.sz_T);
        drawBoundingBoxWrap(particles_outlier, 'LineWidth', 2, 'Color','g');
    end
    if display.target
        drawBoundingBoxWrap(tracker.tracker_res(index,:), 'LineWidth', 2, 'Color','r');
    end
    text(10,15,num2str(index),'FontSize',18,'Color','r');
    if display.textNotice    
        string = ['#' num2str(index) ', feature extraction time:' num2str(tracker.featureExtraction_time,2) ...
            ', optimization time:' num2str(tracker.optimization_time,2)];
         text(10,H-10,string,'color','white','backgroundcolor','k');
    end
    drawnow;

    
%     if savePara.save_figures
%         saveFigurePath = [savePara.save_dir 'figures/'];
%         if ~exist(saveFigurePath, 'dir')
%             mkdir(saveFigurePath)
%         end
%         imageSave = getframe;
%         imageSave = imageSave.cdata;
%         saveFigurePath = [saveFigurePath 'img_' num2str(index, '%04d'), '.jpg'];
%         imwrite(imageSave, saveFigurePath);
%     end
end

if display.textNotice
    string = ['#' num2str(index) ', feature extraction time:' num2str(tracker.featureExtraction_time,2) ...
    ', optimization time:' num2str(tracker.optimization_time,2)];
    disp(string);
    string = ['Number of Outliers:' num2str(length(tracker.outlier_index))];
    disp(string);
end
