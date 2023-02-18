function  C = MTL_APG(X, B, opt)

% Parameters:
% B: (d,(m+d)), B stores target templates and trival templates as columns 
% X: (d,n), X stores observations, each columns is a partical observation
% opt: structure to store the parameters, which include
%   --- opt.lambda: strngth of regularization term
%   --- opt.eta: gradient descent step size
%   --- opt.ite_num: prefixed total number of iterations

lambda = opt.lambda;
eta = opt.eta;
ite_num = opt.iter_maxi;

[m, n] = size(X);
[m, r] = size(B);
C_APG_prev = zeros(r,n);
H = zeros(r,n);
V_APG = zeros(r,n);
C_APG_cur = zeros(r,n);
for(k=1:ite_num)
   %Gradient Mapping
    H = V_APG-2*eta*(B'*B*V_APG-B'*X);
    S = norm(H);
	if (1-lambda*eta/S)> 0
		C_APG_cur = (1-lambda*eta/S)*H;
    else
		C_APG_cur = 0;
	end
    
   %Aggregation
    alpha_prev = 2/(k+1);
    alpha_cur = 2/(k+2);
    V_APG = C_APG_cur + (1-alpha_prev)*alpha_cur/alpha_prev*(C_APG_cur-C_APG_prev);
    
    C_APG_prev = C_APG_cur;   
end
C = C_APG_prev;
end

