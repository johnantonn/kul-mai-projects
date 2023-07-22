%% Exercise 1.3 - Automatic Relevance Determination
clear;
close all;

% Variables
X=6.*rand(100,3)-3;
Y=sinc(X(:,1))+0.1.*randn(100,1);

% Params
gam=10;
sig2=0.4;

% ARD
[dimensions, ordered, costs] = bay_lssvmARD({X, Y, 'f', gam, sig2});

% Simple plot
figure
bar(ordered,[1;2;3]);
xlabel('Dataset')
ylabel('Rank')