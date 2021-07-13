-- HW_03
-- Если я правильно поняла суть задания - то нужно спрогнозировать продажи в рублях, но не "сверху", как мы 
-- делали в предыдущем задании, а "снизу", от клиента.
-- Для этого нам необходимо выделить группы клиентов, в разрезе которых будем производить планирование.
-- Если честно - я не поняла, зачем выделять группы с 3 покупками, неважно когда они покупали. Обе эти группы столь
-- незначительные с точки зрения планирования ТО, что у нас в итоге получится две капли и большое море из всего 
-- остального. У меня получилось что речь идет об 1-2%... Может я где косячу?
-- В общем я сделала так:
-- 1. Новые клиенты.
-- 2. Существующие клиенты.


-- Общая информация, которая нам, возможно, понадобится:

-- 1. Периодичность совершения покупок. 

select 
	EXTRACT(MONTH FROM o_date) AS month_by,
	EXTRACT(year FROM o_date) AS year_by,
	count(id_o) as orders,
	count(distinct(user_id)) as users,
	round((cast(count(id_o) as decimal) / cast(count(distinct(user_id)) as decimal)),2) as orders_per_user,
	sum(price) as sales
from orders
group by year_by, month_by;

-- 2. Жизненный цикл клиента.

-- Создадим представление, в котором посчитаем жизненный цикл (разница в днях между последним и первым заказом)
-- клиента. А затем на основании этих данных проведем группировку клиентов. 

drop view client_life_cycle;
create or replace view client_life_cycle as
select 
	distinct(user_id) as client,
	max(o_date) as last_purchase,
	extract(year from max(o_date)) * 100 + extract(month from max(o_date)) as lst_purch_month, 
	min(o_date) as first_purchase,
	extract (year from min(o_date)) * 100 + extract(month from min(o_date)) as frst_purch_month, 
	max(o_date) - min(o_date) as client_life_cycle,
	sum(price) as sales,
	count(id_o) as orders
from orders
group by user_id;

select * from client_life_cycle; 

-- Новые клиенты: группируем по месяцу первой покупки.

select 
	frst_purch_month,
	count(distinct(client)) as clients_frst_time,
	sum(sales) as sales
from client_life_cycle
group by frst_purch_month 
order by frst_purch_month;

-- Существующие клиенты:

drop view current_clients;
create or replace view current_clients as
select 
	distinct(user_id) as client,
	extract(year from o_date) * 100 + extract(month from o_date) as purch_month, 
	sum(price) as sales,
	count(id_o) as orders
from orders
group by user_id, o_date ;

select * from current_clients;

select 
	purch_month,
	count(distinct(cc.client)) as clients,
	sum(cc.sales) as sales
from current_clients as cc
left join client_life_cycle as clc
on cc.client = clc.client where purch_month > frst_purch_month
group by purch_month 
order by purch_month;
