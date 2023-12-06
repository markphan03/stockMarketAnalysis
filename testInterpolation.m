clc

% Larange Polynomial - example from slide pg.6
Xp = [2, 2.75, 4];
Yp = [0.5, 4/11, 0.25];
P_interpolation = InterpolatedMethods(Xp, Yp);
disp("Polynomial function interpolates x = 2.5")
result = P_interpolation.lagrangePolynomial(2.5);
disp(result);

% Cubic interpolation - example from slide pg.8 Least Square Approximation
% Cubic
Xc = [0, 0.25, 0.50, 0.75, 1.00];
Yc = [1.0000, 1.2840, 1.6487, 2.1170, 2.7183];
C_interpolation = InterpolatedMethods(Xc, Yc);
cubic_function = C_interpolation.leastSquareApproximationCubic();
disp("Cubic function interpolates x = 0.80")
result = cubic_function(0.80);
disp(result);

% Linear interpolation - example from slide pg.8 Least Square Approximation
% Linear
Xl = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
Yl = [1.3, 3.5, 4.2, 5.0, 7.0, 8.8, 10.1, 12.5, 13.9, 15.6];
L_interpolation = InterpolatedMethods(Xl, Yl);
linear_function = L_interpolation.leastSquareApproximationLinear();
disp("Linear function interpolates x = 10")
result = linear_function(10);
disp(result);
