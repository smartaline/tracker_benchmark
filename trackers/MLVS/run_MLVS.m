function results=run_MLVS(seq, res_path, bSaveImage)

close all;
% addpath('MTT_Toolbox');
% addpath(('E:\vlfeat-0.9.20\toolbox'));
% vl_setup;
%% parameter setting

s_frames = seq.s_frames;
para=paraConfig_MLVS(seq.name);

patch_size = para.patch_size;
step_size = para.step_size;

rect=seq.init_rect;
p = [rect(1)+rect(3)/2, rect(2)+rect(4)/2, rect(3), rect(4), 0];
psize = para.psize;
%param0 = [p(1), p(2), p(3)/psize(1), p(5), p(4)/p(3), 0]'; %param0 = [px, py, sc, th,ratio,phi];   
%param0 = affparam2mat(param0); 

opt = para.opt;
opt.psize=para.psize;

[patch_idx, patch_num] = img2patch(psize, patch_size, step_size);
duration = 0; 
tic;

% SC_param = para.SC_param;
 opts.lambda = 0.01;
opts.eta = 0.05; 
%opts.lambda = 0.01;
%opts.eta  = 0.01;
opts.iter_maxi = 100;
SC_param.mode = 2;
SC_param.lambda = 0.01;
% SC_param.lambda2 = 0.001; 
SC_param.pos = 'ture'; 

opt.tmplsize = psize;                                           
sz = opt.tmplsize;
n_sample = opt.numsample;
num_p = 20 ;                                                       
num_n = 100;

paramSR.lambda2 = 0;
paramSR.mode = 2;

%param = [];
%param.est = param0';

normalHeight=320;
normalWidth=240;

% [res, exemplars_stack, drawopt]=initial_tracking(seq, param0,psize,10,opt, res_path, bSaveImage); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img_color = imread(s_frames{1});
if size(img_color,3)==3
	frame	= double(rgb2gray(img_color));
else
	frame	= double(img_color);
end   

scaleHeight = size(frame, 1) / normalHeight;
scaleWidth = size(frame, 2) / normalWidth;
    p(1) = p(1) / scaleWidth;
    p(3) = p(3) / scaleWidth;
    p(2) = p(2) / scaleHeight;
    p(4) = p(4) / scaleHeight;
    frame = imresize(frame, [normalHeight, normalWidth]);
    frame = double(frame) / 255;
    
    
    paramOld = [p(1), p(2), p(3)/opt.tmplsize(2), p(5), p(4) /p(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0]';
    param0 = affparam2mat(paramOld);
    
param = [];
param.est = param0';
drawopt=[];
resl = [];
reportRes = [];
resl = [resl; param0'];
%p0 = p(4)/p(3);
p0 = paramOld(5);

[A_poso A_nego] = affineTrainG(frame, sz, opt, param, num_p, num_n, p0); %obtain poso and nego template       
A_pos = A_poso;
A_neg = A_nego; 
AA_pos = normalizeTemplates(A_pos);
AA_neg = normalizeTemplates(A_neg);
    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  selected feature
% posOri = selectFeature(Ppatch_dict, Npatch_dict, paramSR, prod(opt.tmplsize));  
% k = sum(posOri);             % the number of selected feature
% temp = find(posOri);
% P = zeros(size(Ppatch_dict,1),k);
% for i = 1:k
%     P(temp(i),i) = 1;
% end
% opt.P = P;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% AAA_pos = opt.P'* Ppatch_dict;
% AAA_neg = opt.P'* Npatch_dict;

align_patch_longfeature = reshape(eye(patch_num),patch_num*patch_num,1); 

%drawopt = drawtrackresult([], 0, frame, psize, reportRes(end,:));
% num = seq.endFrame-seq.startFrame+1;
% res = zeros(num, 6);
% res(1,:) = param.est';
%% Do Tracking

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for f = 1:seq.len
    frame = imread(s_frames{f});
    if size(frame,3)==3
        frame_img = double(rgb2gray(frame));
    else
        frame_img = double(frame);
     %   frame = double(frame)/255; 
    end  
    
    frame = imresize(frame_img, [normalHeight, normalWidth]);
    frame = double(frame) / 255;
    
    tic
    
    PosoTemplateDict = normalizeTemplates(AA_pos);   
    Ppatch_dict = reshape(PosoTemplateDict(patch_idx,:), patch_size*patch_size, patch_num*num_p); % Poso patch dictionary
    Ppatch_dict = normalizeTemplates(Ppatch_dict);

%     NegoTemplateDict = normalizeTemplates(AA_neg);   
%     Npatch_dict = reshape(NegoTemplateDict(patch_idx,:), patch_size*patch_size, patch_num*num_n); % Nego patch dictionary
%     Npatch_dict = normalizeTemplates(Npatch_dict);

   % sampling    
    particles_geo = sampling(resl(end,:), opt.numsample, opt.affsig);     
    Y= warpimg(frame, affparam2mat(particles_geo), psize); 
    Y= Y.*(Y>0); 
    [Y,Y_norm] = normalizeTemplates(reshape(Y,psize(1)*psize(2), opt.numsample));
    candidates =Y;
    % cropping patches 
    particles_patches = candidates(patch_idx, :);
    particles_patches = reshape(particles_patches,patch_size*patch_size, patch_num*opt.numsample);
    candi_patch_data = normalizeTemplates(particles_patches); % l2-norm normalization 
%     candi_patch_data = opt.P'* candi_patch_data;
    
    %Poso sparse coding
    Ppatch_coef = MTL_APG(candi_patch_data,  Ppatch_dict, opts); %每块的稀疏系数
%     temp = ones(patch_num*num_p, patch_num*opt.numsample);
%     for j=1:3600
%         for i =1:10
%             recon=sum((candi_patch_data (:,j)-Ppatch_dict(:,(i-1)*patch_num+1:i*patch_num)*Ppatch_coef((i-1)*patch_num+1:i*patch_num,j)).^2);
%              thr = 0.04;                                                 % the occlusion indicator            
%              thr_lable = recon>=thr;
%              temp((i-1)*patch_num+1:i*patch_num,j)=0;
%         end
%     end
%       p = temp.*abs(Ppatch_coef);                                       % the weighted histogram for the candidate

    Pmerge_coef = zeros(patch_num, patch_num*opt.numsample);  
    for i=1:num_p                       %将各分模板段累加得到W
        Pmerge_coef = Pmerge_coef + abs( Ppatch_coef((i-1)*patch_num+1:i*patch_num,:));
    end
    Pnormalized_coef = Pmerge_coef./(repmat(sum(Pmerge_coef,1), patch_num, 1)+eps);
%     %Nego sparse coding
%     Npatch_coef = MTL_APG(candi_patch_data,  Npatch_dict, opts); 
%     Nmerge_coef = zeros(patch_num, patch_num*opt.numsample);      
%     for i=1:num_n
%         Nmerge_coef = Nmerge_coef + abs(Npatch_coef((i-1)*patch_num+1:i*patch_num,:));
%     end
%     Nnormalized_coef = Nmerge_coef./(repmat(sum(Nmerge_coef,1), patch_num, 1)+eps);
    
%     normalized_coef =Pnormalized_coef-Nnormalized_coef;
    % alignment-pooling
    patch_longfeatures = reshape(Pnormalized_coef,patch_num*patch_num, opt.numsample);  
   
	%paramSR.lambda= 0.01;
    % MAP inference
    sim_measure = sum(align_patch_longfeature'*patch_longfeatures,1); %提取W对角线上的元素
    conf = sim_measure;
    [sort_conf, sort_idx] = sort(conf,'descend');    
    best_idx = sort_idx(1);
    best_particle_geo = particles_geo(:, best_idx);       
    best_patch_coef = Pnormalized_coef(:,(best_idx-1)*patch_num+1:best_idx*patch_num);
    
  %% template update
   % sklm variables 
   tmpl.mean = mean(PosoTemplateDict,2);     
   tmpl.basis = [];                                        
   tmpl.eigval = [];                                      
   tmpl.numsample = 0;                                     
   tmpl.warpimg = [];
   [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = sklm(PosoTemplateDict, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample);

    tmpl.warpimg = [tmpl.warpimg,candidates(:,best_idx)];
    if size(tmpl.warpimg,2)==5
        [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = sklm(tmpl.warpimg, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, 1);
        if  (size(tmpl.basis,2) > 10)          
            tmpl.basis  = tmpl.basis(:,1:10);   
            tmpl.eigval = tmpl.eigval(1:10);    
        end
        tmpl.warpimg = [];
        recon_coef = mexLasso((candidates(:,best_idx)-tmpl.mean), [tmpl.basis, eye(size(tmpl.basis,1)) ], SC_param); 
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
    
    
	duration = duration + toc;   
    
	param.est=affparam2mat(best_particle_geo)';
	res = affparam2geom(param.est); 
      p(1) = round(res(1));
      p(2) = round(res(2)); 
      p(3) = round(res(3) * opt.tmplsize(2));
      p(4) = round(res(5) * (opt.tmplsize(1) / opt.tmplsize(2)) * p(3));
      p(5) = res(4);
      p(1) = p(1) * scaleWidth;
      p(3) = p(3) * scaleWidth;
      p(2) = p(2) * scaleHeight;
      p(4) = p(4) * scaleHeight;
      paramOld = [p(1), p(2), p(3)/opt.tmplsize(2), p(5), p(4) /p(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0]';
      
      resl = [resl; param.est]; 
      
      reportRes = [reportRes; affparam2mat(paramOld)'];
    
    if bSaveImage  
        drawopt = drawtrackresult(drawopt, f, frame, psize, resl(end,:)'); % 
%         imwrite(frame2im(getframe(gcf)),sprintf('%s%04d.jpg',res_path,f));  
    end
    
	
	AA_pos = normalizeTemplates(A_pos);
    AA_neg = normalizeTemplates(A_neg);
  
 
end
   
fps = (seq.len-10)/duration;

% fileName = sprintf('%s%s_ASLA.mat',res_path,seq.name);
% save(fileName,'results');
results.res=reportRes;
results.type='ivtAff';
results.tmplsize = psize;
results.fps = fps;
disp(['fps: ' num2str(results.fps)])



