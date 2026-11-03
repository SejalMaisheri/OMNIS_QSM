
function [ PSNR ] = compute_psnr( chi_recon, chi_true )


img1 = chi_recon;
img2 = chi_true;

min_img = min(img2(:));

img1(img1~=0) = img1(img1~=0) - min_img;
img2(img2~=0) = img2(img2~=0) - min_img;

max_img = max(img2(:));

img1 = 255 * img1 ./ max_img;
img2 = 255 * img2 ./ max_img;


PSNR = psnr(img1, img2, 255);

end


%{
%Gives the same result as above function.

%PSNR function
function PSNR = compute_psnr(chi_recon, chi_true)

% Ground-truth dynamic range
max_val = max(chi_true(:));
min_val = min(chi_true(:));

MAX_I = max_val - min_val;

% Mean squared error
mse = mean((chi_recon(:) - chi_true(:)).^2);

% PSNR
PSNR = 10 * log10((MAX_I^2) / mse);

end
%}

