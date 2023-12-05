clc
totalTestedData = 30;
tesla = Analysis('Tesla Stock', 'TSLA-6 month.csv', totalTestedData);
tesla.runAnalysis();

apple = Analysis('Apple Stock', 'AAPL-6 month.csv', totalTestedData);
apple.runAnalysis();
