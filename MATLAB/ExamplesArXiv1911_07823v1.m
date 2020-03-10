%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
%   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
%   All rights reserved. See LICENSE file in the project root for full license information.
%
%
%   Supporting material for manuscript entitled 
%   "Optimal mechanisms for distributed resource-allocation" 
%   by Chandan, Paccagnan, Marden. See Arxiv:1911.07823 v1
%
%   This script procudes the numerical results featured in Section 6 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all

%--------------------------- Setting the inputs --------------------------%
% solver
platform.solver = 1;

% Set solver options
if platform.solver == 1 % used only if matlab is selected 
    platform.matlabOptions = optimoptions('linprog','Algorithm', ...
                                       'dual-simplex', 'Display','off',...
                                       'ConstraintTolerance', 1e-8,...
                                       'OptimalityTolerance', 1e-8);

    warning(sprintf('\nYou are using the matlab linprog solver.\nWe recommend YALMIP + your favorite LP solver for accuracy.\nTo use YALMIP, set platform.solver=0\n'));
end

if platform.solver == 0 % used only if YALMIP is selected
    % GUROBI
    platform.yalmipOptions = sdpsettings(...
                'solver', 'gurobi','verbose', 0, 'cachesolvers', 1, ...
                'gurobi.NumericFocus', 3, 'gurobi.OptimalityTol', 1e-9, ...
                'gurobi.FeasibilityTol', 1e-9);

%   INSTEAD OF GUROBI, use your FAVORITE SOLVER (e.g., SEDUMI, MOSEK, ...)
%   % SEDUMI        
%   platform.yalmipOptions = sdpsettings(...
%                 'solver', 'sedumi','verbose', 0, 'cachesolvers', 1, ...
%                 'sedumi.bigeps', 1e-6);  
%   % MOSEK 
%   platform.yalmipOptions = sdpsettings(...
%                 'solver', 'mosek','verbose', 0, 'cachesolvers', 1);
end                               
%-------------------------------------------------------------------------%   

%% Example 1: Congestion Games
fprintf('\nComputing the price of anarchy for congestion games ...\n')
maxPlayers = 10;
maxOrder = 8;

arrPoA = zeros(maxPlayers, maxOrder); % Initialize optimal Poa, one per degree <= d
for current_d = 0 : maxOrder
    for n = 1:maxPlayers
    
        % Polynomial congestion games with {1, x, ..., x^d}
        % The normalization by n^2 is merely to improve accuracy for high d
        b = (1:n).^current_d./n^2;     

        % computes PoA
        arrPoA(n,current_d+1) = computeCostMinPoA(n, b, b, platform); 

    end
end

figure

for d = 1:maxOrder
    label = sprintf('d = %d', d);
    semilogy(arrPoA(:,d), 'DisplayName', label);
    hold on
end

hold off

title('Example 1: Congestion Games')
xlabel('n')
ylabel('PoA')
legend

%% Example 2: ell-Coverage Games
fprintf('Computing optimal mechanism for l-coverage ...\n')
maxPlayers = 25;
maxEll = 8;

arrPoA = zeros(maxPlayers, maxEll);
for ell = 1:maxEll
    for n = 1:maxPlayers
        w = min(1:n, ell);
        arrPoA(n, ell) = optimizeWelfareMaxPoA(n, w, platform);
    end
end

figure

for ell = 1:maxEll
    label = sprintf('ell = %d', ell);
    semilogy(arrPoA(:,ell), 'DisplayName', label);
    hold on
end

hold off

title('Example 2: Ell-Coverage Games')
xlabel('n')
ylabel('PoA')
legend

%% Example 3: Probabilistic-Objective Games
fprintf('Computing optimal mechanism for probabilistic-objective games ...\n')
n = 25;
res = 100;
Q = linspace(0,0.99,res);

optPoA = zeros(res, 1);
esPoA = zeros(res, 1);

for idx = 1:res
    q = Q(idx);
    w = 1-q.^(1:n);
    f = w ./ (1:n);
    esPoA(idx) = computeWelfareMaxPoA(n, w, f, platform);
    optPoA(idx) = optimizeWelfareMaxPoA(n, w, platform);
end

figure

plot(esPoA, 'DisplayName', 'PoA^{es}');
hold on
plot(optPoA, 'DisplayName', 'PoA^{opt}');
hold off

title('Example 3: Probabilistic-Objective Games')
xlabel('q')
ylabel('PoA')
legend

fprintf('Done\n\n')

