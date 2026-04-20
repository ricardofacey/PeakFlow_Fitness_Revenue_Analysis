/* ============================================================
   PEAKFLOW FITNESS — REVENUE ANALYSIS (2023–2024)
   Author: Ricardo Facey
   Description: Customer segmentation, AOV decomposition, 
                product performance, and retention analysis
   ============================================================ */


/* ============================================================
   SECTION 1: BUSINESS OVERVIEW
   High-level revenue, order, and customer metrics
   ============================================================ */

-- 1.1 Total Revenue, Orders, and Customers
SELECT 
    ROUND(SUM(final_amount), 2)     AS total_revenue,
    COUNT(order_id)                 AS total_orders,
    COUNT(DISTINCT customer_id)     AS total_customers
FROM `PeakFlow_Fitness.orders`;

/*
  Results:
  - $4,801,509.97 total revenue
  - 10,000 orders
  - 3,664 distinct customers
    (2,853 in 2023 | 2,851 in 2024)
*/


-- 1.2 Yearly Revenue Trend
--     Tracks revenue, order volume, and AOV year-over-year
SELECT 
    EXTRACT(YEAR FROM order_date)           AS year,
    ROUND(SUM(final_amount), 2)             AS total_revenue,
    COUNT(order_id)                         AS total_orders,
    ROUND(SUM(final_amount) / COUNT(order_id), 2) AS avg_order_value
FROM `PeakFlow_Fitness.orders`
GROUP BY year
ORDER BY year;

/*
  Results:
  - Revenue growth is flat YoY (-0.11%)
  - AOV declined by $0.91 despite 4 additional orders in 2024
  - Signals a mild revenue squeeze beneath the surface
*/


-- 1.3 Monthly Revenue Trend
--     Low seasonality check — each month should contribute ~7–9% of annual orders
SELECT 
    EXTRACT(YEAR FROM order_date)   AS year,
    EXTRACT(MONTH FROM order_date)  AS month,
    ROUND(SUM(final_amount), 2)     AS revenue
FROM `PeakFlow_Fitness.orders`
GROUP BY year, month
ORDER BY year, month;


-- 1.4 Monthly AOV Trend with Year-over-Year Context
--     Includes monthly AOV, yearly AOV benchmark, and order share
SELECT 
    year,
    month,
    total_orders,
    ROUND(total_rev, 2)                                                             AS monthly_revenue,
    monthly_aov,
    ROUND(AVG(monthly_aov) OVER (PARTITION BY year), 2)                            AS yearly_avg_aov,
    ROUND(total_orders / SUM(total_orders) OVER (PARTITION BY year) * 100, 2)     AS pct_of_year_orders
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_date)   AS year,
        EXTRACT(MONTH FROM order_date)  AS month,
        COUNT(order_id)                 AS total_orders,
        ROUND(AVG(final_amount), 2)     AS monthly_aov,
        SUM(final_amount)               AS total_rev
    FROM `PeakFlow_Fitness.orders`
    GROUP BY year, month
)
ORDER BY year, month;


/* ============================================================
   SECTION 2: CHANNEL PERFORMANCE
   Online vs. in-store revenue and order breakdown
   ============================================================ */

-- 2.1 Revenue and AOV by Sales Channel
SELECT 
    channel,
    COUNT(order_id)                 AS total_orders,
    ROUND(SUM(final_amount), 2)     AS revenue,
    ROUND(AVG(final_amount), 2)     AS avg_order_value
FROM `PeakFlow_Fitness.orders`
GROUP BY channel;

/*
  Results:
  - Online accounts for ~70% of revenue and orders
  - In-store accounts for ~30%
  - Strong digital channel with room to leverage for targeted campaigns
*/


/* ============================================================
   SECTION 3: PRODUCT PERFORMANCE
   Category, brand, margin, and growth analysis
   ============================================================ */

-- 3.1 Product Catalog Snapshot (sample)
SELECT *
FROM `PeakFlow_Fitness.products`
LIMIT 50;


-- 3.2 Per-Product Profit Margin with Rank
--     Ranks all products by margin to identify pricing efficiency
SELECT
    *,
    RANK() OVER (ORDER BY profit_margin DESC) AS margin_rank
FROM (
    SELECT 
        product_id,
        ROUND(base_price - cost_price, 2)           AS item_profit,
        ROUND((base_price - cost_price) / base_price, 2) AS profit_margin
    FROM `PeakFlow_Fitness.products`
) t
ORDER BY margin_rank;


-- 3.3 Item-Level Profit Summary (from order_items)
--     Validates overall margin using actual transaction prices
SELECT 
    ROUND(SUM(unit_price * quantity), 2)                                        AS revenue,
    ROUND(SUM(cost_price * quantity), 2)                                        AS cost,
    ROUND(SUM((unit_price - cost_price) * quantity), 2)                        AS profit,
    ROUND(SUM((unit_price - cost_price) * quantity) 
          / SUM(unit_price * quantity) * 100, 2)                               AS profit_margin_pct
FROM `PeakFlow_Fitness.order_items`;

/*
  Results:
  - 30% blended profit margin across all transactions
*/


-- 3.4 Total Revenue and Profit by Product
--     Ranks products by units sold; uses actual transaction prices
SELECT 
    p.product_id,
    SUM(oi.quantity)                                                                        AS units_sold,
    ROUND(SUM(oi.quantity * p.base_price), 2)                                              AS product_revenue,
    ROUND(SUM((oi.quantity * p.base_price) - (oi.quantity * p.cost_price)), 2)            AS product_profit,
    ROUND(SUM((oi.quantity * p.base_price) - (oi.quantity * p.cost_price))
          / SUM(oi.quantity * p.base_price), 2)                                            AS profit_margin
FROM `PeakFlow_Fitness.order_items` oi
JOIN `PeakFlow_Fitness.products` p 
    ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY units_sold DESC;


-- 3.5 Monthly Product Performance Trend
--     Tracks revenue, profit, and margin per product over time
SELECT
    EXTRACT(YEAR FROM o.order_date)     AS year,
    EXTRACT(MONTH FROM o.order_date)    AS month, 
    p.product_id,
    SUM(oi.quantity)                                                                        AS units_sold,
    ROUND(SUM(oi.quantity * p.base_price), 2)                                              AS product_revenue,
    ROUND(SUM((oi.quantity * p.base_price) - (oi.quantity * p.cost_price)), 2)            AS product_profit,
    ROUND(SUM((oi.quantity * p.base_price) - (oi.quantity * p.cost_price))
          / SUM(oi.quantity * p.base_price), 2)                                            AS profit_margin
FROM `PeakFlow_Fitness.order_items` oi
JOIN `PeakFlow_Fitness.orders` o 
    ON oi.order_id = o.order_id
JOIN `PeakFlow_Fitness.products` p 
    ON oi.product_id = p.product_id
GROUP BY year, month, p.product_id
ORDER BY product_profit DESC;


-- 3.6 Revenue and Profit by Category
SELECT 
    p.category,
    SUM(oi.quantity)                                                                        AS total_units,
    ROUND(SUM(oi.unit_price * oi.quantity), 2)                                             AS revenue,
    ROUND(SUM((oi.unit_price - oi.cost_price) * oi.quantity), 2)                         AS profit,
    ROUND(SUM((oi.unit_price - oi.cost_price) * oi.quantity)
          / SUM(oi.unit_price * oi.quantity), 2)                                           AS profit_margin,
    ROUND(SUM(oi.unit_price * oi.quantity) 
          / SUM(SUM(oi.unit_price * oi.quantity)) OVER(), 2)                              AS pct_of_total_revenue
FROM `PeakFlow_Fitness.order_items` oi
JOIN `PeakFlow_Fitness.products` p 
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

/*
  Results:
  - All categories carry a consistent 29–32% margin
  - Equipment leads at ~30% of revenue
  - Accessories is the lowest contributor at ~18%
  - Supplements and Apparel are roughly equal at ~26% each
*/


-- 3.7 Revenue and Profit by Brand
SELECT 
    p.brand,
    SUM(oi.quantity)                                                                        AS total_units,
    ROUND(SUM(oi.unit_price * oi.quantity), 2)                                             AS revenue,
    ROUND(SUM((oi.unit_price - oi.cost_price) * oi.quantity), 2)                         AS profit,
    ROUND(SUM((oi.unit_price - oi.cost_price) * oi.quantity)
          / SUM(oi.unit_price * oi.quantity), 2)                                           AS profit_margin
FROM `PeakFlow_Fitness.order_items` oi
JOIN `PeakFlow_Fitness.products` p 
    ON oi.product_id = p.product_id
GROUP BY p.brand
ORDER BY revenue DESC;

/*
  Results:
  - Powermax is the top-performing brand
  - ZenAthlete is the lowest performer
*/


-- 3.8 Top 10 Fastest-Growing Products (Among Top 60 by Volume, Margin > 30%)
--     Identifies high-growth candidates for targeted marketing and acquisition campaigns
WITH yearly_units AS (
    SELECT
        p.product_id,
        EXTRACT(YEAR FROM o.order_date)     AS year,
        SUM(oi.quantity)                    AS units_sold
    FROM `PeakFlow_Fitness.order_items` oi
    JOIN `PeakFlow_Fitness.orders` o
        ON oi.order_id = o.order_id
    JOIN `PeakFlow_Fitness.products` p
        ON oi.product_id = p.product_id
    GROUP BY p.product_id, year
),

pivoted AS (
    SELECT
        product_id,
        SUM(CASE WHEN year = 2023 THEN units_sold ELSE 0 END) AS units_2023,
        SUM(CASE WHEN year = 2024 THEN units_sold ELSE 0 END) AS units_2024
    FROM yearly_units
    GROUP BY product_id
),

growth_calc AS (
    SELECT
        product_id,
        units_2023,
        units_2024,
        ROUND((units_2024 - units_2023) / NULLIF(units_2023, 0), 2)    AS growth_rate,
        (units_2023 + units_2024)                                        AS total_units
    FROM pivoted
    WHERE units_2024 > units_2023   -- growing products only
),

ranked_products AS (
    SELECT *,
        RANK() OVER (ORDER BY total_units DESC) AS volume_rank
    FROM growth_calc
)

SELECT
    rp.volume_rank,
    rp.product_id,
    rp.units_2023,
    rp.units_2024,
    rp.growth_rate,
    rp.total_units,
    ROUND((p.base_price - p.cost_price) / p.base_price, 2) AS profit_margin
FROM ranked_products rp
JOIN `PeakFlow_Fitness.products` p
    ON rp.product_id = p.product_id
WHERE 
    rp.volume_rank <= 60
    AND ROUND((p.base_price - p.cost_price) / p.base_price, 2) > 0.30
ORDER BY growth_rate DESC
LIMIT 10;


/* ============================================================
   SECTION 4: CUSTOMER SEGMENTATION
   Repeat vs. one-time customers — AOV, revenue, and basket analysis
   ============================================================ */

-- 4.1 Customer Count by Type (Repeat vs. One-Time)
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM `PeakFlow_Fitness.orders`
    GROUP BY customer_id
)

SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM customer_orders
GROUP BY customer_type;


-- 4.2 Monthly AOV Breakdown by Customer Type
--     Decomposes AOV into basket size and average item price to isolate drivers
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM `PeakFlow_Fitness.orders`
    GROUP BY customer_id
),

classified_orders AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_date,
        o.final_amount,
        CASE 
            WHEN c.order_count = 1 THEN 'One-time'
            ELSE 'Repeat'
        END AS customer_type
    FROM `PeakFlow_Fitness.orders` o
    JOIN customer_orders c
        ON o.customer_id = c.customer_id
),

order_level AS (
    SELECT 
        co.order_id,
        co.customer_id,
        EXTRACT(YEAR FROM co.order_date)    AS year,
        EXTRACT(MONTH FROM co.order_date)   AS month,
        co.customer_type,
        co.final_amount,
        SUM(oi.quantity)                    AS total_items
    FROM classified_orders co
    JOIN `PeakFlow_Fitness.order_items` oi
        ON co.order_id = oi.order_id
    GROUP BY 
        co.order_id, co.customer_id, year, month,
        co.customer_type, co.final_amount
)

SELECT 
    year,
    month,
    customer_type,
    COUNT(DISTINCT customer_id)                             AS customers,
    COUNT(order_id)                                         AS orders,
    ROUND(SUM(final_amount), 2)                            AS revenue,
    SUM(total_items)                                        AS total_items,
    ROUND(SUM(final_amount) / COUNT(order_id), 2)         AS avg_order_value,
    ROUND(SUM(total_items) / COUNT(order_id), 2)          AS avg_items_per_order,
    ROUND(SUM(final_amount) / SUM(total_items), 2)        AS avg_item_price
FROM order_level
GROUP BY year, month, customer_type
ORDER BY year, month, customer_type;


-- 4.3 Yearly AOV Breakdown by Customer Type
--     Annual rollup of 4.2 for year-over-year comparison
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM `PeakFlow_Fitness.orders`
    GROUP BY customer_id
),

classified_orders AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_date,
        o.final_amount,
        CASE 
            WHEN c.order_count = 1 THEN 'One-time'
            ELSE 'Repeat'
        END AS customer_type
    FROM `PeakFlow_Fitness.orders` o
    JOIN customer_orders c
        ON o.customer_id = c.customer_id
),

order_level AS (
    SELECT 
        co.order_id,
        co.customer_id,
        EXTRACT(YEAR FROM co.order_date)    AS year,
        EXTRACT(MONTH FROM co.order_date)   AS month,
        co.customer_type,
        co.final_amount,
        SUM(oi.quantity)                    AS total_items
    FROM classified_orders co
    JOIN `PeakFlow_Fitness.order_items` oi
        ON co.order_id = oi.order_id
    GROUP BY 
        co.order_id, co.customer_id, year, month,
        co.customer_type, co.final_amount
)

SELECT 
    year,
    customer_type,
    COUNT(DISTINCT customer_id)                             AS customers,
    COUNT(order_id)                                         AS orders,
    ROUND(SUM(final_amount), 2)                            AS revenue,
    SUM(total_items)                                        AS total_items,
    ROUND(SUM(final_amount) / COUNT(order_id), 2)         AS avg_order_value,
    ROUND(SUM(total_items) / COUNT(order_id), 2)          AS avg_items_per_order,
    ROUND(SUM(final_amount) / SUM(total_items), 2)        AS avg_item_price
FROM order_level
GROUP BY year, customer_type
ORDER BY year, customer_type;


/* ============================================================
   SECTION 5: CUSTOMER RETENTION
   Retained, churned, and new customer counts (2023 vs. 2024)
   ============================================================ */

-- 5.1 Retention Summary
--     Quantifies how many 2023 customers returned in 2024,
--     how many churned, and how many were newly acquired
WITH customers_2023 AS (
    SELECT DISTINCT customer_id
    FROM `PeakFlow_Fitness.orders`
    WHERE EXTRACT(YEAR FROM order_date) = 2023
),

customers_2024 AS (
    SELECT DISTINCT customer_id
    FROM `PeakFlow_Fitness.orders`
    WHERE EXTRACT(YEAR FROM order_date) = 2024
)

SELECT
    (SELECT COUNT(*) FROM customers_2023)                       AS customers_2023,
    (SELECT COUNT(*) FROM customers_2024)                       AS customers_2024,

    -- Retained: ordered in both years
    COUNT(DISTINCT c23.customer_id)                             AS retained_customers,

    -- Churned: ordered in 2023 but not 2024
    (SELECT COUNT(*) FROM customers_2023)
        - COUNT(DISTINCT c23.customer_id)                       AS churned_customers,

    -- New: ordered in 2024 but not 2023
    (
        SELECT COUNT(*)
        FROM customers_2024 c24
        LEFT JOIN customers_2023 c23
            ON c24.customer_id = c23.customer_id
        WHERE c23.customer_id IS NULL
    )                                                           AS new_customers_2024

FROM customers_2023 c23
JOIN customers_2024 c24
    ON c23.customer_id = c24.customer_id;

/*
  Results:
  - 2,853 customers in 2023 | 2,851 in 2024
  - 2,040 retained | 813 churned | 811 new
  - Net customer change: -2 YoY
  - Churn and acquisition are nearly perfectly offsetting,
    masking potential degradation in customer base quality
*/
