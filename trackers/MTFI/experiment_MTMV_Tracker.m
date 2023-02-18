function source = experiment_MTMV_Tracker(sequenceName, rel_std_afnv, alpha, save_dir, source)


% views = {'colorhis', 'intensity','HOG','LBP'};
views = {'intensity'};
Options.particleFilter = struct('n_particles', 400, 'rel_std_afnv',rel_std_afnv);

Options.features = struct('views', {views}, 'n_view',length(views), 'sz_T', [15 15]);

Options.models = struct('n_D', 10, 'lambda1', 0.01, 'lambda2', 0.01, 'alpha', alpha, 'tol', 1e-6, 'verbose', 0, 'adaptive_weight', 0);

Options.outlier_rejection = struct('outlierRejection', 1, 'threshold', 1, 'threshold_scale', 1.5, 'max_outlier',5);

Options.display = struct('figure', 1, 'target', 1, 'outliers', 0, 'confident_particles',0, 'nConfident', 3, 'features', 0, 'textNotice',0);

Options.source = struct('sequenceName', sequenceName, 'data_dir', '../Dataset/', 'image', 0, 'frames', [], 'nFrames', 0);

Options.save = struct('save_dir', save_dir, 'save_figures', 1, 'save_result', 1,'save_feature', 1);

if isempty(source)
    Options.source  = inital_source(Options.source);
else
    Options.source = source;
end

Options.features.sz_T = adjustTemplate(Options.features.sz_T, Options.source.init_pos);


MTMV_Tracker(Options);

source = Options.source;