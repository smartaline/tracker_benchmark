function [outlier_index outlier_rejection]= Outlier_rejection(tracker, outlier_rejection, n_particles, n_view)
outlier_index = [];
if outlier_rejection.outlierRejection
    Q = tracker.Q;
    Q = sum(abs(Q));
    Q = reshape(Q,n_particles,n_view);
    Q = sum(Q,2);
    while(1)
        outlier_index = find(Q > outlier_rejection.threshold);
        if length(outlier_index) > outlier_rejection.max_outlier;
            outlier_rejection.threshold = outlier_rejection.threshold * outlier_rejection.threshold_scale;
        elseif isempty(outlier_index)
            outlier_rejection.threshold = outlier_rejection.threshold / outlier_rejection.threshold_scale;
            break;
        else
            break;
        end
    end
end
