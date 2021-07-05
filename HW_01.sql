CREATE TABLE orders (
	id_o INT,
	user_id INT,
	price INT,
	o_date DATE
);

select * from orders;

-- 2. ����������������, ����� ������ ������ ��������
select min(o_date) from orders limit 1;
select max(o_date) from orders limit 1;

-- ������ ��������� �� ������ � 01.01.2016 �� 31.12.2017

-- 3. ��������� ���-�� �����, ���-�� ������� � ���-�� ���������� �������������, ��� ��������� ������.
select count(*) from orders;
select COUNT(distinct id_o) from orders;
select count(distinct user_id) from orders;

-- � ������� 2 002 804 ������ � ����� �� ���������� ������� � 1 015 119 ���������� �������������

-- 4. �� ����� � ������� ��������� ������� ���, ������� ���-�� ������� �� ������������, ������� ����� , 
-- ��� ���������� ��� ���������� ��� �� ����.

select extract (year from o_date) as year_by, avg(price) from orders group by year_by;
select EXTRACT(YEAR_MONTH FROM o_date) as month_by, avg(price) from orders group by month_by;

-- ������� ��� ����� � 2095 �� � 2016 �. �� 2397 �� � 2017.