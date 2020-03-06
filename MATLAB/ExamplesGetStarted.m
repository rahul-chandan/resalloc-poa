%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Author: Dario Paccagnan
%
%       INPUTS:
%       Variable    Size        Description
%       `n`         1x1 int     Number of players
%       `d`         1x1 int     Maximum degree of polynomial 
%       `positive`  1x1 bin     1 to enforce positivity of tolls, 0 else
%                               
%       `platform`  struct      Choice of solver and options
%
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
%                                   sdpsettings('solver', 'gurobi's)
%
%       OUTPUTS
%       Variable    Size        Description
%       `PoA`       1x1 real    Price of anarchy
%       `OptPoA`    1x1 real    Optimal price of anarchy (w. optimal tolls)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Clearing and adding subpath
clc
clear
close all
addpath('code')


%--------------------------- Setting the inputs --------------------------%
% Set number of players, maximum degree, solver, positivity constraint
n = 50;             
d = 1;               
platform.solver = 1;
positive = 1;

% Set solver options
if platform.solver == 1 % used only if matlab is selected 
    platform.matlabOptions = optimoptions('linprog','Algorithm', ...
                                       'dual-simplex', 'Display','off',...
                                       'ConstraintTolerance', 1e-8,...
                                       'OptimalityTolerance', 1e-8);
end

if platform.solver == 0 % used only if YALMIP is selected
    platform.yalmipOptions = sdpsettings(...
                'solver', 'gurobi','verbose', 0, 'cachesolvers', 1, ...
                'gurobi.NumericFocus', 3, 'gurobi.OptimalityTol', 1e-9, ...
                'gurobi.FeasibilityTol', 1e-9);
end                               
%-------------------------------------------------------------------------%           



%----------------------------- Producing output --------------------------%
% Each rows of B contains one of the basis functions {b_1(x), ... b_m(x)}
B = zeros(d+1, n);
for current_d = 0 : d
    % This example: polynomial congestion games with {1, x, ..., x^d}
    % The normalization by n^2 is merely to improve accuracy for high d
    B(current_d+1, :) = (1:n).^current_d./n^2;     
end
   
% computes PoA
PoA = computeCostMinPoA(n, B, B, platform); 

% optimizes PoA
OptPoA = optimizeCostMinPoA(n, B, platform, positive);

%-------------------------------------------------------------------------%  



%--------------------------------- Printing ------------------------------%
fprintf('\n\nThe price of anarchy with n=%3i agents and polynomials of degree d=%1i is \n---> PoA=%5.2f', n, d, PoA)
fprintf('\n\nThe *optimal* price of anarchy with n=%3i agents and polynomials of degree d=%1i is \n---> OptPoA=%5.2f\n\n', n, d, OptPoA)
%-------------------------------------------------------------------------%


