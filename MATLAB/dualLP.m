%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   File: dualLP.m
%   Author: Rahul Chandan
%
%   Description:
%   Implementation of the linear program in Thm. 4, chandan2020when.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x, fval, exitflag, output] = dualLP(n, w, f, costMinGame) 

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
    
    options = optimoptions('linprog','Algorithm','dual-simplex', ...
        'Display','none');

    [x, fval, exitflag, output] = linprog(c, A_ub, B_ub, [], [], ...
        [], [], options);
    
end
