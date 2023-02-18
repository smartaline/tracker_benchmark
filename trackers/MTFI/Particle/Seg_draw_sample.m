function [outs] = Seg_draw_sample(mean_afnv, real_std_afnv, current_aff)
%
%   Usage:    particles = Seg_draw_sample(mean_afnv, real_std_afnv, current_aff)
%  
%   Name:  Seg_draw_sample
%  
%   Description: Initialize the afnv samples using normal prior distribution
%      
%   Output:  
%        outs: output particles
sc			= sqrt(sum(current_aff(1:4).^2)/2);
std_afnv		= real_std_afnv .*[1, sc, sc, 1, sc, sc];


nsamples = size(mean_afnv, 1);
MV_LEN = 6;
mean_afnv(:, 1) = log(mean_afnv(:, 1));
mean_afnv(:, 4) = log(mean_afnv(:, 4));

outs = zeros([nsamples, MV_LEN]); 

outs(:,1:MV_LEN) = randn([nsamples, MV_LEN])*diag(std_afnv) ...
    + mean_afnv;

outs(:,1) = exp(outs(:,1));
outs(:,4) = exp(outs(:,4));