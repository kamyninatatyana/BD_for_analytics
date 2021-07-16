select * from orders;

-- ������ ��������������� �������������, ��� �������� �������� ��� rfm

drop view rfm_analysis;
create or replace view rfm_analysis as
SELECT 
   	user_id as client_id,
   	max(o_date) as last_purch,
   	count(id_o) as orders,
   	sum(price) as sales,
   	'2017-12-31' - max(o_date) as recency,
   	case
   		when'2017-12-31' - max(o_date) <= 30 then 3
   		when '2017-12-31' - max(o_date) > 30 and '2017-12-31' - max(o_date) <= 60 then 2
   		else 1
   		end as recency_code,
   	case
   		when count(id_o) >= 4 then 3
   		when count(id_o) in (2, 3) then 2
   		else 1
   		end as frequency_code,
   	case
   		when sum(price) > 8000 then 3
   		when sum(price) > 3000 and sum(price) <= 8000 then 2
   		else 1
   		end as monetary_code   			
FROM orders
group by user_id;   


-- ��������������� ������� ��� ����������� ���������� ��� �������� frequency (������ ������ ���������,
-- �������� ������������� �� ��� - � ����� ������ � ���, ��� ������� � �������).

select 
	count(case when orders in (1) then client_id end) as range1,
	count(case when orders in (2,3) then client_id end) as range2,
	count(case when orders >= 4 then client_id end) as range3
from rfm_analysis;

-- 1 ����� �� ���� ������ � 774 497 ��������;
-- 2 ��� 3 ������ �� ���� ������ � 147 766 ��������;
-- ����� 4 ������� �� ���� ������ � 92 856 ��������.
-- ����� � ������� ������ 1 015 119 �������� (��� ��� �������. ������� �����).

-- ��������������� ������� ��� ����������� ���������� ��� �������� monetary (������ ������ ���������,
-- �������� ������������� �� ��� - � ����� ������ � ���, ��� ������� � �������).

select 
	count(case when sales <= 3000 then client_id end) as range1,
	count(case when sales > 3000 and sales <= 8000 then client_id end) as range2,
	count(case when sales > 8000 then client_id end) as range3
from rfm_analysis;

-- 680 444 �������� ��������� ������ �� ����� 3000 ��� � �����;
-- 213 801 ������ ��������� ����� �� ����� �� 3000 �� 8000 ������ ������������;
-- 120 874 ������� ��������� ������ �� ����� ����� 8000 ������.
-- ����� � ������� ������ 1 015 119 �������� (��� ��� �������. ������� �����).


-- ������ ��������������� ������������� � ���������� ���������. ������� ������ ���� ������.
drop view rfm_categories;
create or replace view rfm_categories as
select 
	distinct (concat(recency_code, frequency_code, monetary_code)) as rfm_category,
	(case 
		when concat(recency_code, frequency_code, monetary_code) in ('111', '112', '113') then 'Lost_random' 
		when concat(recency_code, frequency_code, monetary_code) in ('121', '122', '123', '131') then 'Lost_regular'
		when concat(recency_code, frequency_code, monetary_code) in ('132', '133') then 'Lost_VIP'
		when concat(recency_code, frequency_code, monetary_code) in ('211', '212', '213') then 'Random'
		when concat(recency_code, frequency_code, monetary_code) in ('221', '222', '223', '231') then 'Regular'
		when concat(recency_code, frequency_code, monetary_code) in ('232', '233') then 'VIP'
		when concat(recency_code, frequency_code, monetary_code) in ('311', '312', '313') then 'New_random'
		when concat(recency_code, frequency_code, monetary_code) in ('321', '322', '331') then 'New_regular'
		when concat(recency_code, frequency_code, monetary_code) in ('323', '332', '333') then 'New_VIP'
	end) as category_name
from rfm_analysis
order by rfm_category;

-- ���������� �������� ������ � �������� ���� ����������� �� ������� rfm:
select 
	category_name,
	count(client_id) as clients,
	sum(sales) as sales,
	sum(orders) as orders
from rfm_analysis
left join rfm_categories
on concat(recency_code, frequency_code, monetary_code) = rfm_category
group by rollup(category_name)
order by category_name;

select sum(price) from orders; -- 4 541 906 608
select count(distinct (user_id)) from orders; -- 1 015 119
select count(id_o) from orders; -- 2 002 804

-- ����� �� ��������, �������� � ���������� ������� ������.
-- ���������� ������� ���� ����� � sql �� ����. � ������ �������.


   