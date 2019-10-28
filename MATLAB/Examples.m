%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   File: Examples.m
%   Author: Rahul Chandan
%
%   Description:
%   The code for the illustrative examples in Section 6 of
%   Chandan R, Paccagnan D, Marden JR (2019) Optimal mechanisms for
%   distributed resource-allocation. Submitted.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Example 1: Congestion Games

maxPlayers = 10;
maxOrder = 8;

arrPoA = zeros(maxPlayers, maxOrder);

for d = 1:maxOrder
    for n = 1:maxPlayers
        % Scaling down the cost and cost-generating functions improves the
        % accuracy of MATLAB's `linprog` function
        c = (1:n).^(d+1)./1000;
        f = (1:n).^d./1000;
        
        arrPoA(n,d) = computeCostMinPoA(n, c', f');
    end
end

figure

for d = 1:maxOrder
    label = sprintf('d = %d', d);
    semilogy(arrPoA(:,d), 'DisplayName', label);
    hold on
end

hold off

title('Example 1: Congestion Games')
xlabel('n')
ylabel('PoA')
legend

%% Example 2: ell-Coverage Games

maxPlayers = 25;
maxEll = 8;

arrPoA = zeros(maxPlayers, maxEll);

for ell = 1:maxEll
    for n = 1:maxPlayers
        w = min(1:n, ell);
        arrPoA(n, ell) = optimizeWelfareMaxPoA(n, w');
    end
end

figure

for ell = 1:maxEll
    label = sprintf('ell = %d', ell);
    semilogy(arrPoA(:,ell), 'DisplayName', label);
    hold on
end

hold off

title('Example 2: Ell-Coverage Games')
xlabel('n')
ylabel('PoA')
legend

%% Example 3: Probabilistic-Objective Games

n = 25;
res = 100;
Q = linspace(0,0.99,res);

optPoA = zeros(res, 1);
esPoA = zeros(res, 1);

for idx = 1:res
    q = Q(idx);
    w = 1-q.^(1:n);
    f = w ./ (1:n);
    esPoA(idx) = computeWelfareMaxPoA(n, w', f');
    optPoA(idx) = optimizeWelfareMaxPoA(n, w');
end

figure

plot(esPoA, 'DisplayName', 'PoA^{es}');
hold on
plot(optPoA, 'DisplayName', 'PoA^{opt}');
hold off

title('Example 3: Probabilistic-Objective Games')
xlabel('q')
ylabel('PoA')
legend

