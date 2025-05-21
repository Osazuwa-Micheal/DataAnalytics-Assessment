# DataAnalytics-Assessment

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
