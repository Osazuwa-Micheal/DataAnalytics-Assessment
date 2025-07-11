-- Select customer details and count of both savings and investment plans, with total deposits
SELECT 
    c.id AS owner_id,
    CONCAT_WS(' ', c.first_name, c.last_name) AS name,
    COUNT(DISTINCT b.id) AS savings_count,
    COUNT(DISTINCT a.id) AS investment_count,
    round(SUM(b.confirmed_amount)) AS total_deposits
FROM
    users_customuser c
        JOIN
    savings_savingsaccount b ON b.owner_id = c.id
        JOIN
    plans_plan a ON b.plan_id = a.id
WHERE
    b.confirmed_amount > 0
        AND a.is_regular_savings = 1
        OR a.is_a_fund = 1
GROUP BY c.id , c.first_name , c.last_name
ORDER BY total_deposits DESC;