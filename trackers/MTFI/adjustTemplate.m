function sz_T = adjustTemplate(sz_T, initial_pos)

height = initial_pos(3) - initial_pos(1);
width = initial_pos(6) - initial_pos(2);


% if min(height,width) > 40
%     sz_T_n = [floor(height/4) floor(width/4)];
% elseif min(height,width) > 21
%     sz_T_n = [floor(height/3) floor(width/3)];
% else
%     sz_T_n = [floor(height/2) floor(width/2)];
% end
if min(height,width) > 15
    sz_T_n = [floor(height/3) floor(width/3)];
else
    sz_T_n = [floor(height/2) floor(width/2)];
end

if prod(sz_T_n) > prod(sz_T)
    sz_T = sz_T_n;
end


sz_T_limit = [25 25];

if prod(sz_T) > prod(sz_T_limit)
    sz_T = sz_T_limit;
end