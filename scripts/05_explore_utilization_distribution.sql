/*
===========================
Explore Distribution of Reimbursements 
===========================

Script Purpose: 
	Using the newly created view, find the percentiles of total medicare reimbursements to get a distribution.

*/

USE desynpuf_practice;
GO

-- Explore which category contributes most to total reimbursements
SELECT 
	FORMAT(AVG(inpatient_medicare_reimb), 'N2') AS avg_inpatient,
	FORMAT(AVG(outpatient_medicare_reimb), 'N2') AS avg_outpatient,
	FORMAT(AVG(carrier_medicare_reimb), 'N2') AS avg_carrier
FROM desynpuf_practice.sample1.vw_beneficiaries_2008;
GO
-- Inpatient contributes most, followed by carrier and then outpatient


-- Explore distribution of reimbursements
WITH #reimb_percentiles AS (
	SELECT
		total_medicare_reimb,
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER () AS p25_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER () AS p50_medicare_reimb,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER () AS p75_medicare_reimb,
		PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER () AS p90_medicare_reimb,
		PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER () AS p95_medicare_reimb,
		PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER () AS p99_medicare_reimb
	FROM desynpuf_practice.sample1.vw_beneficiaries_2008
)

SELECT 
	FORMAT(MIN(total_medicare_reimb), 'N2') AS min_total_reimb,
	FORMAT(MAX(p25_medicare_reimb), 'N2') AS p25_medicare_reimb,
	FORMAT(MAX(p50_medicare_reimb), 'N2') AS p50_medicare_reimb,
	FORMAT(AVG(total_medicare_reimb), 'N2') AS avg_total_reimb,
	FORMAT(MAX(p75_medicare_reimb), 'N2') AS p75_medicare_reimb,
	FORMAT(MAX(p90_medicare_reimb), 'N2') AS p90_medicare_reimb,
	FORMAT(MAX(p95_medicare_reimb), 'N2') AS p95_medicare_reimb,
	FORMAT(MAX(p99_medicare_reimb), 'N2') AS p99_medicare_reimb,
	FORMAT(MAX(total_medicare_reimb), 'N2') AS max_total_reimb
FROM #reimb_percentiles;
GO

-- There is an extreme right skew to the distribution as the average is even higher than the 75th percentile due to the extreme values to the right
-- There are also very extreme differences even when it comes to 95th percentile to the 99th percentile to the max value