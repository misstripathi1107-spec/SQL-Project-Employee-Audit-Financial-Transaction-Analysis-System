use my_sql;
CREATE TABLE employees (
employee_id INT PRIMARY KEY,
employee_name VARCHAR(100),
designation VARCHAR(50),
department VARCHAR(50)
);

CREATE TABLE bank_transactions (
transaction_id INT PRIMARY KEY,
employee_id INT,
transaction_date DATE,
amount DECIMAL(12,2),
debit_credit ENUM('Dr','Cr'),
counterparty_name VARCHAR(100),
transaction_mode VARCHAR(20),
FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE loan_details (
loan_id INT PRIMARY KEY,
employee_id INT,
nbfc_name VARCHAR(100),
loan_amount DECIMAL(12,2),
monthly_emi DECIMAL(12,2),
FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE client_master (
client_id INT PRIMARY KEY,
client_name VARCHAR(100)
);

INSERT INTO employees VALUES
(101,'Rajesh Kumar','Senior Executive','MIS'),
(102,'Ankit Verma','Executive','Operations'),
(103,'Pooja Sharma','Executive','Finance'),
(104,'Suresh Patel','Assistant Manager','Audit'),
(105,'Neha Singh','Senior Executive','MIS');
select * from employees;
INSERT INTO bank_transactions VALUES
(1,101,'2024-06-01',50000,'Dr','Anup Sharma','UPI'),
(2,101,'2024-06-05',200000,'Dr','XYZ Traders','NEFT'),
(3,101,'2024-06-10',150000,'Cr','Salary','IMPS'),
(4,102,'2024-06-03',80000,'Dr','Gopal','UPI'),
(5,102,'2024-06-15',120000,'Cr','Client A','NEFT'),
(6,103,'2024-06-07',300000,'Dr','Kalimuth','RTGS'),
(7,103,'2024-06-20',100000,'Cr','Salary','IMPS'),
(8,104,'2024-06-08',450000,'Dr','Client B','NEFT'),
(9,104,'2024-06-25',200000,'Cr','Salary','IMPS'),
(10,105,'2024-06-12',90000,'Dr','Yuvaraj','UPI');
select * from bank_transactions;
INSERT INTO loan_details VALUES
(1,101,'KreditBee',200000,8500),
(2,101,'Northern Arc',300000,12000),
(3,101,'Poonawalla',250000,9500),
(4,102,'KreditBee',150000,6500),
(5,103,'Poonawalla',400000,15000),
(6,103,'Northern Arc',350000,14000),
(7,103,'KreditBee',180000,7200);
select * from loan_details;
INSERT INTO client_master VALUES
(1,'Client A'),
(2,'Client B'),
(3,'XYZ Traders');
select * from client_master;
-- Advanced MySQL SQL (CTEs)
WITH tx_summary AS (select
employee_id, COUNT(*) AS total_txn,
SUM(amount) AS total_amount
from bank_transactions
group by employee_id),
loan_summary AS (select employee_id,
count(*) As loan_count
from loan_details
group by employee_id)
select e.employee_id, e.employee_name,
ifnull(ts.total_txn,0) as total_txns,
ifnull(ts.total_amount,0) as total_amount,
ifnull(ls.loan_count,0) as loan_count from employees e
left join tx_summary ts on e.employee_id = ts.employee_id
left join loan_summary ls on e.employee_id = ls.employee_id
where ts.total_amount > 300000 or ls.loan_count >=3;
-- Running Transaction Total (Window Function)
select employee_id, transaction_date, amount,
sum(amount) over(partition by employee_id order by transaction_date) as running_total
from bank_transactions;
-- Rank High-Value Transactions
select employee_id, transaction_id, amount,
rank() over(partition by employee_id order by amount) as txn_rank from bank_transactions;
select bt.employee_id, bt.counterparty_name, bt.amount,
case 
when cm.client_name is not null then 'Conflict Risk'
else 'Normal'
end as audit_flag
from bank_transactions bt
left join client_master cm on bt.counterparty_name = cm.client_name;
