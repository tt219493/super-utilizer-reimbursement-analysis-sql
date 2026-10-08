/*
===========================
Create Database and Schema
===========================
Purpose: 
	- Creates database named 'desynpuf_practice' after checking if it exists.
	- If it already exists, drop database and recreate.
	- Adds schema 'sample1' to the new database.

Warning: 
	Running script will drop all data in database named 'desynpuf_practice' if it exists. 
*/

USE master;
GO

-- Check for existing database named 'desynpuf_practice' and drop if exists
IF DB_ID('desynpuf_practice') IS NOT NULL
	BEGIN
		ALTER DATABASE desynpuf_practice SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE desynpuf_practice;
	END;
GO

-- Create 'desynpuf_practice' database
CREATE DATABASE desynpuf_practice;
GO

USE desynpuf_practice;
GO

-- Create schema 'sample1'
CREATE SCHEMA sample1;
GO
