clear
clc
close all
rng(1) % fix seed for randomness

%%%%%%%%%%%
%pca_comparison.m
% A script comparing PCA dimensionality reduction between
% (a) random and (b) highly correlated datasets
%%%%%%%%%%%

%%
% Input datasets
X1=randn(50,500); % random gaussian
X2=load('choles_all').p; % only the p component

%% 
% Eigenvalue decomposition of X1
[q1, ~]=size(X1); % max dims
rmse1=zeros(q1,1); % init rmse
for q=1:q1 % number of principal components
    covX1=cov(X1'); % covariance matrix of X1
    [V1,D1]=eigs(covX1,q); % eigenvectors and eigenvalues of covX1
    Z1=V1'*X1; % reduced dataset for X1
    X1h=V1*Z1; % Reconstruction of X1
    rmse1(q)=sqrt(mean(mean((X1-X1h).^2))); % rmse of X1-X1h
end

%% 
% Eigenvalue decomposition of X2
[q2, ~]=size(X2); % max dims
rmse2=zeros(q2,1); % init rmse
for q=1:q2 % number of principal components
    covX2=cov(X2'); % covariance matrix of X2
    [V2,D2]=eigs(covX2,q); % eigenvectors and eigenvalues of covX2
    Z2=V2'*X2; % reduced dataset for X2
    X2h=V2*Z2; % Reconstruction of X2
    rmse2(q)=sqrt(mean(mean((X2-X2h).^2))); % rmse of X2-X2h
end

%%
% Plot
figure
subplot(1,2,1)
plot(rmse1,'linewidth',2)
title("Gaussian noise 50x500")
xlabel("Principal components")
ylabel("RMSE")
subplot(1,2,2)
plot(rmse2,'linewidth',2)
title("Cholesterol dataset 21x264")
xlabel("Principal components")
ylabel("RMSE")