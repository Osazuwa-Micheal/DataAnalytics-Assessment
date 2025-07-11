WITH Account_Tenure AS (
    SELECT  
        c.id AS customer_id, 
        CONCAT_WS(' ', c.first_name, c.last_name) AS name,
        TIMESTAMPDIFF(MONTH, c.date_joined, '2025-04-18') AS tenure_months,
        COUNT(b.id) AS total_transactions,
        SUM(b.amount * 0.001) AS total_profit
    FROM users_customuser c
    JOIN savings_savingsaccount b ON b.owner_id = c.id
    WHERE b.transaction_status = 'success'
    GROUP BY c.id, c.first_name, c.last_name, c.date_joined
)

SELECT 
    customer_id, 
    name, 
    tenure_months,
    total_transactions,
    CASE 
        WHEN tenure_months = 0 THEN 0
        ELSE (total_transactions / tenure_months) * 12 * (total_profit / total_transactions)
    END AS estimated_clv
FROM Account_Tenure
ORDER BY estimated_clv DESC;