clc
totalTestedData = 6;
tesla = Analysis('Tesla Stock', 'TSLA-1 month.csv', totalTestedData);
tesla.runAnalysis();

apple = Analysis('Apple Stock', 'AAPL-1 month.csv', totalTestedData);
apple.runAnalysis();
