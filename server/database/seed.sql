USE subscription_management;
INSERT IGNORE INTO roles (id,name,permissions) VALUES
(1,'SUPER_ADMIN',JSON_ARRAY('*')),
(2,'ADMIN',JSON_ARRAY('customer.manage','product.manage','plan.manage','invoice.manage','payment.manage','reports.view')),
(3,'STAFF',JSON_ARRAY('customer.view','invoice.view','payment.manage')),
(4,'CUSTOMER',JSON_ARRAY('self.view'));

INSERT IGNORE INTO users (id,name,email,password_hash,role_id,status) VALUES
(1,'Brightloop Admin','admin@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',1,'active');
