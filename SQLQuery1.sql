-- Sams Teach TSQL Database Queries

--b

SELECT cust_email, substring(cust_email, charindex(cust_email, '@') + 1, len(cust_email)) AS cust_email_domain
FROM Customers

-- c

SELECT cust_email, replace(substring(cust_email, charindex(cust_email, '@') + 1, len(cust_email), '.com', '.org')) AS cust_email_domain
FROM Customers

-- d

SELECT order_num, order_date, year(order_date) as year, datepart(qq, order_date) as quarter, month(order_date) as month
FROM Orders
ORDER BY year(order_date), datepart(qq, order_date), month(order_date)

--e
select order_num, order_date, year(order_date) as year, month(order_date) as month, datepart(qq, order_date) as quarter, datename(weekday, datepart(weekday, order_date)) AS weekday
from orders
where datename(weekday, datepart(weekday, order_date)) in ('Saturday', 'Sunday')
order by year(order_date), datepart(qq, order_date), month(order_date)

--f
select item_price, round(item_price, 0) as rounded_item_price 
from orderitems

--g
select*, dense_rank() over (order by item_price desc) as ranking
into #temp_orderitems1
from orderitems

select *
from #temp_orderitems1
where ranking <= 4

-- chapter 11

--b
select order_num, sum(item_prices)
FROM orderitems
Group by order_num

--c

select count(distinct[npl_biblio]) as uniqe_count_npl_biblio
from patstat

--d

select
    sum(quantity * item_price) as total_revenue,
    max(quantity * item_price) as max_revenue,
    min(quantity * item_price) as min_revenue
from
    orderitems


--12

--b

select order_num, count(order_num) as order_num_count, sum (quantity * item_price) as order_num_revenue
from orderitems
group by order_num
having sum (quantity * item_price) >= 100
order by sum (quantity * item_price) ASC

--c

select prod_id, count(prod_id) as prod_id_count, sum(quantity * item_price) as order_num_revenue
from orderitems
group by order_num
having sum (quantity * item_price) >= 50 and sum (quantity * item_price) <= 150
order by sum(quantity * item_price) asc

--d

select npl_biblio 
from patstat
group by(npl_biblio)
having count(*) = 21

--e

select empno, empsalary, deptname, avg(empsalary) as top_earner_dep
from xemp
group by deptname
having avg(empsalary) = SELECT (MAX (top_earner_dep) From (select (avg (empsalary) from xemp group by deptname) as temp)


-- 13

-- b

SELECT cust_contact, cust_name
FROM Customers
WHERE cust_id IN (SELECT cust_id
					FROM Orders
					WHERE order_num IN (SELECT order_num
										FROM orderitems
										WHERE prod_id NOT IN ('TNT2', 'SLING')))

-- c

-- Do it at home

-- d

SELECT cust_name
FROM customers
WHERE cust_id NOT IN (SELECT cust_id FROM Orders)

-- e

SELECT cust_name
FROM customers AS c
WHERE NOT EXISTS (SELECT cust_id
					FROM orders AS o
					WHERE o.cust_id = c.cust_id)

-- f

SELECT cust_name, cust_id
INTO #tmp
FROM Customers AS c
WHERE NOT EXISTS (SELECT cust_id, order_date
				FROM orders AS o
				WHERE DateDiff(month, order_date, '2005-09-01') = 0 AND
				o.cust_id = c.cust_id) -- * Ask the temporary and permanent table trick during the labs*

-- g

SELECT cluster_id, COUNT(npl_biblio) AS no_publications
FROM Patstat_golden_set
GROUP BY cluster_id
HAVING COUNT(npl_biblio) = (
    SELECT MAX(pub_count)
    FROM (
        SELECT COUNT(npl_biblio) AS pub_count
        FROM Patstat_golden_set
        GROUP BY cluster_id
    ) AS subquery
);
 
 -- h

SELECT ID, name, dept_name
from uni_student AS stu
WHERE NOT EXISTS (SELECT *
					FROM uni_advisor AS a
					WHERE a.s_ID = stu.ID)

-- i

SELECT ID, name, dept_name
FROM uni_student
WHERE ID IN (SELECT s_ID
				FROM uni_advisor
				WHERE i_ID IN (SELECT ID
									FROM uni_instructor
									WHERE name IN ('Einstein', 'Mozart')))

-- 14

-- b

SELECT *
FROM customers AS c
CROSS JOIN orders
ORDER BY c.cust_id, order_num

-- c

SELECT vend_name, prod_name, prod_price
FROM vendors AS v
INNER JOIN products AS p
ON v.vend_id = p.vend_id
ORDER BY v.vend_name, p.prod_name

-- d

SELECT cust_id, cust_name, prod_id, vent_id
FROM customers AS c

-- 15

-- b

SELECT c.cust_id, c.cust_name, o.order_num
FROM customers AS c
LEFT OUTER JOIN orders AS o
ON c.cust_id = o.cust_id
WHERE o.order_num IS NULL

SELECT c.cust_id, c.cust_name, o.order_num
FROM customers AS c
LEFT JOIN orders AS o
ON c.cust_id = o.cust_id
WHERE o.order_num IS NULL

-- c

SELECT o.*, oi.*
FROM customers AS c
FULL OUTER JOIN orders AS o 
ON c.cust_id = o.cust_id
FULL OUTER JOIN orderitems AS oi
ON o.order_num = oi.order_num


SELECT *
FROM orders AS o
FULL OUTER JOIN orderitems AS oi ON o.order_num = oi.order_num

-- d

SELECT oi1.*
FROM orderitems AS oi1
JOIN orderitems AS oi2
ON oi1.item_price = oi2.item_price
AND oi1.prod_id <> oi2.prod_id
AND oi1.order_num <> oi2.order_num


SELECT oi1.*
FROM orderitems AS oi1
JOIN orderitems AS oi2
ON oi1.item_price = oi2.item_price
AND oi1.prod_id < oi2.prod_id
AND oi1.order_num < oi2.order_num


select *
from orderitems

-- e

select *
into #even
from patstat
where npl_publn_id % 2 = 0

select *
into #odd
from patstat
where npl_publn_id % 2 <> 0


-- f

SELECT stu.ID, stu.name AS student_name, stu.dept_name, ISNULL(ins.name, 'NULL') AS advisor_name, ISNULL(ins.ID, 'NULL') AS advisor_id
FROM uni_student AS stu
LEFT JOIN uni_advisor AS adv ON stu.ID = adv.s_ID
LEFT JOIN uni_instructor AS ins ON adv.i_ID = ins.ID
ORDER BY stu.ID

select s.name as student_name, s.dept_name as student_dept, s.id as student_id,
       i.name as advisor_name, i.id as advisor_id
from uni_student as s
left join uni_advisor as a on s.id = a.s_id
left join uni_instructor as i on a.i_id = i.id
order by s.id;

-- Chapter 16

-- b

SELECT prod_id, vend_id, prod_name, prod_price
FROM products
WHERE prod_price <= 5
UNION ALL
SELECT prod_id, vend_id, prod_name, prod_price
FROM products
WHERE vend_id IN (1001, 1002)

-- c

SELECT prod_id, vend_id, prod_name, prod_price
FROM products
WHERE prod_price <= 5
UNION
SELECT prod_id, vend_id, prod_name, prod_price
FROM products
WHERE vend_id IN (1001, 1002)

-- d

SELECT prod_id, vend_id, prod_name, prod_price
FROM products
WHERE prod_price <= 5
EXCEPT
SELECT prod_id, vend_id, prod_name, prod_price
FROM products
WHERE vend_id IN (1001, 1002)

-- e

SELECT prod_id, vend_id, prod_price
FROM products
WHERE prod_price <= 5
intersect
SELECT prod_id, vend_id, prod_price
FROM products
WHERE vend_id IN (1001, 1002, 1003)
INTERSECT
SELECT prod_id, vend_id, prod_price
FROM products
WHERE prod_id IN ('FC', 'FU1')

-- f

SELECT DISTINCT o.order_num, c.cust_city, oi.item_price
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
JOIN orderitems oi ON o.order_num = oi.order_num
WHERE c.cust_city IN ('Detroit', 'Chicago')

UNION

SELECT DISTINCT o.order_num, c.cust_city, oi.item_price
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
JOIN orderitems oi ON o.order_num = oi.order_num
WHERE oi.item_price�>�10;

--

select distinct b.order_num, a.cust_city, c.item_price
from customers as a
join orders as b on a.cust_id = b.cust_id
join orderitems as c on b.order_num = c.order_num
where cust_city in ('Detroit','Chicago') or�item_price�>�10
 


-- Chapter 18

-- b

create table #tmp (order_num int null);
insert into #tmp
select distinct b.order_num 
from customers as a 
join orders as b on a.cust_id = b.cust_id 
join orderitems as c on b.order_num = c.order_num 
where cust_city in ('Detroit','Chicago') or item_price > 10;

select *
from #tmp
-- c
INSERT INTO #tmp (order_num)
VALUES (20010), (20011), (20012), (20013)

select *
from #tmp
-- d

select *
into #tmp2
from #tmp
insert #tmp2
values (NULL), (NULL), (NULL)

SELECT *
from #tmp2

-- Chapter 19

-- b

DELETE
from #tmp2
where order_num is null OR order_num >= 20010

select *
from #tmp2

-- c

delete
from #tmp

drop table #tmp
drop table #tmp2

-- d

select *
into #orderitems
from orderitems

select *
from #orderitems

update #orderitems
set item_price = 
case when quantity > 1 then item_price * 10
when quantity = 1 then item_price * 5
else item_price end
where quantity > 1 or quantity = 1  

-- e

select *
into customers_2121236
from customers

select *
from customers_2121236

update customers_2121236
set cust_email =
replace(substring(cust_email, charindex(cust_email, '@') + 1, len(cust_email)), '.com', '.org')
where cust_id in (select customers_2121236.cust_id
					from customers_2121236
					join orders as o
					on o.cust_id = customers_2121236.cust_id
					where order_num in (20005, 20009))

select *
from customers_2121236

--f

select distinct order_date, order_num, cust_id
into #tmp
from orders

update #tmp
set order_date = dateadd(year, (2022 - 
year(order_date)), order_date)

select order_date, year(order_date) as year, month(order_date) as month, datepart(qq, order_date) as quarter
into #tmp2
from #tmp

CREATE TABLE #TimeDimension (
    TimeKey INT IDENTITY(1,1) PRIMARY KEY,
    [Year] INT,
    Quarter INT,
    Month INT,
    order_date DATE
)

insert into #TimeDimension([Year], Quarter, Month, order_date)
select [Year], Quarter, Month, order_date
From #tmp2

select *
from #TimeDimension

-- Chapter 20

-- b

EXEC sp_rename 'customers_2', 'customers' 

-- c


CREATE TABLE orders_new_2121236 (
    order_num INT PRIMARY KEY,
    order_date DATETIME,
    cust_id INT not null)

INSERT INTO orders_new_2121236 (order_num, order_date, cust_id)
VALUES 
    (1, GETDATE(), 100), 
    (2, GETDATE(), 200), 
    (3, GETDATE(), 300)

select *
from orders_new_2121236


