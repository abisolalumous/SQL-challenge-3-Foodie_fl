-- SECTION A 
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

SELECT *
FROM plans AS p
JOIN subscriptions AS s
ON p.plan_id=s.plan_id
WHERE customer_id IN(1,2,11,13,15,16,18,19)

-- Customer_id  1
-- customer with customer_id 1 joined on thr 1st of AUgust 2020 with a trial plan but switched to a basic monthly after the expiration of the trial period.

-- Customer_id  2
-- customer with customer_id 1 joined on the 20th of AUgust 2020 with a trial plan but switched to a pro annual on the 27th September 2020 after the expiration of the trial period.

-- Customer_id  11
-- customer with customer_id 1 joined on the 19th of November 2020 with a trial plan but cancelled his subscription  after the expiration of the trial period.
-- Customer_id  13
-- customer with customer_id 13 joined on the 22nd of December 2020 with a trial plan but switched to a basic monthly after the expiration of the trial period.the customer was on the basic monthly for 3 months before switching to pro monthly on the 29th March 2021
-- Customer_id  15
-- customer with customer_id 15 joined on the 17th of March 2020 with a trial plan but switched to a pro monthly after the expiration of the trial periodfor a month and cancelled the subscriptions on 29th april 2020
-- Customer_id  16
-- customer with customer_id 16 joined on the 31st of May 2020 with a trial plan but switched to a basic monthly after the expiration of the trial period for 4 months and later migratedd to pro annual on the 21st of October 2020
-- Customer_id  18
-- customer with customer_id 18 joined on thr 6th of July 2020 with a trial plan but switched to a pro monthly after the expiration of the trial period.
-- Customer_id  19
-- customer with customer_id 19 joined on thr 22nd of June 2020 with a trial plan but switched to a pro monthly after the expiration of the trial period for 2 months and later migrated to pro annual subscription.






--  1.How many customers has Foodie-Fi ever had?

/*SELECT *
FROM subscriptions*/
/*SELECT COUNT(DISTINCT customer_id)AS num_customers
FROM subscriptions*/
-- ANSWERS
-- foodie_fi has only had 1000 customers

-- 2.What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
/*SELECT month(s.start_date) AS month,
	   year(s.start_date) AS year,
       COUNT(customer_id) AS num_of_trials
FROM  subscriptions AS s
JOIN plans AS p
ON s.plan_id=p.plan_id
WHERE p.plan_name='trial'
GROUP BY month(s.start_date), year(s.start_date)*/

-- ANSWER
-- March had the most number of  98 customers on the trial plan with 
-- February had 68 customer on trial

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
/*SELECT s.plan_id,
       p.plan_name,
       COUNT(s.plan_id) AS number_of_plans
       FROM  subscriptions AS s
JOIN plans AS p
ON s.plan_id=p.plan_id
WHERE 	 year(s.start_date)>2020
GROUP BY s.plan_id,p.plan_name*/

-- ANSWER
-- In 2021 there were 78 cancellations (churn)
-- The were 60 customers on the pro monthly plan_id
-- the were 63 customers on the pro annual plan_id
-- The were 8 customers on the basic monthly plan

-- 4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place?.

/*SELECT 
		COUNT(DISTINCT customer_id) AS total_of_customers,
		SUM(CASE WHEN plan_id=4 THEN 1 ELSE 0  END)AS churned_customer,
		ROUND(SUM(CASE WHEN plan_id=4 THEN 1 ELSE 0 END)/COUNT(DISTINCT customer_id)*100,1)AS pct_churn
FROM subscriptions*/

-- ANSWER
-- A total of 1000 Distinct Customers
-- 307 churned customers
-- 30.7% churned customer compared to the total customers

-- 5.How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

 WITH cte_churn AS (
	SELECT
		*,
		LAG(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS prev_plan
	FROM subscriptions)
SELECT
	COUNT(prev_plan) AS cnt_churn,
    	ROUND(COUNT(*) * 100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),0) AS perc_churn
FROM cte_churn
WHERE plan_id = 4 and prev_plan = 0;

-- ANSWER 
-- The numbr of churn customer are 92 while the percentage churn is approximately 9

-- 6.What is the number and percentage of customer plans after their initial free trial?
WITH cte_next_plan AS (
	SELECT
		*,
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
	FROM subscriptions)
SELECT
	next_plan,
	COUNT(*) AS num_cust,
    	ROUND(COUNT(*) * 100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS perc_next_plan
FROM cte_next_plan
WHERE next_plan is not null and plan_id = 0
GROUP BY next_plan
ORDER BY next_plan

-- ANSWER 
-- plan_id number of customers percentage next plan 
/*1	546	54.6
2	325	32.5
3	37	3.7
4	92	9.2*/


-- 7.What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH cte_next_date AS (
	SELECT
		*,
		LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_date
	FROM subscriptions
    WHERE start_date <= '2020-12-31'),
plans_breakdown AS(
SELECT
	plan_id,
    COUNT(DISTINCT customer_id) AS num_customer
FROM cte_next_date
WHERE (next_date IS NOT NULL AND (start_date < '2020-12-31' AND next_date > '2020-12-31'))
      OR (next_date IS NULL AND start_date < '2020-12-31')
GROUP BY plan_id)
SELECT
	plan_id,
	num_customer,
    ROUND(num_customer * 100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS perc_customer
FROM plans_breakdown
GROUP BY plan_id, num_customer
ORDER BY plan_id;


-- 8 How many customers have upgraded to an annual plan in 2020?
SELECT
	COUNT(customer_id) AS num_customer
FROM subscriptions
WHERE plan_id = 3 AND start_date <= '2020-12-31';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi? 

WITH annual_plan AS (
	SELECT
		customer_id,
        start_date AS annual_date
	FROM subscriptions
    	WHERE plan_id = 3),
trial_plan AS (
	SELECT
		customer_id,
        start_date AS trial_date
	FROM subscriptions
    WHERE plan_id = 0
)
SELECT
	ROUND(AVG(DATEDIFF(annual_date, trial_date)),0) AS avg_upgrade
FROM annual_plan ap
JOIN trial_plan tp ON ap.customer_id = tp.customer_id;


-- 10.Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH annual_plan AS (
	SELECT
		customer_id,
        start_date AS annual_date
	FROM subscriptions
    WHERE plan_id = 3),
trial_plan AS (
	SELECT
		customer_id,
        start_date AS trial_date
	FROM subscriptions
    WHERE plan_id = 0
),
day_period AS (
SELECT
	DATEDIFF(annual_date, trial_date) AS diff
FROM trial_plan tp
LEFT JOIN annual_plan ap ON tp.customer_id = ap.customer_id
WHERE annual_date is not null
),
bins AS (
SELECT
	*, FLOOR(diff/30) AS bins
FROM day_period)
SELECT
	CONCAT((bins * 30) + 1, ' - ', (bins + 1) * 30, ' days ') AS days,
	COUNT(diff) AS total
FROM bins
GROUP BY bins;

-- 11.How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH next_plan AS (
	SELECT 
		*,
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) AS plan
	FROM subscriptions)
SELECT
	COUNT(DISTINCT customer_id) AS num_downgrade
FROM next_plan np
LEFT JOIN plans p ON p.plan_id = np.plan_id
WHERE p.plan_name = 'pro monthly' AND np.plan = 1 AND start_date <= '2020-12-31';