function boxes = aff2image(aff_maps, T_sz)
% Get the bounding "box" of the detected object in image
%	aff2image(aff_maps, T_sz)
% Input:
%	aff_maps	- 6xN matrix, containing N tracking results (N frames) in affine parameters, 
%				  each COLUMN is in the form of [a11 a12 a21 a22 t1 t2]'
%	T_sz		- template size
% Output:
%	boxes		- 8xN matrix, containing N tracking boxes, each COLUMN
%					contains the coordinates of the four corner points.
%

r		= T_sz(1);
c		= T_sz(2);			% height and width of template
n		= size(aff_maps,1);	% number of affine results
boxes	= zeros(n,8);	
R = zeros(2,3);
for ii=1:n
	R(:)	= aff_maps(ii,:);
% 	R	= [ aff(1), aff(2), aff(5);...
% 			aff(3), aff(4), aff(6)];
		
	P	= [	1, r, r, 1; ...
			1, 1, c, c; ...
			1, 1, 1, 1];

	Q	= R*P;
	boxes(ii,:)	= Q(:);
end

% R = reshape(aff_maps,2,[]);
% Rchange = zeros(n*2,3);
% for ii = 1:n
%     Rchange(1+(ii-1)*2:ii*2,1:3) = R(:,1+(ii-1)*3:3+(ii-1)*3);
% end
% 
% Q	= Rchange*P;
% boxes = reshape(Q',8,[]);



