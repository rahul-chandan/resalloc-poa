from .helpers import dualLP, optimalLP, optimalLPConstant
import numpy as np

def computeCostMinPoA(n, B, f, options=None):
    ''' Authors: Rahul Chandan, Dario Paccagnan and Jason Marden
        Copyright(c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
        All rights reserved. See LICENSE file in the project root for full license information.

        Description 
        -----------
        Computes the price-of-anarchy of atomic congestion games 
        with congestion functions obtained as linear combinations of
        {b_1(x),...,b_m(x)}, and n players

        Parameters
        ----------
        n : int
            Number of players.
        B : (m,n) ndarray
            Basis congestion functions defined for 'N = {1, 2, ..., n}'.
        f : (m,n) ndarray
            Player cost functions defined for 'N = {1, 2, ..., n}'.
        options : dict, optional
            Optimization options.

        Returns
        -------
        PoA : float
            Price-of-anarchy.
    '''

    if options is None:
        try:
            from scipy.optimize import linprog

            options = { 'solver' : linprog,
                        'method' : 'revised simplex' }

        except ImportError:
            msg = 'No optimization options were specified, and SciPy is not installed.'
            raise RuntimeError(msg)

    Btemp = np.pad(B, pad_width=((0,0),(1,1)), mode='constant').T
    ftemp = np.pad(f, pad_width=((0,0),(1,1)), mode='constant').T

    x, _, exitFlag, output = dualLP( n, Btemp, ftemp, True, options)

    if exitFlag:
        raise RuntimeError(output)

    PoA = 1./x[1]

    return PoA



def computeWelfareMaxPoA(n, B, f, options=None):
    ''' Authors: Rahul Chandan, Dario Paccagnan and Jason Marden
        Copyright(c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
        All rights reserved. See LICENSE file in the project root for full license information.

        Description 
        -----------
        Computes the price-of-anarchy of atomic congestion games 
        with welfare functions obtained as linear combinations of
        {b_1(x),...,b_m(x)}, utility functions obtained as linear
        combinations of {f_1(x),...,f_m(x)}, and n players.

        Parameters
        ----------
        n : int
            Number of players.
        B : (m,n) ndarray
            Basis welfare functions defined for 'N = {1, 2, ..., n}'.
        f : (m,n) ndarray
            Player utility functions defined for 'N = {1, 2, ..., n}'.
        options : dict, optional
            Optimization options.

        Returns
        -------
        PoA : float
            Price-of-anarchy of optimal constant tolls.
    '''

    if options is None:
        try:
            from scipy.optimize import linprog

            options = { 'solver' : linprog,
                        'method' : 'revised simplex' }

        except ImportError:
            msg = 'No optimization options were specified, and SciPy is not installed.'
            raise RuntimeError(msg)

    Btemp = np.pad(B, pad_width=((0,0),(1,1)), mode='constant').T
    ftemp = np.pad(f, pad_width=((0,0),(1,1)), mode='constant').T

    x, _, exitFlag, output = dualLP( n, Btemp, ftemp, False, options)

    if exitFlag:
        raise RuntimeError(output)

    PoA = x[1]

    return PoA



def optimizeCostMinPoA(n, B, options=None):
    ''' Authors: Rahul Chandan, Dario Paccagnan and Jason Marden
        Copyright(c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
        All rights reserved. See LICENSE file in the project root for full license information.

        Description 
        -----------
        Optimizes the price-of-anarchy of atomic congestion games 
        with congestion functions obtained as linear combination of 
        basis {b_1(x),...,b_m(x)}, and n players.

        Parameters
        ----------
        n : int
            Number of players.
        B : (m,n) ndarray
            Basis cost functions defined for 'N = {1, 2, ..., n}'.
        options : dict, optional
            Optimization options.

        Returns
        -------
        OptPoA : float
            Price-of-anarchy of optimal constant tolls.
        Optf : (m,n) ndarray
            Functions used to generate optimal mechanism.
    '''

    if options is None:
        try:
            from scipy.optimize import linprog

            options = { 'solver' : linprog,
                        'method' : 'revised simplex' }
                        
        except ImportError:
            msg = 'No optimization options were specified, and SciPy is not installed.'
            raise RuntimeError(msg)
    
    m = np.shape( B )[0]
    OptPoA = 0.
    Optf = np.zeros( (m,n), dtype=np.float )

    for currentBasis in np.arange(m):
        w = B[currentBasis,:]
        
        x, _, exitFlag, output = optimalLP(n, np.pad(w, pad_width=1, mode='constant'), True, options)

        if exitFlag:
            raise RuntimeError(output)

        Optf[currentBasis,:] = x[0:n]
        currentPoA = 1./x[n]
        
        OptPoA = max(OptPoA, currentPoA)

    return [ OptPoA, Optf ]



def optimizeCostMinPoAConstant(n, B, options=None):
    ''' Authors: Rahul Chandan, Dario Paccagnan and Jason Marden
        Copyright(c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
        All rights reserved. See LICENSE file in the project root for full license information.

        Description
        -----------
        Optimizes the price-of-anarchy (using *constant* tolls) of atomic 
        congestion games with congestion functions obtained as linear combination 
        of basis {b_1(x),...,b_m(x)}, and n players.

        Parameters
        ----------
        n : int
            Number of players.
        B : (m,n) ndarray
            Basis congestion functions defined for 'N = {1, 2, ..., n}'.
        options : dict, optional
            Optimization options.

        Returns
        -------
        OptPoA : float
            Price-of-anarchy of optimal constant mechanism.
        OptTau : (m,) ndarray
            Values used to generate optimal constant mechanism.
    '''

    if options is None:
        try:
            from scipy.optimize import linprog

            options = { 'solver' : linprog,
                        'method' : 'revised simplex' }
                        
        except ImportError:
            msg = 'No optimization options were specified, and SciPy is not installed.'
            raise RuntimeError(msg)

    m = np.shape( B )[0]
    Btemp = np.pad(B, pad_width=((0,0),(1,1)), mode='constant').T
        
    x, _, exitFlag, output = optimalLPConstant(n, Btemp, True, options)

    if exitFlag:
        raise RuntimeError(output)

    OptPoA = 1./x[m+1]
    OptTau = x[0:m]/x[m]

    return [ OptPoA, OptTau ]



def optimizeWelfareMaxPoA(n, B, options=None):
    ''' Authors: Rahul Chandan, Dario Paccagnan and Jason Marden
        Copyright(c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
        All rights reserved. See LICENSE file in the project root for full license information.

        Description
        -----------
        Optimizes the price-of-anarchy of atomic congestion games 
        with welfare functions obtained as linear combination of basis 
        {b_1(x),...,b_m(x)}, and n players.

        Parameters
        ----------
        n : int
            Number of players.
        B : (m,n) ndarray
            Resource welfare function defined for 'N = {1, 2, ..., n}'.
        options : dict, optional
            Choice of solver and options.

        Returns
        -------
        OptPoA : float
            Optimal price-of-anarchy.
        Optf : (m,n) ndarray
            Functions used to generate optimal mechanism.
    '''

    if options is None:
        try:
            from scipy.optimize import linprog

            options = { 'solver' : linprog,
                        'method' : 'revised simplex' }
                        
        except ImportError:
            msg = 'No optimization options were specified, and SciPy is not installed.'
            raise RuntimeError(msg)
    
    m = np.shape( B )[0]
    OptPoA = 0.
    Optf = np.zeros( (m,n), dtype=np.float )

    for currentBasis in np.arange(m):
        w = B[currentBasis,:]
        
        x, _, exitFlag, output = optimalLP(n, np.pad(w, pad_width=1, mode='constant'), False, options)

        if exitFlag:
            raise RuntimeError(output)

        Optf[currentBasis,:] = x[0:n]
        currentPoA = x[n]
        
        OptPoA = max(OptPoA, currentPoA)

    return [ OptPoA, Optf ]
