function results = run_MTFI(seq, res_path, bSaveImage)

close all;

s_frames = seq.s_frames;
source = [];
para=paraConfig_MTFI(seq.name);
para.source = struct('sequenceName',seq.name, 'data_dir','d:\data_seq\', 'image', 0, 'frames', [], 'nFrames', 0);
para.save = struct('save_dir', 'E:\tracker_benchmark_fenkuaiPQ\tracker_benchmark_v1.0\tmp\imgs\', 'save_figures', 1, 'save_resullt', 1, 'save_feature', 1);

if isempty(source)
    para.source  = inital_source(para.source);
else
    para.source = source;
end

% some initialization
tracker = initialTracker(para);
nFrames = length(seq.s_frames);
n_particles = para.particleFilter.n_particles;
n_view = para.features.n_view;
n_dict = para.models.n_D;
tracker.templateW = ones(n_dict,1);
alpha = para.models.alpha;
tracker.sz_T =  para.features.sz_T;

% psize = tracker.sz_T;
% patch_size = 16;
% step_size = 16;
% [patch_idx, patch_num] = img2patch(psize, patch_size, step_size); 

%fenluai

tracker.Dict = tracker.Dt;
%  TemplateDict = normalizeMat(tracker.Dt(1:1024,:));
%  tracker.patch_Dt = TemplateDict(patch_idx,:);
%  tracker.Dict(1:1024,:) = tracker.patch_Dt;
 tracker.Dict = normalizeMat(tracker.Dict);
duration = 0;

for t = 2:nFrames
    frame = imread(s_frames{t});
    % draw transformation samples from a Gaussian distribution
    tracker.particles = Seg_draw_sample(tracker.particles,... 
    para.particleFilter.rel_std_afnv,tracker.current_aff); 

    % get current image from source
    tracker.img = getImg(para.source,t);
    tic;
    tracker.Y = OMG_extractFeatures(frame,tracker.particles,para.features, tracker.G_V);
    tracker.featureExtraction_time = toc;
    tic;
    
    tracker.YY = tracker.Y;
%     candidates = tracker.YY(1:1024,:);
%     particles_patches =  candidates(patch_idx,:);
%     tracker.candi_patch_data = normalizeMat(particles_patches);
%     tracker.YY(1:1024,:) = tracker.candi_patch_data;
     tracker.YY= normalizeMat(tracker.Y);    %跑两个特征时需去掉 
    [tracker.W, tracker.P, tracker.Q, tracker.iter,tracker.elapse,tracker.objHis] = MT_Group_sparcity_solver_v6( tracker.Dict, tracker.YY, tracker.G_V);
    tracker.optimization_time = toc;
    
    [tracker.outlier_index para.outlier_rejection]= Outlier_rejection(tracker, para.outlier_rejection, n_particles, n_view);

    [tracker.Yt tracker.Err] = MTMV_reconstuction(tracker, n_view, n_dict, n_particles, para.models.adaptive_weight);

    [tracker.target_y tracker.eta, tracker.id_max] = calProsteriorProb(tracker.Err, tracker.Y, alpha, tracker.outlier_index);

    tracker = template_update(tracker, n_dict, n_particles);
    
    duration = duration + toc;
    
    tracker.Dict = tracker.Dt;
%     TemplateDict = normalizeMat(tracker.Dt(1:1024,:));
%     tracker.patch_Dt = TemplateDict(patch_idx,:);
%     tracker.Dict(1:1024,:) = tracker.patch_Dt;
    tracker.Dict = normalizeMat(tracker.Dict);
    
    tracker.current_aff = tracker.particles(tracker.id_max,:);
    
    tracker.tracker_res(t,:) = aff2image(tracker.current_aff, tracker.sz_T);
    
   x1=tracker.tracker_res(t,2);
   x2=tracker.tracker_res(t,8);
   x3=tracker.tracker_res(t,6);
   x4=tracker.tracker_res(t,4);
   y1=tracker.tracker_res(t,1);
   y2=tracker.tracker_res(t,7);
   y3=tracker.tracker_res(t,5);
   y4=tracker.tracker_res(t,3);
   tracker.tracker_result(2*t-1,:)=[x1,x2,x3,x4];
   tracker.tracker_result(2*t,:)=[y1,y2,y3,y4];
    
%     tracker.tracker_result(t,:) = tracker.current_aff;

    Display_func(tracker, para.display,t);
   
    
   [tracker.particles, ~] = Seg_resample(tracker.particles, tracker.eta, tracker.current_aff);
    
end
%    saveResult(tracker.tracker_res, para.save.save_dir, para.source.sequenceName);
 

results.type = '4corner';
results.res = tracker.tracker_result;
results.fps = (nFrames-1)/duration;
results.tmplsize = tracker.sz_T;%[height, width]
disp(['fps:' num2str(results.fps)])
% results.fps=length(run_time)/sum(run_time);
