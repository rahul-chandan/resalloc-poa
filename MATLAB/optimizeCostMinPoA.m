%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   File: optimizeCostMinPoA.m
%   Author: Rahul Chandan
%
%   Description:
%
%   Inputs:
%       Name        Size    Description
%       `n`         1x1     Number of players.
%       `c`         nx1     Resource cost function defined for `N =
%                           (1, 2,..., n)`.
%
%   Outputs:
%       Name        Size    Description
%       `poa`       1x1     Optimal price-of-anarchy.
%       `f`         nx1     An optimal cost-generating function, defined
%                           for `N = (1, 2,..., n)`.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [poa, f] = optimizeCostMinPoA(n, c)
    [x, fval, exitflag, output] = optimalLP(n, [0;c;0], 1);
    
    if exitflag ~= 1
        error(output.message)
    end
    
    poa = 1/vpa(x(end));
    f = vpa(x(1:end-1));
end
