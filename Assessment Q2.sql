-- STEP ONE
WITH customer AS (
    SELECT 
        c.id AS customer_id, 
        CONCAT_WS(" ", c.first_name, c.last_name) AS full_name, 
        COUNT(b.transaction_status) AS total_transaction
    FROM users_customuser c
    JOIN savings_savingsaccount b ON b.owner_id = c.id
    GROUP BY c.id, c.first_name, c.last_name
),

-- STEP TWO
avg_customer AS (
    SELECT 
        customer_id, 
        full_name, 
        total_transaction, 
        total_transaction / 30.0 AS avg_transaction_per_month
    FROM customer
),

-- STEP THREE
frequency AS (
    SELECT 
        customer_id,
        full_name,
        avg_transaction_per_month,
        CASE
            WHEN avg_transaction_per_month >= 10 THEN "High_Frequency"
            WHEN avg_transaction_per_month BETWEEN 3 AND 9 THEN "Medium_Frequency"
            ELSE "Low_Frequency"
        END AS frequency_category
    FROM avg_customer
)

-- STEP FOUR
SELECT 
    frequency_category, 
    COUNT(*) AS customer_count, 
    ROUND(AVG(avg_transaction_per_month), 2) AS avg_transaction_per_month
FROM frequency
GROUP BY frequency_category;

