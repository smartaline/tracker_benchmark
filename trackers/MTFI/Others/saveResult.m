function saveResult(tracker_res, save_dir, sequenceName)
resCenterAll = cell(1, length(size(tracker_res,1)));
resCornersAll = cell(1, length(size(tracker_res,1 )));

for t = 1:size(tracker_res,1)
        x1 = tracker_res(t, 2);
    y1 = tracker_res(t, 1);
        x2 = tracker_res(t, 8);
    y2 = tracker_res(t, 7);
        x3 = tracker_res(t, 6);
    y3 = tracker_res(t, 5);
        x4 = tracker_res(t, 4);
    y4 = tracker_res(t, 3);
    
    resCornersAll{t} = [x1, x2, x3, x4, x1; y1, y2, y3, y4, y1];
    resCenterAll{t} = [(x1 + x3)/2 ; (y1 + y3)/2];
end

res_path = [save_dir sequenceName '_res.mat'];
save(res_path,  'resCenterAll', 'resCornersAll');