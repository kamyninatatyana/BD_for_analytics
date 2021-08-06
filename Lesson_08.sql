-- ƒ« делаем по бд orders
-- ¬ качестве ƒ« сделаем карту поведени€ пользователей. ћы обсуждали, что всех пользователей можно разделить, 
-- к примеру, на New (совершили только 1 покупку, не более 3 мес€цев назад), Regular (совершили 2 или более на 
-- сумму не более стольки-то не более 3 мес€цев), Vip (совершили дорогие покупки и достаточно часто , не более 3 
-- мес€цев назад), Lost (раньше покупали хот€ бы раз и с даты последней покупки прошло больше 3 мес€цев). ¬с€ 
-- база должна войти в эти гурппы (т.е. каждый пользователь должен попадать только в одну из этих групп).

-- «адача:
-- 1. ”точнить критерии групп New,Regular,Vip,Lost
-- 2. ѕо состо€нию на 1.01.2017 понимаем, кто попадает в какую группу, подсчитываем кол-во пользователей в каждой.
-- 3. ѕо состо€нию на 1.02.2017 понимаем, кто вышел из каждой из групп, а кто вошел.
-- 4. јналогично смотрим состо€ние на 1.03.2017, понимаем кто вышел из каждой из групп, а кто вошел.

-- ¬спомогательное представление дл€ распределени€ клиентов по группам: 

drop view rfm_analysis;
create or replace view rfm_analysis as
SELECT 
   	user_id as client_id,
   	max(o_date) as last_purch,
   	count(id_o) as orders,
   	sum(price) as sales,
   	'2017-02-28' - max(o_date) as recency,
   	case
   		when '2017-02-28' - max(o_date) <= 30 then 3
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
where o_date < '2017-02-28'
group by user_id;   

select * from rfm_analysis ra ;

-- ¬спомогательна€ выборка дл€ определени€ диапазонов дл€ критери€ frequency (делала разные диапазоны,
-- смотрела распределение по ним - в итоге пришла к тем, что указаны в выборке).

select 
	count(case when orders in (1) then client_id end) as range1,
	count(case when orders in (2,3) then client_id end) as range2,
	count(case when orders >= 4 then client_id end) as range3
from rfm_analysis;

-- ¬спомогательна€ выборка дл€ определени€ диапазонов дл€ критери€ monetary (делала разные диапазоны,
-- смотрела распределение по ним - в итоге пришла к тем, что указаны в выборке).

select 
	count(case when sales <= 3000 then client_id end) as range1,
	count(case when sales > 3000 and sales <= 8000 then client_id end) as range2,
	count(case when sales > 8000 then client_id end) as range3
from rfm_analysis;

-- создам вспомогательное представление с названи€ми категорий. таблицу дольше было делать.
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

select count(distinct (user_id)) from orders where o_date < '2017-01-01'; -- 445 092






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
-- 5. ¬ итоге делаем вывод, кака€ группа уменьшаетс€, кака€ увеличиваетс€ и продумываем, в чем может быть причина.

ѕрисылайте отчет в pdf
