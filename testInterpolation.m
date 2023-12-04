clc

% Larange Polynomial - example from slide pg.6
Xp = [2, 2.75, 4];
Yp = [0.5, 4/11, 0.25];
P_interpolation = InterpolatedMethods(Xp, Yp);
polynomial_function = P_interpolation.lagrangePolynomial();
disp("Polynomial function interpolates x = 2.5")
result = polynomial_function(2.5);
disp(result);

% Cubic interpolation - example from slide pg.8 Least Square Approximation
Xc = [0, 0.25, 0.50, 0.75, 1.00];
Yc = [1.0000, 1.2840, 1.6487, 2.1170, 2.7183];
C_interpolation = InterpolatedMethods(Xc, Yc);
cubic_function = C_interpolation.leastSquareApproximationCubic();
disp("Cubic function interpolates x = 0.80")
result = cubic_function(0.80);
disp(result);

% Linear interpolation - example from lab 5
Xl = [2, 4, 9, 11, 16, 18, 23, 25, 30];
Yl = [71, 69, 68, 66, 70, 68, 72, 75, 77];
L_interpolation = InterpolatedMethods(Xl, Yl);
linear_function = L_interpolation.piecewiseLinearApproximation();
disp("Linear function interpolates x = 10")
result = linear_function(10);
disp(result);
