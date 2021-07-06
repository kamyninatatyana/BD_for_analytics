-- ЗАДАНИЕ 1. 
-- Залить в свою БД данные по продажам и проверить возможные ошибки в данных.

select * from orders;

-- В таблице 4 столбца - id заказа, id пользователя, цена, дата заказа.
select count(*) from orders; -- в таблицe 2 002 804 записи
-- Поскольку я в начале создала таблицу с полями, чей формат изначально прописала, а ошибок при импорте не 
-- возникло, считаю, что ошибок по некорректном формату нет.

-- Посмотрим минимальные и максимальные значения по каждому из столбцов. 

-- Нумерация заказов:
select min(id_o) from orders; -- 1 234 491
select max(id_o) from orders; -- 6 945 534
select (max(id_o) - min(id_o))/2002804 as increment_step  from orders; -- средний инкремент номера 
-- заказа 2. Хотя он не является абсолютным и колеблется, как мне показалось, от 1 до 3. С чем это связано 
-- не увидела. Считаю, что в этом столбце ошибок нет.

-- Нумерация пользователей:
select min(user_id) from orders; -- 0
select max(user_id) from orders; -- 5 919 156
-- безусловно, user_id = 0 это не есть правильно. Но таких записей:
select count(user_id) from orders where user_id=0; -- всего одна, поэтому этой ошибкой можно пренебречь.
-- Но все таки интересно, с какого номера начинается нумерация пользователей:
select user_id from orders where user_id < 100; -- c 1, а затем 76, а потом 90... Никаких выводов сделать особо 
-- не могу. Думаю, так вполне может быть - старые клиенты потихоньку отваливаются. 
select count(user_id) from orders where user_id > 4000000; -- тоже каких-то особых провалов в нумерации не вижу.
-- Считаю, что в этом столбце нет значимых ошибок.

-- Цена:
select min(price) from orders; -- минимальная цена (- 184)! Наконец-то хоть какой-то косяк.
select max(price) from orders; -- максимальная цена 819 096. Я думаю, это тоже косяк.  
-- Проверим, сколько таких косячных записей:
select count(price) from orders where price < 0; -- таких 6 записей.
-- Для проверки максимальных значений вначале посчитаем средний чек по заказу:
select AVG(price) from orders; -- средний чек по 1 заказу 2 267 уе.
-- Думаю, все что выше средний чек х 100 точно можно отнести к некорректным данным:
select price from orders where price > 200000; -- таких записей 9
select price from orders where price > 100000; -- а таких 64.
-- сложно сказать, что нужно взять за границу отсечения. Нужно все-таки понимать, о каком товаре идет речь. 
-- Если это (я правильно поняла?) интернет магазин дочек-сыночек то я бы, наверное, выкинула бы все, что выше 
-- 100 тыс. уе.

-- !!! Не было сказано, что делать с некорректными данным. Я бы их выкинула. Не стала бы их править. 
-- По сравнению со всей выборкой их незначительное количество. Но с другой стороны, возможно, когда данные качаются 
-- автоматически - неправильно выкидывать данные? Можно же сделать автоматическую коррекцию и такие вылеты на что-то сразу
-- заменять. В общем, хотелось бы знать, как правильно поступить. Пока не стала трогать.

-- Дата:
select min(o_date) from orders; -- 01.01.2016
select max(o_date) from orders; -- 31.12.2017
select * from 
	(select EXTRACT(month FROM o_date) as month_by, 
			EXTRACT(year FROM o_date) as year_by, 
			count(*) as Num_of_orders
		from orders group by month_by, year_by) as foo 
	order by year_by, month_by;	
-- данные представлены в каждом месяце рассматриваемого периода. Считаю что и в этом столбце ошибок нет.
-- С данными можно работать.

-- ЗАДАНИЕ 2. 
-- Проанализировать, какой период данных выгружен
-- Как мы уже выяснили выше данные выгружены за период с 01.01.2016 по 31.12.2017

-- ЗАДАНИЕ 3. 
-- Посчитать кол-во строк, кол-во заказов и кол-во уникальных пользователей, кот совершали заказы.
select count(*) from orders; -- в таблице 2 002 804 записи
select COUNT(distinct id_o) from orders -- 2 002 804 заказа;
select count(distinct user_id) from orders -- 1 015 119 уникальных пользователя;

-- ЗАДАНИЕ 4. 
-- По годам и месяцам посчитать средний чек, среднее кол-во заказов на пользователя, сделать вывод , 
-- как изменялись это показатели Год от года.

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

-- При анализе данных год к году мы видим:
-- 1. Общие продажи в деньгах выросли на 52%, при этом количество заказов выросло только на 33%. То есть растет 
-- средняя стоимость заказа (Средняя стоимость заказа выросла на 14%).
-- 2. Количество покупателей выросло на 47%, при этом количество заказов выросло только на 33%, что говорит о
-- том, что покупатели стали покупать реже (Количество заказов на 1 покупателя снизилось на 10%).
-- 3. Продажи на одного клиента выросли незначительно (всего лишь 3%).
-- Общие выводы: 
-- 1. Умеем привлекать новых клиентов. Это хорошо. 
-- 2. У нас снизилось количество заказов на каждого клиента, но при этом оборот по каждому клиенту не снизился 
-- (даже вырос на 3%) по каждому клиенту. Это хорошо. Так как, возможно, это значит снижением издержек на 
-- сопровождение (чем меньше заказов тем меньше тратим на их обработку и подготовку), а значит, возможно, у нас 
-- повысилась общая доходность. Этот вывод нужно проверять. 
-- 3. И все же мне не нравится практически отсутствие роста продаж на 1 клиента. 3% - это точно ниже уровня инфляции,
-- а значит продажи на одного клиента не растут, а падают!!! И это очень плохо. Нужно искать причину.

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

-- При анализе данных месяц к месяцу мы видим подтверждение наших выводов по году:
-- 1. Средняя стоимость заказа в 2017 году по отношению к 2016 году выросла от 8 до 23% в зависимости
-- от месяца. Самый высокий прирост средней стоимости заказа мы видим в марте, июне и июле. А самый низкий - 
-- в феврале. 
-- 2. При этом количество заказов на 1 пользователя упало на 2 - 13%. Самое сильное падение - в августе. 
-- Меньше всего показатель количества заказов на одного клиента снизился в январе. 


-- ЗАДАНИЕ 5. 
-- Найти кол-во пользователей, кот покупали в одном году и перестали покупать в следующем.

-- Было покупателей в 2016 году:
select 
	count(*)
from
	(select 
		DISTINCT(user_id) AS user_id,
		COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2016 THEN id_o END)) AS orders_2016
	from orders
	group by user_id) as foo
	where orders_2016 > 0;

-- Перестало покупать в 2017 году:
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

-- Стало покупателей в 2017 году:
select 
	count(*)
from
	(select 
		DISTINCT(user_id) AS user_id,
		COUNT(DISTINCT(CASE WHEN EXTRACT(YEAR FROM o_date) = 2017 THEN id_o END)) AS orders_2017
	from orders
	group by user_id) as foo
	where orders_2017 > 0;

-- Выводы: 
-- 1. Всего в 2016 году было 445 092 уникальных покупателя.
-- 2. Из них 360 225 перестали покупать в 2017.
-- 3. А 570 027 появилось новых в 2017 году.
-- 4. Таким образом в 2017 г. было 654 894 покупателя (по запросу). Или 445 092 - 360 225 + 570 027 = 654 894
-- Вообще, конечно, ситуация при которой более 80% покупателей перестали покупать продукцию - должна напрячь и 
-- потребовать дополнительных исследований.

-- ЗАДАНИЕ 6. 
-- Найти ID самого активного по кол-ву покупок пользователя.

select user_id from orders group by user_id order by count(*) desc, user_id desc limit 1; -- id пользователя, 
-- который покупает чаще всех 765 861
select user_id, count(*) from orders where user_id = 765861 group by user_id; -- пользователь с id 765 861 совершил
-- 3 183 покупки. А такое может быть? Я просто не думала, что в интернет магазине могут заказывать не конечные 
-- покупатели. Так может быть если это какой-то оптовик, наверное... Но по 4 заказа в день и каждый день??? Хотелось бы
-- конечно понимать структуру клиентов.
  
-- ЗАДАНИЕ 7. 
-- Найти коэффициенты сезонности по месяцам.

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

-- В 2016 году максимальные продажи были в ноябре и декабре (коэффициент сезонности 1,71 и 1,72 соответственно),
-- а минимальные - в январе и феврале (коэффициент сезонности 0,64 и 0,63).  

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

-- В 2017 году динамика коэффициента сезонности по месяцам более сглаженная - и не смотря на то, что 
-- минимальные продажи по прежнему приходятся на январь и февраль, коэффициент сезонности в эти месяцы
-- составляет 0.78 и 0.71. Аналогичная ситуация с ноябрем и декабрем, да, в эти месяцы продажи по-прежнему
-- максимальные, но коэффициент сезонности уже 1.43 и 1.63. Это хорошо.

