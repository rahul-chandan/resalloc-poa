%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
%   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
%   All rights reserved. See LICENSE file in the project root for full license information.
%
%
%   Description: Optimizes the price-of-anarchy (using *constant* tolls) 
%   of polynomial congestion games with latencies obtained as linear 
%   combination of basis {b_1(x),...,b_m(x)}, and n players
%
%   Inputs:
%       Name        Size    Description
%       `n`         1x1     Number of players.
%       `c`         nx1     Resource cost function defined for `N =
%                           (1, 2,..., n)`.
%
%       `platform`  struct      platform.name ='matlab-built-in' 
%                               (uses matlab linprog solver) or
%                               platform.name ='YALMIP' 
%                               (uses YALMIP interface) 
%                             
%                               platform.options can be used to set the
%                               same native options of linprog, or YALMP,
%                               e.g., 
%                               for linprog
%                               platform.options = optimoptions('linprog','Algorithm', 'linprog', ...
%                               'Display','none');
%                               for YALMIP
%                               platform.options = sdpsettings(...
%                               'solver', 'gurobi','verbose', 0, 'cachesolvers', 1, ...
%                               'gurobi.NumericFocus', 3, 'gurobi.OptimalityTol', 1e-9, ...
%                               'gurobi.FeasibilityTol', 1e-9);
%
%   Outputs:
%       Name        Size    Description
%       `poa`       1x1     Price-of-anarchy of constant tolls
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function OptPoA = optimizeCostMinPoAConstant(n, B, platform)
    
    % Solver options
    if platform.solver == 1 
        % to use Matlab built in LinProg with options
        platform.name = 'matlab-built-in'; 
        platform.options = platform.matlabOptions;
        
        % if optimization toolbox not available, throw error                               
        if license('test','optimization_toolbox')~=1
            error('The optimization toolbox is not installed or licensed. Visit https://www.mathworks.com/products/optimization.html for more info.');
        end

    elseif platform.solver == 0
        % to use YALMIP with options
        platform.name = 'YALMIP'; 
        platform.options = platform.yalmipOptions;

    else, error('Wrong choice of solver.');

    end
    
    % Initialize
    m = size(B,1);
    OptPoA = 0;
    
    % For each basis compute the optimal tolling mechanism
    for current_basis = 1 : m
        b = B(current_basis, :);                           
        c = (1:n).*b;
    
        % Compute optimal toll for current basis 
        [x, ~, exitflag, output] = optimalLPConstant(n, [0 c 0]', 1, platform);
        
        if exitflag ~= 1
            error(output.message)
        end
        
        
        currentOptPoA = 1/x(end);
        % Optimal poa is the largest over all bases
        OptPoA = max( currentOptPoA, max(OptPoA) );
    end

end
