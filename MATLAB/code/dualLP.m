%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
%   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
%   All rights reserved. See LICENSE file in the project root for full license information.
%
%   Description:
%   Implementation of the linear program in ArXiv1911_07823v1 THM 4
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xval, fval, exitflag, output] = dualLP(n, w, f, costMinGame, platform) 

    [rowsW, colsW] = size(w);
    [rowsF, colsF] = size(f);
    
    if rowsW < n+2 || rowsF < n+2
        msg = 'The number of rows in `w` and `f` must be at least `n+2`.';
        error(msg)
    end
    
    if colsW ~= colsF
        msg = 'The number of columns in `w` and `f` must match.';
        error(msg)
    end
    
    IR = generateIR(n);
    a = IR(:,1);
    b = IR(:,2);
    x = IR(:,3);
    
    numRowsIR = size(IR);
    numRowsIR = numRowsIR(1);
    
    A_ub = zeros(numRowsIR*colsW+1,2);
    B_ub = numRowsIR*colsW+1;
    
    % \lambda \geq 0
    A_ub(1,:) = [-1 0];
    B_ub(1) = 0;
    
    for idx=1:colsW
        A2 = zeros(numRowsIR, 2);
        
        A2(:,1) = a.*f(a+x+1,idx) - b.*f(a+x+2,idx);
        A2(:,2) = -w(a+x+1,idx);
        B2 = w(b+x+1,idx);
        
        if costMinGame
            A_ub((idx-1)*numRowsIR+2:idx*numRowsIR+1,:) = -A2;
            B_ub((idx-1)*numRowsIR+2:idx*numRowsIR+1) = B2;
        else
            A_ub((idx-1)*numRowsIR+2:idx*numRowsIR+1,:) = A2;
            B_ub((idx-1)*numRowsIR+2:idx*numRowsIR+1) = -B2;
        end
    end
    
    if costMinGame
        c = [0; -1];
    else
        c = [0; 1];
    end
    
% different options to solve the LP
    if strcmp(platform.name ,'YALMIP')
        %-- solve the LP using YALMIP and solver of choice *recomended* --%
        x = sdpvar(2,1);
        objective = c'*x;
        constraints = [A_ub*x <= B_ub'];
        yalmip_options = platform.options;

        sol = optimize(constraints, objective, yalmip_options);

        xval = value(x);
        fval = value(objective);
        exitflag = contains(sol.info, 'Successfully solved'); 
        output.message = sol.info;
        
    elseif strcmp(platform.name, 'matlab-built-in')
        %-- solve the LP using Matlab built-in solver *not recomended* ---%
        options = platform.options;
        [xval, fval, exitflag, output] = linprog(c, A_ub, B_ub, [], [], ...
            [], [], options);
    else error('wrong choice of platform')
    end
end