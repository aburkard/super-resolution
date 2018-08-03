clear all; clc;

% load dictionary
load('Dictionary/D_512_0.15_5_s2.mat');

img_path = '../images_bmp/test/lo';
ref_img_path = '../images_bmp/test/hi';
out_path = '../images_bmp/out/sat_dict';
bb_out_path = '../images_bmp/out/bicubic';

%filename_list = dir(img_path);
img_dir = dir(fullfile(img_path, '*.bmp'));
for K = 1 : length(img_dir)
    filename = img_dir(K).name;
    % read test image
    im_l = imread(fullfile(img_path, filename));

    % set parameters
    lambda = 0.2;                   % sparsity regularization
    overlap = 4;                    % the more overlap the better (patch size 5x5)
    up_scale = 2;                   % scaling factor, depending on the trained dictionary
    maxIter = 20;                   % if 0, do not use backprojection

    % change color space, work on illuminance only
    im_l_ycbcr = rgb2ycbcr(im_l);
    im_l_y = im_l_ycbcr(:, :, 1);
    im_l_cb = im_l_ycbcr(:, :, 2);
    im_l_cr = im_l_ycbcr(:, :, 3);

    % image super-resolution based on sparse representation
    [im_h_y] = ScSR(im_l_y, 2, Dh, Dl, lambda, overlap);
    [im_h_y] = backprojection(im_h_y, im_l_y, maxIter);

    % upscale the chrominance simply by "bicubic" 
    [nrow, ncol] = size(im_h_y);
    im_h_cb = imresize(im_l_cb, [nrow, ncol], 'bicubic');
    im_h_cr = imresize(im_l_cr, [nrow, ncol], 'bicubic');

    im_h_ycbcr = zeros([nrow, ncol, 3]);
    im_h_ycbcr(:, :, 1) = im_h_y;
    im_h_ycbcr(:, :, 2) = im_h_cb;
    im_h_ycbcr(:, :, 3) = im_h_cr;
    im_h = ycbcr2rgb(uint8(im_h_ycbcr));

    % bicubic interpolation for reference
    im_b = imresize(im_l, [nrow, ncol], 'bicubic');

    % read ground truth image
    
    im = imread(fullfile(ref_img_path, filename));

    % compute PSNR for the illuminance channel
    bb_rmse = compute_rmse(im, im_b);
    sp_rmse = compute_rmse(im, im_h);

    bb_psnr = 20*log10(255/bb_rmse);
    sp_psnr = 20*log10(255/sp_rmse);

    fprintf('Filename: %s\n', filename);
    fprintf('PSNR for Bicubic Interpolation: %f dB\n', bb_psnr);
    fprintf('PSNR for Sparse Representation Recovery: %f dB\n\n', sp_psnr);

    % show the images
    %figure, imshow(im_h);
    %title('Sparse Recovery');
    %figure, imshow(im_b);
    %title('Bicubic Interpolation');
    imwrite(im_h, fullfile(out_path, filename), 'bmp');
    imwrite(im_b, fullfile(bb_out_path, filename), 'bmp');

end