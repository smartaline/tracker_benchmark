% Usage:    tracker_res = MTMV_Tracker(Options)
%
% Name: MTMV_Tracker
%
% Description:
% This is the main funciton to run the MTMV tracker   
%      
% Output: 
% tracker_res:  tracking result contains coordinates of the corner
% points.the k th row is the result for the k th frame. each row is 
% [y1, x1, y2, x2, y3, x3, y4, x4];
%     (x1, y1)--------(x4, y4)
%         \               \
%          \               \
%         (x2, y2)--------(x3, y3)
% Notes :
% Written by: Zhibin Hong, 2013

function tracker_res = MTMV_Tracker(Options)
close all;
% some initialization
tracker = initialTracker(Options);
nFrames = Options.source.nFrames;
n_particles = Options.particleFilter.n_particles;
n_view = Options.features.n_view;
tracker.templateW = ones(10,1);
n_dict = Options.models.n_D;
alpha = Options.models.alpha;
tracker.sz_T =  Options.features.sz_T;
L=10;

for t = 2:nFrames

    % draw transformation samples from a Gaussian distribution
    tracker.particles = Seg_draw_sample(tracker.particles,... 
    Options.particleFilter.rel_std_afnv,tracker.current_aff); 

    % get current image from source
    tracker.img = getImg(Options.source,t);
    tic;
    tracker.Y = OMG_extractFeatures(tracker.img,tracker.particles,Options.features, tracker.G_V);
    tracker.featureExtraction_time = toc;
    tic;
    
    candidates = tracker.Y;
    %·Ö×é
    groupL = reshape(1:size(candidates,2),n_particles/L,L);
    tracker.S = zeros(size([tracker.Dt tracker.Db],2),size(candidates,2));
    tracker.Q = zeros(size([tracker.Dt tracker.Db],2),size(candidates,2));
    for l=1:L 
    tracker.candidatesL = candidates(:,groupL(:,l));

    [tracker.W, tracker.P, tracker.Q, tracker.iter,tracker.elapse,tracker.objHis] = MT_Group_sparcity_solver_v6( [tracker.Dt tracker.Db], tracker.candidatesL, tracker.G_V);
    tracker.optimization_time = toc;
    
    tracker.S(:,groupL(:,l)) = tracker.W;
    tracker.Q(:,groupL(:,l)) = tracker.Q;
    l = l+1;
    end
    [tracker.outlier_index Options.outlier_rejection]= Outlier_rejection(tracker, Options.outlier_rejection, n_particles, n_view);

    [tracker.Yt tracker.Err] = MTMV_reconstuction(tracker, n_view, n_dict, n_particles, Options.models.adaptive_weight);

    [tracker.target_y tracker.eta, tracker.id_max] = calProsteriorProb(tracker.Err, tracker.Y, alpha, tracker.outlier_index);

    tracker = template_update(tracker, n_dict, n_particles);
    
    tracker.current_aff = tracker.particles(tracker.id_max,:);
    
    tracker.tracker_res(t,:) = aff2image(tracker.current_aff, tracker.sz_T);
    
    Display_func(tracker, Options.display,Options.save,t);
    
    [tracker.particles, ~] = Seg_resample(tracker.particles, tracker.eta, tracker.current_aff);
    
end

if Options.save.save_result
    if ~exist(Options.save.save_dir, 'dir')
        mkdir(Options.save.save_dir)
    end
    saveResult(tracker.tracker_res, Options.save.save_dir, Options.source.sequenceName);
end

tracker_res = tracker.tracker_res;
