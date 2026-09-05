-- ==========================================
-- A. DATA PREPROCESSING
-- ==========================================

-- A.1 Clean the Num_Transactions column (remove thousand-separator 
-- spaces inherited from Excel's number formatting)
UPDATE dbo.nexalink
SET Num_Transactions = REPLACE(Num_Transactions, ' ', '');

-- A.2 Check that no value remains non-convertible
SELECT Num_Transactions
FROM dbo.nexalink
WHERE TRY_CAST(Num_Transactions AS FLOAT) IS NULL;

-- A.3 Convert the column type (nvarchar -> float)
ALTER TABLE dbo.nexalink
ADD Num_Transactions_Clean FLOAT;

UPDATE dbo.nexalink
SET Num_Transactions_Clean = CAST(Num_Transactions AS FLOAT);

ALTER TABLE dbo.nexalink DROP COLUMN Num_Transactions;
EXEC sp_rename 'dbo.nexalink.Num_Transactions_Clean', 'Num_Transactions', 'COLUMN';

-- ==========================================
-- B. KPI ANALYSIS QUERIES
-- ==========================================

-- B.1 Daily trend of a metric (installs, sign-ups, DAUs...)
SELECT 
    Date AS Day,
    SUM(total_app_installs) AS Total
FROM dbo.nexalink
GROUP BY Date
ORDER BY Date;

-- B.2 Uninstall rate
SELECT 
    SUM(total_app_installs) AS TotalInstalls,
    SUM(Uninstalls) AS TotalUninstalls,
    CAST(SUM(Uninstalls) AS FLOAT) / NULLIF(SUM(total_app_installs), 0) AS UninstallRate
FROM dbo.nexalink;

-- B.3 Breakdown by dimension Device
SELECT 
    device  AS Dimension,
    SUM(daily_active_users) AS Total
FROM dbo.nexalink
GROUP BY device 
ORDER BY Total DESC;

-- B.4 Average of a metric over the whole period
SELECT 
    AVG(Number_of_App_Crashes) AS AverageValue
FROM dbo.nexalink;

-- B.5 Crash rate relative to DAUs
SELECT 
    Date AS Day,
    SUM(Number_of_App_Crashes) AS TotalCrashes,
    SUM(Daily_Active_Users) AS TotalDAU,
    CAST(SUM(Number_of_App_Crashes) AS FLOAT) / NULLIF(SUM(Daily_Active_Users), 0) AS CrashRate
FROM dbo.nexalink
GROUP BY Date
ORDER BY Date;

-- B.6 Breakdown by Region AND Device
SELECT 
    Region,
    Device,
    SUM(Num_Transactions) AS Total
FROM dbo.nexalink
GROUP BY Region, Device
ORDER BY Region, Total DESC;

-- C. DATA INTEGRATION - Raw Data Extraction for Excel
SELECT 
    Date,
    Region,
    Device,
    Total_App_Installs,
    User_Sign_Ups,
    Daily_Active_Users,
    Num_Transactions,
    Uninstalls,
    Number_of_App_Crashes,
    Avg_Time_Spent_per_User_min
FROM dbo.nexalink
ORDER BY Date;