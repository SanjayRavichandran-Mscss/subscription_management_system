-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: subscription_management
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `entity_id` int unsigned DEFAULT NULL,
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_audit_user` (`user_id`),
  KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'CREATE','invoice',1,NULL,'{\"number\": \"INV-2026-1001\"}',NULL,'2026-10-31 11:35:13'),(2,1,'CREATE','payment',1,NULL,'{\"reference\": \"PAY-2026-0001\"}',NULL,'2026-10-31 11:35:13'),(3,1,'PUT','customers',9,NULL,'{\"name\": \"Northstar Education\", \"email\": \"billing@northstar.example\", \"phone\": \"+91 99555 11880\", \"status\": \"active\", \"tax_id\": \"07AAATN7610Q1Z2\", \"company\": \"Northstar Education Trust\", \"user_id\": null, \"billing_address\": \"Delhi, India\", \"shipping_address\": null}',NULL,'2026-10-31 11:47:47'),(4,1,'PUT','customers',9,NULL,'{\"name\": \"Northstar Education\", \"email\": \"billing@northstar.example\", \"phone\": \"+91 99555 11880\", \"status\": \"active\", \"tax_id\": \"07AAATN7610Q1Z2\", \"company\": \"Northstar Education Trust\", \"user_id\": null, \"billing_address\": \"New Delhi, India\", \"shipping_address\": null}',NULL,'2026-10-31 11:50:38');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `billing_runs`
--

DROP TABLE IF EXISTS `billing_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `billing_runs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `status` enum('pending','running','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  `invoices_generated` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `billing_runs`
--

LOCK TABLES `billing_runs` WRITE;
/*!40000 ALTER TABLE `billing_runs` DISABLE KEYS */;
INSERT INTO `billing_runs` VALUES (1,'2026-10-01','2026-10-31','completed',3,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'2026-11-01','2026-11-30','pending',0,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,'2026-10-01','2026-10-31','completed',6,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,'2026-11-01','2026-11-30','',0,'2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `billing_runs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(160) NOT NULL,
  `parent_id` int unsigned DEFAULT NULL,
  `status` enum('active','archived') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_category_parent` (`parent_id`),
  CONSTRAINT `fk_category_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Software',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'Hosting',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,'CRM',1,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,'Support',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(5,'Security',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(6,'Analytics',1,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(7,'Professional Services',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `name` varchar(160) NOT NULL,
  `company` varchar(160) DEFAULT NULL,
  `email` varchar(190) NOT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `tax_id` varchar(80) DEFAULT NULL,
  `billing_address` text,
  `shipping_address` text,
  `status` enum('active','inactive','archived') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_customer_user` (`user_id`),
  KEY `idx_customer_status` (`status`),
  KEY `idx_customer_name` (`name`),
  CONSTRAINT `fk_customer_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,4,'Aarav Sharma','Sharma Technologies Pvt Ltd','aarav@example.com','+91 98765 43210','27ABCDE1234F1Z5','Pune, Maharashtra, India','Pune, Maharashtra, India','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,NULL,'Priya Mehta','Mehta Retail LLP','priya@example.com','+91 98220 11122','27PQRSX9876L1Z2','Mumbai, Maharashtra, India','Mumbai, Maharashtra, India','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,NULL,'Brightline Consulting','Brightline Consulting','billing@brightline.example','+91 90000 12345','GSTIN123456789','Bengaluru, Karnataka, India','Bengaluru, Karnataka, India','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,7,'Ananya Iyer','Nova Analytics Pvt Ltd','ananya@example.com','+91 98110 34567','27AABCN4412R1Z8','Hyderabad, Telangana, India',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(5,8,'Vikram Singh','Vikram & Sons Logistics','vikram@example.com','+91 98990 78123','27AALFV5567M1Z3','Delhi NCR, India',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(6,NULL,'Fatima Khan','UrbanDesk Interiors','fatima@urbandesk.example','+91 99876 21450','27AAACU2219K1Z1','Chennai, Tamil Nadu, India',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(7,NULL,'Arjun Technologies','Arjun Technologies LLP','accounts@arjun.example','+91 98700 44112','29AADCA8841P1Z5','Bengaluru, Karnataka, India',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(8,NULL,'GreenLeaf Foods','GreenLeaf Foods India','finance@greenleaf.example','+91 97654 22109','27AABCG7611H1Z6','Ahmedabad, Gujarat, India',NULL,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(9,NULL,'Northstar Education','Northstar Education Trust','billing@northstar.example','+91 99555 11880','07AAATN7610Q1Z2','New Delhi, India',NULL,'active','2026-10-31 11:35:13','2026-10-31 06:20:38');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `discounts`
--

DROP TABLE IF EXISTS `discounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discounts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `code` varchar(80) NOT NULL,
  `type` enum('percentage','fixed') NOT NULL DEFAULT 'percentage',
  `value` decimal(15,2) NOT NULL,
  `valid_from` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `status` enum('active','inactive','expired') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discounts`
--

LOCK TABLES `discounts` WRITE;
/*!40000 ALTER TABLE `discounts` DISABLE KEYS */;
INSERT INTO `discounts` VALUES (1,'Welcome Discount','WELCOME10','percentage',10.00,'2026-01-01','2026-12-31','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'Annual Subscription Saving','ANNUAL500','fixed',500.00,'2026-01-01','2026-12-31','active','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `discounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_items`
--

DROP TABLE IF EXISTS `invoice_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `invoice_id` int unsigned NOT NULL,
  `description` varchar(255) NOT NULL,
  `quantity` decimal(12,3) NOT NULL DEFAULT '1.000',
  `unit_price` decimal(15,2) NOT NULL,
  `tax_rate` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `line_total` decimal(15,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_invoice_item` (`invoice_id`),
  CONSTRAINT `fk_invoice_item` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_items`
--

LOCK TABLES `invoice_items` WRITE;
/*!40000 ALTER TABLE `invoice_items` DISABLE KEYS */;
INSERT INTO `invoice_items` VALUES (1,1,'CRM Starter Monthly',1.000,999.00,18.0000,0.00,1178.82),(2,2,'Cloud Hosting Monthly',2.000,2500.00,18.0000,0.00,5900.00),(3,3,'CRM Business Yearly',1.000,9999.00,18.0000,0.00,11798.82),(4,4,'Revenue Intelligence Monthly',1.000,1800.00,18.0000,0.00,2124.00),(5,5,'Security Operations Quarterly',1.000,9600.00,18.0000,0.00,10828.00),(6,6,'CRM Starter Monthly',2.000,999.00,18.0000,0.00,2357.64),(7,7,'Priority Support Monthly',4.000,750.00,18.0000,0.00,3540.00),(8,8,'Analytics Trial conversion',1.000,1800.00,18.0000,0.00,1944.00),(9,9,'Cloud Hosting Monthly',1.000,2500.00,18.0000,0.00,2950.00);
/*!40000 ALTER TABLE `invoice_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `number` varchar(60) NOT NULL,
  `customer_id` int unsigned NOT NULL,
  `subscription_id` int unsigned DEFAULT NULL,
  `billing_run_id` int unsigned DEFAULT NULL,
  `subtotal` decimal(15,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `amount_paid` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` enum('draft','issued','partially_paid','paid','overdue','void') NOT NULL DEFAULT 'draft',
  `issued_at` date DEFAULT NULL,
  `due_at` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `number` (`number`),
  UNIQUE KEY `uq_subscription_billing_period` (`subscription_id`,`billing_run_id`),
  KEY `fk_invoice_customer` (`customer_id`),
  KEY `fk_invoice_billing_run` (`billing_run_id`),
  KEY `idx_invoice_status` (`status`),
  CONSTRAINT `fk_invoice_billing_run` FOREIGN KEY (`billing_run_id`) REFERENCES `billing_runs` (`id`),
  CONSTRAINT `fk_invoice_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_invoice_subscription` FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (1,'INV-2026-1001',1,1,1,999.00,179.82,0.00,1178.82,1178.82,'paid','2026-10-01','2026-10-15','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'INV-2026-1002',2,2,1,5000.00,900.00,0.00,5900.00,3000.00,'partially_paid','2026-10-15','2026-10-30','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,'INV-2026-1003',3,3,NULL,9999.00,1799.82,0.00,11798.82,0.00,'issued','2026-10-20','2026-11-05','2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,'INV-2026-1004',4,4,3,1800.00,324.00,0.00,2124.00,2124.00,'paid','2026-10-03','2026-10-18','2026-10-31 11:35:13','2026-10-31 11:35:13'),(5,'INV-2026-1005',5,5,3,9600.00,1728.00,500.00,10828.00,10828.00,'paid','2026-10-04','2026-10-19','2026-10-31 11:35:13','2026-10-31 11:35:13'),(6,'INV-2026-1006',6,6,3,1998.00,359.64,0.00,2357.64,2357.64,'paid','2026-10-05','2026-10-20','2026-10-31 11:35:13','2026-10-31 11:35:13'),(7,'INV-2026-1007',7,7,3,3000.00,540.00,0.00,3540.00,1500.00,'partially_paid','2026-10-08','2026-10-23','2026-10-31 11:35:13','2026-10-31 11:35:13'),(8,'INV-2026-1008',8,8,NULL,1800.00,324.00,180.00,1944.00,0.00,'issued','2026-10-22','2026-11-06','2026-10-31 11:35:13','2026-10-31 11:35:13'),(9,'INV-2026-1009',9,9,NULL,2500.00,450.00,0.00,2950.00,2950.00,'overdue','2026-09-01','2026-09-16','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `title` varchar(160) NOT NULL,
  `body` text NOT NULL,
  `channel` enum('in_app','email','sms') NOT NULL DEFAULT 'in_app',
  `read_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notification_user_read` (`user_id`,`read_at`),
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,1,'Invoice paid','Invoice INV-2026-1001 has been paid.','in_app',NULL,'2026-10-31 11:35:13'),(2,2,'Payment allocated','Payment PAY-2026-0002 was allocated successfully.','in_app',NULL,'2026-10-31 11:35:13'),(3,4,'Welcome to Brightloop','Your customer portal account is ready.','in_app',NULL,'2026-10-31 11:35:13'),(4,1,'Quarterly billing run ready','The November recurring billing run has 9 eligible subscriptions.','in_app',NULL,'2026-10-31 11:35:13'),(5,2,'Invoices due soon','Five invoices are approaching their payment due date.','in_app',NULL,'2026-10-31 11:35:13'),(6,1,'Payment reconciliation complete','October payments were reconciled successfully.','email',NULL,'2026-10-31 11:35:13'),(7,5,'Refund approved','Refund workflow changes are ready for review.','in_app',NULL,'2026-10-31 11:35:13'),(8,7,'Subscription renewal','Your Revenue Intelligence subscription renews on 01 November.','email',NULL,'2026-10-31 11:35:13');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `fk_password_reset_user` (`user_id`),
  KEY `idx_password_reset_expiry` (`expires_at`),
  CONSTRAINT `fk_password_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_allocations`
--

DROP TABLE IF EXISTS `payment_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_allocations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `payment_id` int unsigned NOT NULL,
  `invoice_id` int unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_allocation_payment` (`payment_id`),
  KEY `fk_allocation_invoice` (`invoice_id`),
  CONSTRAINT `fk_allocation_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `fk_allocation_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_allocations`
--

LOCK TABLES `payment_allocations` WRITE;
/*!40000 ALTER TABLE `payment_allocations` DISABLE KEYS */;
INSERT INTO `payment_allocations` VALUES (1,1,1,1178.82,'2026-10-31 11:35:13'),(2,2,2,3000.00,'2026-10-31 11:35:13');
/*!40000 ALTER TABLE `payment_allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `reference` varchar(80) NOT NULL,
  `customer_id` int unsigned NOT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `method` enum('cash','bank_transfer','card','upi','cheque','gateway') NOT NULL DEFAULT 'bank_transfer',
  `status` enum('pending','completed','failed','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `paid_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reference` (`reference`),
  KEY `fk_payment_customer` (`customer_id`),
  KEY `fk_payment_invoice` (`invoice_id`),
  KEY `idx_payment_status` (`status`),
  CONSTRAINT `fk_payment_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_payment_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,'PAY-2026-0001',1,1,1178.82,'upi','completed','2026-10-05 10:30:00','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'PAY-2026-0002',2,2,3000.00,'bank_transfer','completed','2026-10-18 14:15:00','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,'PAY-2026-0003',4,4,2124.00,'upi','completed','2026-10-07 09:42:00','2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,'PAY-2026-0004',5,5,10828.00,'bank_transfer','completed','2026-10-09 11:20:00','2026-10-31 11:35:13','2026-10-31 11:35:13'),(5,'PAY-2026-0005',6,6,2357.64,'card','completed','2026-10-11 16:05:00','2026-10-31 11:35:13','2026-10-31 11:35:13'),(6,'PAY-2026-0006',7,7,1500.00,'gateway','completed','2026-10-12 13:30:00','2026-10-31 11:35:13','2026-10-31 11:35:13'),(7,'PAY-2026-0007',9,9,2950.00,'bank_transfer','failed','2026-09-18 10:00:00','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `permission_key` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permission_key` (`permission_key`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'customer.view','View customers','2026-10-31 11:35:13'),(2,'customer.create','Create customers','2026-10-31 11:35:13'),(3,'customer.update','Update customers','2026-10-31 11:35:13'),(4,'customer.delete','Delete customers','2026-10-31 11:35:13'),(5,'product.manage','Manage catalog','2026-10-31 11:35:13'),(6,'plan.manage','Manage subscription plans','2026-10-31 11:35:13'),(7,'quotation.manage','Manage quotations','2026-10-31 11:35:13'),(8,'subscription.manage','Manage subscriptions','2026-10-31 11:35:13'),(9,'invoice.view','View invoices','2026-10-31 11:35:13'),(10,'invoice.confirm','Confirm invoices','2026-10-31 11:35:13'),(11,'payment.manage','Manage payments','2026-10-31 11:35:13'),(12,'refund.manage','Manage refunds','2026-10-31 11:35:13'),(13,'reports.view','View reports','2026-10-31 11:35:13'),(14,'users.manage','Manage users and staff','2026-10-31 11:35:13'),(15,'settings.manage','Manage settings','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int unsigned NOT NULL,
  `name` varchar(160) NOT NULL,
  `sku` varchar(80) DEFAULT NULL,
  `attributes` json DEFAULT NULL,
  `price_adjustment` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` enum('active','archived') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `fk_variant_product` (`product_id`),
  CONSTRAINT `fk_variant_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
INSERT INTO `product_variants` VALUES (1,1,'Odoo Brand','CRM-ODOO','{\"brand\": \"Odoo\"}',560.00,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,1,'Enterprise Users','CRM-ENTERPRISE','{\"users\": 25}',1200.00,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,2,'Managed SSD Hosting','HOST-SSD','{\"storage\": \"500GB\"}',700.00,'active','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int unsigned DEFAULT NULL,
  `name` varchar(160) NOT NULL,
  `sku` varchar(80) DEFAULT NULL,
  `product_type` varchar(40) NOT NULL DEFAULT 'subscription',
  `price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `cost_price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `notes` text,
  `status` enum('active','inactive','archived') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `fk_product_category` (`category_id`),
  KEY `idx_product_name` (`name`),
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,3,'Brightloop CRM','CRM-BASE','service',1000.00,350.00,'Cloud CRM subscription','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,2,'Managed Cloud Hosting','HOST-CLOUD','service',2500.00,900.00,'Managed cloud hosting service','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,4,'Priority Support','SUP-PRIORITY','service',750.00,200.00,'Priority business support','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,6,'Revenue Intelligence','BI-REV','service',1800.00,600.00,'Executive revenue and renewal analytics','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(5,5,'Security Operations','SEC-OPS','service',3200.00,1100.00,'Security monitoring and compliance support','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(6,7,'Implementation Services','PRO-IMPL','service',6500.00,3200.00,'Onboarding and ERP implementation services','active','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quotation_items`
--

DROP TABLE IF EXISTS `quotation_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quotation_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `quotation_id` int unsigned NOT NULL,
  `description` varchar(255) NOT NULL,
  `quantity` decimal(12,3) NOT NULL DEFAULT '1.000',
  `unit_price` decimal(15,2) NOT NULL,
  `tax_rate` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `line_total` decimal(15,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_quotation_item` (`quotation_id`),
  CONSTRAINT `fk_quotation_item` FOREIGN KEY (`quotation_id`) REFERENCES `quotations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotation_items`
--

LOCK TABLES `quotation_items` WRITE;
/*!40000 ALTER TABLE `quotation_items` DISABLE KEYS */;
INSERT INTO `quotation_items` VALUES (1,1,'CRM Starter subscription',1.000,999.00,18.0000,0.00,1178.82),(2,1,'Odoo Brand variant',1.000,560.00,18.0000,0.00,660.80),(3,2,'Managed Cloud Hosting',2.000,2500.00,18.0000,0.00,5900.00);
/*!40000 ALTER TABLE `quotation_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quotations`
--

DROP TABLE IF EXISTS `quotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quotations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `number` varchar(60) NOT NULL,
  `customer_id` int unsigned NOT NULL,
  `subtotal` decimal(15,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` enum('draft','sent','accepted','rejected','expired','cancelled') NOT NULL DEFAULT 'draft',
  `valid_until` date DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `number` (`number`),
  KEY `fk_quotation_customer` (`customer_id`),
  KEY `fk_quotation_creator` (`created_by`),
  CONSTRAINT `fk_quotation_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_quotation_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotations`
--

LOCK TABLES `quotations` WRITE;
/*!40000 ALTER TABLE `quotations` DISABLE KEYS */;
INSERT INTO `quotations` VALUES (1,'QT-2026-0001',1,1559.00,280.62,0.00,1839.62,'accepted','2026-11-30',1,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'QT-2026-0002',2,5000.00,900.00,500.00,5400.00,'sent','2026-12-15',2,'2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `quotations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refresh_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `fk_refresh_user` (`user_id`),
  KEY `idx_refresh_expiry` (`expires_at`),
  CONSTRAINT `fk_refresh_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (1,1,'90337903be0e3fb1a5d662244f529eba6755e9f7af6e03a43335055154a7bbb1','2026-11-30 11:45:19',NULL,'2026-10-31 11:45:19'),(2,1,'1bd9ce03dbeb132e74781033a7791f654f5a3e615754ec1223c54bc347911751','2026-11-30 11:47:27',NULL,'2026-10-31 11:47:27'),(3,1,'dd67d3342d26a9037089af601907a60b87750171f658e78f6b3a449346e8c1cb','2026-11-30 11:50:17',NULL,'2026-10-31 11:50:17'),(4,1,'a982f9408b641c53a4947986c30936a75e8d5990a84f0bcaca6d7eadce15307e','2026-11-30 11:51:43',NULL,'2026-10-31 11:51:43'),(5,1,'8a5e204258b6edb5d96732aa8fb3a231781555f6e3174b69188f1cdd72f480a8','2026-11-30 11:53:23',NULL,'2026-10-31 11:53:23'),(6,1,'299173159ed74f7d7eff600f72a3e721d8bd486e62673fbe1e62e5857827e450','2026-11-30 11:55:18',NULL,'2026-10-31 11:55:18'),(7,2,'d108d4bdce69a20096fda59c2ac409e648604949721f34b8799b257bd08d2f1a','2026-11-30 11:56:07',NULL,'2026-10-31 11:56:07'),(8,4,'fe3839237ba7725c498d796abc83db76d97647275fd19a7c5ac0f8917ecff101','2026-11-30 11:56:46',NULL,'2026-10-31 11:56:46');
/*!40000 ALTER TABLE `refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refunds` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `payment_id` int unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `reason` text,
  `status` enum('pending','approved','completed','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_refund_payment` (`payment_id`),
  CONSTRAINT `fk_refund_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refunds`
--

LOCK TABLES `refunds` WRITE;
/*!40000 ALTER TABLE `refunds` DISABLE KEYS */;
INSERT INTO `refunds` VALUES (1,2,500.00,'Duplicate hosting allocation adjustment','pending','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `refunds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_id` int unsigned NOT NULL,
  `permission_id` int unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `fk_role_permissions_permission` (`permission_id`),
  CONSTRAINT `fk_role_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permissions_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (1,1),(2,1),(3,1),(1,2),(2,2),(1,3),(2,3),(1,4),(2,4),(1,5),(2,5),(1,6),(2,6),(1,7),(2,7),(1,8),(2,8),(1,9),(2,9),(3,9),(4,9),(1,10),(2,10),(1,11),(2,11),(3,11),(1,12),(2,12),(1,13),(2,13),(3,13),(1,14),(2,14),(1,15),(2,15);
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'SUPER_ADMIN','Full system administrator',1,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'ADMIN','Business administrator',1,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,'STAFF','Internal operations staff',1,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,'CUSTOMER','Customer portal account',1,'2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(120) NOT NULL,
  `setting_value` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'company_name','Brightloop Software','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'currency','INR','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,'currency_symbol','₹','2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,'timezone','Asia/Kolkata','2026-10-31 11:35:13','2026-10-31 11:35:13'),(5,'default_tax_rate','18','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscription_plans` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int unsigned DEFAULT NULL,
  `name` varchar(160) NOT NULL,
  `billing_cycle` enum('daily','weekly','monthly','quarterly','yearly') NOT NULL DEFAULT 'monthly',
  `billing_interval` int unsigned NOT NULL DEFAULT '1',
  `price` decimal(15,2) NOT NULL,
  `trial_days` int unsigned NOT NULL DEFAULT '0',
  `status` enum('active','inactive','archived') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_plan_product` (`product_id`),
  KEY `idx_plan_status` (`status`),
  CONSTRAINT `fk_plan_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_plans`
--

LOCK TABLES `subscription_plans` WRITE;
/*!40000 ALTER TABLE `subscription_plans` DISABLE KEYS */;
INSERT INTO `subscription_plans` VALUES (1,1,'CRM Starter Monthly','monthly',1,999.00,14,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,1,'CRM Business Yearly','yearly',1,9999.00,14,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,2,'Cloud Hosting Monthly','monthly',1,2500.00,7,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,3,'Priority Support Monthly','monthly',1,750.00,0,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(5,4,'Analytics Monthly','monthly',1,1800.00,14,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(6,5,'Security Operations Quarterly','quarterly',1,9600.00,30,'active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(7,6,'Implementation One Time','yearly',1,6500.00,0,'active','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `subscription_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `number` varchar(60) NOT NULL,
  `customer_id` int unsigned NOT NULL,
  `plan_id` int unsigned DEFAULT NULL,
  `status` enum('trial','active','paused','cancelled','expired','pending') NOT NULL DEFAULT 'active',
  `unit_price` decimal(15,2) NOT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `starts_at` date DEFAULT NULL,
  `next_billing_at` date DEFAULT NULL,
  `ends_at` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `number` (`number`),
  KEY `fk_subscription_customer` (`customer_id`),
  KEY `fk_subscription_plan` (`plan_id`),
  KEY `idx_subscription_status` (`status`),
  KEY `idx_subscription_billing` (`next_billing_at`),
  CONSTRAINT `fk_subscription_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_subscription_plan` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
INSERT INTO `subscriptions` VALUES (1,'SUB-2026-0001',1,1,'active',999.00,1,'2026-01-01','2026-11-01',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'SUB-2026-0002',2,3,'active',2500.00,2,'2026-02-15','2026-11-15',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,'SUB-2026-0003',3,2,'trial',9999.00,1,'2026-10-01','2026-11-01',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,'SUB-2026-0004',4,5,'active',1800.00,1,'2026-03-01','2026-11-01',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(5,'SUB-2026-0005',5,6,'active',9600.00,1,'2026-04-15','2027-01-15',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(6,'SUB-2026-0006',6,1,'active',1998.00,2,'2026-05-01','2026-11-01',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(7,'SUB-2026-0007',7,4,'paused',750.00,4,'2026-06-01','2026-11-01',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(8,'SUB-2026-0008',8,5,'trial',1800.00,1,'2026-10-15','2026-11-15',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(9,'SUB-2026-0009',9,3,'expired',2500.00,1,'2025-08-01','2026-08-01',NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxes`
--

DROP TABLE IF EXISTS `taxes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taxes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `rate` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `country` varchar(80) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxes`
--

LOCK TABLES `taxes` WRITE;
/*!40000 ALTER TABLE `taxes` DISABLE KEYS */;
INSERT INTO `taxes` VALUES (1,'GST Standard',18.0000,'India','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(2,'GST Reduced',5.0000,'India','active','2026-10-31 11:35:13','2026-10-31 11:35:13'),(3,'VAT Standard',20.0000,'United Kingdom','active','2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `taxes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `role_id` int unsigned DEFAULT NULL,
  `status` enum('active','inactive','pending') NOT NULL DEFAULT 'active',
  `refresh_token` varchar(128) DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_users_role` (`role_id`),
  KEY `idx_users_status` (`status`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Brightloop Admin','admin@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',1,'active','7a675c3b078a084936de686176e7ca42c6783ad1a9cdfc0afcf4590735855182b1b355fd0d08364324af618ee06b2a3a','2026-10-31 11:55:18','2026-10-31 11:35:13','2026-10-31 11:55:18'),(2,'Operations Manager','manager@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',2,'active','c6143702b869ca51a4a1751332bb14b2a4c407bfa17f9131b3ca9439a943fe0bba4579567970cbec1cec8457502f1cb2','2026-10-31 11:56:07','2026-10-31 11:35:13','2026-10-31 11:56:07'),(3,'Billing Staff','staff@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',3,'active',NULL,NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(4,'Aarav Sharma','aarav@example.com','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',4,'active','6b85f855897f9e7692c1c0fdfb26c739054a50ffc002fccf90764c90fbc5bb045ed2187a8a09c59cbb9cafee63af9114','2026-10-31 11:56:46','2026-10-31 11:35:13','2026-10-31 11:56:46'),(5,'Neha Kapoor','neha.kapoor@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',2,'active',NULL,NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(6,'Rohan Nair','rohan.nair@brightloop.local','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',3,'active',NULL,NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(7,'Ananya Iyer','ananya@example.com','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',4,'active',NULL,NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13'),(8,'Vikram Singh','vikram@example.com','$2b$12$KWA.toPirae3Ee50iG0zqOiFJ2bZHjvORzoMxJrFW492UyyXhDLzO',4,'active',NULL,NULL,'2026-10-31 11:35:13','2026-10-31 11:35:13');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-31 17:38:34
