function bbox_out = hd_boundBoxRemat(bbox_in, input_mode, output_mode)
% Usage:  hd_boundBoxRemat([x, y, w, h], 1, 2)
%
% Name: hd_boundBoxRemat
%
% Description:
%     reformat the bounding box according to the mode
% Notes :
%       bbox_in = [x, y, w, h]                     %mode1
%       bbox_in = [x0, y0, x2, y2]                 %mode2   two corner 
%       bbox_in = [x0, y0, x1, y1, x2, y2, x3, y3] %mode3   
%       bbox_in = [c_x, c_y, w, h]                 %mode4   
%        (x0,y0)-------(x1,y1)
%           \              \
%            \              \
%             \              \
%             (x3,y3)-------(x2,y2)
%       uniform_bbox = [x0, y0, x1, y1, x2, y2, x3, y3, w, h, c_x, c_y];
%       uniform_bbox = [1,  2,   3,  4,  5,  6,  7,  8, 9, 10, 11,  12];
if isempty(bbox_in)
    bbox_out = [];
    return;
end

if input_mode == 1
    x0 = bbox_in(:,1);
    y0 = bbox_in(:,2);
    w  = bbox_in(:,3);
    h  = bbox_in(:,4);
    x1 = x0 + w - 1;
    y1 = y0;
    x2 = x1;
    y2 = y1 + h - 1;
    x3 = x0;
    y3 = y2;
    c_x = (x0 + x2) / 2;
    c_y = (y0 + y2) / 2;
    uniform_bbox = [x0,y0, x1,y1, x2,y2, x3,y3, w, h, c_x, c_y];
elseif input_mode == 2
    x0 = bbox_in(:,1);
    y0 = bbox_in(:,2);
    x2 = bbox_in(:,3);
    y2 = bbox_in(:,4);
    w  = x2 - x0 + 1;
    h  = y2 - y0 + 1;
    x1 = x2;
    y1 = y0;
    x3 = x0;
    y3 = y2;
    c_x = (x0 + x2) / 2;
    c_y = (y0 + y2) / 2;
    uniform_bbox = [x0,y0, x1,y1, x2,y2, x3,y3, w, h, c_x, c_y];
elseif input_mode == 3
    uniform_bbox = [bbox_in, bbox_in(:, 5:6) - bbox_in(:, 1:2) + 1,...
        (bbox_in(:, 5:6) + bbox_in(:, 1:2)) / 2];
elseif input_mode == 4
    w  = bbox_in(:,3);
    h  = bbox_in(:,4);
    c_x = bbox_in(:,1);
    c_y = bbox_in(:,2);
    x0 = c_x - w / 2 + 0.5;
    y0 = c_y - h / 2 + 0.5;
    x2 = c_x + w / 2 - 0.5 ;
    y2 = c_y + h / 2 - 0.5;
    x1 = x2;
    y1 = y0;
    x3 = x0;
    y3 = y2;
    uniform_bbox = [x0,y0, x1,y1, x2,y2, x3,y3, w, h, c_x, c_y];
end


if output_mode == 1
    index = [1, 2, 9, 10];
elseif output_mode == 2
    index = [1, 2, 5, 6];
elseif output_mode == 3
    index = 1:8;
elseif output_mode == 4
    index = [11, 12, 9, 10];
end

bbox_out = uniform_bbox(:, index);


