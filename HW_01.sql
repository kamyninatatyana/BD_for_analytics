CREATE TABLE orders (
	id_o INT,
	user_id INT,
	price INT,
	o_date DATE
);

select * from orders;

-- 2. ѕроанализировать, какой период данных выгружен
select min(o_date) from orders limit 1;
select max(o_date) from orders limit 1;

-- ƒанные выгружены за период с 01.01.2016 по 31.12.2017

-- 3. ѕосчитать кол-во строк, кол-во заказов и кол-во уникальных пользователей, кот совершали заказы.
select count(*) from orders;
select COUNT(distinct id_o) from orders;
select count(distinct user_id) from orders;

-- ¬ таблице 2 002 804 записи и такое же количество заказов и 1 015 119 уникальных пользователей

-- 4. ѕо годам и мес€цам посчитать средний чек, среднее кол-во заказов на пользовател€, сделать вывод , 
-- как измен€лись это показатели √од от года.

select extract (year from o_date) as year_by, avg(price) from orders group by year_by;
select EXTRACT(YEAR_MONTH FROM o_date) as month_by, avg(price) from orders group by month_by;

-- —редний чек вырос с 2095 уе в 2016 г. до 2397 уе в 2017.