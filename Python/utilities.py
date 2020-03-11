####################################################################################################
#
#   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
#   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
#   All rights reserved. See LICENSE file in the project root for full license information.
#
####################################################################################################

def computeCostMinPoA( n, c, f ):
    import numpy as np
    from dualPoA import dualPoA

    try:
        rowsC, colsC = c.shape
        rowsF, colsF = f.shape
    except ValueError:
        msg = 'Expected `(n, m)` vectors `c` and `f`, but received a one-dimensional vector.'
        raise RuntimeError(msg)

    if rowsC != n or rowsF != n:
        msg = 'Expected `(n, m)` vectors `c` and `f`, but received a one-dimensional vector.'
        raise RuntimeError(msg)

    res = dualPoA( n, 
                   np.vstack( ( np.zeros((1, colsC)), c, np.zeros((1, colsC)) ) ),
                   np.vstack( ( np.zeros((1, colsF)), f, np.zeros((1, colsF)) ) ),
                   True )

    return 1.0/res['x'][1]

def computeWelfareMaxPoA( n, w, f ):
    import numpy as np
    from dualPoA import dualPoA

    try:
        rowsW, colsW = w.shape
        rowsF, colsF = f.shape
    except ValueError:
        msg = 'Expected `(n, m)` vectors `w` and `f`, but received a one-dimensional vector.'
        raise RuntimeError(msg)

    if rowsW != n or rowsF != n:
        msg = 'Expected `(n, m)` vectors `w` and `f`, but received a one-dimensional vector.'
        raise RuntimeError(msg)

    res = dualPoA( n, 
                   np.vstack( ( np.zeros((1, colsW)), w, np.zeros((1, colsW)) ) ),
                   np.vstack( ( np.zeros((1, colsF)), f, np.zeros((1, colsF)) ) ),
                   False )
    
    # We adopt the convention that PoA > 1 for welfare-maximization games as well
    return res['x'][1]

def optimizeCostMinPoA( n, c ):
    import numpy as np
    from optimalPoA import optimalPoA

    if c.shape[0] != n or c.size != n:
        msg = 'Expected an `n`-length array `c`, but received a vector of different size or length.'
        raise RuntimeError(msg)

    c = np.pad(c, 1)

    res = optimalPoA(n, c, True)

    return 1.0/res['x'][-1], res['x'][0:-1]

def optimizeWelfareMaxPoA( n, w ):
    import numpy as np
    from optimalPoA import optimalPoA

    if w.shape[0] != n or w.size != n:
        msg = 'Expected an `n`-length array `w`, but received a vector of different size or length.'
        raise RuntimeError(msg)

    w = np.pad(w, 1)

    res = optimalPoA(n, w, False)

    return res['x'][-1], res['x'][0:-1]
