%% Exercise 2.2 - Wisconsin Breast Cancer dataset
clear;
close all;

%% load dataset
load breast.mat
Xtrain=trainset;
Ytrain=labels_train;
Xtest=testset;
Ytest=labels_test;

%% Visualize the dataset
% Train
rng default % for reproducibility
Y = tsne(Xtrain,'Algorithm','barneshut','NumPCAComponents',5,'NumDimensions',3);
figure
scatter3(Y(:,1),Y(:,2),Y(:,3),15,Ytrain,'filled');
% Test
Y = tsne(Xtest,'Algorithm','barneshut','NumPCAComponents',5,'NumDimensions',3);
figure
scatter3(Y(:,1),Y(:,2),Y(:,3),15,Ytest,'filled');

%% General conf
type='c'; % classification
algorithm='simplex'; % or 'gridsearch'
k = 10; % k-fold crossvalidation

%% Linear kernel
kernel_type='lin_kernel';
model={Xtrain,Ytrain,type,[],[],kernel_type};
[gam,cost] = tunelssvm(model,algorithm,'crossvalidatelssvm',{k,'misclass'});
% Train the classification model
[alpha,b] = trainlssvm({Xtrain,Ytrain,type,gam,[],kernel_type});
% Classification on test data
[Yest, Ylatent]=simlssvm({Xtrain,Ytrain,type,gam,[],kernel_type},{alpha,b},Xtest);
% ROC curve
roc(Ylatent,Ytest);

%% Polynomial kernel
kernel_type='poly_kernel';
model={Xtrain,Ytrain,type,[],[],kernel_type};
[gam,sig2,cost] = tunelssvm(model,algorithm,'crossvalidatelssvm',{k,'misclass'});
% Train the classification model
[alpha,b] = trainlssvm({Xtrain,Ytrain,type,gam,sig2,kernel_type});
% Classification on test data
[Yest, Ylatent]=simlssvm({Xtrain,Ytrain,type,gam,sig2,kernel_type},{alpha,b},Xtest);
% ROC curve
roc(Ylatent,Ytest);

%% RBF kernel
kernel_type='RBF_kernel';
model={Xtrain,Ytrain,type,[],[],kernel_type};
[gam,sig2,cost] = tunelssvm(model,algorithm,'crossvalidatelssvm',{k,'misclass'});
% Train the classification model
[alpha,b] = trainlssvm({Xtrain,Ytrain,type,gam,sig2,kernel_type});
% Classification on test data
[Yest, Ylatent]=simlssvm({Xtrain,Ytrain,type,gam,sig2,kernel_type},{alpha,b},Xtest);
% ROC curve
roc(Ylatent,Ytest);