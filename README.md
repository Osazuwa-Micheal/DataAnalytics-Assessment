# DataAnalytics-SQL Project

## Question 1: High-Value Customers with Multiple Products

###  Objective:
Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

---

###  Explanation:

- I assigned aliases to the tables as follows:
  - `users_customuser` as `c`
  - `savings_savingsaccount` as `b`
  - `plans_plan` as `a`

- I used the `id` column from the `users_customuser` table as `owner_id` since it is a unique identifier for each customer.

- I concatenated the `first_name` and `last_name` columns from the `users_customuser` table to create a readable `name` column using `CONCAT_WS(" ", c.first_name, c.last_name)`.

- I used `COUNT(DISTINCT b.id)` to count the number of unique savings accounts per customer, and `COUNT(DISTINCT a.id)` to count the number of unique investment plans.

- I calculated the total deposits by summing the `confirmed_amount` column from the `savings_savingsaccount` table and labeled it as `total_deposits`.

- From the `users_customuser` table (`c`), I joined:
  - The `savings_savingsaccount` table (`b`) using `b.owner_id = c.id`
  - The `plans_plan` table (`a`) using `b.plan_id = a.id`

- I filtered the records using a `WHERE` clause to ensure:
  - Only funded savings accounts are considered (`b.confirmed_amount > 0`)
  - The plan is a savings type (`a.is_regular_savings = 1`)
  - The plan is also a fund/investment type (`a.is_a_fund = 1`)

- Finally, I grouped the data by `c.id`, `c.first_name`, and `c.last_name`, and sorted the results by `total_deposits` in descending order to get the highest-value customers at the top.

---

###  Output Fields:
- `owner_id`: Unique customer ID
- `name`: Full name (first and last)
- `savings_count`: Count of funded savings accounts
- `investment_count`: Count of funded investment plans
- `total_deposits`: Total deposit value (in kobo)


## Question 2:Transaction Frequency Analysis

###  Objective: Calculate the average number of transactions per customer per month and categorize them:
- "High Frequency" (≥10 transactions/month)
- "Medium Frequency" (3-9 transactions/month)
- "Low Frequency" (≤2 transactions/month)


## 1. Step One: Extracting Customer Transaction Data

```sql
WITH customer AS (
  SELECT 
    c.id AS customer_id, 
    CONCAT_WS(" ", c.first_name, c.last_name) AS full_name, 
    COUNT(transaction_status) AS TOTAL_TRANSACTION
  FROM users_customuser c
  JOIN savings_savingsaccount b ON b.owner_id = c.id
  GROUP BY c.id, c.first_name, c.last_name
)
```

In this first CTE, named `customer`, I gather basic transaction data for each user. The query joins two tables:

- `users_customuser`: Contains personal details of users (like first name, last name, and ID).
- `savings_savingsaccount`: Contains savings account information, including transactions.

The join happens on the condition `b.owner_id = c.id`, linking each savings account with its corresponding user.

Key operations in this step include:
- Creating a full name using `CONCAT_WS(" ", c.first_name, c.last_name)`.
- Counting how many transactions are associated with each user via `COUNT(transaction_status)` (assuming `transaction_status` is available in the joined table or an extended join).
- Grouping the data by user ID and name to ensure each customer appears only once in the result.

The result of this step is a list of customers with their names and the total number of transactions they’ve made.

---

## 2. Step Two: Calculating Average Monthly Transactions

```sql
avg_customer AS (
  SELECT 
    customer_id, 
    full_name, 
    TOTAL_TRANSACTION, 
    TOTAL_TRANSACTION / 30 AS avg_transaction_per_month
  FROM customer
)
```

In this second CTE, named `avg_customer`, I calculate the average number of transactions per month for each customer. This is done by simply dividing the total number of transactions by 30. I use 30 as a rough estimate for the number of days in a month.

This step adds an additional field `avg_transaction_per_month`, which helps in the next step where I classify customers by their activity level.

---

## 3. Step Three: Categorizing Customers by Frequency

```sql
frequency AS (
  SELECT 
    CASE
      WHEN avg_transaction_per_month >= 10 THEN "High_Frequency"
      WHEN avg_transaction_per_month BETWEEN 3 AND 9 THEN "Medium_Frequency"
      ELSE "Low_Frequency"
    END AS frequency_category, 
    avg_transaction_per_month
  FROM avg_customer
)
```

In the third CTE, named `frequency`, I assign each customer to one of three frequency categories based on their average monthly transactions:

- **High_Frequency**: Customers who average 10 or more transactions per month.
- **Medium_Frequency**: Customers who average between 3 and 9 transactions per month.
- **Low_Frequency**: Customers who average less than 3 transactions per month.

This classification is done using a SQL `CASE` statement, which works like an if-else condition.

The result of this step is a new column `frequency_category`, which labels each customer based on their activity level.

---

## 4. Step Four: Summarizing the Results

```sql
SELECT 
  frequency_category, 
  COUNT(frequency_category) AS customer_count, 
  AVG(avg_transaction_per_month) AS avg_transaction_per_month
FROM frequency
GROUP BY frequency_category;
```

In the final part of the query, I produce a summary report using the output from the previous step.

This summary includes:

- `frequency_category`: The label (High, Medium, Low).
- `customer_count`: The total number of customers in each category.
- `avg_transaction_per_month`: The average of the average monthly transactions in each category. This helps me understand how active each group is on average.

## Question 3: Account Inactivity Alert

###  Inactive Accounts SQL Query Explanation

This SQL query is used to identify **savings** or **investment** accounts that have not received any successful inflow transactions in the past **365 days**, as of **April 18, 2025**. It is useful for tracking account inactivity, flagging dormant users, or triggering re-engagement workflows.

---

##  Step 1: Common Table Expression (CTE) — `last_successful_tx`

```sql
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
```

###  What this does:
- Joins the `plans_plan` table (containing account/plan details) with the `savings_savingsaccount` table (containing transaction data).
- Filters only **successful transactions** using:  
  `WHERE b.transaction_status = 'success'`
- For each account/plan, it selects:
  - `account_id`: Unique identifier of the plan.
  - `last_inflow_date`: The most recent successful inflow date.
  - Flags indicating if the account is:
    - a **savings** account (`saving = 1`)
    - an **investment** account (`invest = 1`)
  - `is_archived`: Whether the account is archived.
- Uses `LEFT JOIN` to include accounts even if they have no transaction history.
- Groups by account and flags to ensure accurate aggregation.

---

##  Step 2: Main Query — Filter Inactive Accounts

```sql
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
```

###  What this does:
- Filters the results from the CTE to return:
  - Only **active accounts** (`is_archived = 0`)
  - Only **savings** or **investment** accounts (`saving = 1 OR invest = 1`)
  - Accounts where the last successful inflow was **more than 365 days ago**.
- Returns the following fields:
  - `account_id`: Unique ID of the account.
  - `account_type`: Either `'savings'` or `'investment'` based on the flags.
  - `last_inflow_date`: Date of the most recent successful transaction.
  - `inactivity_days`: Number of days the account has been inactive as of `'2025-04-18'`.



## Question 4: Customer Lifetime Value (CLV) Estimation


This query estimates **Customer Lifetime Value (CLV)** based on account tenure and transaction volume using a simplified business model.

---

## Scenario

Marketing wants to estimate CLV for each user based on:
- **Account tenure** (in months since signup),
- **Transaction volume** (number and amount of transactions),
- **Profit per transaction**: assumed to be **0.1%** (0.001) of the transaction amount.

---

##  CLV Formula

We use the formula:

```
CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
```

- `tenure_months`: Months since user joined
- `avg_profit_per_transaction = total_profit / total_transactions`
- `total_profit = SUM(transaction_amount * 0.001)`

---


##  SQL Query

```sql
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
```

---

##  Explanation

### Step 1: CTE (`Account_Tenure`)
- Joins users with their successful transactions.
- Calculates:
  - `tenure_months`: Time between signup and reference date (`2025-04-18`).
  - `total_transactions`: Count of successful transactions.
  - `total_profit`: 0.1% of transaction value summed per customer.

### Step 2: Final Output
- Calculates `estimated_clv` using the defined formula.
- Includes a `CASE` block to avoid dividing by zero if `tenure_months = 0`.
- Sorts the output by `estimated_clv` in descending order to highlight highest value customers.


