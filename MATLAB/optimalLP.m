%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   File: optimalLP.m
%   Author: Rahul Chandan
%
%   Description:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x, fval, exitflag, output] = optimalLP(n, w, costMinGame)
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
    
    numRowsIR = size(IR);
    numRowsIR = numRowsIR(1);
    
    A_ub = zeros(numRowsIR+n,n+1);
    B_ub = zeros(numRowsIR+n,1);

    A1 = eye(n+1);
    A_ub(1:n,:) = -A1(1:n,:);
    B_ub(1:n) = zeros(n,1);
    
    mask = find(a+x > 0);
    range = (1:numRowsIR)';
    ax = a+x;
    
    A2 = zeros(numRowsIR,n+1);
    A2( sub2ind(size(A2),range(mask),ax(mask)) ) = a(mask);
    A2( sub2ind(size(A2),range,ax+1) ) = -b;
    A2(:,end) = -w(a+x+1);
    B2 = -w(b+x+1);
    
    if costMinGame
        A_ub(n+1:end,:) = -A2;
        B_ub(n+1:end,:) = -B2;
    else
        A_ub(n+1:end,:) = A2;
        B_ub(n+1:end,:) = B2;
    end
    
    c = eye(n+1);
    if costMinGame
        c = -c(end,:);
    else
        c = c(end,:);
    end

    options = optimoptions('linprog','Algorithm','dual-simplex', ...
        'Display','none','OptimalityTolerance',1.0000e-07);
    
    [x, fval, exitflag, output] = linprog(c, A_ub, B_ub, [], [], ...
        [], [], options);
end
