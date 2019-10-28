####################################################################################################
#
#   File: dualPoA.py
#   Author: Rahul Chandan
#   Last updated: 2019/10/24
#
####################################################################################################

def dualPoA(n, w, f, costMinGame=False, method='revised simplex'):
    import numpy as np
    from scipy.optimize import linprog
    from generateVectors import generateIR      

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
    
    IR = generateIR(n) # [a,b,x]
    a = IR[:,0]
    b = IR[:,1]
    x = IR[:,2]

    numRowsIR = IR.shape[0]

    A_ub = np.zeros( ( numRowsIR*colsW+1, 2 ) )
    b_ub = np.zeros( numRowsIR*colsW+1 )

    # lambda \geq 0
    A_ub[-1,:] = np.array([-1., 0.])
    b_ub[-1] = 0.0

    for idx in np.arange(colsW):
        # lambda (a f(a+x)w(a+x) - bf(a+x+1)w(a+x+1)) - mu w(a+x) \leq w(b+x)
        A2 = np.zeros( (numRowsIR, 2) )
        
        A2[:,0] = a*f[a+x, idx] - b*f[a+x+1, idx]
        A2[:,1] = -1.0*w[a+x, idx]
        
        b2 = w[b+x,idx]

        if costMinGame:
            A_ub[idx*numRowsIR:(idx+1)*numRowsIR,:] = -A2
            b_ub[idx*numRowsIR:(idx+1)*numRowsIR] = b2
        else:
            A_ub[idx*numRowsIR:(idx+1)*numRowsIR,:] = A2
            b_ub[idx*numRowsIR:(idx+1)*numRowsIR] = -b2
    
    if costMinGame:
        c = np.array([0., -1])
    else:
        c = np.array([0., 1])

    res = linprog(c, A_ub=A_ub, b_ub=b_ub, method=method)
    
    return res
