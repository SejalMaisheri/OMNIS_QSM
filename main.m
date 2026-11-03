%{
Contains implementation of Multi-orientation QSM methods
1)Cosmos
2)Omnis
3)NDI
then ROI Error code

%}

%clearvars
%close all
%clc



%path to save output
save_outputs = 0;  % 1: save , 0: ignore
output_folder = 'Outputs/Sim1Snr1/';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
fprintf('saving output at: %s \n' , output_folder)


%Loading Data
data_path = 'Sim1Snr1';
disp('started')
load(fullfile(data_path,'kernel_all.mat'));   % kernel_all (256,320,320,8), 0.64mm
disp('kernel loaded')
load(fullfile(data_path,'phase_all_100.mat'));    % phase_all  
load(fullfile(data_path,'weights_all_100.mat'));  % weights_all
load(fullfile(data_path,'mask.mat'));             % mask
load(fullfile(data_path,'Gt.mat'));               % gt
disp('data loaded')


%Parameters
B0 = 7;
gyro = 42.57747892;
nd = 8;                         % Total orientation to be used ( Max value = 8)
N = size(mask);                 % (256,320,320)
scale_gt = [-0.1, 0.1];         % For visualization

kernel = single(kernel_all(:,:,:,1:nd));
phs_use = single(phase_all(:,:,:,1:nd) ./ ( B0 * gyro)); % Hz to ppm conversion
Wgt_use = single(weights_all(:,:,:,1:nd));
gt = single(gt .* mask);

clear phase_all weights_all kernel_all voxel_size matrix_size unit

fprintf('Total Orientations: %d \n' , nd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%COSMOS
%Code taken from 2016 QSM Challenge code : http://qsm.neuroimaging.at
disp('COSMOS')
tic
Phase_tissue = zeros(size(phs_use) , 'single');            

for t = 1:size(phs_use,4)
    Phase_tissue(:,:,:,t) = fftn(phs_use(:,:,:,t));
end

kernel_sum = sum(abs(kernel).^2, 4);
cos = real( ifftn( sum(kernel .* Phase_tissue, 4) ./ (eps + kernel_sum) ) ) .* mask ;  
toc

clear Phase_tissue kernel_sum

rmse_cos = compute_nrmse(cos, gt); 
psnr_cos = compute_psnr(cos, gt);
ssim_cos = compute_ssim(cos, gt);
hfen_cos = compute_hfen(cos, gt);

disp(['nrmse ', num2str(rmse_cos),'% psnr ', num2str(psnr_cos), '% ssim ', num2str(ssim_cos),'% hfen ', num2str(hfen_cos) , '%'])

imagesc3d2(cos, N/2, 2, [90,90,90], scale_gt, [], 'cosmos')
imagesc3d2(gt, N/2, 1, [90,90,90], scale_gt, [], 'GT')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OMNIS
disp('OMNIS')
tic
step_size = 2;     
num_iter = 500;  
grad_tol = 1;
count = 0;
 
x = zeros(N, 'single');
zeta_buffer = zeros([N,nd], 'single');  % store last nd zetas
grad_buffer = zeros([N,nd], 'single');
 
for L = 1:num_iter

    l = mod(L-1 , nd) + 1;
    D = kernel(:,:,:,l);
    y = phs_use(:,:,:,l);
    W2 = Wgt_use(:,:,:,l).^2;

    Dx = real( ifftn ( D .* fftn (x)));

    temp = W2 .* sin( Dx - y) ;
    grad_f = 2 * ifftn( D .* fftn(temp) ) ;  % grad = 2 DT WTW sin(Dx-y)
        
    zeta = x - step_size * real(grad_f);     % auxiliary variable

    x_new = x + ( zeta - zeta_buffer(:,:,:,l) )/nd ;
    x_diff = compute_nrmse(x_new .* mask , x .* mask);

    update_grad = compute_nrmse(grad_buffer(:,:,:,l), grad_f); % relative gradient difference

    if update_grad < grad_tol
        count = count + 1;
    else
        count = 0;
    end

    fprintf('Iter %d | ori %d |  grad update %.6e | count  %d |x diff %.6e \n', ...
            L, l, update_grad ,count, x_diff);

    zeta_buffer(:,:,:,l) = zeta;
    grad_buffer(:,:,:,l) = grad_f;
    x = x_new;

    if count == (nd * 2) 
        break
    end
         
end
toc

x_omnis = x .* mask ; 


clear x zeta_buffer zeta x_new x_diff
clear L l step_size num_iter count
clear D y W2 Dx temp update_grad grad_f grad_buffer

rmse_omnis= compute_nrmse(x_omnis, gt); 
psnr_omnis = compute_psnr(x_omnis, gt);
ssim_omnis = compute_ssim(x_omnis, gt);
hfen_omnis = compute_hfen(x_omnis, gt);

disp(['nrmse ', num2str(rmse_omnis),'% psnr ', num2str(psnr_omnis), '% ssim ', num2str(ssim_omnis),'% hfen ', num2str(hfen_omnis), '%'])
 
imagesc3d2(x_omnis , N/2, 3, [90,90,90], scale_gt, [], 'OMNIS') 
imagesc3d2(gt, N/2, 1, [90,90,90], scale_gt, [], 'GT')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NDI
% Code taken from: https://github.com/polakd/NDI_Toolbox
% Original step_size = 2 and num_iter = 200 (Lead to divergence for simulated data)
% Adjusted for simulated data to step_size = 0.1 and num_iter = 500
% (Reason given in paper)

disp('NDI')
tic
step_size = 0.1;      % gradient descent step size
num_iter = 500;       

M2 = Wgt_use; 


if nd == 1
    tol = 0.5;      % 1-direction may require more iterations: decrease convergence tolerance
else
    tol = 1;
end

Chi = zeros( N , 'single');
grad_prev = 0;

for t = 1:num_iter
    temp = M2 .* sin(real(ifft(ifft(ifft(kernel(:,:,:,1:nd) .* repmat(fftn(Chi),[1,1,1,nd]), [], 1), [], 2), [], 3) - phs_use) ); %ifft separtely on each dim

    grad_f = 2 * sum(ifft(ifft(ifft(kernel(:,:,:,1:nd) .* fft(fft(fft(temp, [], 1), [], 2), [], 3), [], 1), [], 2), [], 3), 4);

    Chi = Chi - step_size * real(grad_f);

    update_grad = compute_nrmse(grad_prev, grad_f);

    disp(['iter: ', num2str(t), '   grad update:', num2str(update_grad)])

    if update_grad < tol
        break
    end

    grad_prev = grad_f;
end
toc

x_ndi = Chi .* mask ;

clear Chi grad_prev grad_f temp M2 update_grad
clear step_size num_iter tol

rmse_ndi= compute_nrmse(x_ndi, gt); 
psnr_ndi = compute_psnr(x_ndi, gt);
ssim_ndi = compute_ssim(x_ndi, gt);
hfen_ndi = compute_hfen(x_ndi, gt);


disp(['nrmse ', num2str(rmse_ndi),'% psnr ', num2str(psnr_ndi), '% ssim ', num2str(ssim_ndi),'% hfen ', num2str(hfen_ndi), '%'])

figure;
imagesc3d2(x_ndi , N/2, 4, [90,90,90], scale_gt, [], 'NDI') 
imagesc3d2(gt, N/2, 1, [90,90,90], scale_gt, [], 'GT')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Saving
if save_outputs == 1
    cos = single(cos);
    x_omnis = single(x_omnis);
    x_ndi = single(x_ndi);

    filename_cos = sprintf('%s/cosmos_%d.mat', output_folder, nd);
    filename_omnis = sprintf('%s/omnis_%d.mat', output_folder, nd);
    filename_ndi = sprintf('%s/ndi_%d.mat', output_folder, nd);

    save(filename_cos, 'cos');
    save(filename_omnis, 'x_omnis');
    save(filename_ndi, 'x_ndi');

    disp('Files Saved')
end

% Table Display
fprintf('Total Orientations: %d \n' , nd);
disp(['COSMOS: nrmse ', num2str(rmse_cos),'% psnr ', num2str(psnr_cos), '% ssim ', num2str(ssim_cos),'% hfen ', num2str(hfen_cos) , '%'])
disp(['NDI:    nrmse ', num2str(rmse_ndi),'% psnr ', num2str(psnr_ndi), '% ssim ', num2str(ssim_ndi),'% hfen ', num2str(hfen_ndi), '%'])
disp(['OMNIS:  nrmse ', num2str(rmse_omnis),'% psnr ', num2str(psnr_omnis), '% ssim ', num2str(ssim_omnis),'% hfen ', num2str(hfen_omnis), '%'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROI Reconstruction Error
% Calculation based on QSM 2016 challenge code: http://qsm.neuroimaging.at

brain_mask = mask;
mask_path = 'Sim1Snr1/SegmentedModel.nii.gz';
label_mask = niftiread(mask_path);
label_mask = label_mask .* brain_mask;

wm_mask = (label_mask ~= 8);
wm_px = sum(wm_mask(:));
gm_mask = (label_mask == 9);
gm_px = sum(gm_mask(:));

methods = struct( ...
    'COSMOS', cos, ...
    'NDI',   x_ndi, ...
    'OMNIS',   x_omnis );

names = fieldnames(methods);

fprintf('Method\t\tGM Error\t~WM Error\n');
fprintf('---------------------------------------\n');

for i = 1:length(names)
    name = names{i};
    recon = methods.(name);

    gm_error = ( sum(abs(recon(gm_mask) - gt(gm_mask))) / gm_px ) .* 100;
    wm_error = (sum(abs(recon(wm_mask) - gt(wm_mask))) / wm_px) .*100;

    fprintf('%s\t\t%.4f\t\t%.4f\n', name, gm_error, wm_error);
end


