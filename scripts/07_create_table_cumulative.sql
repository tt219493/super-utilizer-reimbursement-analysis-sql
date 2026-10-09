/*
===========================
Create Cumulative Table and Create New View
===========================
Script Purpose: 
	- Creates a new table called 'beneficiaries_2008_cumulative'.
	- Each beneficiary will be assigned a row number in order of ascending total reimbursements.
	- A cumulative sum of reimbursements will be done over this order.
	- Percentiles will be assigned based off these row numbers and the cumulative sum.
	- This table will be used for plotting the Lorenz curve to demonstrate concentration of utilization among the top.

	Super-utilizers will be defined in this analysis as the top 10% of population in reimbursements.
	- A new view will be created adding a column marking this assignment as super-utilizer or general population (other 90%)

Methodology and Functions Used:
	- Chained CTEs to apply new functions based off previous CTE 
	- ROW_NUMBER() OVER () to assign a unique row number and ordering to the table, based off total reimbursements
	- SUM() OVER () to have a cumulative sum of reimbursements over the assigned ordering
	- ... / MAX() OVER () to get percentiles for each row
	- CASE WHEN ... to mark whether a beneficiary is a super-utilizer or general population
*/

USE desynpuf_practice;
GO


/*
=============
Create Cumulative Table
=============
Assigns each beneficiary a percentile based off their reimbursements and shows cumulative percent of reimbursements.
Columnstore index and non-clustered index on beneficiary ID will be created.
*/

DROP TABLE IF EXISTS sample1.beneficiaries_2008_cumulative;

IF OBJECT_ID('sample1.beneficiaries_2008_cumulative', 'U') IS NULL
BEGIN
-- Create table
	
	WITH #row_ordering AS (
		SELECT
			-- Give a reference for row ordering (unique assignment for all rows)
			ROW_NUMBER() OVER (ORDER BY total_medicare_reimb ASC) AS row_idx,
			bene_id,
			total_medicare_reimb
		FROM sample1.vw_beneficiaries_2008
	), #cumulative_sum AS (
		SELECT
			*,
			-- Calculate percent population and cumulative sum of reimbursements based off row ordering
			row_idx * 100.0 / MAX(row_idx) OVER () AS percent_population,
			SUM(total_medicare_reimb) OVER (ORDER BY row_idx ASC) AS cumulative_medicare_reimb
		FROM #row_ordering
	)

	SELECT
		*,
		-- Calculate percent of reimbursements
		cumulative_medicare_reimb * 100.0 / MAX(cumulative_medicare_reimb) OVER () AS percent_medicare_reimb
	INTO DESynPUF_practice.sample1.beneficiaries_2008_cumulative
	FROM #cumulative_sum;

-- Create index
	CREATE CLUSTERED COLUMNSTORE INDEX idx_beneficiaries_2008_cumulative_cs
	ON sample1.beneficiaries_2008_cumulative;

	ALTER TABLE DESynPUF_practice.sample1.beneficiaries_2008_cumulative 
	ADD CONSTRAINT pk_bene_id PRIMARY KEY NONCLUSTERED (bene_id);

END;
GO


/*
=============
Create View with New Column
=============
Add new column assigning super-utilizer status (top 10% of utilization / 90th percentile)
*/

CREATE OR ALTER VIEW sample1.vw_beneficiaries_2008_su AS (
	SELECT
		v.*,
		-- Define super-utilizer as being in the top 10% of the population (90th percentile) in terms of reimbursements
		(CASE WHEN c.percent_population >= 90.0 THEN 1 ELSE 0 END) as is_super_utilizer
	FROM sample1.vw_beneficiaries_2008 AS v
	INNER JOIN sample1.beneficiaries_2008_cumulative AS c
	ON v.bene_id = c.bene_id
); 
GO

