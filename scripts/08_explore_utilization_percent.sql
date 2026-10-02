/*
===========================
Explore Percent Utilization 
===========================

Script Purpose: 
	Using the cumulative reimbursement table, explore how much utilization is account for by the top utilizers.
	A function will be created to allow for any percentile to be inputted.
*/


USE desynpuf_practice;
GO

/*
===========
Create Utilization Percentage Function 
===========
Parameter: @percentile as the percentile to look at
Output: Table showing the amount of the total utilization is accounted for by the percentile inputted
*/

CREATE OR ALTER FUNCTION sample1.percent_utilization (@percentile FLOAT)
RETURNS TABLE
AS 
RETURN (
	SELECT TOP (1)
		100.0 - percent_medicare_reimb AS percent_utilization,
		percent_population as percentile_population
	FROM sample1.beneficiaries_2008_cumulative
	WHERE percent_population >= @percentile
);
GO

SELECT * FROM sample1.percent_utilization(90.0);
SELECT * FROM sample1.percent_utilization(95.0);
SELECT * FROM sample1.percent_utilization(99.9);
GO

DROP FUNCTION IF EXISTS sample1.percent_reimb_accounted_for;
GO