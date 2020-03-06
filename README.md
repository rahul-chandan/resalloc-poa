# Compute and optimize the price of anarchy  
(MATLAB<sup>®</sup> and Python)

This repository contains MATLAB<sup>®</sup> and Python scripts to compute and optimize the price of anarchy (PoA) in atomic congestion games and their maximization version.
See [wikipedia](https://en.wikipedia.org/wiki/Congestion_game) for congestion games and the price of anarchy.


**How to use**  
Matlab: clone or download; move to `resalloc-poa/Matlab`; run `ExampleGetStarted.m` to get started.  
Python: clone or download; move to `resalloc-poa/Python`;  run `Examples.py` to get started.


**Requirements**  
The Matlab<sup>®</sup> implementation requires either the Optimization Toolbox, or  [YALMIP](https://yalmip.github.io) + your choice of favorite linear programming solver.  
The Python implementation requires `numpy` and `scipy`.

*Authors*: Rahul Chandan, Dario Paccagnan, Jason Marden. *Email*: <rchandan@ucsb.edu>.
<br><br>

## What this package features

This package allows to:

1) Compute the price of anarchy for (atomic) congestion games; 
2) Optimize the price of anarchy for (atomic) congestion games by designing optimal tolling mechanisms.
  
This package also allows to compute and optimize the price of anarchy for the maximization version of (atomic) congestion games.

More details follow:  

*Computing the PoA*: this package computes the price of anarchy for the class of congestion games where each resource is associated to a latency function (also called delay function) obtained by the linear combination of non-negative real coefficients with the functions {b_1(x), …, b_m(x)}.
Polynomial congestion games are a special case, obtained using the functions {1, x, x^2, … , x^d}.

*Optimizing the PoA*: this package computes optimal tolls and the resulting optimal price of anarchy for the class of congestion games described in the point above.


The scripts `ExamplesArXiv1911_09806v2` and `ExamplesArXiv1911_07823v1` found in `resalloc-poa/Matlab` reproduce the numerical results featured in the articles `paccagnan2019incentivizing` and `chandan2019optimal` referenced below.
<br><br>

# References

The core of this package is a tractable linear program that allows to compute and optimize the price of anarchy.  
If you find this useful, you can cite either of the following papers, where the framework has been developed.

Links: [[pdf1](https://arxiv.org/abs/1911.09806)]
[[pdf2](https://arxiv.org/abs/1911.07823)]


```
@article{paccagnan2019incentivizing,
  title={Incentivizing efficient use of shared infrastructure: Optimal tolls in congestion games},
  author={Paccagnan, Dario and Chandan, Rahul and Ferguson, Bryce L and Marden, Jason R},
  journal={arXiv preprint arXiv:1911.09806 (v2)},
  year={2019}
}
```
```
@article{chandan2019optimal,
  title={Optimal mechanisms for distributed resource-allocation},
  author={Chandan, Rahul and Paccagnan, Dario and Marden, Jason R},
  journal={arXiv preprint arXiv:1911.07823},
  year={2019}
}
```
