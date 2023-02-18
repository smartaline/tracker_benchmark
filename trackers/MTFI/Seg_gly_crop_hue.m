function gly_crop_hue = Seg_gly_crop_hue(img_frame, curr_samples, template_size)
%create gly_crop, gly_inrange
n_bin = 16;
n_fragment = 2;
img_frame(img_frame == 16) = 15;
nsamples = size(curr_samples,1);
gly_crop_hue = zeros(n_fragment*n_bin,nsamples);

for n = 1:nsamples
   %if mod(n,50)==0 fprintf('-'); end
    curr_afnv = curr_samples(n, :);
    gly_crop = IMGaffine_r_his(img_frame, curr_afnv, template_size);
%    gly_crop = reshape(img_cut, prod(template_size), 1);
    offset_his = 0;
    offset_image = 0;
    n_len = length(gly_crop);
    fragment_length = n_len / n_fragment;
    for k = 1:n_fragment
       for i = 1:fragment_length
            bin_index = gly_crop(i+offset_image)+ offset_his + 1;
            gly_crop_hue(bin_index,n) = gly_crop_hue(bin_index,n) + 1;    
       end
       offset_his = offset_his + n_bin;
       offset_image = offset_image + fragment_length; 
    end
end

%gly_crop = gly_zmuv(gly_crop_his);	 % zero-mean-unit-variance
gly_crop_hue = normalizeTemplates(gly_crop_hue);