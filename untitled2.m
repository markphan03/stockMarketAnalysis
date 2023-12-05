% Read the CSV file
data = readtable('TSLA-1 month.csv');
dates = data.Date;
closePrices = data.Close;

% Convert dates to a numeric format for calculations
datesNum = datenum(dates);

% Lagrange Interpolation
degreeLagrange = 5; % Adjust this as needed
pLagrange = polyfit(datesNum, closePrices, degreeLagrange);
yLagrange = polyval(pLagrange, datesNum);

% Calculate RMSD for Lagrange Interpolation
rmsdLagrange = sqrt(mean((closePrices - yLagrange).^2));

% Plotting Lagrange Interpolation
figure;
plot(dates, closePrices, 'o'); 
hold on;
plot(dates, yLagrange, '-'); 
datetick('x','yyyy-mm-dd');
xlabel('Date');
ylabel('Close Price');
title(['Lagrange Interpolation for TSLA Close Price (RMSD: ' num2str(rmsdLagrange) ')']);
hold off;

% Piecewise Linear Approximation
yPiecewiseLinear = interp1(datesNum, closePrices, datesNum, 'linear');

% Calculate RMSD for Piecewise Linear Approximation
rmsdPiecewise = sqrt(mean((closePrices - yPiecewiseLinear).^2));

% Plotting Piecewise Linear Approximation
figure;
plot(dates, closePrices, 'o');
hold on;
plot(dates, yPiecewiseLinear, '-');
datetick('x','yyyy-mm-dd');
xlabel('Date');
ylabel('Close Price');
title(['Piecewise Linear Approximation for TSLA Close Price (RMSD: ' num2str(rmsdPiecewise) ')']);
hold off;

% Least Square Approximation Cubic
degreeCubic = 3;
pCubic = polyfit(datesNum, closePrices, degreeCubic);
yCubic = polyval(pCubic, datesNum);

% Calculate RMSD for Least Square Approximation Cubic
rmsdCubic = sqrt(mean((closePrices - yCubic).^2));

% Plotting Least Square Approximation Cubic
figure;
plot(dates, closePrices, 'o');
hold on;
plot(dates, yCubic, '-');
datetick('x','yyyy-mm-dd');
xlabel('Date');
ylabel('Close Price');
title(['Least Square Approximation Cubic for TSLA Close Price (RMSD: ' num2str(rmsdCubic) ')']);
hold off;
