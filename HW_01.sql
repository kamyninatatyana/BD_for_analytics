-- ������� 1. 
-- ������ � ���� �� ������ �� �������� � ��������� ��������� ������ � ������.

select * from orders;

-- � ������� 4 ������� - id ������, id ������������, ����, ���� ������.
select count(*) from orders; -- � ������e 2 002 804 ������
-- ��������� � � ������ ������� ������� � ������, ��� ������ ���������� ���������, � ������ ��� ������� �� 
-- ��������, ������, ��� ������ �� ������������ ������� ���.

-- ��������� ����������� � ������������ �������� �� ������� �� ��������. 

-- ��������� �������:
select min(id_o) from orders; -- 1 234 491
select max(id_o) from orders; -- 6 945 534
select (max(id_o) - min(id_o))/2002804 as increment_step  from orders; -- ������� ��������� ������ 
-- ������ 2. ���� �� �� �������� ���������� � ����������, ��� ��� ����������, �� 1 �� 3. � ��� ��� ������� 
-- �� �������. ������, ��� � ���� ������� ������ ���.

-- ��������� �������������:
select min(user_id) from orders; -- 0
select max(user_id) from orders; -- 5 919 156
-- ����������, user_id = 0 ��� �� ���� ���������. �� ����� �������:
select count(user_id) from orders where user_id=0; -- ����� ����, ������� ���� ������� ����� ����������.
-- �� ��� ���� ���������, � ������ ������ ���������� ��������� �������������:
select user_id from orders where user_id < 100; -- c 1, � ����� 76, � ����� 90... ������� ������� ������� ����� 
-- �� ����. �����, ��� ������ ����� ���� - ������ ������� ���������� ������������. 
select count(user_id) from orders where user_id > 4000000; -- ���� �����-�� ������ �������� � ��������� �� ����.
-- ������, ��� � ���� ������� ��� �������� ������.

-- ����:
select min(price) from orders; -- ����������� ���� (- 184)! �������-�� ���� �����-�� �����.
select max(price) from orders; -- ������������ ���� 819 096. � �����, ��� ���� �����.  
-- ��������, ������� ����� �������� �������:
select count(price) from orders where price < 0; -- ����� 6 �������.
-- ��� �������� ������������ �������� ������� ��������� ������� ��� �� ������:
select AVG(price) from orders; -- ������� ��� �� 1 ������ 2 267 ��.
-- �����, ��� ��� ���� ������� ��� � 100 ����� ����� ������� � ������������ ������:
select price from orders where price > 200000; -- ����� ������� 9
select price from orders where price > 100000; -- � ����� 64.
-- ������ �������, ��� ����� ����� �� ������� ���������. ����� ���-���� ��������, � ����� ������ ���� ����. 
-- ���� ��� (� ��������� ������?) �������� ������� �����-������� �� � ��, ��������, �������� �� ���, ��� ���� 
-- 100 ���. ��.

-- !!! �� ���� �������, ��� ������ � ������������� ������. � �� �� ��������. �� ����� �� �� �������. 
-- �� ��������� �� ���� �������� �� �������������� ����������. �� � ������ �������, ��������, ����� ������ �������� 
-- ������������� - ����������� ���������� ������? ����� �� ������� �������������� ��������� � ����� ������ �� ���-�� �����
-- ��������. � �����, �������� �� �����, ��� ��������� ���������. ���� �� ����� �������.

-- ����:
select min(o_date) from orders; -- 01.01.2016
select max(o_date) from orders; -- 31.12.2017
select * from 
	(select EXTRACT(month FROM o_date) as month_by, 
			EXTRACT(year FROM o_date) as year_by, 
			count(*) as Num_of_orders
		from orders group by month_by, year_by) as foo 
	order by year_by, month_by;	
-- ������ ������������ � ������ ������ ���������������� �������. ������ ��� � � ���� ������� ������ ���.
-- � ������� ����� ��������.

-- ������� 2. 
-- ����������������, ����� ������ ������ ��������
-- ��� �� ��� �������� ���� ������ ��������� �� ������ � 01.01.2016 �� 31.12.2017

-- ������� 3. 
-- ��������� ���-�� �����, ���-�� ������� � ���-�� ���������� �������������, ��� ��������� ������.
select count(*) from orders; -- � ������� 2 002 804 ������
select COUNT(distinct id_o) from orders -- 2 002 804 ������;
select count(distinct user_id) from orders -- 1 015 119 ���������� ������������;

-- ������� 4. 
-- �� ����� � ������� ��������� ������� ���, ������� ���-�� ������� �� ������������, ������� ����� , 
-- ��� ���������� ��� ���������� ��� �� ����.

drop view month_to_month;
CREATE or replace VIEW month_to_month AS 
SELECT 
	EXTRACT(MONTH FROM o_date) AS month_by,  
	SUM(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN price END) AS price_2016,
	SUM(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN price END) AS price_2017,
	AVG(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN price END) AS avg_price_2016,
	AVG(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN price END) AS avg_price_2017,
	COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN id_o END)) AS orders_2016,
	COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN id_o END)) AS orders_2017,
	COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN user_id END)) AS users_2016,
	COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN user_id END)) AS users_2017
FROM orders
group by month_by;

drop view year_to_year;
CREATE or replace VIEW year_to_year AS 
SELECT 
	SUM(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN price END) AS sales_2016,
	SUM(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN price END) AS sales_2017,
	AVG(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN price END) AS avg_price_2016,
	AVG(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN price END) AS avg_price_2017,
	COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN id_o END)) AS orders_2016,
	COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN id_o END)) AS orders_2017,
	COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN user_id END)) AS users_2016,
	COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN user_id END)) AS users_2017
FROM orders;

select * from year_to_year;
select 
	round(avg_price_2016, 0) avg_price_2016,
	round(avg_price_2017, 0) avg_price_2017,
	round(avg_price_2017/avg_price_2016, 2) as price_by_year,
	orders_2016,
	orders_2017,
	round(cast(orders_2017 as decimal) / cast(orders_2016 as decimal), 2) as orders_by_year,
	users_2016,
	users_2017,
	round(cast(users_2017 as decimal) / cast(users_2016 as decimal), 2) as users_by_year,
	sales_2016,
	sales_2017,
	round(cast(sales_2017 as decimal) / cast(sales_2016 as decimal), 2) as sales_by_year,
	round(cast(orders_2016 as decimal) / cast(users_2016 as decimal), 2) as orders_per_user2016,
	round(cast(orders_2017 as decimal) / cast(users_2017 as decimal), 2) as orders_per_user2017,
	round((cast(orders_2017 as decimal) / cast(users_2017 as decimal)) / 
		  (cast(orders_2016 as decimal) / cast(users_2016 as decimal)), 2) - 1 as orders_per_user_2017to2016,
	round(cast(sales_2016 as decimal) / cast(users_2016 as decimal), 2) as sales_per_user2016,
	round(cast(sales_2017 as decimal) / cast(users_2017 as decimal), 2) as sales_per_user2017,
	round((cast(sales_2017 as decimal) / cast(users_2017 as decimal)) / 
		  (cast(sales_2016 as decimal) / cast(users_2016 as decimal)), 2) - 1 as sales_per_user_2017to2016	  
from year_to_year; 

-- ��� ������� ������ ��� � ���� �� �����:
-- 1. ����� ������� � ������� ������� �� 52%, ��� ���� ���������� ������� ������� ������ �� 33%. �� ���� ������ 
-- ������� ��������� ������ (������� ��������� ������ ������� �� 14%).
-- 2. ���������� ����������� ������� �� 47%, ��� ���� ���������� ������� ������� ������ �� 33%, ��� ������� �
-- ���, ��� ���������� ����� �������� ���� (���������� ������� �� 1 ���������� ��������� �� 10%).
-- 3. ������� �� ������ ������� ������� ������������� (����� ���� 3%).
-- ����� ������: 
-- 1. ����� ���������� ����� ��������. ��� ������. 
-- 2. � ��� ��������� ���������� ������� �� ������� �������, �� ��� ���� ������ �� ������� ������� �� �������� 
-- (���� ����� �� 3%) �� ������� �������. ��� ������. ��� ���, ��������, ��� ������ ��������� �������� �� 
-- ������������� (��� ������ ������� ��� ������ ������ �� �� ��������� � ����������), � ������, ��������, � ��� 
-- ���������� ����� ����������. ���� ����� ����� ���������. 
-- 3. � ��� �� ��� �� �������� ����������� ���������� ����� ������ �� 1 �������. 3% - ��� ����� ���� ������ ��������,
-- � ������ ������� �� ������ ������� �� ������, � ������!!! � ��� ����� �����. ����� ������ �������.

select 
	month_by,
	round(avg_price_2016, 0) avg_price_2016,
	round(avg_price_2017, 0) avg_price_2017,
	round(avg_price_2017 / avg_price_2016, 2) as price2017to2016,
	round(cast(orders_2016 as decimal) / cast(users_2016 as decimal), 2) as orders_per_user2016,
	round(cast(orders_2017 as decimal) / cast(users_2017 as decimal), 2) as orders_per_user2017,
	round((cast(orders_2017 as decimal) / cast(users_2017 as decimal)) / 
		  (cast(orders_2016 as decimal) / cast(users_2016 as decimal)), 2) - 1 as orders_per_user_2017to2016
from month_to_month; 

-- ��� ������� ������ ����� � ������ �� ����� ������������� ����� ������� �� ����:
-- 1. ������� ��������� ������ � 2017 ���� �� ��������� � 2016 ���� ������� �� 8 �� 23% � �����������
-- �� ������. ����� ������� ������� ������� ��������� ������ �� ����� � �����, ���� � ����. � ����� ������ - 
-- � �������. 
-- 2. ��� ���� ���������� ������� �� 1 ������������ ����� �� 2 - 13%. ����� ������� ������� - � �������. 
-- ������ ����� ���������� ���������� ������� �� ������ ������� �������� � ������. 


-- ������� 5. 
-- ����� ���-�� �������������, ��� �������� � ����� ���� � ��������� �������� � ���������.

-- ���� ����������� � 2016 ����:
select 
	count(*)
from
	(select 
		DISTINCT(user_id) AS user_id,
		COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN id_o END)) AS orders_2016
	from orders
	group by user_id) as foo
	where orders_2016 > 0;

-- ��������� �������� � 2017 ����:
select 
	count(orders_2017)
from
	(select 
		DISTINCT(user_id) AS user_id,
		COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN id_o END)) AS orders_2016,
		COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN id_o END)) AS orders_2017
	from orders
	group by user_id) as foo
where orders_2017 = 0;

select 
	count(orders_2016)
from
	(select 
		DISTINCT(user_id) AS user_id,
		COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN id_o END)) AS orders_2016,
		COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN id_o END)) AS orders_2017
	from orders
	group by user_id) as foo
where orders_2016 = 0;

-- ����� ����������� � 2017 ����:
select 
	count(*)
from
	(select 
		DISTINCT(user_id) AS user_id,
		COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN id_o END)) AS orders_2017
	from orders
	group by user_id) as foo
	where orders_2017 > 0;

-- ������: 
-- 1. ����� � 2016 ���� ���� 445 092 ���������� ����������.
-- 2. �� ��� 360 225 ��������� �������� � 2017.
-- 3. � 570 027 ��������� ����� � 2017 ����.
-- 4. ����� ������� � 2017 �. ���� 654 894 ���������� (�� �������). ��� 445 092 - 360 225 + 570 027 = 654 894
-- ������, �������, �������� ��� ������� ����� 80% ����������� ��������� �������� ��������� - ������ ������� � 
-- ����������� �������������� ������������.

-- ������� 6. 
-- ����� ID ������ ��������� �� ���-�� ������� ������������.

select user_id from orders group by user_id order by count(*) desc, user_id desc limit 1; -- id ������������, 
-- ������� �������� ���� ���� 765 861
select user_id, count(*) from orders where user_id = 765861 group by user_id; -- ������������ � id 765 861 ��������
-- 3 183 �������. � ����� ����� ����? � ������ �� ������, ��� � �������� �������� ����� ���������� �� �������� 
-- ����������. ��� ����� ���� ���� ��� �����-�� �������, ��������... �� �� 4 ������ � ���� � ������ ����??? �������� ��
-- ������� �������� ��������� ��������.
  
-- ������� 7. 
-- ����� ������������ ���������� �� �������.

drop view sales_per_year;
CREATE or replace VIEW sales_per_year as
select 
	EXTRACT(YEAR FROM o_date) AS year_by,
	SUM(price) as sales_per_year
from orders
group by year_by;

select 
	month_by,  
	sales_per_month,
	sales_per_year / 12 as avg_sales_per_month,
	round(cast(sales_per_month as decimal) / cast(sales_per_year / 12 as decimal), 2) as seasonality
from 
	(select
		EXTRACT(MONTH FROM o_date) as month_by,  
		EXTRACT(YEAR FROM o_date) as year_by,
		SUM(price) AS sales_per_month
	from orders where EXTRACT(YEAR FROM o_date) = 2016 group by month_by, year_by) as foo
left join sales_per_year
on foo.year_by = sales_per_year.year_by;

-- � 2016 ���� ������������ ������� ���� � ������ � ������� (����������� ���������� 1,71 � 1,72 ��������������),
-- � ����������� - � ������ � ������� (����������� ���������� 0,64 � 0,63).  

select 
	month_by,  
	sales_per_month,
	sales_per_year / 12 as avg_sales_per_month,
	round(cast(sales_per_month as decimal) / cast(sales_per_year / 12 as decimal), 2) as seasonality
from 
	(select
		EXTRACT(MONTH FROM o_date) as month_by,  
		EXTRACT(YEAR FROM o_date) as year_by,
		SUM(price) AS sales_per_month
	from orders where EXTRACT(YEAR FROM o_date) = 2017 group by month_by, year_by) as foo
left join sales_per_year
on foo.year_by = sales_per_year.year_by;

-- � 2017 ���� �������� ������������ ���������� �� ������� ����� ���������� - � �� ������ �� ��, ��� 
-- ����������� ������� �� �������� ���������� �� ������ � �������, ����������� ���������� � ��� ������
-- ���������� 0.78 � 0.71. ����������� �������� � ������� � ��������, ��, � ��� ������ ������� ��-��������
-- ������������, �� ����������� ���������� ��� 1.43 � 1.63. ��� ������.

