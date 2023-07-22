%% Exercise 1.3 - Automatic Relevance Determination
clear;
close all;

% Variables
X=6.*rand(100,3)-3;
Y=sinc(X(:,3))+0.1.*randn(100,1);

% Params
gam=10;
sig2=0.4;

% X1
model1 = {X(:,1),Y,'f',gam,sig2,'RBF_kernel'};
cost1 = crossvalidate(model1, 10, 'mse')
% X3
model2 = {X(:,2),Y,'f',gam,sig2,'RBF_kernel'};
cost2 = crossvalidate(model2, 10, 'mse')
% X2
model3 = {X(:,3),Y,'f',gam,sig2,'RBF_kernel'};
cost3 = crossvalidate(model3, 10, 'mse')