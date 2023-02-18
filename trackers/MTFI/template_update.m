function tracker = template_update(tracker, n_dict, n_particles)


tracker.updateCount = tracker.updateCount +1;
if tracker.updateCount > 3

    A_Max = tracker.W(1:n_dict,tracker.id_max:n_particles:end);
    a_Max = sum(A_Max,2);
    [~, indAmax] = max(a_Max);
    tracker.templateW = tracker.templateW .* exp(sum(A_Max,2));
    tracker.templateW = tracker.templateW /sum(tracker.templateW);

    [~, indAmin] = min(tracker.templateW(2:end));
    indAmin = indAmin + 1;
    min_angle = images_angle(tracker.target_y,tracker.Dt(:,indAmax));
    if( min_angle > 30 && min_angle < 70),
        tracker.Dt(:,indAmin) = tracker.Y(:,tracker.id_max);
        tracker.updateCount = 1;
    end
end