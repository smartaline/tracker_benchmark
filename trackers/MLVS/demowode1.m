clc;
clear all;
addpath('MTT_Toolbox');
addpath(('E:\vlfeat-0.9.20\toolbox'));
vl_setup;
%% parameter setting
setTrackParam;  % initial position and affine parameters
patch_size = 16;
step_size = 8;
[patch_idx, patch_num] = img2patch(psize, patch_size, step_size);
duration = 0; tic;

result = [];
initial_tracking;

opts.lambda = 0.01; 
opts.eta  = 0.01;
opts.iter_maxi = 5;


opt.tmplsize = psize;                                           
sz = opt.tmplsize;
n_sample = opt.numsample;
num_p = EXEMPLAR_NUM ;                                                       
num_n = 30;

[A_poso A_nego] = affineTrainG(dataPath, sz, opt, param, num_p, num_n, forMat, p0); %obtain poso and nego template       
A_pos = A_poso;
A_neg = A_nego; 
AA_pos = normalizeTemplates(A_pos);
AA_neg = normalizeTemplates(A_neg);
    
P = selectFeature(AA_pos, AA_neg, opts);                     % feature selection
AAA_pos = P'*AA_pos;
AAA_neg = P'*AA_neg;

PosoTemplateDict = normalizeTemplates(AAA_pos);   
Ppatch_dict = reshape(PosoTemplateDict(patch_idx,:), patch_size*patch_size, patch_num*num_p); % Poso patch dictionary
Ppatch_dict = normalizeTemplates(Ppatch_dict);

NegoTemplateDict = normalizeTemplates(AAA_neg);   
Npatch_dict = reshape(NegoTemplateDict(patch_idx,:), patch_size*patch_size, patch_num*num_n); % Nego patch dictionary
Npatch_dict = normalizeTemplates(Npatch_dict);
align_patch_longfeature = reshape(eye(patch_num),patch_num*patch_num,1); 
% sklm variables  
tmpl.mean = mean(PosoTemplateDict,2);     
tmpl.basis = [];                                        
tmpl.eigval = [];                                      
tmpl.numsample = 0;                                     
tmpl.warpimg = [];
[tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = sklm(PosoTemplateDict, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample);


%% Do Tracking
for f = begin+num_p:frameNum
     if exist([dataPath int2str(1) '.jpg'],'file')
        imgName = sprintf('%s%d.jpg',dataPath,f);
    elseif exist([dataPath int2str(1) '.bmp'],'file')
        imgName = sprintf('%s%d.bmp',dataPath,f);
    else 
        imgName = sprintf('%s%05d.jpg',dataPath,f); 
    end
    frame = imread(imgName);
    if size(frame,3)==3
        grayframe = rgb2gray(frame);
    else
        grayframe = frame;
        frame = double(frame)/255; 
    end  
    frame_img = double(grayframe)/255;
   % sampling    
    particles_geo = sampling(result(end,:), opt.numsample, opt.affsig);     
    Y= warpimg(frame_img, affparam2mat(particles_geo), psize); 
    Y= Y.*(Y>0); 
    [Y,Y_norm] = normalizeTemplates(reshape(Y,psize(1)*psize(2), opt.numsample));
    candidates = P'*Y;
    % cropping patches 种植补丁
    particles_patches = candidates(patch_idx, :);
    particles_patches = reshape(particles_patches,patch_size*patch_size, patch_num*opt.numsample);
    candi_patch_data= normalizeTemplates(particles_patches); % l2-norm normalization     
    %Poso sparse coding
    Ppatch_coef = MTL_APG(candi_patch_data, Ppatch_dict, opts); 
    Pmerge_coef = zeros(patch_num, patch_num*opt.numsample);  %相当于V（N行，N*粒子个数 列）     
    for i=1:num_p
        Pmerge_coef = Pmerge_coef + abs(Ppatch_coef((i-1)*patch_num+1:i*patch_num,:));
    end
    Pnormalized_coef = Pmerge_coef./(repmat(sum(Pmerge_coef,1), patch_num, 1)+eps);
    %Nego sparse coding
    Npatch_coef = MTL_APG(candi_patch_data, Npatch_dict, opts); 
    Nmerge_coef = zeros(patch_num, patch_num*opt.numsample);  %相当于V（N行，N*粒子个数 列）     
    for i=1:num_n
        Nmerge_coef = Nmerge_coef + abs(Npatch_coef((i-1)*patch_num+1:i*patch_num,:));
    end
    Nnormalized_coef = Nmerge_coef./(repmat(sum(Nmerge_coef,1), patch_num, 1)+eps);
    
    normalized_coef =Pnormalized_coef-Nnormalized_coef;
    % alignment-pooling
    patch_longfeatures = reshape(normalized_coef,patch_num*patch_num, opt.numsample);  
    
    % MAP inference
    sim_measure = sum(align_patch_longfeature'*patch_longfeatures,1) ; 
    conf = sim_measure;
    [sort_conf, sort_idx] = sort(conf,'descend');    
    best_idx = sort_idx(1);
    best_particle_geo = particles_geo(:, best_idx);       
    best_patch_coef = normalized_coef(:,(best_idx-1)*patch_num+1:best_idx*patch_num);
    
    %% template update
    tmpl.warpimg = [tmpl.warpimg,candidates(:,best_idx)];
    if size(tmpl.warpimg,2)==5
        [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = sklm(tmpl.warpimg, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, 1);
        if  (size(tmpl.basis,2) > 10)          
            tmpl.basis  = tmpl.basis(:,1:10);   
            tmpl.eigval = tmpl.eigval(1:10);    
        end
        tmpl.warpimg = [];
        recon_coef = MTL_APG((candidates(:,best_idx)-tmpl.mean), [tmpl.basis, eye(size(tmpl.basis,1)) ], opts); 
        recon = tmpl.basis*recon_coef(1:size(tmpl.basis,2))+tmpl.mean;
        % replace the template probabilistic
        random_weight = [0,(2).^(1:num_p-1)];
        random_weight = cumsum(random_weight/sum(random_weight));
        random_num = rand(1,1);
        for i=2:num_p-1
            if random_num>=random_weight(i-1)&random_num<random_weight(i)
                break;
            end
        end
        if random_num>=random_weight(num_p-1)
            i = num_p;
        end
        A_pos(:,i)=[];
        A_pos(:,num_p) = normalizeTemplates(recon); 
    end
    
    upRate = 5;
    if rem(f, upRate)==0
        [A_neg] = updateNegativeDic(dataPath, sz, opt, param, num_n, forMat, p0, f);
    end 
    
    AA_pos = normalizeTemplates(A_pos);
    AA_neg = normalizeTemplates(A_neg);
    P = selectFeature(AA_pos, AA_neg, opts);     % feature selection
    AAA_pos = P'*AA_pos;
    AAA_neg = P'*AA_neg;
    
    PosoTemplateDict = normalizeTemplates(AAA_pos);   
    Ppatch_dict = reshape(PosoTemplateDict(patch_idx,:), patch_size*patch_size, patch_num*num_p); %Poso patch dictionary
    Ppatch_dict = normalizeTemplates(Ppatch_dict);
    
    NegoTemplateDict = normalizeTemplates(AAA_neg);   
    Npatch_dict = reshape(NegoTemplateDict(patch_idx,:), patch_size*patch_size, patch_num*num_n); % Nego patch dictionary
    Npatch_dict = normalizeTemplates(Npatch_dict);
    
    %% draw result
    result = [result; affparam2mat(best_particle_geo)']; 
    drawopt = drawtrackresult(drawopt, f, frame, psize, result(end,:)');  
    imwrite(frame2im(getframe(gcf)),sprintf('result/%s/Result/%04d.png',title,f)); 
end
duration = duration + toc;      
fprintf('%d frames took %.3f seconds : %.3fps\n',f,duration,f/duration);
fps = f/duration;

fileName = sprintf('result/%s/Result/result.mat',title);
save(fileName,'result','observation');


