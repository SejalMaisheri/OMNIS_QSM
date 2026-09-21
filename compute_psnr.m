
% All three codes gives the same result.

function [ PSNR ] = compute_psnr( chi_recon, chi_true )


img1 = chi_recon;

img2 = chi_true;

%min_img = min(min(img1(:)), min(img2(:)));
min_img = min(min(img2(:)));

img1(img1~=0) = img1(img1~=0) - min_img;
img2(img2~=0) = img2(img2~=0) - min_img;

%max_img = max(max(img1(:)), max(img2(:)));
max_img = max(max(img2(:)));

img1 = 255 * img1 ./ max_img;
img2 = 255 * img2 ./ max_img;


PSNR = psnr(img1, img2, 255);

end


%{
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

%{
function PSNR = compute_psnr(chi_recon, chi_true, mask)

img1 = chi_recon;
img2 = chi_true;


min_true = min(img2(:));
max_true = max(img2(:));
data_range = max_true - min_true;

% Apply mask
img1 = img1 .* mask;
img2 = img2 .* mask;

% Calculate PSNR
PSNR = psnr(img1, img2,data_range );

end
%}