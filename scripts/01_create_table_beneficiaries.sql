/*
===========================
Create Beneficiary Table and Load Data into Table
===========================

Script Purpose: 
	DDL:
	Creates table called 'beneficiaries_2008' under the schema 'sample1'. 
	Table is dropped and recreated if it already exists.

	Non-clustered primary key index created on ID.
	Clustered columnstore index will be created for this table.
	
	DML:
	Loads table data from local file describing Medicare beneficiaries.
	
Data Source:
	Using sample 1 from publicly available synthetic Medicare dataset provided by CMS called DE-SynPUF
	https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-claims-synthetic-public-use-files/cms-2008-2010-data-entrepreneurs-synthetic-public-use-file-de-synpuf/de10-sample-1

	Column descriptions and data types are provided by CMS using this documentation:
	https://www.cms.gov/files/document/de-10-codebook.pdf-0

*/

USE desynpuf_practice;
GO

/*
=========
DDL: Initialize table and columns and created indexes
=========
*/

-- Drop table if it already exists
DROP TABLE IF EXISTS sample1.beneficiaries_2008;
GO

-- Initialize table
-- Columns as defined in documentation 
-- Non-clustered index on ID and clustered columnstore index for table
IF OBJECT_ID('sample1.beneficiaries_2008', 'U') IS NULL 
	BEGIN 
		CREATE TABLE sample1.beneficiaries_2008 (
		DESYNPUF_ID CHAR(16) NOT NULL,
		BENE_BIRTH_DT DATE NOT NULL,
		BENE_DEATH_DT DATE,
		BENE_SEX_IDENT_CD CHAR(1) NOT NULL,
		BENE_RACE_CD CHAR(1) NOT NULL,
		BENE_ESRD_IND CHAR(1) NOT NULL,
		SP_STATE_CODE CHAR(2) NOT NULL,
		BENE_COUNTY_CD CHAR(3) NOT NULL,
		BENE_HI_CVRAGE_TOT_MONS TINYINT NOT NULL,
		BENE_SMI_CVRAGE_TOT_MONS TINYINT NOT NULL,
		BENE_HMO_CVRAGE_TOT_MONS TINYINT NOT NULL,
		PLAN_CVRG_MOS_NUM TINYINT NOT NULL,
		SP_ALZHDMTA TINYINT NOT NULL,
		SP_CHF TINYINT NOT NULL,
		SP_CHRNKIDN TINYINT NOT NULL,
		SP_CNCR TINYINT NOT NULL,
		SP_COPD TINYINT NOT NULL,
		SP_DEPRESSN TINYINT NOT NULL,
		SP_DIABETES TINYINT NOT NULL,
		SP_ISCHMCHT TINYINT NOT NULL,
		SP_OSTEOPRS TINYINT NOT NULL,
		SP_RA_OA TINYINT NOT NULL,
		SP_STRKETIA TINYINT NOT NULL,
		MEDREIMB_IP FLOAT NOT NULL,
		BENRES_IP FLOAT NOT NULL,
		PPPYMT_IP FLOAT NOT NULL,
		MEDREIMB_OP FLOAT NOT NULL,
		BENRES_OP FLOAT NOT NULL,
		PPPYMT_OP FLOAT NOT NULL,
		MEDREIMB_CAR FLOAT NOT NULL,
		BENRES_CAR FLOAT NOT NULL,
		PPPYMT_CAR FLOAT NOT NULL,

		CONSTRAINT pk_desynpuf_id PRIMARY KEY NONCLUSTERED (DESYNPUF_ID)
	);

	CREATE CLUSTERED COLUMNSTORE INDEX idx_beneficiaries_2008_cs
	ON sample1.beneficiaries_2008;

	END;
GO


/*
=========
DML: Load table data from local files using BULK INSERT
=========
*/

-- Drop any existing data from table before loading
TRUNCATE TABLE sample1.beneficiaries_2008;
GO

-- Load data from local file
BULK INSERT sample1.beneficiaries_2008
FROM 'C:\Datasets\DE-SynPUF\1\176541_DE1_0_2008_Beneficiary_Summary_File_Sample_1\DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv'
WITH
(
	FORMAT='CSV',
	FIRSTROW = 2,
	TABLOCK
);
GO