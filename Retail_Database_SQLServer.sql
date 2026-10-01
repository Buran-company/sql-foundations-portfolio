/* ============================================================================
   WEEK 1 RETAIL DATABASE FOR SQL SERVER
   Supports Week 1 Lectures 1-5 and Assignment 1: SQL Foundations Portfolio

   Run this entire script in SQL Server Management Studio.

   WARNING: This script drops and recreates the RetailDB database.
============================================================================ */

USE master;
GO

IF DB_ID('RetailDB') IS NOT NULL
BEGIN
    ALTER DATABASE RetailDB
        SET SINGLE_USER
        WITH ROLLBACK IMMEDIATE;

    DROP DATABASE RetailDB;
END;
GO

CREATE DATABASE RetailDB;
GO

USE RetailDB;
GO

SET NOCOUNT ON;
GO

/* ============================================================================
   TABLE 1: customers
   One row represents one customer.
============================================================================ */

CREATE TABLE dbo.customers
(
    customer_id   INT           NOT NULL,
    first_name    VARCHAR(50)   NOT NULL,
    last_name     VARCHAR(50)   NULL,
    email         VARCHAR(120)  NULL,
    birth_date    DATE          NULL,
    city          VARCHAR(60)   NULL,
    phone         VARCHAR(30)   NULL,
    country_code  VARCHAR(10)   NULL,
    signup_ts     DATETIME2(0)  NULL,
    region        VARCHAR(20)   NULL,

    CONSTRAINT PK_customers PRIMARY KEY (customer_id)
);
GO

;WITH numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 120
)
INSERT INTO dbo.customers
(
    customer_id,
    first_name,
    last_name,
    email,
    birth_date,
    city,
    phone,
    country_code,
    signup_ts,
    region
)
SELECT
    n,
    CONCAT('Customer', n),
    CASE
        WHEN n % 11 = 0 THEN NULL
        ELSE CONCAT('Surname', n)
    END,
    CASE
        WHEN n % 7 = 0 THEN NULL
        WHEN n % 17 = 0 THEN ''
        WHEN n % 19 = 0 THEN '   '
        ELSE CONCAT('Customer', n, '@Example.COM')
    END,
    CASE
        WHEN n % 10 = 0 THEN NULL
        ELSE DATEADD(DAY, -(7000 + n * 37), CAST('2026-01-01' AS DATE))
    END,
    CASE n % 6
        WHEN 0 THEN NULL
        WHEN 1 THEN 'London'
        WHEN 2 THEN 'Berlin'
        WHEN 3 THEN 'Bucharest'
        WHEN 4 THEN 'Istanbul'
        ELSE 'Madrid'
    END,
    CASE
        WHEN n % 8 = 0 THEN NULL
        ELSE CONCAT('555', RIGHT(CONCAT('0000000', n), 7))
    END,
    CASE n % 5
        WHEN 0 THEN ' us '
        WHEN 1 THEN 'GB'
        WHEN 2 THEN ' de '
        WHEN 3 THEN 'RO'
        ELSE ' tr '
    END,
    CASE
        WHEN n % 13 = 0 THEN NULL
        ELSE DATEADD(DAY, -(n * 3), CAST('2026-01-01T09:00:00' AS DATETIME2(0)))
    END,
    CASE
        WHEN n % 12 = 0 THEN NULL
        WHEN n % 4 = 0 THEN 'West'
        WHEN n % 4 = 1 THEN 'North'
        WHEN n % 4 = 2 THEN 'South'
        ELSE 'East'
    END
FROM numbers
OPTION (MAXRECURSION 0);
GO

/* ============================================================================
   TABLE 2: customer_credit
   One row represents the credit position of one customer.
============================================================================ */

CREATE TABLE dbo.customer_credit
(
    customer_id  INT            NOT NULL,
    used_credit  DECIMAL(12, 2) NOT NULL,
    credit_limit DECIMAL(12, 2) NOT NULL,

    CONSTRAINT PK_customer_credit PRIMARY KEY (customer_id),
    CONSTRAINT FK_customer_credit_customer
        FOREIGN KEY (customer_id)
        REFERENCES dbo.customers (customer_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

INSERT INTO dbo.customer_credit
(
    customer_id,
    used_credit,
    credit_limit
)
SELECT
    customer_id,
    CAST((customer_id % 15) * 275.50 AS DECIMAL(12, 2)),
    CAST(
        CASE
            WHEN customer_id % 20 = 0 THEN 0
            ELSE 5000 + (customer_id % 8) * 1000
        END
        AS DECIMAL(12, 2)
    )
FROM dbo.customers;
GO

/* ============================================================================
   TABLE 3: customer_import
   Demonstrates safe conversion from numeric text.
============================================================================ */

CREATE TABLE dbo.customer_import
(
    customer_id       INT          NOT NULL,
    credit_limit_text VARCHAR(30)  NULL,

    CONSTRAINT PK_customer_import PRIMARY KEY (customer_id),
    CONSTRAINT FK_customer_import_customer
        FOREIGN KEY (customer_id)
        REFERENCES dbo.customers (customer_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

INSERT INTO dbo.customer_import
(
    customer_id,
    credit_limit_text
)
SELECT
    customer_id,
    CASE
        WHEN customer_id % 14 = 0 THEN NULL
        ELSE CONCAT(5000 + (customer_id % 8) * 1000, '.00')
    END
FROM dbo.customers;
GO

/* ============================================================================
   TABLE 4: products
   One row represents one retail product.
============================================================================ */

CREATE TABLE dbo.products
(
    product_id   INT            NOT NULL,
    product_name VARCHAR(100)   NOT NULL,
    category     VARCHAR(40)    NOT NULL,
    unit_price   DECIMAL(10, 2) NOT NULL,

    CONSTRAINT PK_products PRIMARY KEY (product_id),
    CONSTRAINT CK_products_unit_price CHECK (unit_price >= 0)
);
GO

INSERT INTO dbo.products
(
    product_id,
    product_name,
    category,
    unit_price
)
VALUES
    (1001, 'Smartphone',      'Electronics', 699.99),
    (1002, 'Smartwatch',      'Electronics', 249.99),
    (1003, 'Speaker',         'Electronics', 129.99),
    (1004, 'Monitor',         'Hardware',    299.99),
    (1005, 'Keyboard',        'Hardware',     79.99),
    (1006, 'Mouse',           'Hardware',     39.99),
    (1007, 'Security Suite',  'Software',    119.99),
    (1008, 'Office Suite',    'Software',    149.99),
    (1009, 'Analytics Pro',   'Software',    249.99),
    (1010, 'Coffee Maker',    'Home',         89.99),
    (1011, 'Sofa Cover',      'Home',         45.00),
    (1012, 'Storage Box',     'Home',         29.99),
    (1013, 'USB Cable',       'Accessories',  15.00),
    (1014, 'Laptop Stand',    'Accessories',  35.00),
    (1015, 'Laptop Sleeve',   'Accessories',  25.00);
GO

/* ============================================================================
   TABLE 5: orders
   One row represents one customer order.
============================================================================ */

CREATE TABLE dbo.orders
(
    order_id      INT            NOT NULL,
    customer_id   INT            NOT NULL,
    order_date    DATE           NOT NULL,
    region        VARCHAR(20)    NULL,
    amount        DECIMAL(14, 2) NOT NULL
        CONSTRAINT DF_orders_amount DEFAULT (0),
    discount      DECIMAL(14, 2) NULL,
    status        VARCHAR(20)    NOT NULL,
    sales_rep     VARCHAR(60)    NULL,
    sales_channel VARCHAR(20)    NOT NULL,

    CONSTRAINT PK_orders PRIMARY KEY (order_id),
    CONSTRAINT FK_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES dbo.customers (customer_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT CK_orders_amount CHECK (amount >= 0),
    CONSTRAINT CK_orders_status
        CHECK (status IN ('Urgent', 'Pending', 'Completed', 'Shipped', 'Cancelled')),
    CONSTRAINT CK_orders_sales_channel
        CHECK (sales_channel IN ('Online', 'Store', 'Partner'))
);
GO

;WITH numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 360
)
INSERT INTO dbo.orders
(
    order_id,
    customer_id,
    order_date,
    region,
    amount,
    discount,
    status,
    sales_rep,
    sales_channel
)
SELECT
    n,
    c.customer_id,
    DATEADD(DAY, n - 1, CAST('2026-01-01' AS DATE)),
    c.region,
    0,
    NULL,
    CASE
        WHEN n % 10 = 0 THEN 'Urgent'
        WHEN n % 7 = 0 THEN 'Pending'
        WHEN n % 4 = 0 THEN 'Shipped'
        ELSE 'Completed'
    END,
    CASE
        WHEN n % 11 = 0 THEN NULL
        WHEN n % 4 = 0 THEN 'Alex Morgan'
        WHEN n % 4 = 1 THEN 'jordan lee'
        WHEN n % 4 = 2 THEN 'Priya Shah'
        ELSE 'Sam Wilson'
    END,
    CASE n % 3
        WHEN 0 THEN 'Online'
        WHEN 1 THEN 'Store'
        ELSE 'Partner'
    END
FROM numbers
JOIN dbo.customers AS c
    ON c.customer_id = ((n - 1) % 120) + 1
OPTION (MAXRECURSION 0);
GO

CREATE INDEX IX_orders_customer_id
    ON dbo.orders (customer_id);
GO

CREATE INDEX IX_orders_order_date
    ON dbo.orders (order_date);
GO

/* ============================================================================
   TABLE 6: order_items
   One row represents one product line within an order.
   Each order has three product lines in this teaching dataset.
============================================================================ */

CREATE TABLE dbo.order_items
(
    line_id         INT            NOT NULL,
    order_id        INT            NOT NULL,
    order_date      DATE           NOT NULL,
    shipped_date    DATE           NULL,
    customer_id     INT            NOT NULL,
    region          VARCHAR(20)    NULL,
    product_id      INT            NOT NULL,
    category        VARCHAR(40)    NOT NULL,
    product_name    VARCHAR(100)   NOT NULL,
    quantity        INT            NOT NULL,
    unit_price      DECIMAL(10, 2) NOT NULL,
    discount        DECIMAL(5, 2)  NULL,
    discount_pct    DECIMAL(5, 2)  NULL,
    cost            DECIMAL(12, 2) NULL,
    shipping_cost   DECIMAL(10, 2) NULL,
    sales_channel   VARCHAR(20)    NOT NULL,
    payment_method  VARCHAR(30)    NULL,
    customer_rating INT            NULL,

    CONSTRAINT PK_order_items PRIMARY KEY (line_id),
    CONSTRAINT FK_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES dbo.orders (order_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_order_items_customer
        FOREIGN KEY (customer_id)
        REFERENCES dbo.customers (customer_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES dbo.products (product_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT CK_order_items_quantity CHECK (quantity >= 0),
    CONSTRAINT CK_order_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT CK_order_items_discount
        CHECK (discount IS NULL OR discount BETWEEN 0 AND 100),
    CONSTRAINT CK_order_items_discount_pct
        CHECK (discount_pct IS NULL OR discount_pct BETWEEN 0 AND 100),
    CONSTRAINT CK_order_items_customer_rating
        CHECK (customer_rating IS NULL OR customer_rating BETWEEN 1 AND 5)
);
GO

INSERT INTO dbo.order_items
(
    line_id,
    order_id,
    order_date,
    shipped_date,
    customer_id,
    region,
    product_id,
    category,
    product_name,
    quantity,
    unit_price,
    discount,
    discount_pct,
    cost,
    shipping_cost,
    sales_channel,
    payment_method,
    customer_rating
)
SELECT
    ids.line_id,
    o.order_id,
    o.order_date,
    CASE
        WHEN o.status IN ('Pending', 'Urgent') OR ids.line_id % 11 = 0 THEN NULL
        ELSE DATEADD(DAY, 1 + ids.line_id % 7, o.order_date)
    END,
    o.customer_id,
    o.region,
    p.product_id,
    p.category,
    CASE
        WHEN ids.line_id % 10 = 0 THEN CONCAT('  ', p.product_name, '  ')
        ELSE p.product_name
    END,
    1 + ids.line_id % 5,
    p.unit_price,
    d.discount_value,
    d.discount_value,
    CASE
        WHEN ids.line_id % 13 = 0 THEN NULL
        ELSE CAST(p.unit_price * 0.62 AS DECIMAL(12, 2))
    END,
    CASE
        WHEN ids.line_id % 9 = 0 THEN NULL
        ELSE CAST(3.50 + item_number.line_number * 1.25 AS DECIMAL(10, 2))
    END,
    o.sales_channel,
    CASE
        WHEN ids.line_id % 8 = 0 THEN NULL
        WHEN ids.line_id % 4 = 0 THEN 'Card'
        WHEN ids.line_id % 4 = 1 THEN 'Cash'
        WHEN ids.line_id % 4 = 2 THEN 'Transfer'
        ELSE 'Wallet'
    END,
    CASE
        WHEN ids.line_id % 10 = 0 THEN NULL
        ELSE 1 + ids.line_id % 5
    END
FROM dbo.orders AS o
CROSS JOIN
(
    VALUES (1), (2), (3)
) AS item_number (line_number)
CROSS APPLY
(
    SELECT (o.order_id - 1) * 3 + item_number.line_number AS line_id
) AS ids
JOIN dbo.products AS p
    ON p.product_id = 1001 + ((o.order_id + item_number.line_number - 2) % 15)
CROSS APPLY
(
    SELECT
        CASE
            WHEN ids.line_id % 6 = 0 THEN NULL
            WHEN ids.line_id % 5 = 0 THEN CAST(20.00 AS DECIMAL(5, 2))
            WHEN ids.line_id % 4 = 0 THEN CAST(15.00 AS DECIMAL(5, 2))
            WHEN ids.line_id % 3 = 0 THEN CAST(10.00 AS DECIMAL(5, 2))
            ELSE CAST(5.00 AS DECIMAL(5, 2))
        END AS discount_value
) AS d;
GO

CREATE INDEX IX_order_items_order_id
    ON dbo.order_items (order_id);
GO

CREATE INDEX IX_order_items_customer_id
    ON dbo.order_items (customer_id);
GO

CREATE INDEX IX_order_items_product_id
    ON dbo.order_items (product_id);
GO

CREATE INDEX IX_order_items_order_date
    ON dbo.order_items (order_date);
GO

CREATE INDEX IX_order_items_category
    ON dbo.order_items (category);
GO

CREATE INDEX IX_order_items_region
    ON dbo.order_items (region);
GO

/* Calculate order-level amounts from the inserted line items. */

UPDATE o
SET
    o.amount = totals.gross_amount,
    o.discount = CASE
        WHEN o.order_id % 7 = 0 THEN NULL
        ELSE totals.discount_amount
    END
FROM dbo.orders AS o
JOIN
(
    SELECT
        order_id,
        CAST(SUM(quantity * unit_price) AS DECIMAL(14, 2)) AS gross_amount,
        CAST(
            SUM(quantity * unit_price * COALESCE(discount_pct, 0) / 100.0)
            AS DECIMAL(14, 2)
        ) AS discount_amount
    FROM dbo.order_items
    GROUP BY order_id
) AS totals
    ON totals.order_id = o.order_id;
GO

/* ============================================================================
   COMPATIBILITY VIEWS FOR LECTURE 1

   Lecture 1 uses the singular names Customer and OrderItem.
   Later lectures and Assignment 1 use customers, orders, and order_items.
============================================================================ */

CREATE VIEW dbo.Customer
AS
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    birth_date,
    city,
    phone,
    country_code,
    signup_ts,
    region
FROM dbo.customers;
GO

CREATE VIEW dbo.OrderItem
AS
SELECT
    line_id,
    order_id,
    order_date,
    shipped_date,
    customer_id,
    region,
    product_id,
    category,
    product_name,
    quantity,
    unit_price,
    discount,
    discount_pct,
    cost,
    shipping_cost,
    sales_channel,
    payment_method,
    customer_rating
FROM dbo.order_items;
GO

/* ============================================================================
   DATA VALIDATION
============================================================================ */

IF (SELECT COUNT(*) FROM dbo.customers) <> 120
    THROW 51000, 'Validation failed: customers must contain 120 rows.', 1;

IF (SELECT COUNT(*) FROM dbo.orders) <> 360
    THROW 51001, 'Validation failed: orders must contain 360 rows.', 1;

IF (SELECT COUNT(*) FROM dbo.order_items) <> 1080
    THROW 51002, 'Validation failed: order_items must contain 1080 rows.', 1;

IF EXISTS
(
    SELECT category
    FROM dbo.order_items
    WHERE order_date >= CAST('2026-01-01' AS DATE)
      AND order_date <  CAST('2027-01-01' AS DATE)
    GROUP BY category
    HAVING COUNT(DISTINCT order_id) < 100
)
    THROW 51003, 'Validation failed: every category must occur in at least 100 distinct 2026 orders.', 1;

IF EXISTS
(
    SELECT sales_channel
    FROM dbo.order_items
    WHERE order_date >= CAST('2026-01-01' AS DATE)
      AND order_date <  CAST('2027-01-01' AS DATE)
    GROUP BY sales_channel
    HAVING COUNT(DISTINCT order_id) < 50
)
    THROW 51004, 'Validation failed: every channel must occur in at least 50 distinct 2026 orders.', 1;
GO

/* ============================================================================
   SQL SERVER DIALECT REFERENCE

   The Week 1 materials use some PostgreSQL-style examples. In SSMS, use these
   SQL Server equivalents when writing or demonstrating those queries:

   PostgreSQL                            SQL Server
   ------------------------------------  --------------------------------------
   DATE '2026-01-01'                    CAST('2026-01-01' AS DATE)
   LIMIT 10                             SELECT TOP (10) ...
   LIMIT 20 OFFSET 40                   OFFSET 40 ROWS FETCH NEXT 20 ROWS ONLY
   DATE_TRUNC('month', order_date)      DATEFROMPARTS(YEAR(order_date),
                                                       MONTH(order_date), 1)
   EXTRACT(YEAR FROM order_date)        YEAR(order_date)
   EXTRACT(MONTH FROM order_date)       MONTH(order_date)
   SUBSTRING(phone FROM 1 FOR 3)        SUBSTRING(phone, 1, 3)
   CURRENT_DATE                         CAST(GETDATE() AS DATE)
   current_date - another_date          DATEDIFF(DAY, another_date,
                                                 CAST(GETDATE() AS DATE))

   All table and column names required by the lectures and Assignment 1 are
   included in this database. Use RetailDB before running the examples.
============================================================================ */

SELECT
    (SELECT COUNT(*) FROM dbo.customers) AS customer_rows,
    (SELECT COUNT(*) FROM dbo.orders) AS order_rows,
    (SELECT COUNT(*) FROM dbo.order_items) AS order_item_rows,
    (SELECT COUNT(*) FROM dbo.products) AS product_rows;
GO

PRINT 'RetailDB was created and validated successfully.';
GO
