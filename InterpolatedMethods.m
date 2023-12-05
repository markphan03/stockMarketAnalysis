classdef InterpolatedMethods
    %INTERPOLATEDMETHODS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X
        Y
    end
    
    methods
        function obj = InterpolatedMethods(X, Y)
            obj.X = X;
            obj.Y = Y;
        end

        function interpolated_value = lagrangePolynomial(obj, x_val)
            X = obj.X;
            Y = obj.Y;
            n = numel(X);
            interpolated_value = 0;
            
            for i = 1:n
                product = Y(i);
                for j = 1:n
                    if i ~= j
                        product = product * (x_val - X(j)) / (X(i) - X(j));
                    end
                end
                interpolated_value = interpolated_value + product;
            end
        end


        function piecewise_function = piecewiseLinearApproximation(obj)
            X = obj.X;
            Y = obj.Y;
            n = numel(X);
            max_error = 5;
            begin = [X(1), Y(1)];
            S_lower = -Inf;
            S_upper = Inf;
        
            for i = 1:(n - 1)
                S_lower_prime = max(S_lower, obj.slope(begin, [X(i+1), Y(i+1) - max_error]));
                S_upper_prime = min(S_upper, obj.slope(begin, [X(i+1), Y(i+1) + max_error]));  
                if S_lower_prime <= S_upper_prime
                    S_lower = S_lower_prime;
                    S_upper = S_upper_prime;              
                else
                    begin = [X(i), obj.f(S_lower, S_upper, X(i), begin(1), begin(2))];
                    S_lower = obj.slope(begin, [X(i+1), Y(i+1) - max_error]);
                    S_upper = obj.slope(begin, [X(i+1), Y(i+1) + max_error]);
                end
            end
        
            fprintf('Approximated linear function is ');
            fprintf('f(x) = %.4f(x - %.4f) + %.4f\n', (S_lower + S_upper)/2, begin(1), begin(2));
            piecewise_function = @(x) (S_lower + S_upper)/2 * (x - begin(1)) + begin(2);
        end

        function cubic_function = leastSquareApproximationCubic(obj)
            X = obj.X;
            Y = obj.Y;
            m = numel(X);
            S = zeros(7, 1); % summation of Xi^k from i = 1 to m - vector length 7
            b = zeros(4, 1); % summation of Yi * Xi ^k from i = 1 to m - vector length 4
            for k = 0: 6 
                for i = 1: m
                    S(k+1) = S(k+1) + X(i)^k;
                    if (k <= 3)
                        b(k+1) = b(k+1) + Y(i) * X(i)^k;
                    end
                end
            end
            
            A = zeros(4, 4);
            for i = 1: 4
                k = i;
                for j = 1: 4
                    A(i, j) = S(k);
                    k = k + 1;
                end
            end
            % create and solve a system of 4 linear equations using Gaussian elimination
            C = obj.gaussianElimination(A, b);
        
            % Make a cubic function
            fprintf('Approximated cubic function is ')
            fprintf('f(x) = %.4f + %.4fx + %.4fx^2 + %.4fx^3\n', C(1), C(2), C(3), C(4));
            cubic_function = @(x) C(1) + C(2) * x + C(3) * x^2 + C(4) * x^3;
        end
        
        function result = slope(obj, pointA, pointB)
            result = (pointB(2) - pointA(2)) / (pointB(1) - pointA(1));
        end
        
        function result = f(obj, Su, Sl, x, begin_x, begin_y)
            result = (Sl + Su)/2 * (x - begin_x) + begin_y;
        end      

        function X = gaussianElimination(obj, A, b)
            [m, n] = size(A);
            Aug = [A, b]; % Augmented matrix 
           
            S = zeros(m, 1);
            for i = 1: (n-1)
                S(i) = max(abs(A(i, 1:n)));
            end
        
            for k = 1: (n-1)
                % Find pivot row
                pivot = abs(A(k, k)) / S(k);
                pivot_row = k;
                for i = (k + 1): n 
                    candidate = abs(A(i, k)) / S(i);
                    if candidate > pivot
                        pivot = candidate;
                        pivot_row = i;
                    end
                end
                
                % Swap rows
                temp = Aug(k, :);
                Aug(k, :) = Aug(pivot_row, :);
                Aug(pivot_row, :) = temp;
                
                % Forward elimination
                for i = (k+1): n 
                    EC = Aug(i, k) / Aug(k, k);
                    for j = k: (n + 1) 
                        Aug(i, j) = Aug(i, j) - EC * Aug(k, j);
                    end
                end
                
            end
           
            X = zeros(m, 1);
            for i = n: -1: 1
                X(i) = Aug(i, n+1);
                for j = n: -1: (i+1)
                    X(i) = X(i) - Aug(i, j) * X(j);
                end
                X(i) = X(i) / Aug(i, i); 
            end  
        end
    end
end

