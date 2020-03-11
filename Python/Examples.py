####################################################################################################
#
#   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
#   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
#   All rights reserved. See LICENSE file in the project root for full license information.
#
#   Description:
#   The code for the illustrative examples in Section 6 of Chandan R, Paccagnan D, Marden JR (2019) 
#   Optimal mechanisms for distributed resource-allocation. Submitted.
#
####################################################################################################

import numpy as np
import matplotlib.pyplot as plt
from utilities import *


####################################################################################################
## Example 1: Congestion Games

maxPlayers = 10
maxOrder = 8

arrPoA = np.zeros((maxPlayers, maxOrder))

for d in np.arange(1,maxOrder+1):
    for n in np.arange(1,maxPlayers+1):
        
        # Define edge cost and cost-generating functions corresponding to number of players `n` and
        # polynomial order `d`, i.e., `B := \{ ( x^{d+1}, x^d ) \}`

        c = np.tile(np.arange(1,n+1)**(d+1), (1,1)).T
        f = np.tile(np.arange(1,n+1)**d, (1,1)).T
        
        # Compute the price-of-anarchy of the specified congestion game

        arrPoA[n-1,d-1] = computeCostMinPoA(n, c, f)

fig, ax = plt.subplots()

for d in np.arange(1,maxOrder+1):
    ax.semilogy(np.arange(1,maxPlayers+1), arrPoA[:,d-1])

legend = ['d = %d' % d for d in np.arange(1, maxOrder+1)]

ax.set_title('Example 1: Congestion Games')
ax.legend( legend )
ax.xaxis.set_label_text('n')
ax.yaxis.set_label_text('PoA')


####################################################################################################
## Example 2: ell-Coverage Games

maxPlayers = 10
maxEll = 8

arrPoA = np.zeros((maxPlayers, maxEll))

for ell in np.arange(1,maxEll+1):
    for n in np.arange(1,maxPlayers+1):
        
        # Define the function `w^\ell (x) := \min \{ x, \ell \}`
        
        w = np.arange(1,n+1)
        w[w > ell] = ell

        # Compute the optimal price-of-anarchy, and optimal utility-allocation function for the
        # specified ell-coverage game

        optPoA, optF = optimizeWelfareMaxPoA(n, w)
        arrPoA[n-1,ell-1] = optPoA

fig, ax = plt.subplots()

for ell in np.arange(1,maxEll+1):
    ax.semilogy(np.arange(1,maxPlayers+1), arrPoA[:,ell-1])

legend = ['ell = %d' % ell for ell in np.arange(1, maxEll+1)]

ax.set_title('Example 2: ell-Coverage Games')
ax.legend( legend )
ax.xaxis.set_label_text('n')
ax.yaxis.set_label_text('PoA')


####################################################################################################
## Example 3: Probabilistic-Objective Games

n = 10
res = 10
Q = np.linspace(0,0.99,res)

optPoAArr = np.zeros(res)
esPoAArr = np.zeros(res)

for idx in np.arange(res):
    q = Q[idx]

    # Define the welfare and equal-shares utility-allocation functions corresponding to the number 
    # of players `n` and the probability of failure `q`

    w = 1.0 - q**np.arange(1,n+1)
    f = w / np.arange(1,n+1)

    # Compute the price-of-anarchy in the case where the equal-shares utility-allocation function
    # is used. This corresponds to the optimal robust price-of-anarchy

    esPoAArr[idx] = computeWelfareMaxPoA( n, 
                                          np.tile(w, (1,1)).T, 
                                          np.tile(f, (1,1)).T )

    # Compute the optimal price-of-anarchy, and optimal utility-allocation function, for the
    # specified probabilistic-objective game

    optPoA, optF = optimizeWelfareMaxPoA(n, w)

    optPoAArr[idx] = optPoA

fig, ax = plt.subplots()

ax.plot(optPoAArr)
ax.plot(esPoAArr)

legend = ['PoA_opt', 'PoA_es']

ax.set_title('Example 3: Probabilistic-Objective Games')
ax.legend( legend )
ax.xaxis.set_label_text('q')
ax.yaxis.set_label_text('PoA')

plt.show()
