%% Exercise 2.3 - Santa Fe dataset
clear;
close all;

%% Load dataset
load santafe.mat
% Visualize train and test data
figure;
hold on;
plot(Z,'k');
idx=length(Z):length(Z)+length(Ztest);
plot(idx,[Z(end); Ztest],'r','LineWidth',1.1);
xlabel('t')
ylabel('value')
hold off;

%% Definitions
orderlist = [1 2 5 10 15 20 25 30 35 40 45 50 60 70 80 90 100];
n = length(orderlist);
gamlist = zeros(1,n);
sig2list = zeros(1,n);
mse = zeros(1,n);
mae = zeros(1,n);
rmse = zeros(1,n);

%% Loop over order values
for i=1:n
    % Turn dataset into AR input
    order = orderlist(i); % how many past time steps to consider for prediction
    X=windowize(Z, 1:(order+1)); % convert to regression problem
    Y=X(:,end); % Y = last column of X
    X=X(:,1:order); % X = X except for last column

	% Auto-tuning of gam and sig2
    %igam=10;isig2=5;
    model = {X,Y,'f',[],[],'RBF_kernel'};
    [gam,sig2] = tunelssvm(model,'simplex','crossvalidatelssvm', {10, 'mae'}); % CAUTION!!!
    % Store tuned params
    gamlist(i)=gam;
    sig2list(i)=sig2;
    
    % LS-SVM training
    [alpha, b] = trainlssvm({X,Y,'f',gam,sig2});

    % Prediction
    Xs=Z(end-order+1:end,1); % initial input points for prediction
    nb=200; % time points we want to predict
    prediction=predict({X,Y,'f',gam,sig2},Xs,nb);
    % Performance
    mse(i)=mean((prediction-Ztest).^2);
    rmse(i)=sqrt(mse(i));
    mae(i)=mean(abs(prediction-Ztest));
end

%% Plot order-cost graph
figure 
hold on
xlabel('order')
ylabel('cost')
plot(orderlist, mae,'b','LineWidth',1.5);
plot(orderlist, rmse,'g','LineWidth',1.5);
legend('MAE','RMSE');
hold off

%% Find hyperparam set with lowest cost
[minimum, idx] = min(mae);
order=orderlist(idx);
gam=gamlist(idx);
sig2=sig2list(idx);

%% Predict with the best model
X=windowize(Z, 1:(order+1)); % convert to regression problem
Y=X(:,end); % Y = last column of X
X=X(:,1:order); % X = X except for last column
Xs=Z(end-order+1:end,1); % initial input points for prediction
nb=200; % time points we want to predict
[alpha,b]=trainlssvm({X,Y,'f',gam,sig2,'RBF_kernel'});
prediction=predict({X,Y,'f',gam,sig2},Xs,nb);

%% Plot predictions
figure;
hold on;
plot(Ztest,'k','LineWidth',1.2);
plot(prediction,'r','LineWidth',1.2);
legend('Ztest','predicted');
xlabel('time step')
ylabel('value')
hold off;