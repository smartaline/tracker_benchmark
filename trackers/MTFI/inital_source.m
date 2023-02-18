function source  = inital_source(source)

if ~isempty(source.frames)
    return;
end

[source.init_pos,source.frames] = initialSettings(source.data_dir, source.sequenceName);
source.nFrames = length(source.frames);
img_frames = cell(source.nFrames,1);
if source.image
    for t = 1:source.nFrames
        img_frames{t}	= imread(source.frames{t});
    end
    source.frames = img_frames;
end




