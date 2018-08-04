% ========================================================================
% Code to plot dictionary visualizations
% =========================================================================

%% Load the dictionary file
path = 'Dictionary\D_Satellite2_1024_0.15_5.mat'; % Our satellite dictionary
path = 'Dictionary\D_1024_0.15_5.mat'; % %Yang's original dictionary
load(path);

%% Rearrange Dh into patches
minDh = min(min(Dh));
maxDh = max(max(Dh));
DhPatchGrid = zeros(191,191) + minDh; % The background color should be black
[nrow,ncol] = size(Dh);
for i = 1:ncol
    DhPatch = reshape(Dh(:,i),[5,5]);
    
    gridX = mod(i-1,32)+1;
    gridY = floor((i-1)/32)+1;
    
    % fprintf(['Patch ', num2str(i), ' gridX ', num2str(gridX), ' gridY ', num2str(gridY),'\n']);
    DhPatchGrid((1:5)+(gridY-1)*6,(1:5)+(gridX-1)*6) = DhPatch;
end

%% Rescale to make more visible
DhPatchGrid = (DhPatchGrid - minDh)/(maxDh-minDh)*1.25;
figure, imshow(DhPatchGrid)