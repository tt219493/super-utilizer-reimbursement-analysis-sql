/*
===========================
Exploring and Choosing Cohort for Analysis 
===========================

Script Purpose: 
	Exploring the population by months of Part A & Part B Medicare coverage
	Choosing the cohort as having coverage for the whole year (12 months for both Part A & Part B)
	Comparing distribution of total Medicare reimbursements / utilization for population inside and out of cohort
	Additionally, looking at dates of death within cohort and exploring distribution
*/

USE desynpuf_practice;
GO

/*
===========
Explore the population counts by Part A & B coverage
===========
*/

SELECT
	BENE_HI_CVRAGE_TOT_MONS, -- Number of months under Part A
	BENE_SMI_CVRAGE_TOT_MONS, -- Number of months under Part B
	COUNT(*) AS count_pop,
	FORMAT(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 'N2') + '%' AS percent_pop,
	SUM(CASE WHEN BENE_DEATH_DT IS NOT NULL THEN 1 ELSE 0 END) AS count_dead
FROM sample1.beneficiaries_2008
GROUP BY BENE_HI_CVRAGE_TOT_MONS, BENE_SMI_CVRAGE_TOT_MONS 
ORDER BY percent_pop DESC;
GO


/*
===========
Explore the distribution of reimbursements (utilization) of those with Part A & B coverage for the entire year vs those without
===========
*/

WITH #cohort_comparison AS (
	SELECT
		DESYNPUF_ID,
		in_cohort,
		total_medicare_reimb,
		-- calculate median within CTE as it will not be allowed in following query with Group By clause
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY in_cohort) AS median_reimb
	FROM sample1.beneficiaries_2008
	-- Cross Apply to allow for referencing newly made columns
	CROSS APPLY (
	SELECT 
		in_cohort = (CASE
			WHEN BENE_HI_CVRAGE_TOT_MONS = 12 AND BENE_SMI_CVRAGE_TOT_MONS = 12 THEN 1
			ELSE 0
		END),
		total_medicare_reimb = 	MEDREIMB_IP + MEDREIMB_OP + MEDREIMB_CAR
	) AS t
)

-- Distribution of reimbursements (utilization)
SELECT
	in_cohort,
	MIN(total_medicare_reimb) AS min_reimb,
	MAX(median_reimb) AS median_reimb,
	AVG(total_medicare_reimb) AS avg_reimb,
	MAX(total_medicare_reimb) AS max_reimb,
	STDEV(total_medicare_reimb) AS stdev_reimb
FROM #cohort_comparison
GROUP BY in_cohort;
GO


/*
-----------------------------------
Beneficiaries with 12 months of coverage in both A & B make up the largest proportion of the total population at 83%
Thus, this would be a good choice for analysis as it utilizes the majority of the dataset.

Additionally, being covered for the entire year will allow for consistency in the utilization numbers 
since those who weren't covered for the entire year will likely skew the distribution toward a lower value.
This can be seen in the fact that the median value for those without full-year coverage is 0.

Negative values can also be seen in the minimum reimbursements for full-year coverage.
While these values can offer other insights, they will not be useful for super-utilizer analysis and will be removed to not affect the distribution.

However, there are those who are covered for the entire year while having died during the year, so that will need to be explored.
------------------------------------
*/


/*
===========
Explore the population counts by month of death (among population with full-year coverage)
===========
*/


-- Explore death dates within population of 12 months of Part A & B Coverage
SELECT
	DATETRUNC(MONTH, BENE_DEATH_DT) AS month_of_death,
	COUNT(*) AS count_dead,
	FORMAT(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 'N2') + '%' AS percent_dead
FROM sample1.beneficiaries_2008
WHERE BENE_HI_CVRAGE_TOT_MONS = 12 AND BENE_SMI_CVRAGE_TOT_MONS = 12
  AND BENE_DEATH_DT IS NOT NULL
GROUP BY DATETRUNC(MONTH, BENE_DEATH_DT)
ORDER BY month_of_death;
GO

-- Dates of death seemingly spread out evenly
-- However, even those who died early in 2008 are included in full-year coverage


/*
===========
Explore the distribution of reimbursements (utilization) among the months of death
===========
*/

WITH #death_comparison AS (
	SELECT
		DESYNPUF_ID,
		month_of_death,
		total_medicare_reimb,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_medicare_reimb) OVER (PARTITION BY month_of_death) AS median_reimb
	FROM sample1.beneficiaries_2008
	CROSS APPLY (
	SELECT 
		month_of_death = COALESCE(DATETRUNC(MONTH, BENE_DEATH_DT), CAST('20990101' AS DATE)),
		total_medicare_reimb = 	MEDREIMB_IP + MEDREIMB_OP + MEDREIMB_CAR
	) AS t
	WHERE BENE_HI_CVRAGE_TOT_MONS = 12 AND BENE_SMI_CVRAGE_TOT_MONS = 12
	  AND total_medicare_reimb >= 0
)

SELECT
	month_of_death,
	MIN(total_medicare_reimb) AS min_reimb,
	MAX(median_reimb) AS median_reimb,
	AVG(total_medicare_reimb) AS avg_reimb,
	MAX(total_medicare_reimb) AS max_reimb,
	STDEV(total_medicare_reimb) AS stdev_reimb
FROM #death_comparison
GROUP BY month_of_death;
GO

/*
There is a clear trend that the later the month of death, the more money is spent by the beneficiary.

Since the amount spent by beneficiaries who died during the year is significantly less than those who are still alive,
it would be more consistent for analysis if beneficiaries that died were excluded from the cohort used for analysis.
*/ 