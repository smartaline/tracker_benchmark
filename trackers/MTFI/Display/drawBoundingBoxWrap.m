function drawBoundingBoxWrap(tracker_res, varargin)
% Usage:  drawBoundingBox(tracker.tracker_res, 'LineWidth', 2);
% Name: drawBoundingBoxWrap
%
% Description:
%     This is a wrap version of drawBoundingBox. 
% Usage:  drawBoundingBox([x, y, w, h], 'LineWidth', 2);
%         drawBoundingBox([x0, y0, x3, y3], 'InputPoints', 1);
%         drawBoundingBox([x0, y0, x1, y1, x2, y2, x3,y3], 'InputPoints', 1);
%
% Name: drawBoundingBox
%
% Description:
%     Draw a bounding box to show the result
% Notes :
%       location = [x, y, w, h]   
%       location = [x0, y0, x3, y3] two corner
%       location = [x0,y0,x1,y1, x2,y2, x3,y3]
%        (x0,y0)-------(x2,y2)
%           \              \
%            \              \
%             \              \
%             (x1,y1)-------(x4,y4)
% Written by: Zhibin Hong, 2013
[~, linewidth color linestyle] = parseVargin(varargin);
n = size(tracker_res,1);
for index = 1:n
    x0 = tracker_res(index,2);
    y0 = tracker_res(index,1);
    x1 = tracker_res(index,4);
    y1 = tracker_res(index,3);
    x3 = tracker_res(index,6);
    y3 = tracker_res(index,5);
    x2 = tracker_res(index,8);
    y2 = tracker_res(index,7);
    drawBoundingBox([x0, y0, x1, y1, x2, y2, x3, y3], 'InputPoints', 1,...
        'Color',color, 'LineWidth',linewidth,'LineStyle', linestyle);
end


function [indicator linewidth color linestyle] = parseVargin(varargin)
linewidth = 2;
linestyle = '-';
color = 'y';
indicator = 0;
varargin = varargin{1};
% if isempty(varargin{1})
%     return;
% end
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i = 1:2:(length(varargin)-1)
        switch (varargin{i})
            case 'LineWidth',       linewidth = varargin{i+1};
            case 'LineStyle',        linestyle = varargin{i+1};
            case 'Color',           color = varargin{i+1};
            case 'InputPoints',        indicator = varargin{i+1};
            otherwise
                error(['Unrecognized option: ',varargin{i}]);
        end
    end
end