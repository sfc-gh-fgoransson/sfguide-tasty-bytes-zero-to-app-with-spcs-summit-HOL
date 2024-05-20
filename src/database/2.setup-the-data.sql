--change role to accountadmin
use role accountadmin;

--create a virtual warehouse for data exploration
create or replace warehouse query_wh with 
	warehouse_size = 'medium' 
	warehouse_type = 'standard' 
	auto_suspend = 300 
	auto_resume = true 
	min_cluster_count = 1 
	max_cluster_count = 1 
	scaling_policy = 'standard';

--create the application database and schema
create or replace database frostbyte_tasty_bytes;
create or replace schema app;

--create table structure for order data 
create or replace table orders (
	order_id number(38,0),
	truck_id number(38,0),
	order_ts timestamp_ntz(9),
	order_detail_id number(38,0),
	line_number number(38,0),
	truck_brand_name varchar(16777216),
	menu_type varchar(16777216),
	primary_city varchar(16777216),
	region varchar(16777216),
	country varchar(16777216),
	franchise_flag number(38,0),
	franchise_id number(38,0),
	franchisee_first_name varchar(16777216),
	franchisee_last_name varchar(16777216),
	location_id number(19,0),
	customer_id number(38,0),
	first_name varchar(16777216),
	last_name varchar(16777216),
	e_mail varchar(16777216),
	phone_number varchar(16777216),
	children_count varchar(16777216),
	gender varchar(16777216),
	marital_status varchar(16777216),
	menu_item_id number(38,0),
	menu_item_name varchar(16777216),
	quantity number(5,0),
	unit_price number(38,4),
	price number(38,4),
	order_amount number(38,4),
	order_tax_amount varchar(16777216),
	order_discount_amount varchar(16777216),
	order_total number(38,4)
);

--create a virtual warehouse for data loading
create or replace warehouse load_wh with 
	warehouse_size = 'large' 
	warehouse_type = 'standard' 
	auto_suspend = 300 
	auto_resume = true 
	min_cluster_count = 1 
	max_cluster_count = 1 
	scaling_policy = 'standard';

--create stage for loading orders data
create or replace stage tasty_bytes_app_stage
	url = 's3://sfquickstarts/frostbyte_tastybytes/app/orders/';

--copy data into orders table using the load wh
 copy into orders from @tasty_bytes_app_stage;

--change our Virtual Warehouse context to use our query_wh
 use warehouse query_wh;

 --simple query to look at 10 rows of data 
select * from orders limit 10;

--query to count all records in the table
select count(*) from orders;

--sales by month
select month(order_ts),monthname(order_ts), sum(price)
from orders 
group by month(order_ts), monthname(order_ts)
order by month(order_ts);


