-- Run this script as the itonics_owner user you created in the first script
-- It creates the database and table required by the lambda
-- It also inserts a record for testing purposes

CREATE DATABASE itonics  
  WITH OWNER = itonics_owner  	   
       ENCODING = 'UTF8'
       LC_COLLATE = 'en_US.utf8'
       LC_CTYPE = 'en_US.utf8'
       CONNECTION LIMIT = -1
       TEMPLATE template0;

CREATE TABLE messages (
  message_id varchar NOT NULL,
  message text NOT NULL,
  CONSTRAINT message_pk PRIMARY KEY (message_id)
);

INSERT INTO messages
  (message_id, message)
VALUES('helloWorld', 'Hello world!');