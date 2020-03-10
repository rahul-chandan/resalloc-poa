####################################################################################################
#
#   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
#   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
#   All rights reserved. See LICENSE file in the project root for full license information.
#
#   Description: 
#   Finds the optimal price-of-anarchy and cost-generating/utility-allocation function.
#
####################################################################################################

def optimalPoA(n, w, costMinGame=False, method='revised simplex'):
    import numpy as np
    from scipy.optimize import linprog
    from generateVectors import generateIR

    I = generateIR(n) # [a,b,x]
    a = I[:,0]
    b = I[:,1]
    x = I[:,2]

    A1 = -1.0*np.eye(n+1)[0:n]
    B1 = np.zeros(n)

    A2 = np.zeros((I.shape[0],n+1))
    A2[np.arange(I.shape[0])[a+x > 0, ...],(a+x-1)[a+x > 0, ...]] = a[a+x > 0, ...]
    A2[np.arange(I.shape[0]),a+x] = -b
    A2[np.arange(I.shape[0]),-1] = -1.0*w[a+x]
    B2 = -1.0*w[b+x]

    if costMinGame:
        A = np.vstack( (A1,-A2) )
        B = np.hstack( (B1,-B2) )
    else:
        A = np.vstack( (A1,A2) )
        B = np.hstack( (B1,B2) )
    
    if costMinGame:
        c = -1.0*np.eye(n+1)[-1] # [ f, mu ]
    else:
        c = np.eye(n+1)[-1] # [ f, mu ]

    res = linprog(c, A_ub=A, b_ub=B, method=method)

    return res
