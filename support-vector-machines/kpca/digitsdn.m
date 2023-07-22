% Experiments on the handwriting data set on kPCA for reconstruction and denoising
clear;
close all;

% Load dataset
load digits; clear size
[N, dim]=size(X);
Ntest=size(Xtest1,1);
minx=min(min(X)); 
maxx=max(max(X));

% Add noise to the digit maps
noisefactor =1.0;
noise = noisefactor*maxx; % sd for Gaussian noise

% Noise on training set
Xn = X;
for i=1:N;
  randn('state', i);
  Xn(i,:) = X(i,:) + noise*randn(1, dim);
end

% Noise on test set
%Xtest1=Xtest2; % Uncomment to test Xtest2
Xnt = Xtest1;
for i=1:size(Xtest1,1);
  randn('state', N+i);
  Xnt(i,:) = Xtest1(i,:) + noise*randn(1,dim);
end

% select training set
Xtr = X(1:1:end,:); % everything
% Initial sig2 value
sig2init =dim*mean(var(Xtr)) % rule of thumb
% Factor for sig2
sigmafactor = 0.1;

for s=1:length(sigmafactor)

    sig2=sig2init*sigmafactor(s);
    % kernel based Principal Component Analysis using the original training data
    disp(['sig2 = ', num2str(sig2)]);

    % kernel PCA
    [lam,U] = kpca(Xtr,'RBF_kernel',sig2,[],'eig',240); 
    [lam, ids]=sort(-lam); lam = -lam; U=U(:,ids);

    % Denoise using the first principal components
    disp(' ');
    disp(' Denoise using the first PCs');

    % choose the digits for test
    digs=[0:9]; ndig=length(digs);
    m=2; % Choose the mth data for each digit 
    Xdt=zeros(ndig,dim);

    % which number of eigenvalues of kpca
    npcs = [1 2 4 8 16 32 64 128];
    lpcs = length(npcs);
    %ADDITION
    cost1list=zeros(length(npcs),1);
    
    % Figure of all digits
    figure; 
    colormap('gray'); 
    title('Denosing using linear PCA'); tic
    
    for k=1:lpcs
        nb_pcs=npcs(k); 
        disp(['nb_pcs = ', num2str(nb_pcs)]); 
        Ud=U(:,(1:nb_pcs)); lamd=lam(1:nb_pcs);
        %ADDITION
        cost1=0;
        for i=1:ndig
            dig=digs(i);
            xt=Xnt(i,:);
            %% Plot
                if k==1 
                    % plot the original clean digits
                    subplot(2+lpcs, ndig, i);
                    pcolor(1:15,16:-1:1,reshape(Xtest1(i,:), 15, 16)'); shading interp; 
                    set(gca,'xticklabel',[]);set(gca,'yticklabel',[]);        
                    if i==1, ylabel('original'), end 

                    % plot the noisy digits 
                    subplot(2+lpcs, ndig, i+ndig); 
                    pcolor(1:15,16:-1:1,reshape(xt, 15, 16)'); shading interp; 
                    set(gca,'xticklabel',[]);set(gca,'yticklabel',[]);        
                    if i==1, ylabel('noisy'), end
                    drawnow
                end        
            %%
            Xdt(i,:) = preimage_rbf(Xtr,sig2,Ud,xt,'denoise');
            subplot(2+lpcs, ndig, i+(2+k-1)*ndig);
            pcolor(1:15,16:-1:1,reshape(Xdt(i,:), 15, 16)'); shading interp; 
            set(gca,'xticklabel',[]);set(gca,'yticklabel',[]);           
            if i==1, ylabel(['n=',num2str(nb_pcs)]); end
            drawnow   
           % ADDITION
           cost1 = cost1 + mean((Xdt(i,:)-Xtest1(i,:)).^2); %add digit cost
         end % for i
     % ADDITION
     %% Final cost
     cost1list(k)=cost1/ndig;
    end % for k
    cost1list
    figure;
    plot(npcs,sqrt(cost1list),'LineWidth',1.5)
    xlabel('Number of principal components')
    ylabel('Cost')
    legend('RMSE')
    text(2,2,num2str(sig2))
end