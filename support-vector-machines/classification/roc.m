%% Exercise 1.3.4 - ROC Curves
clear
close all;

% Load the dataset
load iris.mat

% Model params
gam=0.01;
sig2=10;

% Train the classification model.
[alpha , b] = trainlssvm({Xtrain, Ytrain, 'c', gam, sig2,'RBF_kernel'});

% Classification of the test data.
[Yest, Ylatent] = simlssvm({Xtrain, Ytrain, 'c', gam, sig2,'RBF_kernel'}, {alpha , b}, Xtest);

% Generating the ROC curve.
roc(Ylatent, Ytest);