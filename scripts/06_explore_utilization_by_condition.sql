/*
===========================
Exploring Reimbursements & Utilization by Condition and Number of Conditions 
===========================
Script Purpose: 
	- Grouping by number of conditions to compare reimbursements / utilization for each group
	- For each chronic condition (out of the 11 listed in the dataset), 
	  group by condition to compare reimbursements / utilization for those with condition vs without condition

Methodology and Functions Used:
	- CTEs for selecting necessary information before GROUP BY aggregation
	- PERCENTILE_CONT() for median
	- MIN(), AVG(), MAX() for distribution information
	- LAG() to find the ratio of medians between groups
	- NULLIF() to replace divide-by-zero with NULL  
	- COALESCE() to replace NULL values from NULLIF()
*/

USE desynpuf_practice;
GO

/*
============
Utilization by Number of Conditions
-- Min, median, mean, max reimbursements by number of conditions
============
*/

WITH #conditions AS (
	SELECT
		num_conditions,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY num_conditions) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		num_conditions,
		COUNT(*) AS population_count,
		FORMAT(MIN(total_medicare_reimb), 'N2') AS min_medicare_reimb,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		FORMAT(AVG(total_medicare_reimb), 'N2') AS avg_medicare_reimb,
		FORMAT(MAX(total_medicare_reimb), 'N2') AS max_medicare_reimb
	FROM #conditions
	GROUP BY num_conditions
)

SELECT
	num_conditions,
	population_count,
	min_medicare_reimb,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	avg_medicare_reimb,
	max_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / NULLIF(LAG(median_medicare_reimb, 1) OVER (ORDER BY num_conditions ASC), 0), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO

/*
--------------------
There is a clear trend where an increasing number of conditions increases Medicare utilization.
--------------------
*/

/*
============
Utilization by Condition
-- Median and mean reimbursements for those with condition vs those without
============
*/

/*
--------------------
For each condition, there is an increase in utilization among the population with the condition vs without.
The biggest increase in median reimbursement and utilization comes from Ischemic Heart Disease with a 11.21x increase. 
Chronic Kidney Disease, Diabetes, and Stroke all have greater than 8x increases in utilization.
--------------------
*/


-- Alzheimer's
WITH #condition AS (
	SELECT
		alzheimers,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY alzheimers) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		alzheimers,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY alzheimers
)

SELECT
	alzheimers,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY alzheimers ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO


-- Chronic Heart Failure
WITH #condition AS (
	SELECT
		chronic_heart_failure,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY chronic_heart_failure) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		chronic_heart_failure,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY chronic_heart_failure
)

SELECT
	chronic_heart_failure,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY chronic_heart_failure ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO

-- Chronic Kidney Disease
WITH #condition AS (
	SELECT
		chronic_kidney_disease,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY chronic_kidney_disease) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		chronic_kidney_disease,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY chronic_kidney_disease
)

SELECT
	chronic_kidney_disease,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY chronic_kidney_disease ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO


-- Cancer
WITH #condition AS (
	SELECT
		cancer,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY cancer) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		cancer,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY cancer
)

SELECT
	cancer,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY cancer ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO


-- COPD
WITH #condition AS (
	SELECT
		copd,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY copd) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		copd,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY copd
)

SELECT
	copd,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY copd ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO


-- Depression
WITH #condition AS (
	SELECT
		depression,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY depression) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		depression,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY depression
)

SELECT
	depression,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY depression ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO



-- Diabetes
WITH #condition AS (
	SELECT
		diabetes,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY diabetes) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		diabetes,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY diabetes
)

SELECT
	diabetes,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY diabetes ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO


-- Ischemic Heart Disease
WITH #condition AS (
	SELECT
		ischemic_heart_disease,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY ischemic_heart_disease) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		ischemic_heart_disease,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY ischemic_heart_disease
)

SELECT
	ischemic_heart_disease,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY ischemic_heart_disease ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO



-- Osteoporosis
WITH #condition AS (
	SELECT
		osteoporosis,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY osteoporosis) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		osteoporosis,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY osteoporosis
)

SELECT
	osteoporosis,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY osteoporosis ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO


-- Arthritis
WITH #condition AS (
	SELECT
		arthritis,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY arthritis) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		arthritis,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY arthritis
)

SELECT
	arthritis,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY arthritis ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO


-- Stroke
WITH #condition AS (
	SELECT
		stroke,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY stroke) AS median_medicare_reimb
	FROM sample1.vw_beneficiaries_2008

), #compare AS (
	SELECT
		stroke,
		COUNT(*) AS population_count,
		AVG(median_medicare_reimb) AS median_medicare_reimb,
		AVG(total_medicare_reimb) AS avg_medicare_reimb
	FROM #condition
	GROUP BY stroke
)

SELECT
	stroke,
	population_count,
	FORMAT(median_medicare_reimb, 'N2') AS median_medicare_reimb,
	FORMAT(avg_medicare_reimb, 'N2') AS avg_medicare_reimb,
	FORMAT(COALESCE(median_medicare_reimb / LAG(median_medicare_reimb , 1) OVER (ORDER BY stroke ASC), 1), 'N2') AS ratio_of_medians
FROM #compare;
GO
