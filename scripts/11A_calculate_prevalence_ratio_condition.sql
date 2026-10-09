/*
===========================
Calculating prevalence ratio for each condition
===========================
Script Purpose: 
	- Creates function to output table to compare prevalence of all conditions (which is dropped at the end of the script)
	  within the super-utilizer population (top 10% of reimbursements) vs the general population (bottom 90%).
	- Calculates prevalence ratio and 95% confidence intervals
	  to see if the changes in prevalence is statistically significant.

Function:
	count_of_conditions (@is_super_utilizer INT = NULL)
	- 0 = general population
	- 1 = super-utilizers
	- NULL or DEFAULT = full population

Methodology and Functions Used:
	- CTEs to get counts of all chronic conditions across the columns
	- CROSS APPLY to 'unpivot' the counts so each row corresponds with a different condition
	- INNER JOIN to join two tables created from count_of_conditions
	- CROSS APPLY to calculate prevalence ratios and 95% confidence intervals for the joined table
*/

USE desynpuf_practice;
GO

/*
===========================
Create function to count all conditions
===========================
Creates table that shows condition counts based on population to analyze
0 = general population
1 = super-utilizers
NULL or DEFAULT = full population
*/

CREATE OR ALTER FUNCTION count_of_conditions (@is_super_utilizer INT = NULL)
RETURNS TABLE
AS
RETURN (
	-- Count of all conditions
	WITH condition_counts AS (
		SELECT
			COUNT(*) AS total_count,
			SUM(alzheimers) AS alz_count,
			SUM(chronic_heart_failure) AS chf_count,
			SUM(chronic_kidney_disease) AS ckd_count,
			SUM(cancer) AS can_count,
			SUM(copd) AS copd_count,
			SUM(depression) AS dep_count,
			SUM(diabetes) AS dia_count,
			SUM(ischemic_heart_disease) AS ihd_count,
			SUM(osteoporosis) AS ost_count,
			SUM(arthritis) AS art_count,
			SUM(stroke) AS str_count
		FROM sample1.vw_beneficiaries_2008_su
		WHERE is_super_utilizer = @is_super_utilizer OR @is_super_utilizer IS NULL -- Get table for entire population when inputting NULL or DEFAULT
	)

	-- 'Unpivot' by using Cross Apply to get each condition and their counts on separate rows
	SELECT
		condition,
		condition_count,
		pct.condition_percent,
		cc.total_count
	FROM condition_counts AS cc
	CROSS APPLY (
		VALUES
			('Alzheimer''s', alz_count),
			('Chronic Heart Failure', chf_count),
			('Chronic Kidney Disease', ckd_count),
			('Cancer', can_count),
			('Chronic Obstructive Pulmonary Disease', copd_count),
			('Depression', dep_count),
			('Diabetes', dia_count),
			('Ischemic Heart Disease', ihd_count),
			('Osteoporosis', ost_count),
			('Rheumatoid Arthritis and Osteoarthritis', art_count),
			('Stroke/Transient Ischemic Attack', str_count)
	) v (condition, condition_count)
	CROSS APPLY (
		SELECT condition_percent = condition_count * 100.0 / cc.total_count
	) pct
);
GO

/*
================
Show prevalence of conditions among entire population
================
*/

SELECT 
	condition, condition_count, 
	FORMAT(condition_percent, 'N2') + '%' AS condition_percent 
FROM count_of_conditions(DEFAULT);
GO


/*
================
Compare prevalence of conditions for super-utilizers / SU (top 10%) vs general population / GP (bottom 90%)
================
*/

-- Create temp table 
SELECT
	su.condition,
	su.condition_count AS su_condition_count,
	gp.condition_count AS gp_condition_count,
	su.condition_percent AS su_condition_percent,
	gp.condition_percent AS gp_condition_percent,
	su.total_count AS su_total_count,
	gp.total_count AS gp_total_count
INTO #compare_prevalence
FROM count_of_conditions(1) AS su
INNER JOIN count_of_conditions(0) AS gp
ON su.condition = gp.condition

-- Show comparison of prevalence
SELECT
	condition,
	FORMAT(su_condition_percent, 'N2') + '%' AS su_condition_percent,
	FORMAT(gp_condition_percent, 'N2') + '%' AS gp_condition_percent
FROM #compare_prevalence
ORDER BY su_condition_percent DESC;
GO

/*
---------
All conditions seem to be more prevalent within super-utilizer populations compared to general populations.
Ischemic Heart Disease, Diabetes, Chronic Heart Failure, and Chronic Kidney Disease are all very prevalent within the super-utilizer population.

These conditions match the previous analysis that showed that spending among these conditions was much larger than those without
---------
*/


/*
================
Calculate prevalence ratio between super-utilizers / SU (top 10%) vs general population / GP (bottom 90%)
================
Tells us how many times more likely it is to have the condition within SU vs GP (1 is the same prevalence between populations)

Additionally, calculate 95% confidence intervals to confirm statistical significance
If the CI contains 1, then the prevalence is not statistically significant (alpha = 0.05)
*/

SELECT
	condition,
	FORMAT(prevalence_difference, 'N2') + '%' AS prevalence_difference,
	FORMAT(prevalence_ratio, 'N3') AS prevalence_ratio,
	FORMAT(lower_confidence_interval, 'N3') AS lower_confidence_interval,
	FORMAT(upper_confidence_interval, 'N3') AS upper_confidence_interval
FROM #compare_prevalence AS cmp
CROSS APPLY (
	SELECT
		prevalence_difference = su_condition_percent - gp_condition_percent, -- Absolute difference between the prevalence
		prevalence_ratio = su_condition_percent / gp_condition_percent,
		log_standard_error = SQRT(1.0 * 1/su_condition_count - 1/su_total_count + 1/gp_condition_count - 1/gp_total_count)
) AS pr
CROSS APPLY (
	SELECT
		lower_confidence_interval = EXP(LOG(prevalence_ratio) - 1.96 * log_standard_error),
		upper_confidence_interval = EXP(LOG(prevalence_ratio) + 1.96 * log_standard_error)
) AS ci
ORDER BY prevalence_ratio DESC;
GO

/*
---------
All conditions are more prevalent in the super-utilizer population to a statistically significant degree.
The highest prevalence ratios come from Stroke, Chronic Kidney Disease, and COPD
---------
*/

DROP FUNCTION IF EXISTS count_of_conditions;
DROP TABLE IF EXISTS #compare_prevalence;
