%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   File: computeWelfareMaxPoA.m
%   Author: Rahul Chandan
%
%   Description:
%   Compute the price-of-anarchy of the scalable class of `n`-player local
%   utility-allocation games with resource welfare functions `w` and
%   utility-allocation functions `f`.
%   
%       Variable    Size    Description
%       `n`         1x1     Number of players
%       `w`         nxm     Resource welfare functions, each column
%                           corresponds to a different basis.
%       `f`         nxm     Resource utility-allocation functions, each
%                           column corresponds to a different basis. For 
%                           any `j \in [m]`, column `j` of `w` and `f` are
%                           assumed to be part of the same basis pair
%                           `b_j`.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function poa = computeWelfareMaxPoA(n, w, f)
    [x, fval, exitflag, output] = dualLP(n, [0;w;0], [0;f;0], 0);
    
    if exitflag ~= 1
        error(output.message)
    end
    
    poa = vpa(x(end));
end