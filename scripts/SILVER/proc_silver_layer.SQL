
```sql
/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/


CREATE OR ALTER PROCEDURE SILVER.LOAD_SILVER AS
BEGIN

	-----------------------------------------------------------------
	--1
	TRUNCATE TABLE SILVER.CRM_CUST_INFO ;
	PRINT'>>INSERTING DAETE INTO SILVER.CRM_CUST_INFO'
	INSERT INTO SILVER.CRM_CUST_INFO(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date )
	select 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE WHEN UPPER(TRIM(cst_material_status)) ='S' THEN 'SINGLE'
		 WHEN UPPER(TRIM(cst_material_status)) ='M' THEN 'MARRIED'
		 ELSE 'N/A'
	END cst_material_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) ='F' THEN 'FEMALE'
		 WHEN UPPER(TRIM(CST_GNDR)) ='M' THEN 'MALE'
		 ELSE 'N/A'
	END CST_GNDR ,
	cst_create_date
	FROM (
	SELECT *,
	ROW_NUMBER() over(partition by cst_id order by cst_create_date desc)as flag_last
	FROM bronze.crm_cust_info 
	WHERE CST_ID IS NOT NULL
	) T WHERE flag_last =1

	---------------------------------------------------------------
	--2
	TRUNCATE TABLE SILVER.crm_prd_info;
	PRINT'INSERTING DATE INTO SILVER.crm_prd_info'
	INSERT INTO SILVER.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_date,
	prd_end_date
	)
	SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(PRD_KEY,7,LEN(PRD_KEY)) as prd_KEY,
	prd_nm,
	isnull(prd_cost,0) AS prd_cost,
	CASE WHEN UPPER(TRIM(PRD_LINE))='M' THEN 'Mountain'
		 WHEN UPPER(TRIM(PRD_LINE))='r' THEN 'Road'
		 WHEN UPPER(TRIM(PRD_LINE))='S' THEN 'other sales'
		 WHEN UPPER(TRIM(PRD_LINE))='T' THEN 'Touring'
		 ELSE 'n/a'
	END AS prd_line,
	prd_start_date,
	LEAD(PRD_START_DATE) OVER(PARTITION BY PRD_KEY ORDER BY PRD_START_DATE)-1 AS prd_end_date
	FROM BRONZE.crm_prd_info


	----------------------------------------------------------------
	--3
	TRUNCATE TABLE SILVER.crm_sales_details;
	PRINT'INSERTING DATA INTO SILVER.crm_sales_details'
	INSERT INTO SILVER.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_date,
		sls_ship_date,
		sls_due_date ,
		sls_sales ,
		sls_quantity ,
		sls_price 
	)

	select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when sls_order_date = 0 or len(sls_order_date)!=8 then NULL
		ELSE CAST(CAST (sls_order_date AS varchar)AS DATE)
		END AS sls_order_date,
	case when sls_ship_date = 0 or len(sls_ship_date)!=8 then NULL
		ELSE CAST(CAST (sls_ship_date AS varchar)AS DATE)
		END AS sls_ship_date,
	case when sls_due_date = 0 or len(sls_due_date)!=8 then NULL
		ELSE CAST(CAST (sls_due_date AS varchar)AS DATE)
		END AS sls_due_date,
	CASE WHEN sls_sales is null or sls_sales <=0 or sls_sales!=sls_quantity*ABS(sls_price)
		THEN sls_quantity*ABS(sls_price)
		else sls_sales
		end as sls_sales,
	sls_quantity,
	case when sls_price is null or sls_price <=0 
		then sls_sales/nullif(sls_quantity,0)
		else sls_price
		end as sls_price
	from bronze.crm_sales_details
	---------------------------------------------------------------
	--4
	TRUNCATE TABLE silver.erp_cust_az12;
	PRINT'INSERTING DATA INTO silver.erp_cust_az12'
	insert into silver.erp_cust_az12(cid,bdate,gen)

	SELECT
	CASE WHEN cid LIKE 'NAS%'
	THEN SUBSTRING(cid,4,LEN(cid))
	else cid 
	end AS cid,	
	CASE WHEN bdate>GETDATE() 
	THEN NULL
	ELSE bdate
	END AS BDATE,
	CASE WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'FEMALE'
		 WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'MALE'
		 ELSE 'N/A'
		 END AS gen
	from bronze.erp_cust_az12
	--------------------------------------------------------------------------
	--5
	TRUNCATE TABLE SILVER.erp_loc_a101;
	INSERT INTO SILVER.erp_loc_a101(cid,cntry)
	select 
	replace(cid,'-',''),
	case when TRIM(cntry)='DE' THEN 'Gernamy'
		 when UPPER(TRIM(CNTRY)) IN ('US','UNITED STATES','USA')
		 THEN 'United States'
		 WHEN TRIM(cntry)='' OR CNTRY IS NULL THEN 'n/a'
		 ELSE cntry
	END AS cntry
	from bronze.erp_loc_a101

	---------------------------------------------------------------------------
	--6
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	PRINT'>>>INSERTING DATE INTO silver.erp_px_cat_g1v2'
	insert into silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
	select 
	id,
	cat,
	subcat,
	maintenance
	from bronze.erp_px_cat_g1v2

	select *
	from silver.erp_px_cat_g1v2
	--------------------------------------------------------------------------------------
END
