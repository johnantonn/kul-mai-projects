clear
clc
close all
rng(1) % fix seed for randomness

%%%%%%%%%%%
%personal_regression.m
% A script performing function estimation for the personal regression
% problem of exercise 1
%%%%%%%%%%%

%% 
% Create initial dataset
load('data.mat') % load input
d1=8; d2=8; d3=6; d4=3; d5=2; % rnum=0826803
Tnew = (d1*T1 + d2*T2 + d3*T3 + d4*T4 + d5*T5)/(d1+d2+d3+d4+d5); % Tnew
[m, ~] = size(Tnew); % Get size of Tnew

%%
% Create samples from the initial dataset
idx = randperm(m,3000); % shuffle 3000 rows
X1_s = X1(idx); % Sample X1
X2_s = X2(idx); % Sample X2
X_s = [X1_s, X2_s]; X_t = X_s.'; % create network input
T_s = Tnew(idx); T_t = T_s.'; % Create network target
X_test = X_t(:,2001:3000); % test set input values
T_test = T_t(2001:3000); % test set output values

%%
% Plot training set surface
X1_train = X1_s(1:1000);
X2_train = X2_s(1:1000);
T_train = T_s(1:1000);
figure;
xlin = linspace(min(X1_train),max(X1_train),1000) ;
ylin = linspace(min(X2_train),max(X2_train),1000) ;
[X,Y] = meshgrid(xlin,ylin);
f = scatteredInterpolant(X1_train,X2_train,T_train);
Z = f(X,Y);
mesh(X,Y,Z);

%% 
% Neural net configuration
% algList = ["traingd", "traingda", "traincgf", "traincgp", "trainbfg", "trainlm"];
algList = ["traingd", "traingda", "traincgf", "traincgp", "trainbfg", "trainlm"];
H = [1];% Number of neurons in the hidden layer(s)
epochs = 1000;
% Define arrays to store results
nH = length(H); % number of different configurations for H
nAlg = length(algList);% number of algorithms
MSE = zeros(nAlg,nH);% mse array
elapsed = zeros(nAlg,nH);% elapsed time array

%%
% Training and simulation
for i=1:nAlg
    for j=1:nH
        net=feedforwardnet([10 20],algList(i));% Define the feedfoward net
        net=configure(net,X_t,T_t);% Set the input and output sizes of the net
        net.divideFcn = 'divideblock'; % divide dataset to train, validation, test
        net.divideParam.trainRatio = 1/3; % 1/3 for train
        net.divideParam.valRatio = 1/3; % 1/3 for validation
        net.divideParam.testRatio = 1/3; % 1/3 for test
        net.trainParam.epochs=epochs;% set the number of epochs
        net.layers{1}.transferFcn = 'logsig';
        net=init(net);% Initialize the weights (randomly)
        tic
        net=train(net,X_t,T_t); % train the network
        elapsed(i,j) = toc;
        T_sim = sim(net,X_test);
        MSE(i,j) = perform(net, T_test, T_sim); % mse
    end
end

%%
% Write results to csv
writematrix(MSE, "mse.csv")

%%
% Plot MSE
[m, n] = size(MSE);
figure
hold on
for i=1:m
    plot(H,MSE(i,:),'DisplayName',algList(i),'LineWidth',2);
end
legend('Location','north')

% Plot elapsed time
figure
hold on
for i=1:m
    plot(H,elapsed(i,:),'DisplayName',algList(i),'LineWidth',2);
end
legend('Location','north')
