Use film_rental;
-- Questions AND Answers:
-- 1.	What is the total revenue generated from all rentals in the database? (2 Marks)
        SELECT SUM(DATEDIFF(return_date, rental_date) * f.rental_rate) AS total_revenue
		FROM rental r
		JOIN inventory i ON r.inventory_id = i.inventory_id
		JOIN film f ON i.film_id = f.film_id;

-- 2.	How many rentals were made in each month_name? (2 Marks)
        SELECT DATE_FORMAT(rental_date, '%Y-%m') AS month_name, Monthname(rental_date) Month, COUNT(*) AS num_rentals
		FROM rental
		GROUP BY DATE_FORMAT(rental_date, '%Y-%m'), Monthname(rental_date) ;

-- 3.	What is the rental rate of the film with the longest title in the database? (2 Marks)
        select MAX(length(title)) Longest_title , rental_rate
        from film
        group by film_id
        order by  MAX(length(title)) desc
        limit 1;

-- 4.	What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? (2 Marks)
        Select AVG(rental_rate)
        from film,rental
        where return_date Between "2005-05-05 22:04:30" AND "2005-06-05 22:04:30";
        
-- 5.	What is the most popular category of films in terms of the number of rentals? (3 Marks)
       Select fc.category_id, c.name category_name,  Count(r.rental_id) Number_of_rentals
       From category c
       inner join film_category fc ON c.category_id = fc.category_id
       inner join inventory i ON fc.film_id = i.film_id
       inner join rental r ON i.inventory_id = r.inventory_id
       group by fc.category_id
       order by Count(r.rental_id) Desc
       limit 1;
       
-- 6.	Find the longest movie duration from the list of films that have not been rented by any customer. (3 Marks)
        SELECT MAX(f.length) AS longest_duration
		FROM film f
		JOIN inventory i ON f.film_id = i.film_id
		LEFT JOIN rental r ON i.inventory_id = r.inventory_id
		WHERE r.rental_id IS NULL;

-- 7.	What is the average rental rate for films, broken down by category? (3 Marks)
        Select c.name AS Category, AVG(f.rental_rate) as Average_rental_rate
        from category c
        join film_category fc ON c.category_id = fc.category_id
        join film f ON fc.film_id = f.film_id
        group by c.category_id;
        
-- 8.	What is the total revenue generated from rentals for each actor in the database? (3 Marks)
	    SELECT a.first_name,a.last_name,SUM(datediff(return_date,rental_date)*f.rental_rate) AS Total_Revenue
        from actor a
        join film_actor fa ON a.actor_id = fa.actor_id
        join film f ON fa.film_id = f.film_id
        join inventory i ON f.film_id = i.film_id
        join rental r ON i.inventory_id = r.inventory_id
        group by a.actor_id;

-- 9.	Show all the actresses who worked in a film having a "Wrestler" in the description. (3 Marks)
		Select a.first_name,a.last_name,f.description
        from actor a
        join film_actor fa ON a.actor_id = fa.actor_id
        join film f ON fa.film_id = f.film_id
        where f.description like "%Wrestler%";
        
-- 10.	Which customers have rented the same film more than once? (3 Marks)
      Select c.customer_id,c.first_name, c.last_name, f.title, count(*) as Num_Rented_Same_Film
      from customer c
      Join rental r ON c.customer_id = r.customer_id
      Join inventory i ON r.inventory_id = i.inventory_id
      Join film f ON i.film_id = f.film_id
      Group by c.customer_id, f.film_id
      Having count(*) > 1
      Order by Num_Rented_Same_Film desc;

-- 11.	How many films in the comedy category have a rental rate higher than the average rental rate? (3 Marks)
		SELECT c.name Category_Name, COUNT(*) AS comedy_films_above_avg_rental_rate
		FROM film f
		JOIN film_category fc ON f.film_id = fc.film_id
		JOIN category c ON fc.category_id = c.category_id
		WHERE c.name = 'Comedy'
		AND f.rental_rate > (SELECT AVG(rental_rate) FROM film);

-- 12.	Which films have been rented the most by customers living in each city? (3 Marks)
        SELECT c.city, f.title, COUNT(*) AS rental_count
		FROM rental r
		JOIN inventory i ON r.inventory_id = i.inventory_id
		JOIN film f ON i.film_id = f.film_id
		JOIN customer cu ON r.customer_id = cu.customer_id
		JOIN address a ON cu.address_id = a.address_id
		JOIN city c ON a.city_id = c.city_id
		WHERE f.title = (
		SELECT f2.title
		FROM rental r2
		JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
		JOIN film f2 ON i2.film_id = f2.film_id
		JOIN customer cu2 ON r2.customer_id = cu2.customer_id
		JOIN address a2 ON cu2.address_id = a2.address_id
		JOIN city c2 ON a2.city_id = c2.city_id
		WHERE c2.city = c.city
		GROUP BY f2.film_id
		ORDER BY COUNT(*) DESC
		LIMIT 1
		)
		GROUP BY c.city, f.title
		ORDER BY c.city;
       
-- 13.	What is the total amount spent by customers whose rental payments exceed $200? (3 Marks)
	  Select c.customer_id,c.first_name, c.last_name, f.title, count(*) as Num_Rented_Same_Film
      from customer c
      Join rental r ON c.customer_id = r.customer_id
      Join inventory i ON r.inventory_id = i.inventory_id
      Join film f ON i.film_id = f.film_id
      Group by c.customer_id, f.film_id
      Having count(*) > 1
      Order by Num_Rented_Same_Film desc;

-- 14.	Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema] (2 Marks)
        SELECT TABLE_NAME, COLUMN_NAME
		FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
		WHERE REFERENCED_TABLE_NAME = 'rental';

-- 15.	Create a View for the total revenue generated by each staff member, broken down by store city with the country name. (4 Marks)
       CREATE VIEW revenue_by_staff_city_country AS
       SELECT s.staff_id, s.first_name, s.last_name, ci.city, c.country, SUM(p.amount) AS total_revenue
		FROM payment p
		JOIN rental r ON p.rental_id = r.rental_id
		JOIN staff s ON r.staff_id = s.staff_id
		JOIN store st ON s.store_id = st.store_id
		JOIN address a ON st.address_id = a.address_id
		JOIN city ci ON a.city_id = ci.city_id
		JOIN country c ON ci.country_id = c.country_id
		GROUP BY s.staff_id, ci.city, c.country;

-- 16.	Create a view based on rental information consisting of visiting_day, customer_name, the title of the film,  no_of_rental_days, 
--      the amount paid by the customer along with the percentage of customer spending. (4 Marks)
        CREATE VIEW rental_spending AS
		SELECT 
		DATE(rental_date) AS visiting_day,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		f.title AS film_title,
		rental_duration AS no_of_rental_days,
		amount AS amount_paid,
		(amount / (SELECT SUM(amount) FROM payment WHERE customer_id = p.customer_id)) * 100 AS spending_percentage
		FROM 
		rental r
		JOIN customer c ON r.customer_id = c.customer_id
		JOIN inventory i ON r.inventory_id = i.inventory_id
		JOIN film f ON i.film_id = f.film_id
		JOIN payment p ON r.rental_id = p.rental_id;

-- 17.	Display the customers who paid 50% of their total rental costs within one day. (5 Marks)
      SELECT 
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_paid,
    ROUND(SUM(p.amount) / SUM(f.rental_rate), 2) AS percentage_paid,
    r.rental_date,
    r.return_date
FROM 
    customer c 
    Join rental r ON c.customer_id = r.customer_id 
    Join payment p ON r.rental_id = p.rental_id
    Join inventory i ON r.inventory_id = i.inventory_id
    Join film f ON i.film_id = f.film_id
GROUP BY 
    r.rental_id 
HAVING 
    percentage_paid >= (0.5)
    AND DATEDIFF(r.return_date, r.rental_date) = 1;
