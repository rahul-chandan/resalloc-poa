%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   File: computeCostMinPoA.m
%   Author: Rahul Chandan
%
%   Description:
%   Compute the price-of-anarchy of the scalable class of `n`-player local
%   cost-sharing games with resource cost functions `c` and cost-generating
%   functions `f`.
%   
%       Variable    Size    Description
%       `n`         1x1     Number of players
%       `c`         nxm     Resource cost functions, each column
%                           corresponds to a different basis.
%       `f`         nxm     Resource cost-generating functions, each column
%                           corresponds to a different basis. For any  
%                           `j \in [m]`, column `j` of `c` and `f` are
%                           assumed to be part of the same basis pair
%                           `b_j`.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function poa = computeCostMinPoA(n, c, f)
    [x, fval, exitflag, output] = dualLP(n, [0;c;0], [0;f;0], 1);
    
    if exitflag ~= 1
        error(output.message)
    end
    
    poa = 1/vpa(x(end));
end