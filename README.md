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
