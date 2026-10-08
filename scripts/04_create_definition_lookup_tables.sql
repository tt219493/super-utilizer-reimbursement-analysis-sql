/*
===========================
Create Lookup / Definition Tables
===========================
Script Purpose: 
	- Create schema called 'lookups' and create lookup tables to convert codes into their defined descriptions by using INNER JOIN.
	- Tables will include both original codes and newly changed codes used in the views
	- Primary Key will be on the newly changed codes

	- Code definitions as defined by 
	https://www.cms.gov/files/document/de-10-codebook.pdf-0
*/

USE desynpuf_practice;
GO

-- Create schema 'lookups'
CREATE SCHEMA lookups;
GO

/*
=========
Initialize tables 
=========
*/


-- Sex
DROP TABLE IF EXISTS lookups.sex_codes;
IF OBJECT_ID('lookups.sex_codes', 'U') IS NULL 
	BEGIN
		CREATE TABLE lookups.sex_codes (
			int_code TINYINT PRIMARY KEY,
			char_code CHAR(1),
			sex_label VARCHAR(10) 
	);
	END;
GO

-- Race
DROP TABLE IF EXISTS lookups.race_codes;
IF OBJECT_ID('lookups.race_codes', 'U') IS NULL 
	BEGIN
		CREATE TABLE lookups.race_codes (
			int_code TINYINT PRIMARY KEY,
			char_code CHAR(1),
			race_label VARCHAR(10) 
	);
	END;
GO

-- ESRD (End Stage Renal Disease)
DROP TABLE IF EXISTS lookups.esrd_codes;
IF OBJECT_ID('lookups.esrd_codes', 'U') IS NULL 
	BEGIN   
		CREATE TABLE lookups.esrd_codes (
			char_code CHAR(1) PRIMARY KEY,
			esrd_label VARCHAR(3) 
	);
	END;
GO

-- State
DROP TABLE IF EXISTS lookups.state_codes;
IF OBJECT_ID('lookups.state_codes', 'U') IS NULL 
	BEGIN   
		CREATE TABLE lookups.state_codes (
			int_code TINYINT PRIMARY KEY,
			char_code CHAR(3),
			state_label VARCHAR(10) 
	);
	END;
GO

-- Condition
DROP TABLE IF EXISTS lookups.condition_codes;
IF OBJECT_ID('lookups.condition_codes', 'U') IS NULL 
	BEGIN   
		CREATE TABLE lookups.condition_codes (
			int_code_new TINYINT PRIMARY KEY,
			int_code_original TINYINT,
			condition_label VARCHAR(3) 
	);
	END;
GO

/*
=========
Initialize definitions into lookup tables 
=========
*/

INSERT INTO lookups.sex_codes (int_code, char_code, sex_label)
VALUES 
	(1, '1', 'Male'),
	(2, '2', 'Female');

INSERT INTO lookups.race_codes (int_code, char_code, race_label)
VALUES 
	(1, '1', 'White'),
	(2, '2', 'Black'),
	(3, '3', 'Others'),
	(5, '5', 'Hispanic');

INSERT INTO lookups.esrd_codes (char_code, esrd_label)
VALUES 
	('0', 'No'),
	('Y', 'Yes');

INSERT INTO lookups.state_codes (int_code, char_code, state_label)
VALUES 
	(1, '01', 'AL'),
	(2, '02', 'AK'),
	(3, '03', 'AZ'),
	(4, '04', 'AR'),
	(5, '05', 'CA'),
	(6, '06', 'CO'),
	(7, '07', 'CT'),
	(8, '08', 'DE'),
	(9, '09', 'DC'),
	(10, '10', 'FL'),
	(11, '11', 'GA'),
	(12, '12', 'HI'),
	(13, '13', 'ID'),
	(14, '14', 'IL'),
	(15, '15', 'IN'),
	(16, '16', 'IA'),
	(17, '17', 'KS'),
	(18, '18', 'KY'),
	(19, '19', 'LA'),
	(20, '20', 'ME'),
	(21, '21', 'MD'),
	(22, '22', 'MA'),
	(23, '23', 'MI'),
	(24, '24', 'MN'),
	(25, '25', 'MS'),
	(26, '26', 'MO'),
	(27, '27', 'MT'),
	(28, '28', 'NE'),
	(29, '29', 'NV'),
	(30, '30', 'NH'),
	(31, '31', 'NJ'),
	(32, '32', 'NM'),
	(33, '33', 'NY'),
	(34, '34', 'NC'),
	(35, '35', 'ND'),
	(36, '36', 'OH'),
	(37, '37', 'OK'),
	(38, '38', 'OR'),
	(39, '39', 'PA'),
	(41, '41', 'RI'),
	(42, '42', 'SC'),
	(43, '43', 'SD'),
	(44, '44', 'TN'),
	(45, '45', 'TX'),
	(46, '46', 'UT'),
	(47, '47', 'VT'),
	(49, '49', 'VA'),
	(50, '50', 'WA'),
	(51, '51', 'WV'),
	(52, '52', 'WI'),
	(53, '53', 'WY'),
	(54, '54', 'Others');

INSERT INTO lookups.condition_codes (int_code_original, int_code_new, condition_label)
VALUES 
	(1, 1, 'Yes'),
	(0, 2, 'No')
