/*
===========================
Calculating prevalence ratio by ESRD (End-Stage Renal Disease) 
===========================
Script Purpose: 
	Creates function to output table to compare prevalence by ESRD within the super-utilizer population (top 10% of reimbursements) vs the general population (bottom 90%).
	Uses the prevalence to calculate prevalence ratio and calculates 95% confidence intervals for statistical significance between prevalences.
*/

USE desynpuf_practice;
GO

/*
===========================
Create function to count esrd
===========================
Creates table that shows ESRD counts based on population to analyze
0 = general population
1 = super-utilizers
NULL or DEFAULT = full population
*/

CREATE OR ALTER FUNCTION count_of_esrd (@is_super_utilizer INT = NULL)
RETURNS TABLE
AS
RETURN (
	SELECT
		l.esrd_label AS esrd,
		COUNT(*) AS population_count,
		COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS population_percent,
		SUM(COUNT(*)) OVER () AS total_count
	FROM sample1.vw_beneficiaries_2008_su AS v
	INNER JOIN lookups.esrd_codes AS l
	ON l.char_code = v.bene_esrd_code
	WHERE is_super_utilizer = @is_super_utilizer OR @is_super_utilizer IS NULL -- Get table for entire population when inputting NULL
	GROUP BY l.esrd_label
);
GO

/*
================
Show prevalence of conditions among entire population
================
*/
SELECT 
	esrd, 
	population_count,
	FORMAT(population_percent, 'N3') + '%' AS population_percent 
FROM count_of_esrd(DEFAULT);
GO


/*
================
Compare prevalence of esrd for super-utilizers / SU (top 10%) vs general population / GP (bottom 90%)
================
*/

-- Create temp table 
SELECT
	su.esrd,
	su.population_count AS su_population_count,
	gp.population_count AS gp_population_count,
	su.population_percent AS su_population_percent,
	gp.population_percent AS gp_population_percent,
	su.total_count AS su_total_count,
	gp.total_count AS gp_total_count
INTO #compare_prevalence
FROM count_of_esrd(1) AS su
INNER JOIN count_of_esrd(0) AS gp
ON su.esrd = gp.esrd;

-- Show comparison of prevalence
SELECT
	esrd,
	su_population_count,
	gp_population_count,
	FORMAT(su_population_percent, 'N3') + '%' AS su_population_percent,
	FORMAT(gp_population_percent, 'N3') + '%' AS gp_population_percent
FROM #compare_prevalence
ORDER BY su_population_percent DESC;
GO



/*
================
Calculate prevalence ratio between super-utilizers / SU (top 10%) vs general population / GP (bottom 90%)
================
Tells us how many times more likely it is to have the condition within SU vs GP (1 is the same prevalence between populations)

Additionally, calculate 95% confidence intervals to confirm statistical significance
If the CI contains 1, then the prevalence is not statistically significant (alpha = 0.05)
*/

SELECT
	esrd,
	FORMAT(prevalence_difference, 'N2') + '%' AS prevalence_difference,
	FORMAT(prevalence_ratio, 'N3') AS prevalence_ratio,
	FORMAT(lower_confidence_interval, 'N3') AS lower_confidence_interval,
	FORMAT(upper_confidence_interval, 'N3') AS upper_confidence_interval
FROM #compare_prevalence AS cmp
CROSS APPLY (
	SELECT
		prevalence_difference = su_population_percent - gp_population_percent, -- Absolute difference between the prevalence
		prevalence_ratio = su_population_percent / gp_population_percent,
		log_standard_error = SQRT(1.0 * 1/su_population_count - 1/su_total_count + 1/gp_population_count - 1/gp_total_count)
) AS pr
CROSS APPLY (
	SELECT
		lower_confidence_interval = EXP(LOG(prevalence_ratio) - 1.96 * log_standard_error),
		upper_confidence_interval = EXP(LOG(prevalence_ratio) + 1.96 * log_standard_error)
) AS ci
ORDER BY prevalence_ratio DESC;

/*
---------
Those with ESRD are much more prevalent within super-utilizers while those without are much less present.
---------
*/

DROP FUNCTION IF EXISTS count_of_esrd;
DROP TABLE IF EXISTS #compare_prevalence;
