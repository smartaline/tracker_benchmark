function [gly_crop, gly_inrange] = Seg_gly_crop(img_frame, curr_samples, template_size)
%create gly_crop, gly_inrange

nsamples = size(curr_samples,1);
gly_crop = zeros(prod(template_size),nsamples);
gly_inrange = zeros(nsamples,1);

parfor n = 1:nsamples
   [gly_crop(:,n), gly_inrange(n)] = iExtractFeature(curr_samples(n, :), template_size, img_frame);
end


% for n = 1:nsamples
%    curr_afnv = curr_samples(n, :);
%    [img_cut, gly_inrange(n)] = IMGaffine_r(img_frame, curr_afnv, template_size);
%    img_cut = TanTriggsImPreprocess(img_cut);
%    gly_crop(:,n) = reshape(img_cut, prod(template_size), 1);
% end


gly_crop = gly_zmuv(gly_crop);	 % zero-mean-unit-variance
gly_crop = normalizeTemplates(gly_crop);

end



function [feature gly_inrange] = iExtractFeature(curr_afnv, template_size, img_frame)

[img_cut, gly_inrange] = IMGaffine_r(img_frame, curr_afnv, template_size);
img_cut = TanTriggsImPreprocess(img_cut);
feature = reshape(img_cut, prod(template_size), 1);
end
