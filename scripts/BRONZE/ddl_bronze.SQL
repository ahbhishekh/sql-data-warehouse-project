/*
DDL Script: Create Bronze Tables
Script Purpose:
This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
begin
BEGIN TRY
	PRINT '=================================================================================================================================='
	PRINT 'LOADING BRONZE LAYER'
	PRINT '=================================================================================================================================='
	PRINT '=================================================================================================================================='
	PRINT 'LOADING CRM TABLES'
	PRINT '=================================================================================================================================='
	
	TRUNCATE TABLE bronze.crm_cust_info
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\user\OneDrive\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		)
	--------------------------------------------------------------
	TRUNCATE TABLE BRONZE.crm_prd_info
	BULK INSERT BRONZE.crm_prd_info
	FROM 'C:\Users\user\OneDrive\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		)
	------------------------------------------------------------------
	TRUNCATE TABLE BRONZE.crm_prd_info
	BULK INSERT BRONZE.crm_prd_info
	FROM 'C:\Users\user\OneDrive\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		)
	----------------------------------------------------------------------
	TRUNCATE TABLE bronze.crm_sales_details
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\user\OneDrive\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		)
	----------------------------------------------------------------------
	PRINT '=================================================================================================================================='
	PRINT 'LOADING ERP TABLE'
	PRINT '=================================================================================================================================='
	
	
	TRUNCATE TABLE bronze.erp_cust_az12
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\user\OneDrive\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		)
	------------------------------------------------------------------
	TRUNCATE TABLE bronze.erp_loc_a101
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\user\OneDrive\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		)
	---------------------------------------------------------------------
	TRUNCATE TABLE bronze.erp_px_cat_g1v2
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\user\OneDrive\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		TABLOCK
		)
----------------------------------------------------------------------------


END TRY
BEGIN CATCH
PRINT '==================================================='
PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
PRINT 'ERROR MESSAGE' + CAST(ERROR_MESSAGE() AS NVARCHAR);
PRINT 'ERROR MESSAGE' + CAST(ERROR_MESSAGE() AS NVARCHAR);
PRINT '==================================================='
END CATCH
END


SELECT COUNT(*)
FROM BRONZE.crm_cust_info 
