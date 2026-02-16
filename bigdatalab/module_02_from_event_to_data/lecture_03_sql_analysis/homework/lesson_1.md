# Lesson 1: SQL Analysis Fundamentals

## Overview
This lesson focuses on fundamental SQL analysis techniques including JOIN operations, filtering with WHERE clauses, grouping data with GROUP BY, using HAVING clauses for aggregate filtering, subqueries for complex data retrieval, and window functions for analytical calculations.

## Learning Objectives
Students will practice:
- JOIN operations to connect related tables
- WHERE clauses for data filtering
- GROUP BY for data aggregation
- HAVING for filtering aggregated data
- Subqueries for complex data retrieval
- Window functions for analytical calculations
- Comprehensive analytical queries combining multiple concepts

## Tasks
Complete the following SQL exercises using the EcoMarket dataset:

### Part 1: JOIN Operations
- Display for each sale the product name, category, and store address

### Part 2: WHERE Filtering
- Display all stores located in 'Poland'
- Display transactions with sales amount above 1500 for class B products, sorted by transaction number

### Part 3: GROUP BY Aggregation
- Show the count of stores in each country, sorted by store count in descending order

### Part 4: HAVING Clauses
- For each product show total sales amount and average sale, where total sales exceed 400,000, sorted by total sales in descending order

### Part 5: Subqueries
- Show the name and surname of the seller who made the highest-value sale and the address of the store where they work

### Part 6: Window Functions
- Find revenue of all German stores by month and difference with previous month, sorted by month in ascending order

### Part 7: Comprehensive Analysis Task
- For each store, calculate sales aggregates and analytical metrics by country:
  - Count of sales (COUNT(sales_id))
  - Total sales amount (SUM(total_price))
  - Keep only stores with at least 2 sales
  - Calculate store's share of country's total revenue
  - Rank stores by sales amount within their country
  - Compute cumulative revenue by country, sorted by descending store revenue
  - Sort results by country and store rank