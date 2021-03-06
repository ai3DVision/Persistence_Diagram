% function [] = combine_PDs()

% load settings
 setting_up_shrec2010_nonrigid_s;

% load distance matrix

DescriptorType = 'HKS';
load(fullfile(DIST_DIR, ['distance_',DescriptorType,'.mat']), 'D_multi_level');
[num_shapes,num_shapes,HKS_pLevels] = size(D_multi_level);
HKS_D_multi_level = D_multi_level;


DescriptorType = 'WKS';
load(fullfile(DIST_DIR, ['distance_',DescriptorType,'.mat']), 'D_multi_level');
[~,~,WKS_pLevels] = size(D_multi_level);
WKS_D_multi_level = D_multi_level;

DescriptorType = 'SIHKS';
load(fullfile(DIST_DIR, ['distance_',DescriptorType,'.mat']), 'D_multi_level');
[~,~,SIHKS_pLevels] = size(D_multi_level);
SIHKS_D_multi_level = D_multi_level;

pLevels = HKS_pLevels + WKS_pLevels + SIHKS_pLevels;
stacked_DD = zeros(num_shapes,num_shapes,pLevels);

for i = 1:num_shapes
    for j =1:num_shapes
        H  = HKS_D_multi_level(i,j,:);
        W  = WKS_D_multi_level(i,j,:);
        SI = SIHKS_D_multi_level(i,j,:);
        
        stacked_DD(i,j,:) = [H(:);...
                            W(:);...
                            SI(:)]; 
    end
end

% % Normalize each function distance
% for p = 1: pLevels
%     D = stacked_DD(:,:,p);
%     D = D/sum(D(:));
%     stacked_DD(:,:,p) = D;
% end

% load('GroundTruth_SHREC2010.mat');
% % Linear combined level partition
% for p = 1: pLevels
%     D = sum(stacked_DD(:,:,1:p),3);
%     fprintf('Linear combined level partition %dth level performace.\n', p);
%     Evaluation_DistanceMatrix(D,GroundTruth);
% end


% 
% 
% N_file = 200;
% num_tier_A = size(D_cellA{1,1},1);
% D_A = zeros(N_file,N_file,num_tier_A);
% 
% num_tier_B = size(D_cellB{1,1},1);
% D_B = zeros(N_file,N_file,num_tier_B);
% 
% num_tier_C = size(D_cellC{1,1},1);
% D_C = zeros(N_file,N_file,num_tier_C);
% 
% % transform to matrix [N_file,N_file,num_tier]
% 
% for i = 1:N_file
%     for j = 1:N_file
%         if i~=j
%           d =  D_cellA{i,j}; 
%           D_A(i,j,:) = d;
%           d =  D_cellB{i,j}; 
%           D_B(i,j,:) = cell2mat(d);          
%           d =  D_cellC{i,j}; 
%           D_C(i,j,:) = cell2mat(d);   
%           %D(i,j,:) = cell2mat(d);
%         end
%     end
% end
% 
% if 1
%     
% % contecate the matrix
% D = zeros(N_file,N_file,num_tier_B+num_tier_A+num_tier_C);
% %D = zeros(N_file,N_file,num_tier_A-5);
% % D(:,:,6:num_tier_A-3) = D_A(:,:,6:num_tier_A-3);
% % D(:,:,num_tier_A+1:num_tier_A+num_tier_B-9) = D_B(:,:,1:num_tier_B-9);
% % D(:,:,num_tier_A+num_tier_B+1:end-7) = D_C(:,:,1:end-7);
% 
% D(:,:,1:num_tier_A) = D_A(:,:,1:num_tier_A);
% D(:,:,num_tier_A+1:num_tier_A+num_tier_B) = D_B(:,:,1:num_tier_B);
% D(:,:,num_tier_A+num_tier_B+1:end) = D_C(:,:,1:end);
% 
% % learn the metric
% [D, A] = learn_metric(D);
% Evaluation_DistanceMatrix_2010(D)
% 
% else
% % evaluate
% D_tier_A = sum(D_A(:,:,6:num_tier_A-3),3);
% D_tier_B = sum(D_B(:,:,1:num_tier_B-0),3);
% D_tier_C = sum(D_C(:,:,1:num_tier_C-7),3);
% 
% D_tier = D_tier_B;%5*D_tier_A+0.*D_tier_B+0.*D_tier_C;
% Evaluation_DistanceMatrix_2010(D_tier)
% end
% 
% end
% 
% function [D, A] = learn_metric(DM)
% 
%     num_sample_class = 4;
%     load('GroundTruth_SHREC2010.mat');
%     GroundTruth = GroundTruth+1;
%     Samples = GroundTruth(1:num_sample_class,:);
%     Samples = Samples(:);
%     num_samples = size(Samples,1);
%     
%     s = size(DM);
%     N_file = s(1);     % number of examples
%     num_tier = s(3);     % dimensionality of examples    
% 
%     DISTANCES = zeros(num_samples,num_samples,num_tier);
%         
%     % S: similarity constraints (in the form of a pairwise-similarity matrix)
%     % D: disimilarity constraints (in the form of a pairwise-disimilarity matrix)
%     S = zeros(num_samples,num_samples);
%     D = zeros(num_samples,num_samples);
%     y = zeros(num_samples,1);
%     
%     for i =1:num_samples
%         for j = i+1:num_samples
%             d = DM(Samples(i),Samples(j),:);
%             d = d(:);
%             DISTANCES(i,j,:) = d;
%             DISTANCES(j,i,:) = d;
% 
%                 %% Similar and Dissimilar matrix construction
%                 i_class = floor((i-1)/num_sample_class);
%                 j_class = floor((j-1)/num_sample_class);
%                 if i_class ~= j_class
%                     D(i,j) = 1;
%                     D(j,i) = 1;
%                 else
%                     S(i,j) = 1;
%                     S(j,i) = 1;
%                 end
%         end
%         y(i) = i_class;
%     end
% 
%     % learn the metric
%     s = size(DISTANCES);
%     N = s(1);     % number of examples
%     d = s(3);     % dimensionality of examples    
%     A = eye(d,d);%*0.1;
%     W = zeros(d,d);
% 
%     for i = 1:N,
%       for j = i+1:N,
%         if S(i,j) == 1,
%           d_ij = DISTANCES(i,j,:); %X(i,:) - X(j,:);
%           d_ij = d_ij(:)';
%           W = W + (d_ij'*d_ij);
%         end;
%       end;
%     end;     
% 
%     w = unroll(W);
%     t = w' * unroll(A)/mean(w);
%     
%     maxiter = 100;
%     
%     C = 10;
% %     A = Newton(DISTANCES, S, D, C);
% %     A
% 
%     [A, converge] = iter_projection_new2(DISTANCES, S, D, A, w, t, maxiter);
% %     
% %     
% %     X = DISTANCES*100;
% %     params = struct();
% %     A0 = eye(size(X,3));
%     
% %    A = Persistence_MetricLearning_Main(@Persistence_ItmlAlg, y, X, A0, params);
%     
%     D_baseline = zeros(N_file,N_file);
%     for i = 1:N_file
%         for j = 1:N_file
%             d = DM(i,j,:);
%             d = d(:);
%             D_baseline(i,j) = d'*A*d; %sqrt(d'*A*d); diag(A).*d.*d; sum( sqrt(diag(A).*d.*d) );%
%         end
%     end
%     
%     D = D_baseline;
%     
% 
% end
% 
% 
