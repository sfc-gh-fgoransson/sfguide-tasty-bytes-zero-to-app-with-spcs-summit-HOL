USE DATABASE FROSTBYTE_TASTY_BYTES;
USE SCHEMA APP;
USE ROLE tasty_app_admin_role;

SHOW IMAGE REPOSITORIES;

call system$registry_list_images('/frostbyte_tasty_bytes/app/tasty_app_repository');