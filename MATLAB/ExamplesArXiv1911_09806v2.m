%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
%   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
%   All rights reserved. See LICENSE file in the project root for full license information.
%
%
%   Supporting material for manuscript entitled 
%       "Incentivizing efficient use of shared infrastructure: Optimal
%        tolls in congestion games" by Paccagnan, Chandan, Ferguson, Marden
%        See Arxiv:1911.09806 v2
%
%   Description: this script 
%
%     i) computes the price-of-anarchy (PoA) for polynomial atomic
%        congestion games (also non-polynomial upon changing the expression
%        for the basis functions in the variable `B`)
%
%    ii) design tolls that optimize the PoA for polynomial atomic
%        congestion games (also non-polynomial upon changing the expression
%        for the basis functions in the variable `B`)
%
%   iii) reproduces the results in Table 1 and Table 2 from the manuscript
%        "Incentivizing efficient use of shared infrastructure: Optimal 
%         tolls in congestion games" by Paccagnan, Chandan, Ferguson,
%         Marden. See Arxiv:1911.09806 v2
%
%
%   Inputs:
%   Name           Size        Description
%	`n`            1x1 int     Number of players
%	`d`            1x1 int     Highest degree of polynomial
%
%   `platform`     struct      Choice of solver and options
%                             - platform.solver  
%                               1 (uses matlab linprog solver) or
%                               0 (recommended, uses YALMIP interface) 
%                               
%                             - platform.matlabOptions sets solver options
%                               for linprog (only if platform.solver = 1) 
%                               Example: platform.matlabOptions = 
%                                   optimoptions('linprog','Algorithm', ...
%                                   'dual-simplex');
%
%                             - platform.yalmipOptions sets solver options
%                               for YALMIP (only if platform.solver = 0) 
%                               Example: platform.yalmipOptions =
%                                   sdpsettings('solver', 'gurobi')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Clearing and adding subpath
clc
clear
close all
addpath('code')


%--------------------------- Setting the inputs --------------------------%
% Set number of players, maximum degree, solver, positivity constraint
n = 100;             
d = 6;               
platform.solver = 1;

% Set solver options
if platform.solver == 1 % used only if matlab is selected 
    platform.matlabOptions = optimoptions('linprog','Algorithm', ...
                                       'dual-simplex', 'Display','off',...
                                       'ConstraintTolerance', 1e-8,...
                                       'OptimalityTolerance', 1e-8);
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




%%----------- Producing output - do not modify below this line ----------%%
fprintf('\n*======= Prices of anarchy values with %2.0i agents =======*\n\n\n',n)


%-------- Table 1 second column: recovering results from (32-35): --------% 
%         i.e., compute PoA un-tolled 
fprintf('---------------------------------------------------------\n');
fprintf('Computing PoA for polynomial congestion games 0 <= d <= 6\n')
fprintf('Un-tolled\n\n')

arrPoA    = zeros(d+1,1); % Initialize optimal Poa, one per degree <= d
for current_d = 0 : d
    
    fprintf('d = %1i ', current_d)
    % Polynomial congestion games with {1, x, ..., x^d}
    % The normalization by n^2 is merely to improve accuracy for high d
    B(current_d+1, :) = (1:n).^current_d./n^2;     

    
    % computes PoA
    arrPoA(current_d+1) = computeCostMinPoA(n, B, B, platform); 
    fprintf('done\n')
end
fprintf('---------------------------------------------------------\n\n\n');





%---------- Table 1 fourth column: optimal PoA with local tolls ----------% 
fprintf('---------------------------------------------------------\n');
fprintf('Optimizing PoA for polynomial congestion games 0 <= d <= 6\n')
fprintf('Congestion-dependent tolls\n\n')

arrOptPoA = zeros(d+1,1);  % Initialize optimal Poa, one per degree <= d
for current_d = 0 : d
    
    fprintf('d = %1i ', current_d)
    % Polynomial congestion games with {1, x, ..., x^d}
    % The normalization by n^2 is merely to improve accuracy for high d
    B = (1:n).^current_d/(n^2);                           
    
    % compute optimal toll for each basis x^j
    current_OptPOA =  optimizeCostMinPoA(n, B, platform);

    
    % optimal poa is the largest over all bases
    arrOptPoA(current_d+1) = max( current_OptPOA, max(arrOptPoA) );
    fprintf('done\n')
end
fprintf('---------------------------------------------------------\n\n\n');





%----- Table 1 fifth column: optimal PoA with *constant* local tolls -----% 
fprintf('---------------------------------------------------------\n');
fprintf('Optimizing PoA for polynomial congestion games 0 <= d <= 6\n')
fprintf('Congestion-idependent tolls\n\n')

arrOptPoAConst = zeros(d+1,1); % Initialize Poa, one per degree <= d
for current_d = 0 : d
    
    fprintf('d = %1i ', current_d)
    % Polynomial congestion games with {1, x, ..., x^d}
    % The normalization by n^2 is merely to improve accuracy for high d
    B = (1:n).^current_d/(n^2);
    
    % compute optimal *constant* toll for each basis x^j
    current_OptPOAConst = optimizeCostMinPoAConstant(n, B, platform); 
    
    % optimal poa is the largest over all bases
    arrOptPoAConst(current_d+1) = max(current_OptPOAConst,max(arrOptPoAConst));
    fprintf('done\n')
end
fprintf('---------------------------------------------------------\n\n\n');






%------- Table 2 second column: PoA for discretized pigouvian tolls ------% 
fprintf('---------------------------------------------------------\n');
fprintf('Computing PoA for polynomial congestion games 0 <= d <= 6\n')
fprintf('Marginal cost tolls (Pigouvian tolls) \n\n')

arrPoAPigou    = zeros(d+1,1); % Initialize Poa, one per degree <= d
for current_d = 0 : d
    
    fprintf('d = %1i ', current_d)    
    % Polynomial congestion games with {1, x, ..., x^d}
    % The normalization by n^2 is merely to improve accuracy for high d
    B(current_d+1, :) = (1:n).^current_d./n^2;
    
    % pigouvian toll
    pigtoll(current_d+1, 1) = 0 ;
    pigtoll(current_d+1, 2:n) = (1:n-1).*( (2:n).^current_d - (1:n-1).^current_d )/(n^2);
    f = B + pigtoll;
    
    % computes PoA
    arrPoAPigou(current_d+1) = computeCostMinPoA(n, B, f, platform); 
    fprintf('done\n')
end
fprintf('---------------------------------------------------------\n\n\n\n');




% TABLE 1
fprintf('     Degree d     |  PoA (no toll)  |  PoA (optimal local toll)  |  PoA (optimal consant toll) \n')
fprintf('  [Tab 1, col #1] | [Tab 1, col #2] |       [Tab 1, col #4]      |       [Tab 1, col #5]       \n')
fprintf('-----------------------------------------------------------------------------------------------\n')
formatSpec = '%10i        | %12.2f    | %17.2f          | %17.2f           \n';
fprintf(formatSpec, [1:d; arrPoA(2:end)'; arrOptPoA(2:end)'; arrOptPoAConst(2:end)']);
fprintf('\n\n\n\n')

% TABLE 2
fprintf('     Degree d     |  PoA (no toll)  |  PoA (marginal cost toll)  \n');
fprintf('  [Tab 2, col #1] | [Tab 2, col #2] |       [Tab 2, col #3]      \n')
fprintf('-----------------------------------------------------------------\n')
formatSpec = '%10i        | %12.2f    | %17.2f          \n';
fprintf(formatSpec, [1:d; arrPoA(2:end)'; arrPoAPigou(2:end)']);
fprintf('\n')

% Warning: Matlab solution is far from being accurate for d=6. Use YALMIP +
% Gurobi, or any other reliable solver
if platform.solver == 1
    warning(sprintf('Matlab''s solution is far from being accurate for d=6\nUse YALMIP + Gurobi, or any other reliable solver\n'))
end
