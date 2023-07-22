%% Exercise 1.4 - Robust Regression
clear;
close all;

%% Dataset
X=(-6:0.2:6)';
Y = sinc (X) + 0.1.* rand ( size (X));
% Outliers
out = [15 17 19];
Y( out) = 0.7+0.3* rand ( size ( out));
out = [41 44 46];
Y( out) = 1.5+0.2* rand ( size ( out));

%% Without paying attention
model = initlssvm (X, Y, 'f', [], [], 'RBF_kernel');
costFun = 'crossvalidatelssvm';
model = tunelssvm (model , 'simplex', costFun , {10 , 'mse';});
plotlssvm ( model );

%% Deal with outliers
model = initlssvm (X, Y, 'f', [], [], 'RBF_kernel');
costFun = 'rcrossvalidatelssvm';
wFun = 'wmyriad'; % whuber, whampel, wlogistic, wmyriad
model = tunelssvm (model , 'simplex', costFun , {10 , 'mae';}, wFun );
model = robustlssvm ( model );
plotlssvm ( model );