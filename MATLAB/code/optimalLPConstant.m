%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
%   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
%   All rights reserved. See LICENSE file in the project root for full license information.
%
%   Description: computes the optimal costant tolls minimizing the price of
%   anarchy, and the corresponding optimal value of the price of anarchy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xval, fval, exitflag, output] = optimalLPConstant(n, w, costMinGame, platform)
    [rowsW, colsW] = size(w);
    
    if rowsW < n+2
        msg = 'The number of rows in `w` must be at least `n+2`.';
        error(msg)
    end
    
    if colsW ~= 1
        msg = '`w` must only have one column.';
        error(msg)
    end

    IR = generateIR(n);
    a = IR(:,1);
    b = IR(:,2);
    x = IR(:,3);
    
    numRowsIR = size(IR, 1);
    
 
    mask = find(a+x > 0);
    range = (1:numRowsIR)';
    ax = a+x;
    
    A2 = zeros(numRowsIR,n+1);
    A2( sub2ind(size(A2),range(mask),ax(mask)) ) = a(mask);
    A2( sub2ind(size(A2),range,ax+1) ) = -b;
    A2(:,end) = -w(a+x+1);
    B2 = -w(b+x+1);
    
  
    A2 = [A2(:,1:end-1) * (w(2:end-1)./(1:n)'), a-b , A2(:,end)];
    
    if costMinGame
        A_ub = -A2;
        B_ub = -B2;
    else
        A_ub = A2;
        B_ub = B2;
    end
    
    c = eye(3);
    if costMinGame
        c = -c(end,:);
    else
        c = c(end,:);
    end


    % different options to solve the LP
    if strcmp(platform.name ,'YALMIP')
        %-- solve the LP using YALMIP and solver of choice *recommended* -%
        x = sdpvar(3,1);
        objective = c*x;
        constraints = [A_ub*x <= B_ub];
        yalmip_options = platform.options;

        sol = optimize(constraints, objective, yalmip_options);

        xval = value(x);
        fval = value(objective);
        exitflag = contains(sol.info, 'Successfully solved'); 
        output.message = sol.info;
        
    elseif strcmp(platform.name, 'matlab-built-in')
        %-- solve the LP using Matlab built-in solver *not recommended* --%
        options = platform.options;
        [xval, fval, exitflag, output] = linprog(c, A_ub, B_ub, [], [], ...
        [], [], options);
    
    else error('wrong choice of platform'); 
    end 
end
