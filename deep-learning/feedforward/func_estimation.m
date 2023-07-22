clear
clc
close all
rng(1) % fix seed for randomness

%%%%%%%%%%%
%ann_func_estimation.m
% A script performing function estimation using a feed-forward neural 
% network and various learning algorithms
%%%%%%%%%%%

%%
% Configuration
% algList = ["traingd", "traingda", "traincgf", "traincgp", "trainbfg", "trainlm"];
algList = ["traingd", "traingda", "traincgf", "traincgp", "trainbfg", "trainlm"];
H = 50;% Number of neurons in the hidden layer
delta_epochs = [1,14,85,900];% Number of epochs to train in each step
epochs = cumsum(delta_epochs);
%generation of examples and targets
dx=0.05;% Decrease this value to increase the number of data points
x=0:dx:3*pi;y=sin(x.^2);
sigma=0.2;% Standard deviation of added noise
yn=y+sigma*randn(size(y));% Add gaussian noise
t=y;% Targets. Change to yn to train on noisy data
% Define arrays to store results
nEpochs = length(delta_epochs);% number of epochs
nAlg = length(algList);% number of algorithms
MSE = zeros(nAlg,nEpochs);% mse array
elapsed = zeros(nAlg,nEpochs);% elapsed time array

%%
% Training and simulation
for i=1:nAlg
    %creation of network
    net=feedforwardnet(H,algList(i));% Define the feedfoward net (hidden layers)
    net=configure(net,x,t);% Set the input and output sizes of the net
    net.divideFcn = 'dividetrain';% Use training set only (no validation and test split)
    net=init(net);% Initialize the weights (randomly)
    for j=1:nEpochs
        net.trainParam.epochs=delta_epochs(j);% set the number of epochs for the training
        tic
        net = train(net,x,t); % train the network
        y_sim = sim(net,x); % simulate the networks with the input vector x
        if j>1
            elapsed(i,j) = elapsed(i,j-1) + toc;
        else
            elapsed(i,j) = toc;
        end
        MSE(i,j) = perform(net, t, y_sim); % mse

    end
end

%% 
% Print values
MSE
elapsed

%%
% Write results to csv
%writematrix(MSE, "mse.csv")
%writematrix(elapsed, "elapsed.csv")