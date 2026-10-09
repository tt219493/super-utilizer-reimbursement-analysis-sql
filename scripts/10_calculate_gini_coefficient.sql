/*
===========================
Calculate Gini Coefficient 
===========================
Script Purpose: 
	- Calculates Gini coefficient from the cumulative table
	- Utilizes Riemann sums (with trapezoids) for each data point to approximate area under the Lorenz curve.
	- Uses this area to calculate Gini coefficient to show "inequality" among the distribution of utilization / reimbursements
	(Usually used to measure economic inequality among populations such as countries but adapted here inequality among utilization / reimbursements)

Methodology and Functions Used:
	- LEAD() to find difference along population percentile and to find sum along reimbursement percetile
	- CROSS APPLY to get area of trapezoid for each data point
	- SUM() to add up all areas to get area under Lorenz curve
*/

USE desynpuf_practice;
GO

-- Find height = difference in population percentage between each data point
-- Find sum of base = sum of cumulative reimbursement percentage at for both data points
WITH #trapezoid_measurements AS (
	SELECT
		(LEAD(percent_population, 1, 100) OVER (ORDER BY row_idx) - percent_population) AS trapezoid_height,
		(LEAD(percent_medicare_reimb, 1, -100) OVER (ORDER BY row_idx) + percent_medicare_reimb) AS trapezoid_base_sum
	FROM sample1.beneficiaries_2008_cumulative
)

-- Sums up the area underneath the Lorenz curve and calculates Gini coefficient
SELECT
	SUM(x.trapezoid_area) as total_area_under_curve,
	1 - 2 * (SUM(x.trapezoid_area) / 10000) AS gini_coefficient -- Formula: 1 - 2 * Area under Lorenz
FROM #trapezoid_measurements AS t
-- Calculates trapezoid area between each data point
CROSS APPLY (SELECT trapezoid_area = 0.5 * trapezoid_height *  trapezoid_base_sum) AS x;

/*
Gini: 0.757 or 75.7
For reference, the current highest gini for a country is 0.630 or 63.0
Thus, the distribution of utilization / reimbursements is more concentrated among the top percentile than even the most unequal countries
*/
