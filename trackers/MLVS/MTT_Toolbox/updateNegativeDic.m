function [X_neg] = updateNegativeDic(dataPath, sz, opt, param, num_n, forMat, p0, f )
% function [X_neg] = updateDic(dataPath, sz, opt, param, num_n, forMat )
% update the negative templates in the template
% input --- 
% dataPath（输入图片的路径）: the path for the input images
% sz（跟踪窗口的大小）: the size of the tracking window
% opt（初始化的参数）: initial parameters
% param（仿射参数）: the affine parameters
% num_n（负样本的个数）: the number for the negative templates
% forMat（输入视频图片的格式）: the format of the input images in one video, for example '.jpg' '.bmp'.
% p0(第一帧的长宽比): aspect ratio in the first frame
% f（帧索引）: the frame index

% output ---
% X_neg: the negative tempaltes in the template for the next frame

img_color = imread([dataPath int2str(f) forMat]);
if size(img_color,3)==3
    img	= double(rgb2gray(img_color));
else
    img	= double(img_color);
end

%%----------------- update negative samples in the template----------------更新模板中的负样本
n = num_n;    % Sampling Number
param.param0 = zeros(6,n);      % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
sigma = [round(sz(2)*param.est(3)), round(sz(1)*param.est(3)*p0), .000, .000, .000, .000];
param.param = param.param0 + randMatrix.*repmat(sigma(:),[1,n]);

back = round(sigma(1)/5);
center = param.param0(1,1);
left = center - back;
right = center + back;
nono = param.param(1,:)<=right&param.param(1,:)>=center;
param.param(1,nono) = right;
nono = param.param(1,:)>=left&param.param(1,:)<center;
param.param(1,nono) = left;

back = round(sigma(2)/5);
center = param.param0(2,1);
top = center - back;
bottom = center + back;
nono = param.param(2,:)<=bottom&param.param(2,:)>=center;
param.param(2,nono) = bottom;
nono = param.param(2,:)>=top&param.param(2,:)<center;
param.param(2,nono) = top;

o = affparam2mat(param.param);     % Extract or Warp Samples which are related to above affine parameters
wimgs = warpimg(img, o, sz);

m = prod(opt.tmplsize);
X_neg = zeros(m, n);
for i = 1: n
    X_neg(:,i) = reshape(wimgs(:,:,i), m, 1);
end


end

