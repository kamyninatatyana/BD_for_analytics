-- Äàíû 2 òàáëèöû:
-- Òàáëèöà êëèåíòîâ clients, â êîòîğîé íàõîäÿòñÿ äàííûå ïî êàğòî÷íîìó ëèìèòó êàæäîãî êëèåíòà
-- clients
-- id_client (primary key) number,
-- limit_sum number

DROP TABLE IF EXISTS clients;
CREATE TABLE clients (
  id_client SERIAL PRIMARY KEY,
  limit_sum INTEGER
  );

-- transactions
-- id_transaction (primary key) number,
-- id_client (foreign key) number,
-- transaction_date number,
-- transaction_time number,
-- transaction_sum number

DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
  id_transaction SERIAL PRIMARY KEY,
  id_client INTEGER,
  transaction_date DATE,
  transaction_time TIME,
  transaction_sum numeric,
  FOREIGN KEY (id_client) REFERENCES clients(id_client));
 
 INSERT INTO clients 
	(limit_sum)
VALUES
	(100000),
	(50000),
	(10000);
	
SELECT * FROM clients;  
 
      
INSERT INTO transactions 
	(id_client, transaction_date, transaction_time, transaction_sum)
VALUES
	(random()*(3-1)+1, (date '2019-01-01' + CAST((random()*(365*2 - 1) + 1) as INTEGER)), make_time(CAST((random()*(23 - 1) + 1) as INTEGER), CAST((random()*(60 - 1) + 1) as INTEGER), CAST((random()*(60 - 1) + 1) as INTEGER)), round(cast((random()*(10000-500)+500) as numeric),2));
	
SELECT * FROM transactions;


-- Çàäàíèå 1: Íàïèñàòü òåêñò SQL-çàïğîñà, âûâîäÿùåãî êîëè÷åñòâî òğàíçàêöèé, ñóììó òğàíçàêöèé, ñğåäíşş ñóììó 
-- òğàíçàêöèè è äàòó è âğåìÿ ïåğâîé òğàíçàêöèè äëÿ êàæäîãî êëèåíòà

select 
	id_client as client_id,
	count(id_transaction) as num_of_trans,
	sum(transaction_sum) as sum_total,
	round(cast(avg(transaction_sum) as numeric), 2) as avg_sum,
	min(concat(transaction_date, ' ', transaction_time)) as first_day_and_time
from transactions 
group by id_client
order by id_client; 


-- Çàäàíèå 2: Íàéòè id ïîëüçîâàòåëåé, êîò èñïîëüçîâàëè áîëåå 70% êàğòî÷íîãî ëèìèòà
select 
	client_id,
	sum_total,
	limit_sum
from 
	(select 
		transactions.id_client as client_id,
		sum(transaction_sum) as sum_total,
		clients.limit_sum as limit_sum
	from transactions 
	left join clients 
	on transactions.id_client = clients.id_client
	group by transactions.id_client, clients.limit_sum 
	order by transactions.id_client) as foo
where sum_total > limit_sum * 0.7; 
