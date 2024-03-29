classdef Analysis    
    properties
        stockName
        stockRecord
        totalTestedData
    end
    
    methods
        function obj = Analysis(stockName, stockRecord, totalTestedData)
            %STOCKANALYSIS Construct an instance of this class
            %   Detailed explanation goes here
            obj.stockName = stockName;
            obj.stockRecord = stockRecord;
            obj.totalTestedData = totalTestedData;
        end

        function [dates, closedPrices] = getDateAndClosedPrices(obj)
            opts = detectImportOptions(obj.stockRecord);
            opts.VariableNamingRule = 'preserve';
            data = readtable(obj.stockRecord, opts);
            
            % Select the 'Date' and 'Close' columns
            dates = data.('Date');
            closedPrices = data.('Close');
            
            % Convert dates to MATLAB datetime
            dates = datetime(dates, 'InputFormat', 'yyyy-MM-dd');
        end

        function runAnalysis(obj)
            [dates, closedPrices] = getDateAndClosedPrices(obj);
            totalSells = numel(closedPrices);
            totalTestedData = obj.totalTestedData;
            totalTrainedData = totalSells - totalTestedData;

            % create train and test data
            X_trained = zeros(totalTrainedData, 1);
            for i = 1: totalTrainedData
                X_trained(i) = i;
            end

            Y_trained = zeros(totalTrainedData, 1);
            for i = 1: totalTrainedData
                Y_trained(i) = closedPrices(i);
            end

            X_tested = zeros(totalTestedData, 1);
            for i = 1: totalTestedData
                X_tested(i) = i;
            end

            Y_tested = zeros(totalTestedData, 1);
            for i = 1: totalTestedData
                Y_tested(i) = closedPrices(totalTrainedData + i);
            end 

            % Create interpolation method
            interpolation = InterpolatedMethods(X_trained, Y_trained);

            linear_function = interpolation.leastSquareApproximationLinear();

            cubic_function = interpolation.leastSquareApproximationCubic();

            % Interpolation
            % Calculate interpolated value
            Y_interpolated_polynomial = zeros(totalTrainedData, 1);
            for i = 1: totalTrainedData
                Y_interpolated_polynomial(i) = interpolation.lagrangePolynomial(i);
            end

            Y_interpolated_linear = zeros(totalTrainedData, 1);
            for i = 1: totalTrainedData
                Y_interpolated_linear(i) = linear_function(i);
            end

            Y_interpolated_cubic = zeros(totalTrainedData, 1);
            for i = 1: totalTrainedData
                Y_interpolated_cubic(i) = cubic_function(i);
            end

            dates_trained = dates(1: totalTrainedData);

            % Plot graph
            is_interpolation = 1;
            plotGraph(obj, dates_trained, Y_trained, Y_interpolated_polynomial, Y_interpolated_linear, Y_interpolated_cubic, is_interpolation); 
            
            % Extrapolation
            % Calculate expected value
            Y_expected_polynomial = zeros(totalTestedData, 1);
            for i = 1: totalTestedData
                Y_expected_polynomial(i) = interpolation.lagrangePolynomial(totalTrainedData + i);
            end

            Y_expected_linear = zeros(totalTestedData, 1);
            for i = 1: totalTestedData
                Y_expected_linear(i) = linear_function(totalTrainedData + i);
            end

            Y_expected_cubic = zeros(totalTestedData, 1);
            for i = 1: totalTestedData
                Y_expected_cubic(i) = cubic_function(totalTrainedData + i);
            end

            dates_tested = dates((totalTrainedData + 1): end);

            % Plot graph
            is_interpolation = 0;
            plotGraph(obj, dates_tested, Y_tested, Y_expected_polynomial, Y_expected_linear, Y_expected_cubic, is_interpolation);
           

            % Perform RMSD
            RMSD_polynomial = obj.rootMeanSquareDeviation(Y_tested, Y_expected_polynomial);
            RMSD_linear = obj.rootMeanSquareDeviation(Y_tested, Y_expected_linear);
            RMSD_cubic = obj.rootMeanSquareDeviation(Y_tested, Y_expected_cubic);

            % Compare different methods' RMSD, and pick the best method
            min_RMSD = min([RMSD_polynomial, RMSD_linear, RMSD_cubic]);
            forecastPrices = zeros(totalTestedData, 1);
            
            fprintf("Polynomial function's RMSD between tested data and its forecast prices for the next 30 dates is %.4f\n", RMSD_polynomial);
            fprintf("Linear function's RMSD between tested data and its forecast prices for the next 30 dates is %.4f\n", RMSD_linear);
            fprintf("cubic function's RMSD between tested data and its forecast prices for the next 30 dates is %.4f\n", RMSD_cubic);

            if (min_RMSD == RMSD_polynomial)
                forecastPrices = Y_expected_polynomial;
                fprintf("=> Polynomial function is best matched %s !\n", obj.stockName);
            elseif (min_RMSD == RMSD_linear)
                forecastPrices = Y_expected_linear;
                fprintf("=> Linear function is best matched for %s !\n", obj.stockName);
            else
                forecastPrices = Y_expected_cubic;
                fprintf("=> cubic function is best matched %s !\n", obj.stockName);
            end

            % Determine buying date, selling date, and max profit
            [buy, sell, maxProfit] = obj.buySellStock(forecastPrices);
            buyDate = dates(totalTrainedData + buy);
            sellDate = dates(totalTrainedData + sell);

            % Notify the user forecast prices, buy date, sell date, and
            % maximum profit.
            disp("------------------------------------------------- ");
            disp("Forecast prices correspondent to tested dates table")
            dates_forecastPrices = table(dates_tested, forecastPrices, 'VariableNames', {'Dates', 'Forecast prices'});
            disp(dates_forecastPrices);
            fprintf("Best day to buy stock suggested by best matched function: %s\n", buyDate);
            fprintf("Best day to sell stock suggested by best matched function: %s\n", sellDate);
            fprintf("Maximum profit is $%.4f\n", maxProfit);

            % Actual
            [actualBuy, actualSell, actualMaxProfit] = obj.buySellStock(Y_tested);
            actualBuyDate = dates(totalTrainedData + actualBuy);
            actualSellDate = dates(totalTrainedData + actualSell);

            % Notify the user actual prices, buy date, sell date, and
            % maximum profit.
            disp("------------------------------------------------- ");
            disp("Actual prices correspondent to tested dates table")
            actual_dates_prices = table(dates_tested, Y_tested, 'VariableNames', {'Dates', 'Actual prices'});
            disp(actual_dates_prices);
            fprintf("Actual best day to buy stock: %s\n", actualBuyDate);
            fprintf("Actual best day to sell stock: %s\n", actualSellDate);
            fprintf("Actual maximum profit is $%.4f\n", actualMaxProfit);
            fprintf("If you buy stock on %s and sell it on %s as the best matched function suggests, your actual " + ...
                "profit is %.2f.\n", buyDate, sellDate, closedPrices(find(dates == sellDate)) - closedPrices(find(dates == buyDate)));
        end
        
        function plotGraph(obj, dates, Y, Y_polynomial, Y_linear, Y_cubic, is_interpolation)
            % Assuming you have already defined your data and interpolation methods

            % Figure 1: Test data and Polynomial Interpolation
            figure;
            plot(dates, Y, 'b.', 'MarkerSize', 15); % blue
            hold on;
            plot(dates, Y_polynomial, 'm-', 'LineWidth', 1.5, 'MarkerSize', 15);
            % datetick('x', 'yyyy-mm-dd', 'keepticks');
            xlabel('Date');
            ylabel('Price');
            title(obj.stockName);
            legend('Actual Stock Price', 'Polynomial Function');
            grid on;
            if (is_interpolation == 1)
                set(gcf, 'Name', 'Polynomial Interpolation'); % Set figure name
            else 
                set(gcf, 'Name', 'Polynomial Extrapolation'); % Set figure name
            end
            
            % Set y-axis range
            maxY_axis = max(Y_polynomial);
            ylim([0 maxY_axis]);
            
            % Figure 2: Test data and Piecewise Linear Interpolation
            figure;
            plot(dates, Y, 'b.', 'MarkerSize', 15); % blue
            hold on;
            plot(dates, Y_linear, 'r-', 'LineWidth', 1.5, 'MarkerSize', 15);
            % datetick('x', 'yyyy-mm-dd', 'keepticks');
            xlabel('Date');
            ylabel('Price');
            title(obj.stockName);
            legend('Actual Stock Price', 'Linear Function');
            grid on;
            if (is_interpolation == 1)
                set(gcf, 'Name', 'Linear Interpolation'); % Set figure name
            else
                set(gcf, 'Name', 'Linear Extrapolation'); % Set figure name
            end
            % Set y-axis range
            maxY_axis = max(Y_linear);
            ylim([0 maxY_axis]);
            
            % Figure 3: Test data and Least Square Cubic Interpolation
            figure;
            plot(dates, Y, 'b.', 'MarkerSize', 15); % blue
            hold on;
            plot(dates, Y_cubic, 'k-', 'LineWidth', 1.5, 'MarkerSize', 15);
            % datetick('x', 'yyyy-mm-dd', 'keepticks');
            xlabel('Date');
            ylabel('Price');
            title(obj.stockName);
            legend('Actual Stock Price', 'Cubic Function');
            grid on;
            if (is_interpolation == 1)
                set(gcf, 'Name', 'Cubic Interpolation'); % Set figure name
            else
                set(gcf, 'Name', 'Cubic Extrapolation'); % Set figure name
            end
            
            % Set y-axis range
            maxY_axis = max(Y_cubic);
            ylim([0 maxY_axis]);
        end

        function [buy, sell, maxProfit] = buySellStock(obj, forecastPrices)
            n = numel(forecastPrices);
            maxProfit = 0;
            buy = 1; % buy index
            sell = 1; % sell index
            left = 1;
            right = 2;
            while (right <= n)
                if (forecastPrices(left) < forecastPrices(right))
                    profit = forecastPrices(right) - forecastPrices(left);
                    if profit > maxProfit
                        maxProfit = profit;
                        buy = left;
                        sell = right;
                    end
                else
                    left = right;
                end
                right = right + 1;
            end
        end

        function rootMeanSquareDeviation = rootMeanSquareDeviation(obj, T, E)
            % T: an array of tested value
            % E: an array of estimated value from interpolated methods
            lowerbound = 1;
            upperbound = numel(T);
            rootMeanSquareDeviation = 0;
            for i = lowerbound: upperbound
               rootMeanSquareDeviation = rootMeanSquareDeviation + (T(i) - E(i))^2;
            end
            rootMeanSquareDeviation = sqrt(rootMeanSquareDeviation / (upperbound - lowerbound + 1));
        end
        
    end
end

