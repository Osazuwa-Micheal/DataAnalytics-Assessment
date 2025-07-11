WITH last_successful_tx AS (
    SELECT 
        a.id AS account_id,
        MAX(DATE(b.transaction_date)) AS last_inflow_date,
        a.is_regular_savings AS saving,
        a.is_a_fund AS invest,
        a.is_archived
    FROM plans_plan a
    LEFT JOIN savings_savingsaccount b ON a.id = b.plan_id
    WHERE b.transaction_status = 'success'
    GROUP BY a.id, a.is_regular_savings, a.is_a_fund, a.is_archived
)

SELECT 
    account_id,
    CASE 
        WHEN saving = 1 THEN 'savings'
        WHEN invest = 1 THEN 'investment'
    END AS account_type,
    last_inflow_date,
    DATEDIFF('2025-04-18', last_inflow_date) AS inactivity_days
FROM last_successful_tx
WHERE 
    is_archived = 0
    AND (saving = 1 OR invest = 1)
    AND DATEDIFF('2025-04-18', last_inflow_date) > 365;
