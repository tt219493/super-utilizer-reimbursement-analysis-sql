/*
===========================
Create Beneficiary View from Table
===========================
Script Purpose: 
	- Creates a view that filters for cohort population and only includes relevant columns for super-utilizer analysis.
	- Renames columns to more understandable names and changes some data types for better efficiency and usability.
	- Adds new columns for simpler analysis in the future.

Methodology and Functions Used:
	- CAST() to change CHAR into TINYINT for better usability.
	- % or Modulo operator to change code numbers for better usability.
	- FLOOR() and YEAR() to get age categories for every decade.
	- CROSS APPLY (...) twice to create new columns and once again to reference those new columns for additional columns.
*/

USE desynpuf_practice;
GO

-- Drop view if it already exists
DROP VIEW IF EXISTS sample1.vw_beneficiaries_2008;
GO

-- Create view with renamed and additional columns
CREATE VIEW sample1.vw_beneficiaries_2008 AS (
	SELECT
		DESYNPUF_ID AS bene_id,
		BENE_BIRTH_DT AS bene_birth_date,
		BENE_DEATH_DT AS bene_death_date,

		-- New column describing age & age category; age is assumed to be 2008 - birth year
		2008 - YEAR(BENE_BIRTH_DT) AS bene_age,
		FLOOR((2008 - YEAR(BENE_BIRTH_DT)) / 10) * 10 as bene_age_category,

		-- Convert columns to tinyint for faster processing since all values are numbers
		CAST(BENE_SEX_IDENT_CD AS tinyint) AS bene_sex_code,
		CAST(BENE_RACE_CD AS tinyint) AS bene_race_code,
		BENE_ESRD_IND AS bene_esrd_code, -- Cannot be casted since values are '0' and 'Y'
		CAST(SP_STATE_CODE AS tinyint) AS state_code,

		BENE_HI_CVRAGE_TOT_MONS AS part_a_coverage_months,
		BENE_SMI_CVRAGE_TOT_MONS AS part_b_coverage_months,

		-- All columns marking conditions
		cond.*,
		num_cond.num_conditions,

		MEDREIMB_IP AS inpatient_medicare_reimb,
		MEDREIMB_OP AS outpatient_medicare_reimb,
		MEDREIMB_CAR AS carrier_medicare_reimb,

		-- Sum of Medicare reimbursements from the three categories
		MEDREIMB_IP + MEDREIMB_OP + MEDREIMB_CAR AS total_medicare_reimb
	FROM sample1.beneficiaries_2008

	-- Use Cross Apply to use new columns in same query
	CROSS APPLY (
		SELECT
		-- Columns marking whether beneficiary has condition
		-- Originally: 1 was defined as 'Yes', and 2 was defined as 'No'
		-- Use modulo operator to change so that 1 is still defined as 'Yes' but 0 is defined as 'No'
		SP_ALZHDMTA % 2 AS alzheimers,
		SP_CHF % 2 AS chronic_heart_failure,
		SP_CHRNKIDN % 2 AS chronic_kidney_disease,
		SP_CNCR % 2 AS cancer,
		SP_COPD % 2 AS copd,
		SP_DEPRESSN % 2 AS depression,
		SP_DIABETES % 2 AS diabetes,
		SP_ISCHMCHT % 2 AS ischemic_heart_disease,
		SP_OSTEOPRS % 2 AS osteoporosis,
		SP_RA_OA % 2 AS arthritis,
		SP_STRKETIA % 2 AS stroke
	) AS cond

	-- Use Cross Apply again to sum conditions across each row for number of conditions per beneficiary
	CROSS APPLY (
		SELECT
		(alzheimers + chronic_heart_failure + chronic_kidney_disease + cancer + copd + depression 
		+ diabetes + ischemic_heart_disease + osteoporosis + arthritis + stroke) 
		AS num_conditions  
	) AS num_cond

	-- Filters:
	-- Consistent coverage throughout the year
	WHERE BENE_HI_CVRAGE_TOT_MONS = 12 AND BENE_SMI_CVRAGE_TOT_MONS = 12
	-- Exclude those with negative reimbursements as they are not important to super-utilizer analysis
	  AND MEDREIMB_IP + MEDREIMB_OP + MEDREIMB_CAR >= 0
	-- Exclude those who died during the year for consistency, once again
	  AND BENE_DEATH_DT IS NULL
); 
GO
