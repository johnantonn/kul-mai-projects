clear
clc
close all
rng(1) % fix seed for randomness

%%%%%%%%%%%
%pca_digits.m
% A script performing PCA analysis on handwritten digit image
%%%%%%%%%%%

%%
% Input dataset
threes=load('threes','-ascii');
figure
colormap('gray'); 
imagesc(reshape(threes(1,:),16,16),[0,1]) % plot for fun
title('threes(1)');

%%
% Mean of threes
mu=mean(threes);
figure
colormap('gray'); 
imagesc(reshape(mu,16,16),[0,1]) % plot for fun
title('mean(threes)');

%% 
% Eigenvalue decomposition
[qMax, ~]=size(threes); % max dims
qPCA=256;
rmse=zeros(qPCA,1);
for q=1:qPCA % number of principal components
    covT=cov(threes'); % covariance matrix
    [V,D]=eigs(covT,q); % eigenvectors and eigenvalues
    % plot(diag(D)); % plot the eigenvalues
    Z=V'*threes;
    threesHat=V*Z; % Reconstruction
    rmse(q)=sqrt(mean(mean((threes-threesHat).^2))); % rmse
end

%%
% Plot RMSE vs principal components
figure
plot(rmse,'linewidth',2)
title('Performance of handwritten digit PCA')
xlabel("Principal components")
ylabel("RMSE")

%%
% Plot threes and threesHat
figure
colormap('gray');
subplot(1,2,1);
imagesc(reshape(threes(1,:),16,16),[0,1]);
title('Original');
subplot(1,2,2);
imagesc(reshape(threesHat(1,:),16,16),[0,1]);
title("Reconstructed"+", q="+qPCA);

%%
% Plot cumsum of eigenvalues
eigSum=sum(diag(D))-cumsum(diag(D)); % matrix storing the inverse cumsum
figure
plot(eigSum,'linewidth',2);
title("Cumulative sum of all but the q largest eigenvalues");
xlabel('q');
ylabel('$S\bar{q}$','Interpreter','Latex');