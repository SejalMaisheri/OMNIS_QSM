% Details of how to generate Multiori dataset from Single orientation RC2 framework data and code.


% Single orientation RC2 framework data and code : https://doi.org/10.34973/m20r-jt17
% Download from above link to get all required files. 

% Below changes were done to generate Multiori dataset:
% 1) Details of eight B0_dir directions used. 
% 2) Details of Signal Simulation
% 3) Details of Preprocessing
% 4) Final Save format we use:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Details of eight B0_dir directions used

%Using Angles:
%B0_dir = [ 0 0 1]
%Along X : 22, -22, 10 , -15 degrees
%Along Y : 22, -22 , 10 degrees
%Rotation around X-axis: B0_dir = [ 0 -sintheta costheta ]
%Rotation around Y-axis: B0_dir = [ sintheta 0 costheta]

%B0_dir Creation - theta in degrees
function dir = around_X(theta) 

 dir = [0, -sind(theta), cosd(theta)];
 dir = dir / norm(dir);  % normalize 

end

function dir = around_Y(theta)

 dir = [sind(theta), 0, cosd(theta)];
 dir = dir / norm(dir);

end

B0_dirs = [
    [0 0 1];                     % ori_1  usual case

    around_X(22);               % ori_2
    around_X(-22);              % ori_3
    around_X(10);               % ori_4

    around_Y(22);              % ori_5
    around_Y(-22);             % ori_6
    around_Y(10);              % ori_7

    around_X(-15)              % ori_8
    ];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2) Details of Signal Simulation

 % Use RC2 code file named : MacroCreateSimulationData.m
 % Use Challenge Protocol of this file ( Protocol == 3 )

% CHANGES:
 % Change SimParams{Protocol}.B0_dir = B0_dirs(i,:) for ith orientation

 % Set SimParams{Protocol}.Output_dir as per where you want to save
 % Magnitude and Phase data for different echos. Subfolder name SimulatedHR
 % will be created inside that Output_dir

% KEEP REST all parameters same like: 
 % 1) Chimap_file = 
 % = 'data/chimodel/ChiModelMIX.nii for SIM2  and
 % = 'data/chimodel/ChiModelMIX_noCalc.nii for SIM 1
 % 2) PhaseOffset = 0
 % 3) Shimm = 1 
 % Note: Shimm will automatically get 0 for BrainExtracted Simulation
 % 4) Res = [ 1 1 1]
 % Note: This Res is for downsampled signal (sig). 
 % Original Resolution Signal (sigHR) will be having 0.64mm


% MacroCreateSimulationData.m uses file CreateSimulatedData.m 
 % Change B0_dir in that file. 
 % B0_dir= SimParams.B0_dir; ( from B0_dir = [0 0 1])

 % Note: We used BackGroundFieldRemoval = 1 case only
 % This case corresponds to BrainExtracted Region. 
 % Note: We used High-Res signal (sigHR) instead of Downsampled Signal (sig)
 
% From this section you will get SimulatedHR folder containing 4 echoes's
% magnitude and phase images.
% ( For example: SimulatedHR/Magnitude_TE004BrainExtracted )



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3) Details of Preprocessing

 % Use RC2 code file named : MacroCreateQSMpipelineAndCompareHighResLowRes.m
 % Follow above file guidelines to download SEPIA for preprocessing. 

% CHANGES:
 % Change SimulationParameters.mat file's path for loading. 
 % Set ResCount = 2 ( from 1) for HR 
 % Set peak_SNR = 100 for SNR1 and = 1000 for SNR2
 % Set OutputDir{DataCount} (Path to save noisy Data_magn and Data_phase)


% Follow the file and SEPIA documentation to download preprocessing packages.
% Stop code at: SepiaIOWrapper(input,output_basename,mask_filename,algorParam)

% AFTER SUCCESSFUL RUN u will get: 
 % 1) unwrapping\Data_fieldmap.nii.gz  as Frequency Map or Local field Map
 % in Hz unit. 
 % Data_fieldmap is generated before Background field removal step, for
 % Challenge Protocol using BrainExtracted Region only, this is same as local
 % field map. 
 % 2) unwrapping\Data_weights.nii.gz as Weighting Map


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4) Final Save format we use: 

   % Sim1Snr1 --> 
   %  Gt.mat, mask.mat, phase_all.mat, weights_all.mat, kernel_all.mat


%CODE: 

output_path = 'Sim1Snr1'; % Set yourself

% LOCAL FIELD MAPS
% Put your file paths here % Change for Sim1/Sim2 and Snr1/Sinr2
paths = {
    '...\ori_1_data\unwrapping\Data_fieldmap.nii.gz' 
    '...\ori_2_data\unwrapping\Data_fieldmap.nii.gz'
    '...\ori_3_data\unwrapping\Data_fieldmap.nii.gz'
    '...\ori_4_data\unwrapping\Data_fieldmap.nii.gz'
    '...\ori_5_data\unwrapping\Data_fieldmap.nii.gz'
    '...\ori_6_data\unwrapping\Data_fieldmap.nii.gz'
    '...\ori_7_data\unwrapping\Data_fieldmap.nii.gz'
    '...\ori_8_data\unwrapping\Data_fieldmap.nii.gz'
};

for i = 1:8
    vol = niftiread(paths{i});
    vol = single(vol);   
    
    if i == 1
        [nx, ny, nz] = size(vol);
        phase_all = zeros(nx, ny, nz, 8);
        
    end
    
    phase_all(:,:,:,i) = vol;
end
info = niftiinfo(paths{1});
voxel_size = info.PixelDimensions;  % 0.64
disp(voxel_size);
matrix_size = size(phase_all(:,:,:,1)); % [256, 320, 320]
disp(matrix_size)
unit = 'Hz';
save(fullfile(output_path,'phase_all_100.mat'),'phase_all', 'voxel_size', 'matrix_size', 'unit', '-v7.3');  % 100 is for Snr1, set name yourself. 

% WEIGHTING MAPS 
weight_paths = {
    '...\ori_1_data\unwrapping\Data_weights.nii.gz'
    '...\ori_2_data\unwrapping\Data_weights.nii.gz'
    '...\ori_3_data\unwrapping\Data_weights.nii.gz'
    '...\ori_4_data\unwrapping\Data_weights.nii.gz'
    '...\ori_5_data\unwrapping\Data_weights.nii.gz'
    '...\ori_6_data\unwrapping\Data_weights.nii.gz'
    '...\ori_7_data\unwrapping\Data_weights.nii.gz'
    '...\ori_8_data\unwrapping\Data_weights.nii.gz'
};

for i = 1:8
    vol = niftiread(weight_paths{i});
    vol = single(vol);
    
    if i == 1
        [nx, ny, nz] = size(vol);
        weights_all = zeros(nx, ny, nz, 8);
    end
    
    weights_all(:,:,:,i) = vol;
end
info = niftiinfo(weight_paths{1});
voxel_size = info.PixelDimensions;  
disp(voxel_size);
matrix_size = size(weights_all(:,:,:,1));
disp(matrix_size)
save(fullfile(output_path, 'weights_all_100.mat'), 'weights_all','voxel_size', 'matrix_size', '-v7.3');

% DIPOLE KERNELS
% Below Dipole kernel function taken from RC2 framework : https://doi.org/10.34973/m20r-jt17
function D = create_dipole_kernel(B0_dir, voxel_size, N, createInKspace)

if createInKspace  
    disp('Dipole kernel created directly in k-space - it does support rotations')
    [ky,kx,kz] = meshgrid(-N(2)/2:N(2)/2-1, -N(1)/2:N(1)/2-1, -N(3)/2:N(3)/2-1);

    kx = (kx / max(abs(kx(:)))) / (2*voxel_size(1));
    ky = (ky / max(abs(ky(:)))) / (2*voxel_size(2));
    kz = (kz / max(abs(kz(:)))) / (2*voxel_size(3));

    k2 = kx.^2 + ky.^2 + kz.^2;

%     R_tot = eye(3);
%     R_tot (3,1:3)=B0_dir;
    D = fftshift( 1/3 - (kx * B0_dir(1) + ky * B0_dir(2) + kz * B0_dir(3)).^2 ./ (k2 + eps) );       
else
    disp('Dipole kernel created in the object domain')
    % dipole kernel: (3*cos(theta)^2 - 1) / (4*pi*r^3)

    [Y,X,Z] = meshgrid(-N(2)/2:(N(2)/2-1),...
        -N(1)/2:(N(1)/2-1),...
        -N(3)/2:(N(3)/2-1));

    X = X * voxel_size(1);
    Y = Y * voxel_size(2);
    Z = Z * voxel_size(3);

    d = prod(voxel_size) * ( 3 * (X*B0_dir(1) + Y*B0_dir(2) + Z*B0_dir(3)).^2 - X.^2 - Y.^2 - Z.^2 ) ./ (4 * pi * (X.^2 + Y.^2 + Z.^2).^2.5);

    d(isnan(d)) = 0;
    D = fftn(fftshift(d));
end

end


kernel_all = [];

for i = 1:8
    B0_dir = B0_dirs(i,:);
    fprintf('B0_dir used: [%g %g %g]\n', B0_dir);
    D = create_dipole_kernel(B0_dir , voxel_size, matrix_size, 1);   %voxel = 0.64, matrixsize = [256,320,320]  
    kernel_all = cat(4, kernel_all, D);
end
kernel_all = single(kernel_all);
save(fullfile(output_path, 'kernel_all.mat'), 'kernel_all', '-v7.3');


% MASK
mask = niftiread('...\data\masks\BrainMask.nii.gz');
save(fullfile(output_path, 'mask.mat'), 'mask', '-v7.3');

% GT
gt = niftiread('...\data\chimodel\ChiModelMIX_noCalc.nii'); %For Sim1
% gt = niftiread('...\data\chimodel\ChiModelMIX.nii') %For Sim2
gt = (gt - mean(gt(mask == 1))) .* mask ;
gt = single(gt);
save(fullfile(output_path, 'Gt.mat'), 'gt','voxel_size', 'matrix_size' ,'-v7.3');
