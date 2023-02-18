function [W, P, Q, iter,elapse,objHis] = MT_Group_sparcity_solver_v6(D, X, G_V, varargin)

[m, n] = size(X);
[m, r] = size(D);
nG = size(G_V,1);
% Default setting
norm_type = 'L1-2';
maxIter = 100;
P = rand(r,n * nG);
Q = rand(r,n * nG);
tol = 1e-4;
verbose = 0;
lambda1 = 1;
lambda2 = 1;
minIter = 10;
L = 2*norm(D*D');
% Read optional parameters
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i = 1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'NORM_TYPE',   norm_type = varargin{i+1};
            case 'LAMBDA1',     lambda1 = varargin{i+1};
            case 'LAMBDA2',     lambda2 = varargin{i+1};
            case 'MAX_ITER',    maxIter = varargin{i+1};
            case 'MIN_ITER',    minIter = varargin{i+1};
            case 'P_INIT',      P = varargin{i+1};
            case 'Q_INIT',      Q = varargin{i+1};
            case 'TOL',         tol = varargin{i+1};
            case 'VERBOSE',     verbose = varargin{i+1};
            case 'LIPSCHITZ',     L = varargin{i+1};
            otherwise
                error(['Unrecognized option: ',varargin{i}]);
        end
    end
end


% Iterative updating
elapse = cputime;

objHis = zeros(1000, 1);


DtD = cell(nG,1);
DtX = cell(nG,1);
D_g = cell(nG,1);
X_g = cell(nG,1);
obj = 0;
W = P+Q;
for g = 1:nG
    D_g{g} =  D(G_V(g,1):G_V(g,2), :);
    X_g{g} = X(G_V(g,1):G_V(g,2), :);
%     Dtemp = D(G_V(g,1):G_V(g,2), :);
%     Xtemp = X(G_V(g,1):G_V(g,2), :);
    Wtemp = W(:, (g - 1) * n + 1 : g * n);
    obj = obj + sum(sum((X_g{g} - D_g{g} * Wtemp).^2));
    DtD{g} = D_g{g}' * D_g{g};
    DtX{g} = D_g{g}' * X_g{g};
%     DtD = [DtD Dtemp' * Dtemp];
%     DtX = [DtX Dtemp' * Xtemp];
end
R = zeros(size(P));
S = R;
P_old = R;
Q_old = R;
% the objective function to be changed 
objHis(1) = 0.5 * obj + lambda1 * mixed_norm(P, norm_type) + lambda2 * mixed_norm(Q', norm_type);
theta = 1/L;
k = 0;
alpha_old = 1;
for iter = 1:maxIter
    % the gradient function to be changed
    dev_RS = zeros(size(R));
    W_RS = R + S;
    for g = 1:nG
%         DtDtemp = DtD(:, (g - 1) * r + 1 : g * r);
%         DtXtemp = DtX(:, (g - 1) * n + 1 : g * n);
        Wtemp = W_RS(:, (g - 1) * n + 1 : g * n);
        dev_RS(:, (g - 1) * n + 1 : g * n) = DtD{g} * Wtemp - DtX{g};
    end
    dev_RS = dev_RS * theta;
    U = R - dev_RS;
    V = S - dev_RS;
    eta1 = lambda1*theta;
    eta2 = lambda2*theta;
    P = subproblem_solver(U, eta1, norm_type);
    Q = subproblem_solver(V', eta2, norm_type);
    Q = Q';

    % the objective function to be changed 
    W = P + Q;
    obj = 0;
    for g = 1:nG
%         Dtemp = D(G_V(g,1):G_V(g,2), :);
%         Xtemp = X(G_V(g,1):G_V(g,2), :);
        Wtemp = W(:, (g - 1) * n + 1 : g * n);
        obj = obj + sum(sum((X_g{g} - D_g{g} * Wtemp).^2));
    end
    obj = 0.5 * obj + lambda1 * mixed_norm(P, norm_type) + lambda2 * mixed_norm(Q', norm_type);   
    objHis(iter+1) = obj;
    stop_cri = abs(objHis(iter+1)-objHis(iter))/abs(objHis(iter+1)-objHis(1));
    if rem(iter,100)==0 && verbose,
        fprintf('\titeration %d,\tobjective=%f,\tstopping criteria=%.3e.\n',iter,obj,stop_cri);
    end
    if stop_cri < tol && iter>=minIter,
        break;
    end
    alpha = 2/ (k+3);
    R = P + alpha * (1 / alpha_old - 1) * (P - P_old);
    S = Q + alpha * (1 / alpha_old - 1) * (Q - Q_old);
    alpha_old = alpha;
    P_old = P;
    Q_old = Q;
    k = k+1;

end
elapse = cputime-elapse;

if verbose,
	fprintf('\nFinal Iter = %d,\tFinal Elapse = %f.\n', iter,elapse);
end


%H = Z;

function W = subproblem_solver(U, eta, norm_type)
switch upper(norm_type),
        case 'L1-2',
            W = max(0,1-eta./(sqrt(sum(U.^2,2))*ones(1,size(U,2))+1e-10)).*U;             
        case 'L1-INF',
            W = zeros(size(U));
            for i = 1:size(U,1),
                W(i,:) = U(i,:) - projL1(U(i,:)',eta)';
            end
        case 'L1',
            W = max(0,abs(U)-eta);
            W(U<0) = -W(U<0);
        otherwise,
            error('No such type of group norm.\n');
end

    