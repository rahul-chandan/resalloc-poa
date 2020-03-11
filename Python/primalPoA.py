####################################################################################################
#
#   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
#   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
#   All rights reserved. See LICENSE file in the project root for full license information.
#
####################################################################################################
    
def primalPoA(n, w, f, costMinGame=False, method='revised simplex'):
    import numpy as np
    from scipy.optimize import linprog
    from generateVectors import generateI       

    try:
        rowsW, colsW = w.shape
        rowsF, colsF = f.shape
    except ValueError:
        msg = 'Expected `(n, m)` vectors `w` and `f`, but received a one-dimensional vector.'
        raise RuntimeError(msg)

    if rowsW < n+2 or rowsF < n+2:
        msg = 'The number of rows in `w` and `f` must be at least `n+2`.'
        raise RuntimeError(msg)

    if colsW != colsF:
        msg = 'The number of columns in `w` and `f` must match.'
        raise RuntimeError(msg)
    
    I = generateI(n) # [a,b,x]
    a = I[:,0]
    b = I[:,1]
    x = I[:,2]

    numRowsI = I.shape[0]

    A_ub = np.zeros( (numRowsI*colsW + 1, numRowsI*colsW) )
    b_ub = np.zeros( (numRowsI*colsW + 1,) )

    A_eq = np.zeros( (1, numRowsI*colsW) )
    b_eq = 1.0
    
    c = np.zeros( (numRowsI*colsW,) )

    for idx in np.arange(colsW):        
        # sum of NE constraints
        A1 = a*f[a+x, idx] - b*f[a+x+1, idx]

        # \sum_{a,x,b} w(a+x) theta(a,x,b) = 1
        A2 = w[a+x, idx]

        if costMinGame:
            A_ub[0, idx*numRowsI:(idx+1)*numRowsI] = A1
        else:
            A_ub[0, idx*numRowsI:(idx+1)*numRowsI] = -A1
    
        A_eq[0, idx*numRowsI:(idx+1)*numRowsI] = A2

        if costMinGame:
            c[idx*numRowsI:(idx+1)*numRowsI] = w[b+x, idx]
        else:
            c[idx*numRowsI:(idx+1)*numRowsI] = -1.0*w[b+x, idx]

    # theta(a,x,b) \geq 0
    A_ub[1:numRowsI*colsW + 1,:] = -1.0*np.eye(numRowsI*colsW)

    res = linprog(c, A_ub=A_ub, b_ub=b_ub, A_eq=A_eq, b_eq=b_eq, method=method)
    
    return res
