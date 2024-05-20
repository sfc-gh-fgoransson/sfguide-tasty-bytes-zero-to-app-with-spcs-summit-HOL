USE DATABASE frostbyte_tasty_bytes;
USE SCHEMA APP;

CREATE ROLE tasty_app_admin_role;

GRANT ALL ON DATABASE frostbyte_tasty_bytes TO ROLE tasty_app_admin_role;
GRANT ALL ON SCHEMA frostbyte_tasty_bytes.app TO ROLE tasty_app_admin_role;
GRANT SELECT ON ALL TABLES IN SCHEMA frostbyte_tasty_bytes.app TO ROLE tasty_app_admin_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA frostbyte_tasty_bytes.app TO ROLE tasty_app_admin_role;

CREATE OR REPLACE WAREHOUSE tasty_app_warehouse WITH
WAREHOUSE_SIZE='X-SMALL'
AUTO_SUSPEND = 180
AUTO_RESUME = true
INITIALLY_SUSPENDED=false;

GRANT ALL ON WAREHOUSE tasty_app_warehouse TO ROLE tasty_app_admin_role;

CREATE COMPUTE POOL tasty_app_backend_compute_pool
MIN_NODES = 1
MAX_NODES = 1
INSTANCE_FAMILY = CPU_X64_S;

GRANT USAGE ON COMPUTE POOL tasty_app_backend_compute_pool TO ROLE tasty_app_admin_role;
GRANT MONITOR ON COMPUTE POOL tasty_app_backend_compute_pool TO ROLE tasty_app_admin_role;

CREATE COMPUTE POOL tasty_app_frontend_compute_pool
MIN_NODES = 1
MAX_NODES = 1
INSTANCE_FAMILY = CPU_X64_XS;

GRANT USAGE ON COMPUTE POOL tasty_app_frontend_compute_pool TO ROLE tasty_app_admin_role;
GRANT MONITOR ON COMPUTE POOL tasty_app_frontend_compute_pool TO ROLE tasty_app_admin_role;


-- Create security integration
CREATE SECURITY INTEGRATION "Application Authentication"
  TYPE=oauth
  OAUTH_CLIENT=snowservices_ingress
  ENABLED=true;

GRANT OWNERSHIP ON INTEGRATION "Application Authentication"
TO ROLE tasty_app_admin_role REVOKE CURRENT GRANTS;

GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE tasty_app_admin_role;

SET sql = ('GRANT ROLE tasty_app_admin_role TO USER ' || CURRENT_USER() || '');
EXECUTE IMMEDIATE $sql;
USE ROLE tasty_app_admin_role;

-- Create image repository  
CREATE OR REPLACE IMAGE REPOSITORY tasty_app_repository;
-- Show the repo we just created
SHOW IMAGE REPOSITORIES;
-- List images in repo (can be called later to verify that images have been pushed to the repo)
call system$registry_list_images('/frostbyte_tasty_bytes/app/tasty_app_repository');

-- Create a stage to hold service specification files
CREATE STAGE tasty_app_stage DIRECTORY = ( ENABLE = true );

-- Create Users table for the Website
create or replace table users (
	user_id number(38,0) autoincrement,
	user_name varchar(16777216) not null,
	hashed_password varchar(16777216),
	franchise_id number(38,0),
	password_date timestamp_ntz(9),
	status boolean,
	unique (user_name)
);

 -- Add Franchisee logins 
insert into users
    values
    (1,'user1','$2b$10$v0IoU/pokkiM13e.eayf1u3DkgtIBMGO1uRO2O.mlb2K2cLztV5vy',1,current_timestamp,TRUE), 
    (2,'user2','$2b$10$e2TXM/kLlazbH1xl31SeOe6RTyfL3E9mE8sZZsU33AE52rO.u44JC',120,current_timestamp,TRUE),
    (3,'user3','$2b$10$WX4e1LAC.rAabBJV58RuKerEK4T/U4htgXrmedTa5oiGCWIRHwe0e',271,current_timestamp,TRUE);

USE ROLE ACCOUNTADMIN;
CREATE ROLE tasty_app_ext_role;

GRANT USAGE ON DATABASE frostbyte_tasty_bytes TO ROLE tasty_app_ext_role;
GRANT USAGE ON SCHEMA frostbyte_tasty_bytes.app TO ROLE tasty_app_ext_role;


CREATE USER IF NOT EXISTS user1 PASSWORD='password1' MUST_CHANGE_PASSWORD=TRUE DEFAULT_ROLE=tasty_app_ext_role;
GRANT ROLE tasty_app_ext_role TO USER user1;

CREATE USER IF NOT EXISTS user2 PASSWORD='password120' MUST_CHANGE_PASSWORD=TRUE DEFAULT_ROLE=tasty_app_ext_role;
GRANT ROLE tasty_app_ext_role TO USER user2;

CREATE USER IF NOT EXISTS user3 PASSWORD='password270' MUST_CHANGE_PASSWORD=TRUE DEFAULT_ROLE=tasty_app_ext_role;
GRANT ROLE tasty_app_ext_role TO USER user3;

