function [Y G_V]= OMG_extractFeatures_init(img_color,aff_samples,param)
n_view = param.n_view;
views = param.views;
sz_T = param.sz_T;
Y = [];
G_V = zeros(n_view, 2);
dbegin = 1;
if(size(img_color,3) == 3)
    img     = double(rgb2gray(img_color));
else
    img     = double(img_color);
    img_color(:,:,2) = img_color(:,:,1);
    img_color(:,:,3) = img_color(:,:,1);
end

for i = 1:n_view
    switch views{i}
        case 'intensity'
            Y = [Y ;Seg_gly_crop(img, aff_samples(:,1:6), sz_T)];
        case 'colorhis'
            img_re = floor(double(img_color) / 16);
            if ~exist('re_aff_samples','var')
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            Y = [Y ;Seg_gly_crop_his(img_re, re_aff_samples, sz_T*2)];
        case 'hue'
            if ~exist('img_Hsv','var')
                img_Hsv = rgb2hsv(img_color);
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            img_re = floor(img_Hsv(:,:,1)/0.0625);
            Y = [Y ;Seg_gly_crop_hue(img_re, re_aff_samples, sz_T*2)];
        case 'value'
            if ~exist('img_Hsv','var')
                img_Hsv = rgb2hsv(img_color);
            end
            if ~exist('re_aff_samples','var')
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            img_re = floor(img_Hsv(:,:,3)/0.0625);     
            Y = [Y ;Seg_gly_crop_hue(img_re, re_aff_samples, sz_T*2)];
        case 'saturation'
            if ~exist('img_Hsv','var')
                img_Hsv = rgb2hsv(img_color);
            end
            if ~exist('re_aff_samples','var')
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            img_re = floor(img_Hsv(:,:,2)/0.0625);      
            Y = [Y ;Seg_gly_crop_hue(img_re, re_aff_samples, sz_T*2)];
%         case 'HOG'
%             if ~exist('re_aff_samples','var')
%                 re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
%             end
%             Y = [Y ;Seg_gly_crop_HOG(img, re_aff_samples, sz_T*2)];
        case 'LBP'
            if ~exist('re_aff_samples','var')
                re_aff_samples = aff_samples * diag([1/2 1/2 1/2 1/2 1 1]);
            end
            Y = [Y ;Seg_gly_crop_LBP(img, re_aff_samples, sz_T*2)];
        case 'otherfeature'
        otherwise 
    end
    dend = size(Y,1);
    G_V(i,:) = [dbegin dend];
    dbegin = dend + 1;
end
