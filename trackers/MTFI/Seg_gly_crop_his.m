function gly_crop= Seg_gly_crop_his(img_frame, curr_samples, template_size)
%create gly_crop, gly_inrange
n_fragment = 2;
n_bin = 16;
n_channel = 3;
nsamples = size(curr_samples,1);
gly_crop_his = zeros(n_bin*n_channel*n_fragment,nsamples);

% for n = 1:nsamples
%    %if mod(n,50)==0 fprintf('-'); end
%    curr_afnv = curr_samples(n, :);
%    offset_his = 0;
%    for j = 1:n_channel
%        gly_crop = IMGaffine_r_his(img_frame(:,:,j), curr_afnv, template_size);
%        n_len = length(gly_crop);
%        fragment_length = n_len / n_fragment;
%        offset_image = 0;
%        for k = 1:n_fragment
%            for i = 1:fragment_length
%                 bin_index = gly_crop(i+offset_image)+ offset_his + 1;
%                 gly_crop_his(bin_index,n) = gly_crop_his(bin_index,n) + 1;    
%            end
%            offset_his = offset_his + n_bin;
%            offset_image = offset_image + fragment_length; 
%        end
%    end
% %    gly_crop = reshape(img_cut, prod(template_size), 1);
% 
% end


parfor n = 1:nsamples
   gly_crop_his(:,n)  = iExtractFeature(curr_samples(n, :), template_size, img_frame);
end

%gly_crop = gly_zmuv(gly_crop_his);	 % zero-mean-unit-variance
gly_crop = normalizeTemplates(gly_crop_his);

end
function [gly_crop_his gly_inrange] = iExtractFeature(curr_afnv, template_size, img_frame)
n_fragment = 2;
n_bin = 16;
n_channel = 3;
offset_his = 0;
gly_crop_his = zeros(n_bin*n_channel*n_fragment,1);
for j = 1:n_channel
   gly_crop = IMGaffine_r_his(img_frame(:,:,j), curr_afnv, template_size);
   n_len = length(gly_crop);
   fragment_length = n_len / n_fragment;
   offset_image = 0;
   for k = 1:n_fragment
       for i = 1:fragment_length
            bin_index = gly_crop(i+offset_image)+ offset_his + 1;
            gly_crop_his(bin_index) = gly_crop_his(bin_index) + 1;    
       end
       offset_his = offset_his + n_bin;
       offset_image = offset_image + fragment_length; 
   end
end
end