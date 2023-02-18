function [Yt Err] = MTMV_reconstuction(tracker, n_view, n_dict, n_particles, adaptive_weight)
Y = tracker.Y;
C = tracker.S;
Yt = zeros(size(Y));
G_V = tracker.G_V;
Dt = tracker.Dt;
for i = 1: n_view
    Yt(G_V(i,1):G_V(i,2),:) = Dt(G_V(i,1) : G_V(i,2),:) * C(1:n_dict,(i-1)*n_particles+1:i*n_particles);
end

tracker.Yt = Yt;

view_weights = ones(n_view, 1);
view_errs = zeros(n_view, n_particles);
if adaptive_weight
    alpha = 30;
    for i = 1: n_view
        Yt(G_V(i,1):G_V(i,2),:) = Dt(G_V(i,1) : G_V(i,2),:) * C(1:n_dict,(i-1)*n_particles+1:i*n_particles);
        Err = sqrt(sum((Y(G_V(i,1):G_V(i,2),:)-Yt(G_V(i,1):G_V(i,2),:)).^2));
        eta = exp(-alpha*Err);
        eta = eta / sum(eta);
        view_weights(i) =  -sum(eta .* log(eta));
        temp = Err * view_weights(i);
        view_errs(i,:) = temp;
    end
    Err = sum(view_errs);
else
    Err = sum((Y-Yt).^2);
end

