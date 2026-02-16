# Lesson 2: SQL Data Processing Operations

## Overview
This lesson focuses on SQL data processing operations including DML (Data Manipulation Language), DDL (Data Definition Language), DCL (Data Control Language), and advanced operations with transactions.

## Learning Objectives
Students will practice:
- DML operations: INSERT, UPDATE, DELETE
- DDL operations: CREATE, ALTER, DROP tables and constraints
- DCL operations: GRANT, REVOKE permissions
- Transaction management
- Advanced DML with functions and views
- Advanced analytical operations

## Tasks
Complete the following SQL exercises using the EcoMarket dataset:

### Part 1: DML Operations
- Insert two new products into the Products table
- Select products where is_allergic = 'Yes' and vitality_days > 0
- Update is_allergic for 'Bananas Family Pack' to 'Yes'
- Delete one of the added products
- Verify all changes with SELECT * FROM Products

### Part 2: DDL Operations
- Create a new table named Data_Layers with columns: LayerID (SERIAL, PRIMARY KEY), LayerName (VARCHAR(50), UNIQUE, NOT NULL), Description (TEXT)
- Populate the LayerName column with three values: 'Bronze', 'Silver', 'Gold'
- Add a manager_email column to the Data_Layers table (VARCHAR(100))
- Add a UNIQUE constraint to the manager_email column in the shops table
- Rename the address column in the Shops table to shop_address

### Part 3: DCL Operations
- Create a new PostgreSQL role named data_engineer_trainee with a simple password
- Grant the data_engineer_trainee role SELECT permission on the Sales table
- Test as data_engineer_trainee, attempting to SELECT from Sales (should work)
- Attempt to perform INSERT of a new sale as data_engineer_trainee (should fail)
- As administrator, grant INSERT and UPDATE permissions on Sales to data_engineer_trainee
- Test INSERT and UPDATE as data_engineer_trainee (now should work)

### Part 4: Advanced DML with Transactions
- Increase the price of all products in the 'Dairy' category by 10%
- Delete all employees without any sales
- Insert a new employee and their first sale in a single transaction

### Part 5: Functions and Views for Gold Layer
- Create a function AvgSalesPerEmployee (PL/pgSQL) for calculating the average sales for an employee
- Create a view FullStatShops for aggregated shop statistics with columns (shop_id, shop_address, country, total_sales_count, total_sales_amount)

### Part 6: Advanced DML Operations
- Find employees with sales > 1000
- Update product classification to 'A' for categories with total revenue > 5000
- Set modify_timestamp for products without dates