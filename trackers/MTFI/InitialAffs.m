function aff_samples = InitialAffs(cpt, num, sz_T)
p = cell(num,1);
p{1}= cpt;
for i=2:num
    p{i} = cpt+randn(2,3)*0.6;
end
% p{2} = cpt + [-1 0 0; 0 0 0];
% p{3} = cpt + [1 0 0; 0 0 0];
% p{4} = cpt + [0 -1 0; 0 0 0];
% p{5} = cpt + [0 1 0; 0 0 0];
% p{6} = cpt + [0 0 1; 0 0 0];
% p{7} = cpt + [0 0 0; -1 0 0];
% p{8} = cpt + [0 0 0; 1 0 0];
% p{9} = cpt + [0 0 0; 0 -1 0];
% p{10} = cpt + [0 0 0; 0 1 0];
aff_samples = zeros(length(p),6);
for i = 1:length(p)
    R = corners2afnv(p{i}, sz_T);
    aff_samples(i,:) = R(:);
end
