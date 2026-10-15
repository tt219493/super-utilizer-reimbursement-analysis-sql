/*
===========================
Explore Percent Utilization 
===========================
Script Purpose: 
	- Creates function 'percent_utilization' (which is dropped at the end of the script)
	- Takes parameter @percentile FLOAT which is the population percentile to look at
	- Returns table with 'percent_utilization' and 'percentile_population' 
	- Show how much of total utilization is accounted for by the percentile inputted

Example:
	SELECT * FROM sample1.percent_utilization(90.0)
	- Returns the percent utilization accounted for by the 90th percentile of utilizers (top 10% of utilizers)
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

DROP FUNCTION IF EXISTS sample1.percent_utilization;
GO
