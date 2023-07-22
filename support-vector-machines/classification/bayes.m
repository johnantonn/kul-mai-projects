%% Exercise 1.3.5 - Bayesian Framework
clear
close all;

% Load the dataset
load iris.mat

% Model params
gam=41;
sig2=10;

% Bayesian framework
bay_modoutClass({Xtrain, Ytrain, 'c', gam, sig2}, 'figure');
colorbar;