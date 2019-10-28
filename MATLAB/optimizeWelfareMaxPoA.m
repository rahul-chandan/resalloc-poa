%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   File: optimizeWelfareMaxPoA.m
%   Author: Rahul Chandan
%
%   Description:
%
%   Inputs:
%       Name        Size    Description
%       `n`         1x1     Number of players.
%       `w`         nx1     Resource welfare function defined for `N =
%                           (1, 2,..., n)`.
%
%   Outputs:
%       Name        Size    Description
%       `poa`       1x1     Optimal price-of-anarchy.
%       `f`         nx1     An optimal utility-allocation function, defined
%                           for `N = (1, 2,..., n)`.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [poa, f] = optimizeWelfareMaxPoA(n, w)
    [x, fval, exitflag, output] = optimalLP(n, [0;w;0], 0);
    
    if exitflag ~= 1
        error(output.message)
    end
    
    poa = vpa(x(end));
    f = vpa(x(1:end-1));
end
