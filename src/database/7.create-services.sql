USE DATABASE FROSTBYTE_TASTY_BYTES;
USE SCHEMA APP;
USE ROLE tasty_app_admin_role;

CREATE SERVICE backend_service
  IN COMPUTE POOL tasty_app_backend_compute_pool
  FROM SPECIFICATION $$
spec:
  container:
  - name: backend
    image: /frostbyte_tasty_bytes/app/tasty_app_repository/backend_service_image:tutorial
    env:
      PORT: 3000
      ACCESS_TOKEN_SECRET: aöldjflösdjflö
      REFRESH_TOKEN_SECRET: öwejmfölmeswflö
      CLIENT_VALIDATION: Snowflake
  endpoint:
  - name: apiendpoint
    port: 3000
    public: true
$$
  MIN_INSTANCES=1
  MAX_INSTANCES=1
;
GRANT USAGE ON SERVICE backend_service TO ROLE tasty_app_ext_role;


SELECT SYSTEM$GET_SERVICE_STATUS('backend_service'); 

CALL SYSTEM$GET_SERVICE_LOGS('backend_service', '0', 'backend', 50);


CREATE SERVICE frontend_service
  IN COMPUTE POOL tasty_app_frontend_compute_pool
  FROM SPECIFICATION $$
spec:
  container:
  - name: frontend
    image: /frostbyte_tasty_bytes/app/tasty_app_repository/frontend_service_image:tutorial
    env:    
      PORT: 4000
      FRONTEND_SERVICE_PORT: 4000
      REACT_APP_BACKEND_SERVICE_URL: /api
      REACT_APP_CLIENT_VALIDATION: Snowflake
  - name: router
    image: /frostbyte_tasty_bytes/app/tasty_app_repository/router_service_image:tutorial
    env:
      FRONTEND_SERVICE: localhost:4000
      BACKEND_SERVICE: backend-service:3000
  endpoint:
  - name: routerendpoint
    port: 8000
    public: true
$$
  MIN_INSTANCES=1
  MAX_INSTANCES=1
;
GRANT USAGE ON SERVICE frontend_service TO ROLE tasty_app_ext_role;

SELECT SYSTEM$GET_SERVICE_STATUS('frontend_service'); 
CALL SYSTEM$GET_SERVICE_LOGS('frontend_service', '0', 'frontend', 50);
CALL SYSTEM$GET_SERVICE_LOGS('frontend_service', '0', 'router', 50);

SHOW ENDPOINTS IN SERVICE frontend_service;
