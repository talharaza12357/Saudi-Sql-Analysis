CREATE DATABASE saudi_retail_analysis;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name_english VARCHAR(100),
    product_name_arabic VARCHAR(100),
    category VARCHAR(50),
    price_sar DECIMAL(10,2)
);

INSERT INTO products VALUES
(1, 'Saudi Dates', 'تمور سعودية', 'Food', 45.00),
(2, 'Arabic Coffee', 'قهوة عربية', 'Beverages', 25.00),
(3, 'Oud Perfume', 'عطور العود', 'Personal Care', 120.00),
(4, 'Khubz Arabic', 'خبز عربي', 'Bakery', 3.50),
(5, 'Saudi Honey', 'عسل سعودي', 'Food', 85.00),
(6, 'Traditional Dress', 'ثوب تقليدي', 'Clothing', 150.00);


CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name_english VARCHAR(50),
    city_name_arabic VARCHAR(50),
    region VARCHAR(50)
);

INSERT INTO cities VALUES
(1, 'Riyadh', 'الرياض', 'Central'),
(2, 'Jeddah', 'جدة', 'Western'),
(3, 'Dammam', 'الدمام', 'Eastern'),
(4, 'Mecca', 'مكة', 'Western'),
(5, 'Medina', 'المدينة', 'Western');


CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    city_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO sales VALUES
(1, '2024-01-15', 1, 1, 10),  -- Riyadh, Dates
(2, '2024-01-20', 1, 2, 5),   -- Riyadh, Coffee
(3, '2024-02-05', 2, 1, 8),   -- Jeddah, Dates
(4, '2024-02-10', 2, 3, 3),   -- Jeddah, Perfume
(5, '2024-02-15', 3, 4, 20),  -- Dammam, Bread
(6, '2024-03-01', 1, 5, 4),   -- Riyadh, Honey
(7, '2024-03-10', 2, 6, 2),   -- Jeddah, Dress
(8, '2024-03-20', 3, 1, 12),  -- Dammam, Dates
(9, '2024-03-25', 1, 3, 6),   -- Riyadh, Perfume
(10, '2024-04-05', 2, 2, 7);  -- Jeddah, Coffee

--Query 1: See All Data
SELECT * FROM sales;
SELECT * FROM products;
SELECT * FROM cities;

--Query 2: Total Sales Revenue
SELECT 
    SUM(s.quantity * p.price_sar) as total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id;

--Query 3: Sales by City
SELECT 
    c.city_name_english as city,
    SUM(s.quantity) as total_quantity
FROM sales s
JOIN cities c ON s.city_id = c.city_id
GROUP BY c.city_name_english
ORDER BY total_quantity DESC;

--Query 4: Top Selling Products
SELECT 
    p.product_name_english as product,
    SUM(s.quantity) as total_sold,
    SUM(s.quantity * p.price_sar) as total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name_english
ORDER BY total_revenue DESC;

--Query 5: Sales Performance by Region
SELECT 
    c.region,
    SUM(s.quantity * p.price_sar) as regional_revenue,
    COUNT(DISTINCT s.sale_id) as number_of_transactions
FROM sales s
JOIN cities c ON s.city_id = c.city_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.region
ORDER BY regional_revenue DESC;

--Query 6: Customer Preferences by City
SELECT 
    c.city_name_english as city,
    p.category,
    SUM(s.quantity) as quantity_sold
FROM sales s
JOIN cities c ON s.city_id = c.city_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.city_name_english, p.category
ORDER BY city, quantity_sold DESC;


--Query 7: Products Never Sold in Specific Cities
-- Cross join to see all possible city-product combinations
SELECT 
    c.city_name_english as city,
    p.product_name_english as product
FROM cities c
CROSS JOIN products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM sales s 
    WHERE s.city_id = c.city_id AND s.product_id = p.product_id
)
ORDER BY city, product;

--Query 8: High-Value Products Analysis
SELECT 
    p.product_name_english,
    p.price_sar,
    SUM(s.quantity) as total_sold,
    (p.price_sar * SUM(s.quantity)) as total_revenue,
    CASE 
        WHEN (p.price_sar * SUM(s.quantity)) > 500 THEN 'High Performer'
        WHEN (p.price_sar * SUM(s.quantity)) > 200 THEN 'Medium Performer'
        ELSE 'Low Performer'
    END as performance_category
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name_english, p.price_sar
ORDER BY total_revenue DESC;

--Summary View
CREATE VIEW sales_summary AS
SELECT 
    s.sale_date,
    c.city_name_english as city,
    c.region,
    p.product_name_english as product,
    p.category,
    s.quantity,
    p.price_sar,
    (s.quantity * p.price_sar) as total_sale_amount
FROM sales s
JOIN cities c ON s.city_id = c.city_id
JOIN products p ON s.product_id = p.product_id;





