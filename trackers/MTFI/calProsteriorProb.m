function [y, eta, id_max] = calProsteriorProb(Et, Y, alpha, outlier_index)
eta = exp(-alpha*Et);
eta(outlier_index) = 0;
[~, id_max] = max(eta);
y = Y(:, id_max);
