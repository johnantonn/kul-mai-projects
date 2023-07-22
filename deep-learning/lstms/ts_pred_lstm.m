clear
clc
close all
rng(1) % fix seed for randomness

%%%%%%%%%%%
%ts_pred_lstm.m
% A script performing time series prediction on the Santa Fe dataset 
% using an LSTM neural network
%%%%%%%%%%%

%%
% Import dataset and standardize
dataTrain=importdata('lasertrain.dat').';
numTimeStepsTrain = numel(dataTrain);
dataTest=importdata('laserpred.dat').';
mu=mean(dataTrain); % mean
sig=std(dataTrain); % std
dataTrainStandardized=(dataTrain-mu)/sig; % apply to X
dataTestStandardized=(dataTest-mu)/sig; % apply to Y

%%
% Prepare predictors and responses
p=15;
[XTrain, YTrain] = getTimeSeriesTrainData(dataTrainStandardized.',p);

%%
% Define LSTM network architecture
numFeatures = p;
numResponses = 1;
numHiddenUnits = 20;
layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];
options = trainingOptions('adam', ...
    'MaxEpochs',500, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.007, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',80, ...
    'LearnRateDropFactor',0.25, ...
    'Verbose',0, ...
    'Plots','training-progress');

%%
% Train LSTM network
net = trainNetwork(XTrain,YTrain,layers,options);

%%
% Forecast future timesteps
% Initialize state
net = predictAndUpdateState(net,XTrain);
% First prediction
XNext=YTrain(end-p+1:end).';
[net,YSim] = predictAndUpdateState(net,XNext);
YPred(:,1)=YSim;

% Prediction loop
numTimeStepsTest = numel(dataTest);
for i = 2:numTimeStepsTest
    XNext=[XNext(2:end); YSim];
    [net,YSim] = predictAndUpdateState(net,XNext,'ExecutionEnvironment','cpu');
    YPred(:,i)=YSim;
end

YPred = sig*YPred + mu;

YTest = dataTest(1:end);
rmse = sqrt(mean((YPred-YTest).^2))

%%
% Plot the training time series with the forecasted values
if 0
    figure
    plot(dataTrain(1:end-1))
    hold on
    idx = numTimeStepsTrain:(numTimeStepsTrain+numTimeStepsTest);
    plot(idx,[dataTrain(numTimeStepsTrain) YPred],'.-')
    hold off
    xlabel("Month")
    ylabel("Cases")
    title("Forecast")
    legend(["Observed" "Forecast"])
end
%%
% Compare the forecasted values with the test data.
figure
subplot(2,1,1)
plot(YTest)
hold on
plot(YPred,'.-')
hold off
legend(["Observed" "Forecast"])
ylabel("Cases")
title("Forecast")

subplot(2,1,2)
stem(YPred - YTest)
xlabel("Month")
ylabel("Error")
title("RMSE = " + rmse)

%%
figure
plot(YPred,'LineWidth',1.5)
hold on
plot(YTest,'LineWidth',1.5)
xlabel("Time index")
legend('Predicted', 'Expected')
title("LSTM"+", H="+numHiddenUnits+", Lag="+p);