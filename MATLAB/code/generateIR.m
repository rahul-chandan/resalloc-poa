%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
%   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
%   All rights reserved. See LICENSE file in the project root for full license information.
%
%   Description: 
%   Generate the set `\mathcal{I}_R` as defined in the manuscript
%   "Utility Design for Distributed Resource Allocation -- Part I: 
%    Characterizing and Optimizing the Exact Price of Anarchy" by
%    Paccangnan, Chandan, Marden. See Arxiv 1807.01333 v3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function matrix = generateIR( n )

    height = 2*n^2 + 1;
    matrix = zeros(height, 3);
    
    sideFaceLen = floor((n+1)*n/2);
    sideFace = find(flip(tril(ones(n+1)),1))-1;
    sideFace = [floor(sideFace/(n+1)), mod(sideFace,n+1)];
    sideFace = sideFace(n+2:end,:);
    
    matrix(1:sideFaceLen,1:2) = sideFace;
    matrix(sideFaceLen+1:2*sideFaceLen,2:3) = sideFace;
    matrix(2*sideFaceLen+1:3*sideFaceLen,[3,1]) = sideFace;
    
    lastFace = [sideFace, n - sum(sideFace,2)];
    matrix(3*sideFaceLen+1:end,:) = lastFace(prod(lastFace,2) >= 1,:);

end
