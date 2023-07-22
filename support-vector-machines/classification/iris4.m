%% Exercise 1.3.1 - Iris dataset
clear
close all;

% Load the dataset
load iris.mat

% Configuration
type='c';
values=[1e-3, 1e-2, 1e-1, 1e0, 1e1, 1e2, 1e3];
gamlist=values; g=length(gamlist);
sig2list=values; s=length(sig2list);
t=1;
kernel_type='RBF_kernel';
cost_RS=zeros(g,s);
cost_CV=zeros(g,s);
cost_LOO=zeros(g,s);

for i=1:g
    for j=1:s
        model= {Xtrain,Ytrain,type,gamlist(i),sig2list(j),kernel_type};
        measure='misclass';
        % Random split
        perc=0.8;
        cost_RS(j,i)=rsplitvalidate(model,perc,measure);
        % 10-fold cross validation
        k=10;
        cost_CV(j,i)=crossvalidate(model,k,measure);
        % Leave-one-out validation
        cost_LOO(j,i)=leaveoneout(model,measure);
        disp(['gam : ', num2str(gamlist(i)), '   sig2 : ', num2str(sig2list(j)), '   cost : ', num2str(cost_LOO(i,j))])
    end
end

% Stem plot
x=log10(gamlist);
y=log10(sig2list);
figure
stem3(x,y,cost_RS,'-r','LineWidth',2);
hold on
stem3(x,y,cost_CV,'-b','LineWidth',2);
hold on
stem3(x,y,cost_LOO,'-g','LineWidth',2);
grid on
xlabel('log(gam)');
ylabel('log(sig2)');
zlabel('misclassification error');
legend('Random split','10-fold CV','Leave-one-out');
hold off

figure
[X,Y]=meshgrid(-3:3,-3:3);
s = surf(X,Y,cost_LOO);
grid on
xlabel('log(gam)');
ylabel('log(sig2)');
zlabel('misclassification error');
colorbar;