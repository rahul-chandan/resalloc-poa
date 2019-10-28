###########################################################################
#
#   File: generateVectors.py
#   Author: Rahul Chandan   
#   Last updated: 2019/10/24
#
#   Description:
#   Functions for generating the vectors `I` and `I_R` of triples (a,b,x). 
#   Vector `I` is exactly `(1/6)(n+1)(n+2)(n+3) - 1` rows long.
#   Vector `I_R` is exactly `(2)(n^2) + 1` rows long.
#
###########################################################################

def generateI( n ):
    import numpy as np

    vtri = np.vectorize(np.tri, otypes=[np.object], excluded=['N','M'])
    matrix = np.vstack( np.nonzero( np.fliplr( np.stack( vtri( n+1, n+1, -np.arange(n+1) ) ) ) ) ).T[1:]

    return matrix

def generateIR( n ):
    import numpy as np
    
    height = 2*n**2 + 1
    matrix = np.zeros((height,3), dtype=np.int)

    sideFaceLen = int((n+1)*n/2)
    sideFace = np.vstack( np.nonzero( np.flipud(np.tri(n+1)) ) )[:,n+1:]
    
    matrix[0:sideFaceLen,0:2] = sideFace.T
    matrix[sideFaceLen:2*sideFaceLen,1:3] = sideFace.T
    matrix[2*sideFaceLen:3*sideFaceLen,[2,0]] = sideFace.T

    lastFace = np.vstack( (sideFace, n - np.sum(sideFace, axis=0)) )
    mask = np.prod(lastFace, axis=0) >= 1
    
    matrix[3*sideFaceLen:,:] = lastFace.T[mask,...]

    return matrix
