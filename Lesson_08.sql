-- ДЗ делаем по бд orders
-- В качестве ДЗ сделаем карту поведения пользователей. Мы обсуждали, что всех пользователей можно разделить, 
-- к примеру, на New (совершили только 1 покупку, не более 3 месяцев назад), Regular (совершили 2 или более на 
-- сумму не более стольки-то не более 3 месяцев), Vip (совершили дорогие покупки и достаточно часто , не более 3 
-- месяцев назад), Lost (раньше покупали хотя бы раз и с даты последней покупки прошло больше 3 месяцев). Вся 
-- база должна войти в эти гурппы (т.е. каждый пользователь должен попадать только в одну из этих групп).

-- Задача:
-- 1. Уточнить критерии групп New,Regular,Vip,Lost
-- 2. По состоянию на 1.01.2017 понимаем, кто попадает в какую группу, подсчитываем кол-во пользователей в каждой.

-- Вспомогательное представление для распределения клиентов по группам: 

drop view rfm_analysis;
create or replace view rfm_analysis as
SELECT 
   	user_id as client_id,
   	max(o_date) as last_purch,
   	count(id_o) as orders,
   	sum(price) as sales,
   	'2016-12-31' - max(o_date) as recency,
   	case
   		when'2016-12-31' - max(o_date) <= 30 then 3
   		when '2016-12-31' - max(o_date) > 30 and '2016-12-31' - max(o_date) <= 60 then 2
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

select * from rfm_analysis ra ;

-- Вспомогательная выборка для определения диапазонов для критерия frequency (делала разные диапазоны,
-- смотрела распределение по ним - в итоге пришла к тем, что указаны в выборке).

select 
	count(case when orders in (1) then client_id end) as range1,
	count(case when orders in (2,3) then client_id end) as range2,
	count(case when orders >= 4 then client_id end) as range3
from rfm_analysis;

-- 1 заказ за весь период у 774 497 клиентов;
-- 2 или 3 заказа за весь период у 147 766 клиентов;
-- более 4 заказов за весь период у 92 856 клиентов.
-- Всего в выборку попали 1 015 119 клиентов (это все клиенты. выборка верна).

-- Вспомогательная выборка для определения диапазонов для критерия monetary (делала разные диапазоны,
-- смотрела распределение по ним - в итоге пришла к тем, что указаны в выборке).

select 
	count(case when sales <= 3000 then client_id end) as range1,
	count(case when sales > 3000 and sales <= 8000 then client_id end) as range2,
	count(case when sales > 8000 then client_id end) as range3
from rfm_analysis;

-- 680 444 клиентов приобрели товара на сумму 3000 руб и менее;
-- 213 801 клиент приобрели товар на сумму от 3000 до 8000 рублей включительно;
-- 120 874 клиента приобрели товара на сумму более 8000 рублей.
-- Всего в выборку попали 1 015 119 клиентов (это все клиенты. выборка верна).


-- создам вспомогательное представление с названиями категорий. таблицу дольше было делать.
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

-- собственно итоговый запрос с расчетом всех показателей по группам rfm:
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

-- итоги по клиентам, продажам и количеству заказов бьются.


-- 3. По состоянию на 1.02.2017 понимаем, кто вышел из каждой из групп, а кто вошел.

drop view rfm_analysis;
create or replace view rfm_analysis as
SELECT 
   	user_id as client_id,
   	max(o_date) as last_purch,
   	count(id_o) as orders,
   	sum(price) as sales,
   	'2017-01-31' - max(o_date) as recency,
   	case
   		when'2017-01-31' - max(o_date) <= 30 then 3
   		when '2017-01-31' - max(o_date) > 30 and '2017-01-31' - max(o_date) <= 60 then 2
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

-- 4. Аналогично смотрим состояние на 1.03.2017, понимаем кто вышел из каждой из групп, а кто вошел.

drop view rfm_analysis;
create or replace view rfm_analysis as
SELECT 
   	user_id as client_id,
   	max(o_date) as last_purch,
   	count(id_o) as orders,
   	sum(price) as sales,
   	'2017-02-28' - max(o_date) as recency,
   	case
   		when'2017-02-28' - max(o_date) <= 30 then 3
   		when '2017-02-28' - max(o_date) > 30 and '2017-02-28' - max(o_date) <= 60 then 2
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
-- 5. В итоге делаем вывод, какая группа уменьшается, какая увеличивается и продумываем, в чем может быть причина.

Присылайте отчет в pdf
