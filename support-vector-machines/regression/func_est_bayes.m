%% Exercise 1.2.3 - Bayesian framework
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
% Initial hyperparam values
sig2 = 0.4;
gam = 10;
% Param optimization
%crit_L1 = bay_lssvm ({ Xtrain , Ytrain , 'f', gam , sig2 }, 1);
%crit_L2 = bay_lssvm ({ Xtrain , Ytrain , 'f', gam , sig2 }, 2);
crit_L3 = bay_lssvm ({ Xtrain , Ytrain , 'f', gam , sig2 }, 3);
%[~, alpha ,b] = bay_optimize ({ Xtrain , Ytrain , 'f', gam , sig2 }, 1);
[~, gam] = bay_optimize ({ Xtrain , Ytrain , 'f', gam , sig2 }, 2);
[~, sig2 ] = bay_optimize ({ Xtrain , Ytrain , 'f', gam , sig2 }, 3);
sig2e = bay_errorbar ({ Xtrain , Ytrain , 'f', gam , sig2 }, 'figure');