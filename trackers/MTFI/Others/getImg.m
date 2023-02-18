function img = getImg(source, index)
% get current image from source
if source.image
    img = source.frames{index};
else
    img = imread(source.frames{index});
end