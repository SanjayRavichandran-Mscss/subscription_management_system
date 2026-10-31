USE subscription_management;
INSERT IGNORE INTO roles (id,name,description,is_system) VALUES
(1,'SUPER_ADMIN','Full system administrator',TRUE),
(2,'ADMIN','Business administrator',TRUE),
(3,'STAFF','Internal operations staff',TRUE),
(4,'CUSTOMER','Customer portal account',TRUE);

INSERT IGNORE INTO users (id,name,email,password_hash,role_id,status) VALUES
(1,'Brightloop Admin','admin@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',1,'active');

INSERT IGNORE INTO users (id,name,email,password_hash,role_id,status) VALUES
(5,'Neha Kapoor','neha.kapoor@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',2,'active'),
(6,'Rohan Nair','rohan.nair@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',3,'active'),
(7,'Ananya Iyer','ananya@example.com','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',4,'active'),
(8,'Vikram Singh','vikram@example.com','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',4,'active');

INSERT IGNORE INTO customers (id,user_id,name,company,email,phone,tax_id,billing_address,status) VALUES
(4,7,'Ananya Iyer','Nova Analytics Pvt Ltd','ananya@example.com','+91 98110 34567','27AABCN4412R1Z8','Hyderabad, Telangana, India','active'),
(5,8,'Vikram Singh','Vikram & Sons Logistics','vikram@example.com','+91 98990 78123','27AALFV5567M1Z3','Delhi NCR, India','active'),
(6,NULL,'Fatima Khan','UrbanDesk Interiors','fatima@urbandesk.example','+91 99876 21450','27AAACU2219K1Z1','Chennai, Tamil Nadu, India','active'),
(7,NULL,'Arjun Technologies','Arjun Technologies LLP','accounts@arjun.example','+91 98700 44112','29AADCA8841P1Z5','Bengaluru, Karnataka, India','active'),
(8,NULL,'GreenLeaf Foods','GreenLeaf Foods India','finance@greenleaf.example','+91 97654 22109','27AABCG7611H1Z6','Ahmedabad, Gujarat, India','active'),
(9,NULL,'Northstar Education','Northstar Education Trust','billing@northstar.example','+91 99555 11880','07AAATN7610Q1Z2','New Delhi, India','active');

INSERT IGNORE INTO categories (id,name,parent_id,status) VALUES
(5,'Security',NULL,'active'),(6,'Analytics',1,'active'),(7,'Professional Services',NULL,'active');
INSERT IGNORE INTO products (id,category_id,name,sku,product_type,price,cost_price,notes,status) VALUES
(4,6,'Revenue Intelligence','BI-REV','service',1800.00,600.00,'Executive revenue and renewal analytics','active'),
(5,5,'Security Operations','SEC-OPS','service',3200.00,1100.00,'Security monitoring and compliance support','active'),
(6,7,'Implementation Services','PRO-IMPL','service',6500.00,3200.00,'Onboarding and ERP implementation services','active');
INSERT IGNORE INTO subscription_plans (id,product_id,name,billing_cycle,billing_interval,price,trial_days,status) VALUES
(5,4,'Analytics Monthly','monthly',1,1800.00,14,'active'),
(6,5,'Security Operations Quarterly','quarterly',1,9600.00,30,'active'),
(7,6,'Implementation One Time','yearly',1,6500.00,0,'active');

INSERT IGNORE INTO subscriptions (id,number,customer_id,plan_id,status,unit_price,quantity,starts_at,next_billing_at) VALUES
(4,'SUB-2026-0004',4,5,'active',1800.00,1,'2026-03-01','2026-11-01'),
(5,'SUB-2026-0005',5,6,'active',9600.00,1,'2026-04-15','2027-01-15'),
(6,'SUB-2026-0006',6,1,'active',1998.00,2,'2026-05-01','2026-11-01'),
(7,'SUB-2026-0007',7,4,'paused',750.00,4,'2026-06-01','2026-11-01'),
(8,'SUB-2026-0008',8,5,'trial',1800.00,1,'2026-10-15','2026-11-15'),
(9,'SUB-2026-0009',9,3,'expired',2500.00,1,'2025-08-01','2026-08-01');

INSERT IGNORE INTO billing_runs (id,period_start,period_end,status,invoices_generated) VALUES
(3,'2026-10-01','2026-10-31','completed',6),(4,'2026-11-01','2026-11-30','processing',0);
INSERT IGNORE INTO invoices (id,number,customer_id,subscription_id,billing_run_id,subtotal,tax_amount,discount_amount,total,amount_paid,status,issued_at,due_at) VALUES
(4,'INV-2026-1004',4,4,3,1800.00,324.00,0.00,2124.00,2124.00,'paid','2026-10-03','2026-10-18'),
(5,'INV-2026-1005',5,5,3,9600.00,1728.00,500.00,10828.00,10828.00,'paid','2026-10-04','2026-10-19'),
(6,'INV-2026-1006',6,6,3,1998.00,359.64,0.00,2357.64,2357.64,'paid','2026-10-05','2026-10-20'),
(7,'INV-2026-1007',7,7,3,3000.00,540.00,0.00,3540.00,1500.00,'partially_paid','2026-10-08','2026-10-23'),
(8,'INV-2026-1008',8,8,NULL,1800.00,324.00,180.00,1944.00,0.00,'issued','2026-10-22','2026-11-06'),
(9,'INV-2026-1009',9,9,NULL,2500.00,450.00,0.00,2950.00,2950.00,'overdue','2026-09-01','2026-09-16');

INSERT IGNORE INTO invoice_items (invoice_id,description,quantity,unit_price,tax_rate,line_total) VALUES
(4,'Revenue Intelligence Monthly',1,1800.00,18,2124.00),(5,'Security Operations Quarterly',1,9600.00,18,10828.00),
(6,'CRM Starter Monthly',2,999.00,18,2357.64),(7,'Priority Support Monthly',4,750.00,18,3540.00),
(8,'Analytics Trial conversion',1,1800.00,18,1944.00),(9,'Cloud Hosting Monthly',1,2500.00,18,2950.00);

INSERT IGNORE INTO payments (id,reference,customer_id,invoice_id,amount,method,status,paid_at) VALUES
(3,'PAY-2026-0003',4,4,2124.00,'upi','completed','2026-10-07 09:42:00'),
(4,'PAY-2026-0004',5,5,10828.00,'bank_transfer','completed','2026-10-09 11:20:00'),
(5,'PAY-2026-0005',6,6,2357.64,'card','completed','2026-10-11 16:05:00'),
(6,'PAY-2026-0006',7,7,1500.00,'gateway','completed','2026-10-12 13:30:00'),
(7,'PAY-2026-0007',9,9,2950.00,'bank_transfer','failed','2026-09-18 10:00:00');

INSERT IGNORE INTO notifications (user_id,title,body,channel) VALUES
(1,'Quarterly billing run ready','The November recurring billing run has 9 eligible subscriptions.','in_app'),
(2,'Invoices due soon','Five invoices are approaching their payment due date.','in_app'),
(1,'Payment reconciliation complete','October payments were reconciled successfully.','email'),
(5,'Refund approved','Refund workflow changes are ready for review.','in_app'),
(7,'Subscription renewal','Your Revenue Intelligence subscription renews on 01 November.','email');
