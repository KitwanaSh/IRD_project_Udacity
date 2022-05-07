
/*                                                                SQL PROJECT PREPARATION
                                                                  DVD RENTAL QUERIES
Question1
 Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.
For this query, you will need 5 tables: Category, Film_Category, Inventory, Rental and Film. Your solution should have three columns:
Film title, Category name and Count of Rentals.*/
SELECT DISTINCT clss.movies, clss.category, clss.rental_counts
FROM
   (SELECT re.rental_id,
		   cat.name,
		   f.title AS movies,
	   	   cat.name AS category,
	   	   COUNT(re.rental_id) OVER (PARTITION BY f.title) AS rental_counts
	FROM category cat
	JOIN film_category fc
	ON cat.category_id = fc.category_id
	JOIN film f
	ON fc.film_id = f.film_id
	JOIN inventory inv
	ON inv.film_id = f.film_id
	JOIN rental re
	ON re.inventory_id = inv.inventory_id
    WHERE cat.name IN ('Family', 'Comedy', 'Animation', 'Children', 'Classics', 'Music')
	GROUP BY 1,2,3,4
   ) AS clss
ORDER BY 2, 1;

/*Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. Can you provide a table with
the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental
duration for movies across all categories? Make sure to also indicate the category that these family-friendly movies fall into. */

SELECT f.title, 
       cat.name,
       f.rental_duration as rt_duration,
	   NTILE(4) OVER (ORDER BY f.rental_duration) AS std_quartile
FROM category cat
JOIN film_category fc
ON cat.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
WHERE cat.name IN ('Family', 'Comedy', 'Animation', 'Children', 'Classics', 'Music')
ORDER BY 3;

/* Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category
for each corresponding rental duration category. The resulting table should have three columns:
Category
Rental length category
Count
*/
WITH film_quart AS
		(SELECT cat.name AS category,
		 		f.rental_duration,
				NTILE(4) OVER (ORDER BY f.rental_duration) AS stand_quart
		FROM category cat
		JOIN film_category fc
		ON cat.category_id = fc.category_id
		JOIN film f
		ON fc.film_id = f.film_id
		WHERE cat.name IN ('Family', 'Comedy', 'Animation', 'Children', 'Classics', 'Music')
		ORDER BY 1,2)
SELECT category,
	   stand_quart,
	   COUNT(stand_quart)
FROM film_quart
GROUP BY 1,2
ORDER BY 1,2;




/* Questtion 2 */
/*Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. Your table should
include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.*/
SELECT DATE_PART('month', r.rental_date) AS rental_month,
	   DATE_PART('year', r.rental_date) AS rental_year,
	   s.store_id,
	   COUNT(s.store_id) AS count_rental
FROM rental r
JOiN staff st
ON r.staff_id = st.staff_id
JOIN store s
ON s.store_id = st.store_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

/*We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments.
Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers?*/
WITH tab1 AS (
        SELECT c.first_name || ' ' || c.last_name AS fullname,
        SUM(p.amount) AS amount_spent,
        COUNT(p.payment_date) AS cntpay_year
        FROM customer c
        JOIN payment p
        ON c.customer_id = p.customer_id
        WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 10
             ),
     tab2 AS (
        SELECT c.first_name || ' ' || c.last_name AS fullname,
        DATE_TRUNC('month', p.payment_date) AS monthly_pment,
        SUM(p.amount) AS pay_amount,
        COUNT(p.payment_date) AS pay_countpermon
        FROM customer AS c
        JOIN payment p
        ON c.customer_id = p.customer_id
        WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
        GROUP BY 1,2
        ORDER BY 2 DESC)
SELECT tab2.monthly_pment,
       tab1.fullname,
       tab2.pay_countpermon,
       tab2.pay_amount
FROM tab1
JOIN tab2
ON tab1.fullname = tab2.fullname
ORDER BY 2,1
LIMIT 10;

/* write a query to compare the payment amounts in each successive month.
Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments. */
WITH tab1 AS (
        SELECT c.first_name || ' ' || c.last_name AS fullname,
        SUM(p.amount) AS amount_spent,
        COUNT(p.payment_date) AS cntpay_year
        FROM customer c
        JOIN payment p
        ON c.customer_id = p.customer_id
        WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 10
             ),
     tab2 AS (
        SELECT c.first_name || ' ' || c.last_name AS fullname,
        DATE_TRUNC('month', p.payment_date) AS monthly_pment,
        SUM(p.amount) AS pay_amount,
        COUNT(p.payment_date) AS pay_countpermon
        FROM customer AS c
        JOIN payment p
        ON c.customer_id = p.customer_id
        WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
        GROUP BY 1,2
        ORDER BY 2 DESC)
SELECT tab2.monthly_pment, 
       tab1.fullname,
       tab2.pay_amount,
       tab2.pay_amount - LAG(tab2.pay_amount) OVER (ORDER BY tab2.monthly_pment) AS mnt_paydiff
FROM tab1
JOIN tab2
ON tab1.fullname = tab2.fullname
ORDER BY 2,1
LIMIT 10;