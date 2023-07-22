%% Exercise 1.2.2 - Sinc function estimation (auto-tuning)
clear;
close all;

%% Dataset
X=(-3:0.01:3)';
Y=sinc(X)+0.1*randn(length(X),1);
Xtrain=X(1:2:end);
Ytrain=Y(1:2:end);
Xtest=X(2:2:end);
Ytest=Y(2:2:end);

%% Auto-tuning
type = 'f';
kernel_type = 'RBF_kernel';
model = {Xtrain,Ytrain,type,[],[],kernel_type};
algorithm='gridsearch';
% Auto-tuning
[gam,sig2] = tunelssvm(model,algorithm,'crossvalidatelssvm', {10, 'mse'});

%% Training
[alpha,b] = trainlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel'});
Yt = simlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel','preprocess'},{alpha,b},Xtest);
% Plot
plotlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel','preprocess'},{alpha,b});
hold on; plot(min(X):.1:max(X),sinc(min(X):.1:max(X)),'r-.');

%% Results
MSE = mean((Yt - Ytest).^2);   % Mean Squared Error
disp(gam);
disp(sig2);
disp(MSE);