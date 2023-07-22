%% Exercise 1.3.1 - Iris dataset
clear
close all;

% Load the dataset
load iris.mat

% Configuration
type='c';
gam=1;
t=1;
kernel_type='poly_kernel';
%sig=0.2; % in case of RBF kernel
acc = zeros(10,1);

for d = 4
    kpar=[t; d];

    % LS-SVM solver
    [alpha, b] = trainlssvm({Xtrain,Ytrain,type,gam,kpar,kernel_type});

    % Evaluation
    Ypred=simlssvm({Xtrain,Ytrain,type,gam,kpar,kernel_type,'preprocess'},{alpha,b},Xtest);
    % Error
    err = sum(Ypred~=Ytest);
    acc(d)=1-err/length(Ytest);
    
    %Plot
    figure; 
    plotlssvm({Xtrain,Ytrain,type,gam,[t; d],'poly_kernel','preprocess'},{alpha,b});

    % Print error rate
    fprintf('\n on test: #misclass = %d, error rate = %.2f%%\n', err, err/length(Ytest)*100)
end

% Plot errors
figure
plot(acc,'*-','LineWidth',1.2);
xlabel('degree');
ylabel('accuracy');