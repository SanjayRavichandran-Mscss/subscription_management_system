-- Brightloop Subscription Management ERP
-- Execute this file once in MySQL Workbench or the MySQL CLI.
CREATE DATABASE IF NOT EXISTS subscription_management
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE subscription_management;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS password_reset_tokens, audit_logs, refresh_tokens, notifications, refund_items, refunds, payment_allocations, payments, invoice_items, invoices, quotation_items, quotations, subscriptions, billing_runs, subscription_plans, product_variants, products, categories, taxes, discounts, customers, permissions, role_permissions, users, roles, settings;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE roles (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255) NULL,
  is_system BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE permissions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  permission_key VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
  role_id INT UNSIGNED NOT NULL,
  permission_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NULL,
  role_id INT UNSIGNED NULL,
  status ENUM('active','inactive','pending') NOT NULL DEFAULT 'active',
  refresh_token VARCHAR(128) NULL,
  last_login_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id),
  INDEX idx_users_status (status)
) ENGINE=InnoDB;

CREATE TABLE refresh_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_refresh_expiry (expires_at)
) ENGINE=InnoDB;

CREATE TABLE password_reset_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_password_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_password_reset_expiry (expires_at)
) ENGINE=InnoDB;

CREATE TABLE customers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NULL,
  name VARCHAR(160) NOT NULL,
  company VARCHAR(160) NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  phone VARCHAR(40) NULL,
  tax_id VARCHAR(80) NULL,
  billing_address TEXT NULL,
  shipping_address TEXT NULL,
  status ENUM('active','inactive','archived') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_customer_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_customer_status (status),
  INDEX idx_customer_name (name)
) ENGINE=InnoDB;

CREATE TABLE categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  parent_id INT UNSIGNED NULL,
  status ENUM('active','archived') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES categories(id),
  INDEX idx_category_parent (parent_id)
) ENGINE=InnoDB;

CREATE TABLE products (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED NULL,
  name VARCHAR(160) NOT NULL,
  sku VARCHAR(80) NULL UNIQUE,
  product_type VARCHAR(40) NOT NULL DEFAULT 'subscription',
  price DECIMAL(15,2) NOT NULL DEFAULT 0,
  cost_price DECIMAL(15,2) NOT NULL DEFAULT 0,
  notes TEXT NULL,
  status ENUM('active','inactive','archived') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_product_name (name)
) ENGINE=InnoDB;

CREATE TABLE product_variants (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id INT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  sku VARCHAR(80) NULL UNIQUE,
  attributes JSON NULL,
  price_adjustment DECIMAL(15,2) NOT NULL DEFAULT 0,
  status ENUM('active','archived') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_variant_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE subscription_plans (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id INT UNSIGNED NULL,
  name VARCHAR(160) NOT NULL,
  billing_cycle ENUM('daily','weekly','monthly','quarterly','yearly') NOT NULL DEFAULT 'monthly',
  billing_interval INT UNSIGNED NOT NULL DEFAULT 1,
  price DECIMAL(15,2) NOT NULL,
  trial_days INT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('active','inactive','archived') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_plan_product FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_plan_status (status)
) ENGINE=InnoDB;

CREATE TABLE quotations (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  number VARCHAR(60) NOT NULL UNIQUE,
  customer_id INT UNSIGNED NOT NULL,
  subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  total DECIMAL(15,2) NOT NULL DEFAULT 0,
  status ENUM('draft','sent','accepted','rejected','expired','cancelled') NOT NULL DEFAULT 'draft',
  valid_until DATE NULL,
  created_by INT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_quotation_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_quotation_creator FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE quotation_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  quotation_id INT UNSIGNED NOT NULL,
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(12,3) NOT NULL DEFAULT 1,
  unit_price DECIMAL(15,2) NOT NULL,
  tax_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  line_total DECIMAL(15,2) NOT NULL,
  CONSTRAINT fk_quotation_item FOREIGN KEY (quotation_id) REFERENCES quotations(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE subscriptions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  number VARCHAR(60) NOT NULL UNIQUE,
  customer_id INT UNSIGNED NOT NULL,
  plan_id INT UNSIGNED NULL,
  status ENUM('trial','active','paused','cancelled','expired','pending') NOT NULL DEFAULT 'active',
  unit_price DECIMAL(15,2) NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  starts_at DATE NULL,
  next_billing_at DATE NULL,
  ends_at DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_subscription_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_subscription_plan FOREIGN KEY (plan_id) REFERENCES subscription_plans(id),
  INDEX idx_subscription_status (status),
  INDEX idx_subscription_billing (next_billing_at)
) ENGINE=InnoDB;

CREATE TABLE billing_runs (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  status ENUM('pending','running','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  invoices_generated INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE invoices (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  number VARCHAR(60) NOT NULL UNIQUE,
  customer_id INT UNSIGNED NOT NULL,
  subscription_id INT UNSIGNED NULL,
  billing_run_id INT UNSIGNED NULL,
  subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  total DECIMAL(15,2) NOT NULL DEFAULT 0,
  amount_paid DECIMAL(15,2) NOT NULL DEFAULT 0,
  status ENUM('draft','issued','partially_paid','paid','overdue','void') NOT NULL DEFAULT 'draft',
  issued_at DATE NULL,
  due_at DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_invoice_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_invoice_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
  CONSTRAINT fk_invoice_billing_run FOREIGN KEY (billing_run_id) REFERENCES billing_runs(id),
  UNIQUE KEY uq_subscription_billing_period (subscription_id, billing_run_id),
  INDEX idx_invoice_status (status)
) ENGINE=InnoDB;

CREATE TABLE invoice_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  invoice_id INT UNSIGNED NOT NULL,
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(12,3) NOT NULL DEFAULT 1,
  unit_price DECIMAL(15,2) NOT NULL,
  tax_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  line_total DECIMAL(15,2) NOT NULL,
  CONSTRAINT fk_invoice_item FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE taxes (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  rate DECIMAL(8,4) NOT NULL DEFAULT 0,
  country VARCHAR(80) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE discounts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(80) NOT NULL UNIQUE,
  type ENUM('percentage','fixed') NOT NULL DEFAULT 'percentage',
  value DECIMAL(15,2) NOT NULL,
  valid_from DATE NULL,
  valid_until DATE NULL,
  status ENUM('active','inactive','expired') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE payments (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reference VARCHAR(80) NOT NULL UNIQUE,
  customer_id INT UNSIGNED NOT NULL,
  invoice_id INT UNSIGNED NULL,
  amount DECIMAL(15,2) NOT NULL,
  method ENUM('cash','bank_transfer','card','upi','cheque','gateway') NOT NULL DEFAULT 'bank_transfer',
  status ENUM('pending','completed','failed','cancelled','refunded') NOT NULL DEFAULT 'pending',
  paid_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id),
  INDEX idx_payment_status (status)
) ENGINE=InnoDB;

CREATE TABLE payment_allocations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  payment_id INT UNSIGNED NOT NULL,
  invoice_id INT UNSIGNED NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_allocation_payment FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
  CONSTRAINT fk_allocation_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id)
) ENGINE=InnoDB;

CREATE TABLE refunds (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  payment_id INT UNSIGNED NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  reason TEXT NULL,
  status ENUM('pending','approved','completed','rejected') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_refund_payment FOREIGN KEY (payment_id) REFERENCES payments(id)
) ENGINE=InnoDB;

CREATE TABLE notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NULL,
  title VARCHAR(160) NOT NULL,
  body TEXT NOT NULL,
  channel ENUM('in_app','email','sms') NOT NULL DEFAULT 'in_app',
  read_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_notification_user_read (user_id, read_at)
) ENGINE=InnoDB;

CREATE TABLE settings (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(120) NOT NULL UNIQUE,
  setting_value TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100) NULL,
  entity_id INT UNSIGNED NULL,
  old_values JSON NULL,
  new_values JSON NULL,
  ip_address VARCHAR(45) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_audit_entity (entity_type, entity_id)
) ENGINE=InnoDB;

-- Seed roles, permissions, and users.
INSERT INTO roles (id, name, description, is_system) VALUES
(1, 'SUPER_ADMIN', 'Full system administrator', TRUE),
(2, 'ADMIN', 'Business administrator', TRUE),
(3, 'STAFF', 'Internal operations staff', TRUE),
(4, 'CUSTOMER', 'Customer portal account', TRUE);

INSERT INTO permissions (id, permission_key, description) VALUES
(1, 'customer.view', 'View customers'), (2, 'customer.create', 'Create customers'),
(3, 'customer.update', 'Update customers'), (4, 'customer.delete', 'Delete customers'),
(5, 'product.manage', 'Manage catalog'), (6, 'plan.manage', 'Manage subscription plans'),
(7, 'quotation.manage', 'Manage quotations'), (8, 'subscription.manage', 'Manage subscriptions'),
(9, 'invoice.view', 'View invoices'), (10, 'invoice.confirm', 'Confirm invoices'),
(11, 'payment.manage', 'Manage payments'), (12, 'refund.manage', 'Manage refunds'),
(13, 'reports.view', 'View reports'), (14, 'users.manage', 'Manage users and staff'),
(15, 'settings.manage', 'Manage settings');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p WHERE r.name IN ('SUPER_ADMIN', 'ADMIN');
INSERT INTO role_permissions (role_id, permission_id) VALUES
(3,1),(3,9),(3,11),(3,13),(4,9);

-- Password for every seeded user: Admin123!
INSERT INTO users (id, name, email, password_hash, role_id, status) VALUES
(1, 'Brightloop Admin', 'admin@brightloop.local', '$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO', 1, 'active'),
(2, 'Operations Manager', 'manager@brightloop.local', '$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO', 2, 'active'),
(3, 'Billing Staff', 'staff@brightloop.local', '$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO', 3, 'active'),
(4, 'Aarav Sharma', 'aarav@example.com', '$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO', 4, 'active');

INSERT INTO customers (id, user_id, name, company, email, phone, tax_id, billing_address, shipping_address, status) VALUES
(1,4,'Aarav Sharma','Sharma Technologies Pvt Ltd','aarav@example.com','+91 98765 43210','27ABCDE1234F1Z5','Pune, Maharashtra, India','Pune, Maharashtra, India','active'),
(2,NULL,'Priya Mehta','Mehta Retail LLP','priya@example.com','+91 98220 11122','27PQRSX9876L1Z2','Mumbai, Maharashtra, India','Mumbai, Maharashtra, India','active'),
(3,NULL,'Brightline Consulting','Brightline Consulting','billing@brightline.example','+91 90000 12345','GSTIN123456789','Bengaluru, Karnataka, India','Bengaluru, Karnataka, India','active');

INSERT INTO categories (id, name, parent_id, status) VALUES
(1,'Software',NULL,'active'),(2,'Hosting',NULL,'active'),(3,'CRM',1,'active'),(4,'Support',NULL,'active');
INSERT INTO products (id, category_id, name, sku, product_type, price, cost_price, notes, status) VALUES
(1,3,'Brightloop CRM','CRM-BASE','service',1000.00,350.00,'Cloud CRM subscription','active'),
(2,2,'Managed Cloud Hosting','HOST-CLOUD','service',2500.00,900.00,'Managed cloud hosting service','active'),
(3,4,'Priority Support','SUP-PRIORITY','service',750.00,200.00,'Priority business support','active');
INSERT INTO product_variants (id, product_id, name, sku, attributes, price_adjustment, status) VALUES
(1,1,'Odoo Brand','CRM-ODOO',JSON_OBJECT('brand','Odoo'),560.00,'active'),
(2,1,'Enterprise Users','CRM-ENTERPRISE',JSON_OBJECT('users',25),1200.00,'active'),
(3,2,'Managed SSD Hosting','HOST-SSD',JSON_OBJECT('storage','500GB'),700.00,'active');
INSERT INTO subscription_plans (id, product_id, name, billing_cycle, billing_interval, price, trial_days, status) VALUES
(1,1,'CRM Starter Monthly','monthly',1,999.00,14,'active'),
(2,1,'CRM Business Yearly','yearly',1,9999.00,14,'active'),
(3,2,'Cloud Hosting Monthly','monthly',1,2500.00,7,'active'),
(4,3,'Priority Support Monthly','monthly',1,750.00,0,'active');

INSERT INTO subscriptions (id, number, customer_id, plan_id, status, unit_price, quantity, starts_at, next_billing_at) VALUES
(1,'SUB-2026-0001',1,1,'active',999.00,1,'2026-01-01','2026-11-01'),
(2,'SUB-2026-0002',2,3,'active',2500.00,2,'2026-02-15','2026-11-15'),
(3,'SUB-2026-0003',3,2,'trial',9999.00,1,'2026-10-01','2026-11-01');

INSERT INTO quotations (id, number, customer_id, subtotal, tax_amount, discount_amount, total, status, valid_until, created_by) VALUES
(1,'QT-2026-0001',1,1559.00,280.62,0.00,1839.62,'accepted','2026-11-30',1),
(2,'QT-2026-0002',2,5000.00,900.00,500.00,5400.00,'sent','2026-12-15',2);
INSERT INTO quotation_items (quotation_id, description, quantity, unit_price, tax_rate, line_total) VALUES
(1,'CRM Starter subscription',1,999.00,18,1178.82),(1,'Odoo Brand variant',1,560.00,18,660.80),
(2,'Managed Cloud Hosting',2,2500.00,18,5900.00);

INSERT INTO billing_runs (id, period_start, period_end, status, invoices_generated) VALUES
(1,'2026-10-01','2026-10-31','completed',3),(2,'2026-11-01','2026-11-30','pending',0);

INSERT INTO invoices (id, number, customer_id, subscription_id, billing_run_id, subtotal, tax_amount, discount_amount, total, amount_paid, status, issued_at, due_at) VALUES
(1,'INV-2026-1001',1,1,1,999.00,179.82,0,1178.82,1178.82,'paid','2026-10-01','2026-10-15'),
(2,'INV-2026-1002',2,2,1,5000.00,900.00,0,5900.00,3000.00,'partially_paid','2026-10-15','2026-10-30'),
(3,'INV-2026-1003',3,3,NULL,9999.00,1799.82,0,11798.82,0,'issued','2026-10-20','2026-11-05');
INSERT INTO invoice_items (invoice_id, description, quantity, unit_price, tax_rate, line_total) VALUES
(1,'CRM Starter Monthly',1,999.00,18,1178.82),(2,'Cloud Hosting Monthly',2,2500.00,18,5900.00),(3,'CRM Business Yearly',1,9999.00,18,11798.82);

INSERT INTO taxes (id, name, rate, country, status) VALUES
(1,'GST Standard',18.0000,'India','active'),(2,'GST Reduced',5.0000,'India','active'),(3,'VAT Standard',20.0000,'United Kingdom','active');
INSERT INTO discounts (id, name, code, type, value, valid_from, valid_until, status) VALUES
(1,'Welcome Discount','WELCOME10','percentage',10.00,'2026-01-01','2026-12-31','active'),
(2,'Annual Subscription Saving','ANNUAL500','fixed',500.00,'2026-01-01','2026-12-31','active');

INSERT INTO payments (id, reference, customer_id, invoice_id, amount, method, status, paid_at) VALUES
(1,'PAY-2026-0001',1,1,1178.82,'upi','completed','2026-10-05 10:30:00'),
(2,'PAY-2026-0002',2,2,3000.00,'bank_transfer','completed','2026-10-18 14:15:00');
INSERT INTO payment_allocations (payment_id, invoice_id, amount) VALUES (1,1,1178.82),(2,2,3000.00);
INSERT INTO refunds (payment_id, amount, reason, status) VALUES (2,500.00,'Duplicate hosting allocation adjustment','pending');

INSERT INTO notifications (user_id, title, body, channel) VALUES
(1,'Invoice paid','Invoice INV-2026-1001 has been paid.','in_app'),
(2,'Payment allocated','Payment PAY-2026-0002 was allocated successfully.','in_app'),
(4,'Welcome to Brightloop','Your customer portal account is ready.','in_app');
INSERT INTO settings (setting_key, setting_value) VALUES
('company_name','Brightloop Software'),('currency','INR'),('currency_symbol','₹'),('timezone','Asia/Kolkata'),('default_tax_rate','18');
INSERT INTO audit_logs (user_id, action, entity_type, entity_id, new_values) VALUES
(1,'CREATE','invoice',1,JSON_OBJECT('number','INV-2026-1001')),
(1,'CREATE','payment',1,JSON_OBJECT('reference','PAY-2026-0001'));
