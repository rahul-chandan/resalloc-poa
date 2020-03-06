%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Author: Rahul Chandan, Dario Paccagnan
%
%   Description:
%   Computes the price-of-anarchy of polynomial congestion games 
%   with welfare besis obtained as linear combination of
%   {b_1(x),...,b_m(x)}, and n players
%   
%       Variable    Size        Description
%       `n`         1x1 int     Number of players
%       `B`         mxn real    Resource cost functions, each row 
%                               corresponds to a basis in {b_1(x),...,b_m(x)}
%       `f`         mxn real    Resource utility-allocation functions, each
%                               column corresponds to a different basis. For 
%                               any `j \in [m]`, column `j` of `w` and `f`
%                               are assumed to be part of the same basis
%                               pairs `b_j`.
%
%       `platform`  struct      Choice of solver and options
%
%                             - platform.solver  
%                               1 (uses matlab linprog solver) or
%                               0 (uses YALMIP interface) 
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
%                                   sdpsettings('solver', 'gurobi')%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function poa = computeWelfareMaxPoA(n, B, f, platform)
    % Solver options
    if platform.solver == 1 
        % to use Matlab built in LinProg with options
        platform.name = 'matlab-built-in'; 
        platform.options = platform.matlabOptions;
        fprintf('\n')
        warning(sprintf('You are using the matlab linprog solver.\nWe recommend YALMIP + gurobi for accuracy.\nTo use YALMIP, set platform.solver=0\n'));

    elseif platform.solver == 0
        % to use YALMIP with options
        platform.name = 'YALMIP'; 
        platform.options = platform.yalmipOptions;

    else, error('Wrong choice of solver.');

    end
    
    % handy expressions used to call solver
    m = size(B,1);
    w = B';
    f = f';
    
    % solve linear program to compute price of anarchy
    [x, ~, exitflag, output] = dualLP(n, [zeros(1,m); w; zeros(1,m)], [zeros(1,m); f; zeros(1,m)], 0,  platform);
    
    if exitflag ~= 1
        error(output.message)
    end
    
    poa = x(end);
end