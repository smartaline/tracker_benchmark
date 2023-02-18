function opt=paraConfig_MTFI(title)

rel_std_afnvs = {[0.005,0.0005,0.0005,0.005,4,4]};

alpha =30;

views = {'intensity','colorhis'};  %,'colorhis'
opt.particleFilter = struct('n_particles', 400, 'rel_std_afnv',rel_std_afnvs);

opt.features = struct('views', {views}, 'n_view',length(views), 'sz_T', [32 32]);

opt.models = struct('n_D', 20, 'lambda1', 0.01, 'lambda2', 0.01, 'alpha', alpha, 'tol', 1e-6, 'verbose', 0, 'adaptive_weight', 0);

opt.outlier_rejection = struct('outlierRejection', 1, 'threshold', 1, 'threshold_scale', 1.5, 'max_outlier', 8);

opt.display = struct('figure', 1, 'target', 1, 'outliers', 0, 'confident_particles',0, 'nConfident', 3, 'features', 0, 'textNotice',0);
