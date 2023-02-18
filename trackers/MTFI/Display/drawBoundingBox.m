function drawBoundingBox(location, varargin)
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



[indicator linewidth color linestyle] = parseVargin(varargin);

if length(location) == 8
    X = [location(1), location(3), location(7), location(5), location(1)];
    Y = [location(2), location(4), location(8), location(6), location(2)];
    p = line(X,Y);
    set(p, 'Color', color); set(p, 'LineWidth', linewidth); set(p, 'LineStyle', '-');
else
    if indicator   
        [width height]= BoundingBox_size(location);
        rectangle('Position',[location(1) location(2) width height],...
            'edgecolor',color, 'LineWidth',linewidth,'LineStyle', linestyle);
    else
        rectangle('Position',[location(1) location(2) location(3) location(4)],...
            'edgecolor',color, 'LineWidth',linewidth,'LineStyle', linestyle);
    end
end


function [argout1 argout2] = BoundingBox_size(box)
% output the size of the bounding box  [width height]

if isempty(box)
    argout1 = [];
    argout2 = [];
else
    %width
    argout1 = box(:,3) - box(:,1) + 1;
    %height
    argout2 = box(:,4) - box(:,2) + 1;
end
if nargout == 1
    argout1 = [argout1 argout2];
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