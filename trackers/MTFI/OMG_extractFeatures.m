function Y = OMG_extractFeatures(img_color,aff_samples,param,G_V)
n_view = param.n_view;
views = param.views;
sz_T = param.sz_T;
n_sample = size(aff_samples,1);
Y = zeros(G_V(end), n_sample);
if(size(img_color,3) == 3)
    img     = double(rgb2gray(img_color));
else
    img     = double(img_color);
    img_color(:,:,2) = img_color(:,:,1);
    img_color(:,:,3) = img_color(:,:,1);
end

for i = 1:n_view
%     tic;
    switch views{i}
        case 'intensity'
            %Y = [Y ;Seg_gly_crop(img, aff_samples(:,1:6), sz_T)];
            Y(G_V(i,1):G_V(i,2),:) = Seg_gly_crop(img, aff_samples(:,1:6), sz_T);
        case 'colorhis'
            img_re = floor(double(img_color) / 16);
            if ~exist('re_aff_samples','var')
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            Y(G_V(i,1):G_V(i,2),:) = Seg_gly_crop_his(img_re, re_aff_samples, sz_T*2);
        case 'hue'
            if ~exist('img_Hsv','var')
                img_Hsv = rgb2hsv(img_color);
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            img_re = floor(img_Hsv(:,:,1)/0.0625);
            Y(G_V(i,1):G_V(i,2),:) = Seg_gly_crop_hue(img_re, re_aff_samples, sz_T*2);
        case 'value'
            if ~exist('img_Hsv','var')
                img_Hsv = rgb2hsv(img_color);
            end
            if ~exist('re_aff_samples','var')
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            img_re = floor(img_Hsv(:,:,3)/0.0625);      
            Y(G_V(i,1):G_V(i,2),:) = Seg_gly_crop_hue(img_re, re_aff_samples, sz_T*2);
        case 'edge'
        case 'saturation'
            if ~exist('img_Hsv','var')
                img_Hsv = rgb2hsv(img_color);
            end
            if ~exist('re_aff_samples','var')
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            img_re = floor(img_Hsv(:,:,2)/0.0625);      
            Y(G_V(i,1):G_V(i,2),:) = Seg_gly_crop_hue(img_re, re_aff_samples, sz_T*2);
%         case 'HOG'
%             if ~exist('re_aff_samples','var')
%                 re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
%             end
%             n_dim = G_V(i,2) - G_V(i,1) + 1;
%             Y(G_V(i,1):G_V(i,2),:) = Seg_gly_crop_HOG(img, re_aff_samples, sz_T*2, n_dim);
        case 'LBP'
            if ~exist('re_aff_samples','var')
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            n_dim = G_V(i,2) - G_V(i,1) + 1;
            Y(G_V(i,1):G_V(i,2),:) = Seg_gly_crop_LBP(img, re_aff_samples, sz_T*2, n_dim);
        case 'otherfeature'
        otherwise 
    end
%     toc;
end

