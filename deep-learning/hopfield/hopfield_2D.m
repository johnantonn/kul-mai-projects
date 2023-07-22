%%%%%%%%%%%
% hopfield_2D.m
% A script which generates n random initial points 
%and visualises results of simulation of a 2d Hopfield network 'net'
%%%%%%%%%%

T = [1 1; -1 -1; 1 -1]'; % patterns to memorize
[~, cT] = size(T); % num of patterns
net = newhop(T); % init network
n=100; % number of points
steps=50; % Steps
iters=zeros(n,1); % store the step of convergence for each point
attrCounters=zeros(cT,1); % store the attractor counts

a=[0; 0]
[y,Pf,Af] = sim(net,{1 steps},{},a);
y{steps}
for i=1:n
    a={rands(2,1)}; % generate an initial point 
    [y,Pf,Af] = sim(net,{1 steps},{},a); % simulation of the network for 50 timesteps 
    % check for convergence step
    for j=2:steps
        if y{j}==y{j-1}
            % check for attractor
            iters(i) = j;
            %y{j}
            for k=1:cT
                if y{j}==T(:,k)
                    attrCounters(k)=attrCounters(k)+1;
                end
            end
            break;
        end
    end
    record=[cell2mat(a) cell2mat(y)]; % formatting results  
    start=cell2mat(a); % formatting results 
    plot(start(1,1),start(2,1),'bx',record(1,:),record(2,:),'r'); % plot evolution
    hold on;
    plot(record(1,steps),record(2,steps),'gO');  % plot the final point with a green circle
end
legend('initial state','time evolution','attractor','Location', 'northeast');
title('Time evolution in the phase space of 2d Hopfield model');