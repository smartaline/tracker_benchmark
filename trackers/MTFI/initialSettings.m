function [init_pos,s_frames]=initialSettings(fprefixpre, sequenceName)

fprefix = [fprefixpre sequenceName '/img/'];
notation = dlmread([fprefixpre sequenceName '/groundtruth_rect.txt']);
notation = hd_boundBoxRemat(notation(1,:), 1, 3);
notation = reshape(notation,2,[]);
init_pos = notation([2 1], [1 4 2]);

temp = dir([fprefix '*.jpg']);
nframes = length(temp);
if nframes == 0
    temp = dir([fprefix '*.png']);
    nframes = length(temp);
end
%  nframes = 2;
s_frames	= cell(nframes,1);

for t=1:nframes
    s_frames{t}	= strcat(fprefix, temp(t).name);
end
