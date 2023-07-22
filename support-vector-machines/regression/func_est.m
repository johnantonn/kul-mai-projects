%% Exercise 1.2.1 - Sinc function estimation
clear;
close all;

%% Dataset
X=(-3:0.01:3)';
Y=sinc(X)+0.1*randn(length(X),1);
Xtrain=X(1:2:end);
Ytrain=Y(1:2:end);
Xtest=X(2:2:end);
Ytest=Y(2:2:end);

%% SVM Regression
gamlist = [1e0 1e1 1e3 1e5 1e6];
sig2list = [1e-2 1e-1 1e0 1e1 1e2];
MSE = zeros(length(gamlist),length(sig2list));

% For loop
for i=1:length(gamlist) 
    for j=1:length(sig2list)
        gam = gamlist(i);
        sig2 = sig2list(j);
        type = 'f';
        [alpha,b] = trainlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel'});
        Yt = simlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel','preprocess'},{alpha,b},Xtest);
        figure
        plotlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel','preprocess'},{alpha,b});
        MSE(i,j) = mean((Yt - Ytest).^2);   % Mean Squared Error
    end
end

%% Plots
%display(MSE)
cdata = MSE;
xvalues = sig2list;
yvalues = gamlist;
h = heatmap(xvalues,yvalues,cdata);
h.XLabel = 'sig2';
h.YLabel = 'gam';