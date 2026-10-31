USE subscription_management;
INSERT IGNORE INTO roles (id,name,description,is_system) VALUES
(1,'SUPER_ADMIN','Full system administrator',TRUE),
(2,'ADMIN','Business administrator',TRUE),
(3,'STAFF','Internal operations staff',TRUE),
(4,'CUSTOMER','Customer portal account',TRUE);

INSERT IGNORE INTO users (id,name,email,password_hash,role_id,status) VALUES
(1,'Brightloop Admin','admin@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',1,'active');
