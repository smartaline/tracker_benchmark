% Usage:    tracker = initialTracker(Options)
%
% Name: initialTracker
%
% Description:
% to initial the dictionary and the structure of the tracker 
%      
% Output: 
% Tracker.current_aff: the affine variables for the target in current
%                       estimation
% Tracker.Dt:          the target dictionary
% Tracker.Db:          the background dictionary
% Tracker.G_V:         the index for the feature groups
% Tracker.G_V_dims:    the dimension for each view
% Tracker.tracker_res: the tracking results (bounding boxes)
% Tracker.particles:   the partiles, each row is a single particle
% Tracker.Weight:      the weight of templates in the dictionary.
% Tracker.updateCount: the counter of dictionary update. it prohibits too
%                      frequent update
% Written by: Zhibin Hong, 2013

function tracker = initialTracker(Options)

tracker = intialDitionary(Options);

tracker.tracker_res = zeros(Options.source.nFrames,8);
tracker.tracker_result = zeros(Options.source.nFrames,6);
tracker.tracker_res(1,:) = aff2image(tracker.current_aff, Options.features.sz_T);
tracker.tracker_result(1,:) = tracker.current_aff;
tracker.particles = ones(Options.particleFilter.n_particles,1) * tracker.current_aff;
tracker.Weight = ones(Options.models.n_D,1);
tracker.updateCount = 11;



