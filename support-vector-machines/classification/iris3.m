%% Exercise 1.3.1 - Iris dataset
clear
close all;

% Load the dataset
load iris.mat

% Configuration
type='c';
gamlist=[1e-3, 1e-2,1e-1,1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9,1e10];
t=1;
kernel_type='RBF_kernel';
sig2=1;
acc = [];

for gam=gamlist
    disp(['gam : ', num2str(gam), '   sig2 : ', num2str(sig2)]),
    [alpha,b] = trainlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel'});

    % Plot the decision boundary of a 2-d LS-SVM classifier
    plotlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel','preprocess'},{alpha,b});

    % Obtain the output of the trained classifier
    [Yht, Zt] = simlssvm({Xtrain,Ytrain,type,gam,sig2,'RBF_kernel'}, {alpha,b}, Xtest);
    err = sum(Yht~=Ytest); 
    acc=[acc; 1-err/length(Ytest)];
    fprintf('\n on test: #misclass = %d, error rate = %.2f%% \n', err, err/length(Ytest)*100)
    disp('Press any key to continue...'), pause,         
end


% Plot errors
figure
plot(log10(gamlist),acc,'*-','LineWidth',1.2);
xlabel('log(gam)');
ylabel('accuracy');