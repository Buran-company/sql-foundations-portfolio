# sql-foundations-portfolio

Aleksei Mukhin, PostgreSQL, Retail_Database_SQLServer.sql

Question 5 Interpretation required:

Top positions by gross_line_values are formed by expensive products (Smartphone). High gross_line_value is bigger than the median of the dataset, so it makes the key contribution into total revenue.

Question 8 Interpretation required:

The result contains all orders, where shipped_date is not filled in. COALESCE allows to processes missing values correctly (set status 'Not Shipped'). It is important for monitoring logistics operations which are in progress or delayed.