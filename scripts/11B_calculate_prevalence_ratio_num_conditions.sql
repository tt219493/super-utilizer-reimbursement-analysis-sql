/*
===========================
Calculating prevalence ratio by number of conditions
===========================
Script Purpose: 
	- Creates function to output table to compare prevalence by number of conditions (which is dropped at the end of the script)
	  within the super-utilizer population (top 10% of reimbursements) vs the general population (bottom 90%).
	- Calculates prevalence ratio and 95% confidence intervals
	  to see if the changes in prevalence is statistically significant.

Function:
	count_of_num_conditions (@is_super_utilizer INT = NULL)
	- 0 = general population
	- 1 = super-utilizers
	- NULL or DEFAULT = full population

Methodology and Functions Used:
	- COUNT(), SUM(COUNT()) OVER () to get counts and percentages
	- GROUP BY to group by number of conditions
	- INNER JOIN to join two tables created from count_of_num_conditions
	- CROSS APPLY to calculate prevalence ratios and 95% confidence intervals for the joined table
*/

USE desynpuf_practice;
GO

/*
===========================
Create function to count number of conditions
===========================
Creates table that shows number of condition counts based on population to analyze
0 = general population
1 = super-utilizers
NULL or DEFAULT = full population
*/

CREATE OR ALTER FUNCTION count_of_num_conditions (@is_super_utilizer INT = NULL)
RETURNS TABLE
AS
RETURN (
	SELECT
		num_conditions,
		COUNT(*) AS population_count,
		COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS population_percent,
		SUM(COUNT(*)) OVER () AS total_count
	FROM sample1.vw_beneficiaries_2008_su
	WHERE is_super_utilizer = @is_super_utilizer OR @is_super_utilizer IS NULL -- Get table for entire population when inputting NULL
	GROUP BY num_conditions
);
GO

/*
================
Show prevalence of conditions among entire population
================
*/
SELECT 
	num_conditions, 
	population_count,
	FORMAT(population_percent, 'N3') + '%' AS population_percent 
FROM count_of_num_conditions(DEFAULT)
ORDER BY num_conditions ASC;
GO


/*
================
Compare prevalence of number of conditions for super-utilizers / SU (top 10%) vs general population / GP (bottom 90%)
================
*/

-- Create temp table 
SELECT
	su.num_conditions,
	su.population_count AS su_population_count,
	gp.population_count AS gp_population_count,
	su.population_percent AS su_population_percent,
	gp.population_percent AS gp_population_percent,
	su.total_count AS su_total_count,
	gp.total_count AS gp_total_count
INTO #compare_prevalence
FROM count_of_num_conditions(1) AS su
INNER JOIN count_of_num_conditions(0) AS gp
ON su.num_conditions = gp.num_conditions;

-- Show comparison of prevalence
SELECT
	num_conditions,
	su_population_count,
	gp_population_count,
	FORMAT(su_population_percent, 'N3') + '%' AS su_population_percent,
	FORMAT(gp_population_percent, 'N3') + '%' AS gp_population_percent
FROM #compare_prevalence
ORDER BY num_conditions ASC;
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
	num_conditions,
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
ORDER BY num_conditions ASC;

/*
---------
Between 0-3 conditions, there is a statistically significant amount less among super-utilizers.
From 5 and above, the ratio is significantly more.

The prevalence ratio increases greatly as the number of conditions climb, 
so those with a very high number of conditions are much more likely to be a super-utilizer.
---------
*/

DROP FUNCTION IF EXISTS count_of_num_conditions;
DROP TABLE IF EXISTS #compare_prevalence;
