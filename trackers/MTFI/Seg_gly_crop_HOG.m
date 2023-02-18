function gly_crop = Seg_gly_crop_HOG(img_frame, curr_samples, template_size, varargin)
%create gly_crop, gly_inrange

nsamples = size(curr_samples,1);
% gly_inrange = zeros(nsamples,1);
if ~isempty(varargin)
    dim = varargin{1};
    gly_crop_his = zeros(dim,nsamples);
else
    dim = 1;
end
% 
% for n = 1:nsamples
%    %if mod(n,50)==0 fprintf('-'); end
%    curr_afnv = curr_samples(n, :);
%    [img_cut, gly_inrange] = IMGaffine_r(img_frame, curr_afnv, template_size);
%    if gly_inrange
% %         img_cut = double(TanTriggsImPreprocess(img_cut));
%         gly_crop_his(:,n) = HoG(img_cut,Params);
%    else
%         gly_crop_his(:,n) = 1;
%    end
% end


parfor n = 1:nsamples
    [gly_crop_his(:,n) gly_inrange] = iExtractFeature(curr_samples(n, :), template_size, img_frame, dim);
end

%gly_crop = gly_zmuv(gly_crop_his);	 % zero-mean-unit-variance
gly_crop = normalizeTemplates(gly_crop_his);

end

function [feature gly_inrange] = iExtractFeature(curr_afnv, template_size, img_frame, dim)
Params = [9 10 1 0 0.2];
[img_cut, gly_inrange] = IMGaffine_r(img_frame, curr_afnv, template_size);
if gly_inrange
    feature = HoG(img_cut,Params);
else
    feature(1:dim) = 1;
end


end
