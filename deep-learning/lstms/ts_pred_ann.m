clear
clc
close all
rng(1) % fix seed for randomness

%%%%%%%%%%%
%ts_pred_ann.m
% A script performing time series prediction on the Santa Fe dataset 
% using a 2-layer feedforward ANN
%%%%%%%%%%%

%%
% Import dataset and normalize
X_train_init=importdata('lasertrain.dat');
Y_test_init=importdata('laserpred.dat');
mu_train=mean(X_train_init); % mean
sd_train=std(X_train_init); % std
X_train_norm=(X_train_init-mu_train)/sd_train; % apply to X
Y_test_norm=(Y_test_init-mu_train)/sd_train; % apply to Y

%%
% Plot training and test set
figure;
subplot(1,2,1)
plot(X_train_init); % plot training set
xlabel("Time index")
title('Training set')
hold on
subplot(1,2,2)
plot(Y_test_init,'LineWidth',1.5); % plot test set
xlabel("Time index")
title('Test set')

%%
% Configure a 2-layer MLP for training
lagArray=[5 10 15 20 25 30];
[~, n]=size(lagArray);
MSE=zeros(n,1);
RMSE=zeros(n,1);
elapsed=zeros(n,1);
for i=1:n % lag
    lagArray(i)
    [X_train, Y_train]=getTimeSeriesTrainData(X_train_norm,lagArray(i));
    alg='trainlm'; % training algorithm
    H=20; % num of neurons in the hidden layer
    net=feedforwardnet(H,alg);% Define the feedfoward net
    net=configure(net,X_train,Y_train);% Set the input and output sizes of the net
    net.divideFcn='divideblock'; % divide to train, validation
    net.divideParam.trainRatio = 0.8; % for train
    net.divideParam.valRatio = 0.2; % validation
    net.divideParam.testRatio = 0.0; % test
    net.trainParam.epochs=200;% set the number of epochs
    net=init(net);% Initialize the weights (randomly)

    %%
    % Training
    tic
    net=train(net,X_train,Y_train); % train the network
    elapsed(i)=toc;

    %%
    % Predict the next 100 values
    Y_pred=zeros(100,1);
    X_next=X_train_norm(end-lagArray(i)+1:end); % input of first prediction
    for j=1:100
        y_sim=sim(net,X_next); % sim net with input x
        Y_pred(j)=y_sim; % save value
        X_next=[X_next(2:end); y_sim]; % updade according to prediction
    end

    %%
    % Evaluation
    Y_pred_final = Y_pred * sd_train + mu_train; %unstandardize
    MSE(i) = perform(net,Y_test_init,Y_pred_final);
    RMSE(i) = sqrt(mean((Y_pred_final-Y_test_init).^2))
    %%
    % Plot results for the original sets
    if 0
        figure
        plot(Y_pred_final,'LineWidth',1.5)
        hold on
        plot(Y_test_init,'LineWidth',1.5)
        xlabel("Time index")
        legend('Predicted', 'Expected')
        title("Algorithm: "+alg+", H="+H+", Lag="+lagArray(i));
    end
end