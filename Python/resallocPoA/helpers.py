import numpy as np

def generateIR( n ):
    height = 2*n**2 + 1
    matrix = np.zeros((height,3), dtype=np.int)

    sideFaceLen = int((n+1)*n/2)
    sideFace = np.vstack( np.nonzero( np.flipud( np.tri(n+1) ) ) )[:,n+1:]
    
    matrix[0:sideFaceLen,0:2] = sideFace.T
    matrix[sideFaceLen:2*sideFaceLen,1:3] = sideFace.T
    matrix[2*sideFaceLen:3*sideFaceLen,[2,0]] = sideFace.T

    lastFace = np.vstack( (sideFace, n - np.sum(sideFace, axis=0)) )
    mask = np.prod(lastFace, axis=0) >= 1
    
    matrix[3*sideFaceLen:,:] = lastFace.T[mask,...]

    return matrix



def dualLP( n, w, f, costMinGame=False, options=None):
    if options == None:
        msg = 'No optimization options were specified.'
        raise RuntimeError(msg)

    if not np.ndim(w) == 2 or not np.ndim(f) == 2:
        msg = 'Expected 2-dimensional ndarrays `w` and `f`, but received an ndarry with `ndim != 2`.'
        raise RuntimeError(msg)
    
    rowsW, colsW = np.shape(w)
    rowsF, colsF = np.shape(f)
    
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

    numRowsIR = np.shape(IR)[0]

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
        
        b2 = -1.0*w[b+x,idx]

        if costMinGame:
            A_ub[idx*numRowsIR:(idx+1)*numRowsIR,:] = -A2
            b_ub[idx*numRowsIR:(idx+1)*numRowsIR] = -b2
        else:
            A_ub[idx*numRowsIR:(idx+1)*numRowsIR,:] = A2
            b_ub[idx*numRowsIR:(idx+1)*numRowsIR] = b2
    
    if costMinGame:
        c = np.array([0., -1])
    else:
        c = np.array([0., 1])

    res = options['solver'](c, A_ub=A_ub, b_ub=b_ub, method=options['method'])
    
    return [ res['x'], res['fun'], res['status'], res['message'] ]



def optimalLP(n, w, costMinGame=False, options=None):
    if options == None:
        msg = 'No optimization options were specified.'
        raise RuntimeError(msg)

    if np.ndim(w) != 1:
        msg = '`w` must be an ndarray with `ndim==1`.'
        raise RuntimeError(msg)

    rowsW = np.shape(w)[0]

    if rowsW < n+2:
        msg = 'The number of entries in `w` must be at least `n+2`.'
        raise RuntimeError(msg)

    IR = generateIR(n) # [a,b,x]
    a = IR[:,0]
    b = IR[:,1]
    x = IR[:,2]

    # Nonnegativity constraint
    A1 = -1.0*np.eye(n+1)[0:n]
    B1 = np.zeros(n)

    # PoA constraint
    A2 = np.zeros((np.shape(IR)[0],n+1))
    A2[np.arange(np.shape(IR)[0])[a+x > 0, ...],(a+x-1)[a+x > 0, ...]] = a[a+x > 0, ...]
    A2[np.arange(np.shape(IR)[0]),a+x] = -b
    A2[np.arange(np.shape(IR)[0]),-1] = -1.0*w[a+x]
    B2 = -1.0*w[b+x]

    if costMinGame:
        A_ub = np.vstack( (A1,-A2) )
        b_ub = np.hstack( (B1,-B2) )
    else:
        A_ub = np.vstack( (A1,A2) )
        b_ub = np.hstack( (B1,B2) )
    
    if costMinGame:
        c = -1.0*np.eye(n+1)[-1] # [ f, mu ]
    else:
        c = np.eye(n+1)[-1] # [ f, mu ]

    res = options['solver'](c, A_ub=A_ub, b_ub=b_ub, method=options['method'])
    
    return [ res['x'], res['fun'], res['status'], res['message'] ]



def optimalLPConstant(n, w, costMinGame=False, options=None):
    if options == None:
        msg = 'No optimization options were specified.'
        raise RuntimeError(msg)

    if np.ndim(w) != 2:
        msg = 'Expected an ndarray `w` with `ndim==2`.'
        raise RuntimeError(msg)

    rowsW, m = np.shape(w)

    if rowsW < n+2:
        msg = 'The number of entries in `w` must be at least `n+2`.'
        raise RuntimeError(msg)

    z = np.arange(n+1, dtype=np.int)
    x, y = np.reshape( np.meshgrid(z, z), (2, z.size**2) )

    A_ub = -1.0*np.eye(m+2)[-2]
    b_ub = 0.

    for idx in np.arange(m):
        Atemp = np.zeros( (x.size, m+2), dtype=np.float)
        btemp = np.zeros( (x.size,), dtype=np.float )

        Atemp[:, idx] = x-y
        Atemp[:, -2] = np.where( x+y<=n, w[x,idx]*x-w[x+1,idx]*y, 
                                         w[x,idx]*(n-y)-w[x+1,idx]*(n-x) )
        Atemp[:, -1] = -1.0*w[x,idx]*x

        btemp = -1.0*w[y,idx]*y

        if costMinGame:
            A_ub = np.vstack( (A_ub,-Atemp) )
            b_ub = np.hstack( (b_ub,-btemp) )
        else:
            A_ub = np.vstack( (A_ub,Atemp) )
            b_ub = np.hstack( (b_ub,btemp) )
    
    if costMinGame:
        c = -1.0*np.eye(m+2)[-1] # [ sigma, nu, rho ]
    else:
        c = np.eye(m+2)[-1] # [ sigma, nu, rho ]

    res = options['solver'](c, A_ub=A_ub, b_ub=b_ub, method=options['method'])
    
    return [ res['x'], res['fun'], res['status'], res['message'] ]


