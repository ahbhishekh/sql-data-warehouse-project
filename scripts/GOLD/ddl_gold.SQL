
/*
=============================================================================
DDL Script: Create Gold Views
=============================================================================

Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
=============================================================================
*/
--==================================================================================
--CREATE: gold.dim_customers
--==================================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

create view gold.dim_customers as 
select 
	row_number() over(order by cst_id) as customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_material_status as marital_status,
	CASE WHEN ci.cst_gndr!='n/a'
		THEN ci.cst_gndr
		ELSE coalesce(ca.gen,'n/a')
	END AS gender,
	ca.bdate as birth_date,
	ci.cst_create_date as create_date
from silver.crm_cust_info as ci
LEFT JOIN  SILVER.erp_cust_az12 AS ca
ON		   ci.cst_key=ca.cid
LEFT JOIN SILVER.erp_loc_a101 AS la
ON		   ci.cst_key=la.cid
GO

--==============================================================================
    CREATING:gold.di_products
--==============================================================================
IF OBJECT_ID('gold.di_products', 'V') IS NOT NULL
    DROP VIEW gold.di_products;
GO

CREATE VIEW gold.di_products AS
SELECT 
row_number() over(order by pn.prd_start_date,pn.prd_key)as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance as maintenance,
pn.prd_cost as product_cost,
pn.prd_line as product_line,
pn.prd_start_date as start_date

FROM SILVER.crm_prd_info as pn
LEFT JOIN silver.erp_px_cat_g1v2 as pc
on pn.cat_id=pc.id	
WHERE prd_end_date is null
GO

  --==============================================================================
    CREATING:gold.fact_sales
--==============================================================================

  IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales as
SELECT 
sd.sls_ord_num As order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_date as order_date,
sd.sls_ship_date as ship_date,
sd.sls_due_date as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.di_products as pr
ON sd.sls_prd_key=pr.product_number
LEFT JOIN gold.dim_customers as cu
ON sd.sls_cust_id=cu.customer_id

GO


      
      


  
