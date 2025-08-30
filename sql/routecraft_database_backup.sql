-- MySQL dump 10.13  Distrib 5.7.24, for osx11.1 (x86_64)
--
-- Host: localhost    Database: routecraft
-- ------------------------------------------------------
-- Server version	9.2.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accessorial_definitions_master`
--

DROP TABLE IF EXISTS `accessorial_definitions_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accessorial_definitions_master` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `accessorial_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique accessorial code (e.g., ACC-DET01)',
  `accessorial_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Name of the charge (e.g., Detention, Driver Assist)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Short explanation of the condition under which it is applied',
  `applies_to` enum('Pickup','Delivery','In-Transit','General') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Pickup / Delivery / In-Transit / General',
  `trigger_condition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'E.g., More than 2 hours waiting, over 1 extra stop',
  `rate_type` enum('Flat Fee','Per Hour','Per KM','Per Attempt','Per Pallet','Per MT','Per Stop') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Rate calculation method',
  `rate_value` decimal(10,2) NOT NULL COMMENT 'Numeric amount (e.g., ₹500/hour for detention)',
  `unit` enum('Hours','KM','Pallet','Stop','Attempt','MT','Trip') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Hours / KM / Pallet / Stop / Attempt',
  `taxable` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Whether GST or other tax applies',
  `included_in_base` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Whether it is bundled or billed separately',
  `invoice_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'For finance/invoice processing systems',
  `gl_mapping` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'General Ledger account mapping',
  `applicable_equipment_types` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'E.g., Only for reefers, flatbeds, etc.',
  `carrier_editable_in_bid` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Can carriers propose their own value in RFP?',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Notes on usage, exceptions, or region-specific rules',
  `is_active` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Whether this accessorial is currently active',
  `effective_from` date NOT NULL COMMENT 'Date from which this accessorial is effective',
  `effective_to` date DEFAULT NULL COMMENT 'Date until which this accessorial is effective (NULL for indefinite)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who created the accessorial',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who last updated the accessorial',
  PRIMARY KEY (`id`),
  UNIQUE KEY `accessorial_id` (`accessorial_id`),
  KEY `idx_accessorial_id` (`accessorial_id`),
  KEY `idx_accessorial_name` (`accessorial_name`),
  KEY `idx_applies_to` (`applies_to`),
  KEY `idx_rate_type` (`rate_type`),
  KEY `idx_taxable` (`taxable`),
  KEY `idx_included_in_base` (`included_in_base`),
  KEY `idx_carrier_editable` (`carrier_editable_in_bid`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_effective_from` (`effective_from`),
  KEY `idx_effective_to` (`effective_to`),
  KEY `idx_rate_value` (`rate_value`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Accessorial Definitions Master for TL transportation with comprehensive charge definitions';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accessorial_definitions_master`
--

LOCK TABLES `accessorial_definitions_master` WRITE;
/*!40000 ALTER TABLE `accessorial_definitions_master` DISABLE KEYS */;
INSERT INTO `accessorial_definitions_master` VALUES (1,'ACC-DET-2025','Detention – Delivery Site','Charged when truck waits beyond free time at delivery location','Delivery','After 2 hours of free time','Per Hour',400.00,'Hours','Yes','No','DET-DEL','GL-4001','All equipment types','No','Applicable to metro zones only','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(2,'ACC-DET-PICKUP','Detention – Pickup Site','Charged when truck waits beyond free time at pickup location','Pickup','After 1.5 hours of free time','Per Hour',350.00,'Hours','Yes','No','DET-PICK','GL-4002','All equipment types','No','Standard detention charge for pickup delays','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(3,'ACC-MULTI-01','Multi-stop Fee','Additional charge for deliveries at multiple drop-off points','Delivery','For each additional stop beyond first delivery','Per Stop',500.00,'Stop','Yes','No','MULTI-STOP','GL-4003','All equipment types','Yes','Negotiable based on distance and complexity','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(4,'ACC-LOAD-01','Loading Assistance','When driver or vehicle helps with loading operations','Pickup','Manual loading assistance required','Per MT',150.00,'MT','Yes','No','LOAD-ASSIST','GL-4004','All equipment types','Yes','Based on actual loading time and complexity','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(5,'ACC-UNLOAD-01','Unloading Assistance','When driver or vehicle helps with unloading operations','Delivery','Manual unloading assistance required','Per MT',150.00,'MT','Yes','No','UNLOAD-ASSIST','GL-4005','All equipment types','Yes','Based on actual unloading time and complexity','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(6,'ACC-TOLL-01','Toll Charges','Highway and bridge toll fees for certain routes','In-Transit','Route includes toll roads or bridges','Flat Fee',250.00,'Trip','Yes','No','TOLL-FEE','GL-4006','All equipment types','No','Fixed toll charge for standard routes','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(7,'ACC-ESCORT-01','Escort Fee','For high-value or over-dimensional cargo requiring escort','In-Transit','Cargo value exceeds ₹10 lakhs or dimensions exceed limits','Flat Fee',2000.00,'Trip','Yes','No','ESCORT-FEE','GL-4007','All equipment types','No','Required for high-value shipments and oversized cargo','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(8,'ACC-FUEL-01','Fuel Surcharge','Variable percentage based on diesel price index','General','Applied when diesel price exceeds base threshold','Per KM',2.50,'KM','Yes','Yes','FUEL-SUR','GL-4008','All equipment types','No','Percentage varies monthly based on fuel price index','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(9,'ACC-NIGHT-01','Night Delivery Charges','For delivery outside regular business hours','Delivery','Delivery between 8 PM and 6 AM','Flat Fee',800.00,'Trip','Yes','No','NIGHT-DEL','GL-4009','All equipment types','Yes','Additional charge for after-hours delivery','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(10,'ACC-REATTEMPT-01','Reattempt Fee','When delivery is unsuccessful and retried','Delivery','Delivery attempt failed, retry required','Per Attempt',300.00,'Attempt','Yes','No','REATTEMPT','GL-4010','All equipment types','No','Charged for each additional delivery attempt','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(11,'ACC-WEIGH-01','Weighbridge Fee','Charged when weighing is mandatory at checkpoints','In-Transit','Mandatory weighing at checkpoints or borders','Flat Fee',200.00,'Trip','Yes','No','WEIGH-FEE','GL-4011','All equipment types','No','Standard weighbridge charge','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(12,'ACC-TEMP-01','Temperature Monitoring','Additional charge for temperature-controlled shipments','In-Transit','Temperature monitoring and recording required','Per Hour',50.00,'Hours','Yes','No','TEMP-MON','GL-4012','Reefer, insulated trailers only','No','For pharmaceuticals and temperature-sensitive cargo','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(13,'ACC-SEC-01','Security Escort','Armed or unarmed security personnel for high-value cargo','In-Transit','Cargo value exceeds ₹25 lakhs or security requirement','Flat Fee',5000.00,'Trip','Yes','No','SEC-ESCORT','GL-4013','All equipment types','No','Required for high-value electronics, jewelry, cash','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(14,'ACC-BORDER-01','Border Crossing Fee','Additional charges for interstate or international border crossing','In-Transit','Crossing state or international borders','Flat Fee',400.00,'Trip','Yes','No','BORDER-FEE','GL-4014','All equipment types','No','Standard border crossing charge','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(15,'ACC-EQUIP-01','Special Equipment Fee','Additional charge for specialized equipment requirements','General','Specialized equipment like hydraulic lift, crane, etc.','Flat Fee',1500.00,'Trip','Yes','No','SPEC-EQUIP','GL-4015','Specialized equipment only','Yes','Based on equipment type and availability','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System'),(16,'ACC-DOC-01','Documentation Fee','Additional paperwork and documentation processing','General','Complex documentation or special permits required','Flat Fee',300.00,'Trip','Yes','No','DOC-FEE','GL-4016','All equipment types','No','For shipments requiring special permits or documentation','Yes','2025-08-09',NULL,'2025-08-09 12:59:00','2025-08-09 12:59:00','System','System');
/*!40000 ALTER TABLE `accessorial_definitions_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `accessorial_summary_by_category`
--

DROP TABLE IF EXISTS `accessorial_summary_by_category`;
/*!50001 DROP VIEW IF EXISTS `accessorial_summary_by_category`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `accessorial_summary_by_category` AS SELECT 
 1 AS `applies_to`,
 1 AS `total_accessorials`,
 1 AS `taxable_count`,
 1 AS `included_in_base_count`,
 1 AS `carrier_editable_count`,
 1 AS `avg_rate_value`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_accessorials`
--

DROP TABLE IF EXISTS `active_accessorials`;
/*!50001 DROP VIEW IF EXISTS `active_accessorials`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_accessorials` AS SELECT 
 1 AS `accessorial_id`,
 1 AS `accessorial_name`,
 1 AS `applies_to`,
 1 AS `rate_type`,
 1 AS `rate_value`,
 1 AS `unit`,
 1 AS `taxable`,
 1 AS `included_in_base`,
 1 AS `carrier_editable_in_bid`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_bids`
--

DROP TABLE IF EXISTS `active_bids`;
/*!50001 DROP VIEW IF EXISTS `active_bids`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_bids` AS SELECT 
 1 AS `id`,
 1 AS `bid_reference`,
 1 AS `bid_title`,
 1 AS `description`,
 1 AS `bid_type`,
 1 AS `priority`,
 1 AS `bid_start_date`,
 1 AS `bid_end_date`,
 1 AS `submission_deadline`,
 1 AS `award_date`,
 1 AS `contract_start_date`,
 1 AS `contract_end_date`,
 1 AS `budget_amount`,
 1 AS `currency`,
 1 AS `estimated_cost`,
 1 AS `min_bid_amount`,
 1 AS `max_bid_amount`,
 1 AS `status`,
 1 AS `bid_category`,
 1 AS `equipment_requirements`,
 1 AS `service_level_requirements`,
 1 AS `insurance_requirements`,
 1 AS `compliance_requirements`,
 1 AS `origin_regions`,
 1 AS `destination_regions`,
 1 AS `applicable_lanes`,
 1 AS `target_carrier_types`,
 1 AS `max_carriers_per_lane`,
 1 AS `min_carrier_rating`,
 1 AS `evaluation_criteria`,
 1 AS `scoring_matrix`,
 1 AS `is_template`,
 1 AS `allow_partial_awards`,
 1 AS `auto_extend`,
 1 AS `extension_days`,
 1 AS `created_by`,
 1 AS `created_at`,
 1 AS `updated_at`,
 1 AS `published_by`,
 1 AS `published_at`,
 1 AS `closed_by`,
 1 AS `closed_at`,
 1 AS `awarded_by`,
 1 AS `awarded_at`,
 1 AS `external_reference`,
 1 AS `notes`,
 1 AS `attachments`,
 1 AS `total_lanes`,
 1 AS `total_invited_carriers`,
 1 AS `total_responses`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_carriers`
--

DROP TABLE IF EXISTS `active_carriers`;
/*!50001 DROP VIEW IF EXISTS `active_carriers`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_carriers` AS SELECT 
 1 AS `carrier_id`,
 1 AS `carrier_name`,
 1 AS `carrier_code`,
 1 AS `region_coverage`,
 1 AS `fleet_size`,
 1 AS `vehicle_types`,
 1 AS `avg_on_time_performance`,
 1 AS `avg_acceptance_rate`,
 1 AS `billing_accuracy`,
 1 AS `carrier_rating`,
 1 AS `preferred_carrier`,
 1 AS `contracted`,
 1 AS `compliance_valid_until`,
 1 AS `last_load_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_carriers_recent_performance`
--

DROP TABLE IF EXISTS `active_carriers_recent_performance`;
/*!50001 DROP VIEW IF EXISTS `active_carriers_recent_performance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_carriers_recent_performance` AS SELECT 
 1 AS `carrier_id`,
 1 AS `carrier_name`,
 1 AS `period_label`,
 1 AS `total_loads_assigned`,
 1 AS `loads_accepted`,
 1 AS `acceptance_rate`,
 1 AS `overall_on_time_performance`,
 1 AS `billing_accuracy_rate`,
 1 AS `performance_rating`,
 1 AS `scorecard_grade`,
 1 AS `risk_score`,
 1 AS `compliance_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_commodities_by_category`
--

DROP TABLE IF EXISTS `active_commodities_by_category`;
/*!50001 DROP VIEW IF EXISTS `active_commodities_by_category`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_commodities_by_category` AS SELECT 
 1 AS `commodity_category`,
 1 AS `count`,
 1 AS `avg_weight`,
 1 AS `temp_controlled_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_contracts`
--

DROP TABLE IF EXISTS `active_contracts`;
/*!50001 DROP VIEW IF EXISTS `active_contracts`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_contracts` AS SELECT 
 1 AS `contract_id`,
 1 AS `carrier_name`,
 1 AS `carrier_code`,
 1 AS `origin_location`,
 1 AS `destination_location`,
 1 AS `mode`,
 1 AS `equipment_type`,
 1 AS `service_level`,
 1 AS `rate_type`,
 1 AS `base_rate`,
 1 AS `rate_currency`,
 1 AS `effective_from`,
 1 AS `effective_to`,
 1 AS `contract_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_fuel_surcharges`
--

DROP TABLE IF EXISTS `active_fuel_surcharges`;
/*!50001 DROP VIEW IF EXISTS `active_fuel_surcharges`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_fuel_surcharges` AS SELECT 
 1 AS `effective_date`,
 1 AS `fuel_price_min`,
 1 AS `fuel_price_max`,
 1 AS `fuel_surcharge_percentage`,
 1 AS `base_fuel_price`,
 1 AS `change_per_rupee`,
 1 AS `currency`,
 1 AS `applicable_region`,
 1 AS `surcharge_type`,
 1 AS `notes`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_lanes_by_type`
--

DROP TABLE IF EXISTS `active_lanes_by_type`;
/*!50001 DROP VIEW IF EXISTS `active_lanes_by_type`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_lanes_by_type` AS SELECT 
 1 AS `lane_type`,
 1 AS `total_lanes`,
 1 AS `avg_distance_km`,
 1 AS `avg_transit_days`,
 1 AS `avg_monthly_frequency`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_locations_by_type`
--

DROP TABLE IF EXISTS `active_locations_by_type`;
/*!50001 DROP VIEW IF EXISTS `active_locations_by_type`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_locations_by_type` AS SELECT 
 1 AS `location_type`,
 1 AS `count`,
 1 AS `avg_sla`,
 1 AS `parking_available_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_modes_summary`
--

DROP TABLE IF EXISTS `active_modes_summary`;
/*!50001 DROP VIEW IF EXISTS `active_modes_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_modes_summary` AS SELECT 
 1 AS `mode_type`,
 1 AS `total_modes`,
 1 AS `time_definite_modes`,
 1 AS `multileg_modes`,
 1 AS `avg_transit_time`,
 1 AS `high_efficiency_modes`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_routing_guides`
--

DROP TABLE IF EXISTS `active_routing_guides`;
/*!50001 DROP VIEW IF EXISTS `active_routing_guides`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_routing_guides` AS SELECT 
 1 AS `routing_guide_id`,
 1 AS `origin_location`,
 1 AS `destination_location`,
 1 AS `lane_id`,
 1 AS `equipment_type`,
 1 AS `service_level`,
 1 AS `mode`,
 1 AS `primary_carrier_name`,
 1 AS `primary_carrier_rate`,
 1 AS `primary_carrier_rate_type`,
 1 AS `backup_carrier_1_name`,
 1 AS `backup_carrier_2_name`,
 1 AS `tender_sequence`,
 1 AS `tender_lead_time_hours`,
 1 AS `transit_sla_days`,
 1 AS `routing_guide_status`,
 1 AS `valid_from`,
 1 AS `valid_to`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_seasons_overview`
--

DROP TABLE IF EXISTS `active_seasons_overview`;
/*!50001 DROP VIEW IF EXISTS `active_seasons_overview`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_seasons_overview` AS SELECT 
 1 AS `season_id`,
 1 AS `season_name`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `impact_type`,
 1 AS `capacity_risk_level`,
 1 AS `rate_multiplier_percent`,
 1 AS `sla_adjustment_days`,
 1 AS `affected_regions`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `active_service_levels`
--

DROP TABLE IF EXISTS `active_service_levels`;
/*!50001 DROP VIEW IF EXISTS `active_service_levels`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `active_service_levels` AS SELECT 
 1 AS `service_level_id`,
 1 AS `service_level_name`,
 1 AS `service_category`,
 1 AS `max_transit_time_days`,
 1 AS `sla_type`,
 1 AS `priority_tag`,
 1 AS `mode`,
 1 AS `enabled_for_bidding`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bid_carriers`
--

DROP TABLE IF EXISTS `bid_carriers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bid_carriers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bid_id` int NOT NULL,
  `carrier_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `bid_id` (`bid_id`),
  KEY `carrier_id` (`carrier_id`),
  CONSTRAINT `bid_carriers_ibfk_1` FOREIGN KEY (`bid_id`) REFERENCES `bids` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bid_carriers_ibfk_2` FOREIGN KEY (`carrier_id`) REFERENCES `carriers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bid_carriers`
--

LOCK TABLES `bid_carriers` WRITE;
/*!40000 ALTER TABLE `bid_carriers` DISABLE KEYS */;
/*!40000 ALTER TABLE `bid_carriers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bid_lanes`
--

DROP TABLE IF EXISTS `bid_lanes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bid_lanes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bid_id` int NOT NULL,
  `lane_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `bid_id` (`bid_id`),
  KEY `lane_id` (`lane_id`),
  CONSTRAINT `bid_lanes_ibfk_1` FOREIGN KEY (`bid_id`) REFERENCES `bids` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bid_lanes_ibfk_2` FOREIGN KEY (`lane_id`) REFERENCES `lanes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bid_lanes`
--

LOCK TABLES `bid_lanes` WRITE;
/*!40000 ALTER TABLE `bid_lanes` DISABLE KEYS */;
/*!40000 ALTER TABLE `bid_lanes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bid_responses`
--

DROP TABLE IF EXISTS `bid_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bid_responses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bid_id` int NOT NULL,
  `carrier_id` int NOT NULL,
  `proposed_cost` decimal(10,2) NOT NULL,
  `proposed_transit_days` int DEFAULT NULL,
  `status` enum('pending','accepted','rejected') DEFAULT 'pending',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_bid_responses_bid_id` (`bid_id`),
  KEY `idx_bid_responses_carrier_id` (`carrier_id`),
  CONSTRAINT `bid_responses_ibfk_1` FOREIGN KEY (`bid_id`) REFERENCES `bids` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bid_responses_ibfk_2` FOREIGN KEY (`carrier_id`) REFERENCES `carriers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bid_responses`
--

LOCK TABLES `bid_responses` WRITE;
/*!40000 ALTER TABLE `bid_responses` DISABLE KEYS */;
INSERT INTO `bid_responses` VALUES (1,1,1,2400.00,5,'pending',NULL,'2025-08-09 07:05:12','2025-08-09 07:05:12'),(2,2,1,1150.00,2,'pending',NULL,'2025-08-09 07:05:12','2025-08-09 07:05:12');
/*!40000 ALTER TABLE `bid_responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `bid_statistics`
--

DROP TABLE IF EXISTS `bid_statistics`;
/*!50001 DROP VIEW IF EXISTS `bid_statistics`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `bid_statistics` AS SELECT 
 1 AS `bid_type`,
 1 AS `status`,
 1 AS `bid_count`,
 1 AS `avg_budget`,
 1 AS `avg_estimated_cost`,
 1 AS `min_budget`,
 1 AS `max_budget`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bids` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `lane_id` int DEFAULT NULL,
  `estimated_cost` decimal(10,2) DEFAULT NULL,
  `status` enum('open','awarded','closed','cancelled') DEFAULT 'open',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `idx_bids_lane_id` (`lane_id`),
  KEY `idx_bids_status` (`status`),
  CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`lane_id`) REFERENCES `lanes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bids_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids`
--

LOCK TABLES `bids` WRITE;
/*!40000 ALTER TABLE `bids` DISABLE KEYS */;
INSERT INTO `bids` VALUES (1,'NYC to LA Express','Fast delivery from New York to Los Angeles',1,2500.00,'open',2,'2025-08-09 07:05:12','2025-08-09 07:05:12'),(2,'Chicago to Houston','Reliable shipping from Chicago to Houston',2,1200.00,'open',2,'2025-08-09 07:05:12','2025-08-09 07:05:12'),(12,'routecraft','routecraft',1,100.00,'open',1,'2025-08-10 21:02:04','2025-08-10 21:02:04'),(13,'routecraft','git push origin main --force',2,10000.00,'open',1,'2025-08-10 21:06:18','2025-08-10 21:06:18');
/*!40000 ALTER TABLE `bids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bids_master`
--

DROP TABLE IF EXISTS `bids_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bids_master` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bid_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique bid reference number',
  `bid_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Title/name of the bid',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Detailed description of the bid requirements',
  `bid_type` enum('contract','spot','seasonal','regional','tender') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Type of bid',
  `priority` enum('low','medium','high','urgent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium' COMMENT 'Bid priority level',
  `bid_start_date` date NOT NULL COMMENT 'When the bid becomes active',
  `bid_end_date` date NOT NULL COMMENT 'When the bid expires',
  `submission_deadline` datetime NOT NULL COMMENT 'Deadline for carrier submissions',
  `award_date` date DEFAULT NULL COMMENT 'When the bid was awarded',
  `contract_start_date` date DEFAULT NULL COMMENT 'Contract start date if awarded',
  `contract_end_date` date DEFAULT NULL COMMENT 'Contract end date if awarded',
  `budget_amount` decimal(12,2) DEFAULT NULL COMMENT 'Budget allocated for this bid',
  `currency` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'INR' COMMENT 'Currency for financial values',
  `estimated_cost` decimal(12,2) DEFAULT NULL COMMENT 'Estimated cost for the bid',
  `min_bid_amount` decimal(12,2) DEFAULT NULL COMMENT 'Minimum acceptable bid amount',
  `max_bid_amount` decimal(12,2) DEFAULT NULL COMMENT 'Maximum acceptable bid amount',
  `status` enum('draft','published','open','evaluating','awarded','closed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'draft' COMMENT 'Current bid status',
  `bid_category` enum('freight','warehousing','last_mile','cross_border','specialized') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'freight' COMMENT 'Category of services',
  `equipment_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Required equipment types and specifications',
  `service_level_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Service level requirements (SLA)',
  `insurance_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Insurance and liability requirements',
  `compliance_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Regulatory and compliance requirements',
  `origin_regions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Origin regions/cities covered',
  `destination_regions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Destination regions/cities covered',
  `applicable_lanes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Specific lanes or routes covered',
  `target_carrier_types` enum('all','preferred','certified','regional') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'all' COMMENT 'Types of carriers eligible',
  `max_carriers_per_lane` int DEFAULT '5' COMMENT 'Maximum carriers per lane',
  `min_carrier_rating` decimal(3,2) DEFAULT '3.00' COMMENT 'Minimum carrier rating required',
  `evaluation_criteria` json DEFAULT NULL COMMENT 'JSON object defining evaluation criteria and weights',
  `scoring_matrix` json DEFAULT NULL COMMENT 'Scoring matrix for bid evaluation',
  `is_template` tinyint(1) DEFAULT '0' COMMENT 'Whether this bid can be used as a template',
  `allow_partial_awards` tinyint(1) DEFAULT '0' COMMENT 'Allow partial lane awards',
  `auto_extend` tinyint(1) DEFAULT '0' COMMENT 'Auto-extend if no responses',
  `extension_days` int DEFAULT '7' COMMENT 'Days to extend if auto-extend is enabled',
  `created_by` int NOT NULL COMMENT 'User ID who created the bid',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `published_by` int DEFAULT NULL COMMENT 'User ID who published the bid',
  `published_at` timestamp NULL DEFAULT NULL COMMENT 'When the bid was published',
  `closed_by` int DEFAULT NULL COMMENT 'User ID who closed the bid',
  `closed_at` timestamp NULL DEFAULT NULL COMMENT 'When the bid was closed',
  `awarded_by` int DEFAULT NULL COMMENT 'User ID who awarded the bid',
  `awarded_at` timestamp NULL DEFAULT NULL COMMENT 'When the bid was awarded',
  `external_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'External system reference',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Additional notes and comments',
  `attachments` json DEFAULT NULL COMMENT 'JSON array of attachment references',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid_reference` (`bid_reference`),
  KEY `idx_bid_reference` (`bid_reference`),
  KEY `idx_status` (`status`),
  KEY `idx_bid_type` (`bid_type`),
  KEY `idx_priority` (`priority`),
  KEY `idx_submission_deadline` (`submission_deadline`),
  KEY `idx_bid_dates` (`bid_start_date`,`bid_end_date`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_budget_range` (`min_bid_amount`,`max_bid_amount`),
  KEY `idx_category` (`bid_category`),
  KEY `idx_created_at` (`created_at`),
  KEY `published_by` (`published_by`),
  KEY `closed_by` (`closed_by`),
  KEY `awarded_by` (`awarded_by`),
  CONSTRAINT `bids_master_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `bids_master_ibfk_2` FOREIGN KEY (`published_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bids_master_ibfk_3` FOREIGN KEY (`closed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bids_master_ibfk_4` FOREIGN KEY (`awarded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for comprehensive bid management in TL transportation';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids_master`
--

LOCK TABLES `bids_master` WRITE;
/*!40000 ALTER TABLE `bids_master` DISABLE KEYS */;
INSERT INTO `bids_master` VALUES (1,'BID-2025-001','Mumbai-Delhi Express Freight Service','High-priority freight service between Mumbai and Delhi with daily departures','contract','high','2025-01-01','2025-12-31','2024-12-15 18:00:00',NULL,NULL,NULL,5000000.00,'INR',4500000.00,NULL,NULL,'published','freight','20ft and 40ft containers, flatbed trailers','24-hour delivery guarantee',NULL,NULL,'Mumbai, Pune, Nashik','Delhi, Noida, Gurgaon',NULL,'preferred',3,4.00,NULL,NULL,0,0,0,7,1,'2025-08-09 14:52:32','2025-08-09 14:52:32',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,'BID-2025-002','Bangalore-Chennai Seasonal Transport','Seasonal transport service for agricultural products','seasonal','medium','2025-03-01','2025-08-31','2025-02-15 18:00:00',NULL,NULL,NULL,2000000.00,'INR',1800000.00,NULL,NULL,'open','freight','Reefer trailers, temperature-controlled containers','Temperature monitoring and reporting',NULL,NULL,'Bangalore, Mysore','Chennai, Coimbatore',NULL,'certified',2,4.50,NULL,NULL,0,0,0,7,1,'2025-08-09 14:52:32','2025-08-09 14:52:32',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,'BID-2025-003','Pan-India Spot Freight Services','On-demand spot freight services across major Indian cities','spot','urgent','2025-01-01','2025-12-31','2024-12-20 18:00:00',NULL,NULL,NULL,10000000.00,'INR',9000000.00,NULL,NULL,'draft','freight','All equipment types accepted','Flexible delivery windows',NULL,NULL,'All major cities','All major cities',NULL,'all',10,3.00,NULL,NULL,0,0,0,7,1,'2025-08-09 14:52:32','2025-08-09 14:52:32',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `bids_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `carrier_editable_accessorials`
--

DROP TABLE IF EXISTS `carrier_editable_accessorials`;
/*!50001 DROP VIEW IF EXISTS `carrier_editable_accessorials`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `carrier_editable_accessorials` AS SELECT 
 1 AS `accessorial_id`,
 1 AS `accessorial_name`,
 1 AS `applies_to`,
 1 AS `rate_type`,
 1 AS `rate_value`,
 1 AS `unit`,
 1 AS `remarks`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `carrier_historical_metrics`
--

DROP TABLE IF EXISTS `carrier_historical_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `carrier_historical_metrics` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `carrier_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique carrier reference (linked to Carrier Master)',
  `carrier_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'For readability and reporting',
  `period_type` enum('Weekly','Monthly','Quarterly','Yearly') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Time period granularity',
  `period_start_date` date NOT NULL COMMENT 'Start of the reporting period',
  `period_end_date` date NOT NULL COMMENT 'End of the reporting period',
  `period_label` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Human readable period (e.g., May 2025, Q1 FY25)',
  `lane_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Optional - performance by specific lane (Origin → Destination)',
  `origin_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Origin city/state for lane-specific metrics',
  `destination_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Destination city/state for lane-specific metrics',
  `equipment_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Equipment type (e.g., 32ft SXL, Reefer, Container)',
  `total_loads_assigned` int NOT NULL DEFAULT '0' COMMENT 'Number of loads given in the period',
  `loads_accepted` int NOT NULL DEFAULT '0' COMMENT 'Number of loads accepted by carrier',
  `loads_rejected` int NOT NULL DEFAULT '0' COMMENT 'Number of loads rejected by carrier',
  `loads_cancelled_by_carrier` int NOT NULL DEFAULT '0' COMMENT 'How many accepted loads they cancelled',
  `loads_completed` int NOT NULL DEFAULT '0' COMMENT 'Successfully completed loads',
  `acceptance_rate` decimal(5,2) DEFAULT NULL COMMENT '= (Accepted / Assigned) * 100',
  `completion_rate` decimal(5,2) DEFAULT NULL COMMENT '= (Completed / Accepted) * 100',
  `on_time_pickup_rate` decimal(5,2) DEFAULT NULL COMMENT '% of pickups made on/before scheduled time',
  `on_time_delivery_rate` decimal(5,2) DEFAULT NULL COMMENT '% of deliveries made on/before scheduled time',
  `overall_on_time_performance` decimal(5,2) DEFAULT NULL COMMENT 'Combined pickup and delivery OTP',
  `late_pickup_count` int NOT NULL DEFAULT '0' COMMENT 'Absolute count of late pickups',
  `late_delivery_count` int NOT NULL DEFAULT '0' COMMENT 'Absolute count of late deliveries',
  `early_pickup_count` int NOT NULL DEFAULT '0' COMMENT 'Early pickups (good performance)',
  `early_delivery_count` int NOT NULL DEFAULT '0' COMMENT 'Early deliveries (good performance)',
  `billing_accuracy_rate` decimal(5,2) DEFAULT NULL COMMENT '% of invoices with no dispute or mismatch',
  `billing_disputes_count` int NOT NULL DEFAULT '0' COMMENT 'Number of billing disputes',
  `average_detention_time_hours` decimal(6,2) DEFAULT NULL COMMENT 'Time carrier waited during loading/unloading',
  `detention_charges_applied` decimal(10,2) DEFAULT NULL COMMENT 'Total detention charges applied',
  `claim_incidents_count` int NOT NULL DEFAULT '0' COMMENT 'Count of reported damage/loss claims',
  `claim_percentage` decimal(5,2) DEFAULT NULL COMMENT '(Claim Incidents / Loads) * 100',
  `customer_complaints_count` int NOT NULL DEFAULT '0' COMMENT 'Count of complaints raised',
  `quality_issues_count` int NOT NULL DEFAULT '0' COMMENT 'Other quality-related issues',
  `performance_rating` decimal(3,1) DEFAULT NULL COMMENT 'Internal performance score (1.0-5.0)',
  `scorecard_grade` enum('A+','A','A-','B+','B','B-','C+','C','C-','D','E') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Letter grade classification',
  `risk_score` decimal(5,2) DEFAULT NULL COMMENT 'Risk assessment score (0-100, lower is better)',
  `average_transit_time_hours` decimal(6,2) DEFAULT NULL COMMENT 'Average time from pickup to delivery',
  `fuel_efficiency_score` decimal(5,2) DEFAULT NULL COMMENT 'Fuel consumption efficiency rating',
  `driver_behavior_score` decimal(5,2) DEFAULT NULL COMMENT 'Driver conduct and professionalism rating',
  `is_blacklisted` tinyint(1) DEFAULT '0' COMMENT 'Whether carrier is blacklisted in this period',
  `is_preferred_carrier` tinyint(1) DEFAULT '0' COMMENT 'Whether carrier was preferred in this period',
  `compliance_status` enum('Compliant','Non-Compliant','Under Review') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Compliant' COMMENT 'Compliance status for the period',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Qualitative notes (e.g., repeated no-shows, exceptional service)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who created the metrics record',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who last updated the metrics record',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_carrier_period_lane` (`carrier_id`,`period_type`,`period_start_date`,`lane_id`),
  KEY `idx_carrier_id` (`carrier_id`),
  KEY `idx_period_dates` (`period_start_date`,`period_end_date`),
  KEY `idx_period_type` (`period_type`),
  KEY `idx_lane_id` (`lane_id`),
  KEY `idx_equipment_type` (`equipment_type`),
  KEY `idx_acceptance_rate` (`acceptance_rate`),
  KEY `idx_otp_pickup` (`on_time_pickup_rate`),
  KEY `idx_otp_delivery` (`on_time_delivery_rate`),
  KEY `idx_overall_otp` (`overall_on_time_performance`),
  KEY `idx_billing_accuracy` (`billing_accuracy_rate`),
  KEY `idx_performance_rating` (`performance_rating`),
  KEY `idx_scorecard_grade` (`scorecard_grade`),
  KEY `idx_risk_score` (`risk_score`),
  KEY `idx_compliance_status` (`compliance_status`),
  KEY `idx_is_blacklisted` (`is_blacklisted`),
  KEY `idx_is_preferred_carrier` (`is_preferred_carrier`),
  CONSTRAINT `carrier_historical_metrics_ibfk_1` FOREIGN KEY (`carrier_id`) REFERENCES `carrier_master` (`carrier_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Carrier Historical Metrics for TL transportation procurement - captures performance data over time for each carrier';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carrier_historical_metrics`
--

LOCK TABLES `carrier_historical_metrics` WRITE;
/*!40000 ALTER TABLE `carrier_historical_metrics` DISABLE KEYS */;
INSERT INTO `carrier_historical_metrics` VALUES (1,'CAR-001','ABC Transport Ltd','Monthly','2024-08-06','2024-08-31','August 2024','LANE-12-01','Pune, Maharashtra','Ahmedabad, Gujarat','20ft Container',48,44,4,0,40,91.67,90.91,80.88,92.03,86.45,1,9,1,2,92.56,2,5.97,1127.56,1,0.00,2,1,2.8,'C+',52.88,59.47,87.07,84.61,0,1,'Compliant','Monthly performance metrics for August 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(2,'CAR-002','Gati Ltd','Monthly','2024-08-06','2024-08-31','August 2024','LANE-12-02','Chennai, Tamil Nadu','Hyderabad, Telangana','Flatbed Trailer',38,27,11,1,22,71.05,81.48,78.23,83.13,80.68,0,5,0,1,95.14,1,6.87,3739.96,0,4.55,0,0,4.1,'B+',23.40,50.68,74.97,76.41,0,1,'Compliant','Monthly performance metrics for August 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(3,'CAR-003','South Express','Monthly','2024-08-06','2024-08-31','August 2024','LANE-12-03','Kolkata, West Bengal','Pune, Maharashtra','20ft Container',20,14,6,1,14,70.00,100.00,76.10,90.33,83.22,2,0,1,2,85.35,0,2.69,4961.92,2,7.14,2,1,3.0,'C',33.81,70.17,79.50,83.73,0,0,'Compliant','Monthly performance metrics for August 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(4,'CAR-004','Cold Chain Express','Monthly','2024-08-06','2024-08-31','August 2024','LANE-12-04','Gurgaon, Haryana','Bangalore, Karnataka','Flatbed Trailer',38,26,12,0,22,68.42,84.62,95.71,88.09,91.90,0,0,0,0,86.15,2,3.08,3089.97,1,4.55,0,1,3.6,'B+',23.03,38.77,76.08,84.09,0,0,'Compliant','Monthly performance metrics for August 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(5,'CAR-005','East West Cargo','Monthly','2024-08-06','2024-08-31','August 2024','LANE-12-05','Kolkata, West Bengal','Pune, Maharashtra','32ft SXL',25,17,8,0,16,68.00,94.12,88.83,83.03,85.93,1,2,1,0,95.21,1,3.70,4234.67,0,12.50,1,1,4.3,'B-',13.84,64.66,91.57,96.87,0,0,'Compliant','Monthly performance metrics for August 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(6,'CAR-001','ABC Transport Ltd','Monthly','2024-09-05','2024-09-30','September 2024','LANE-11-01','Kolkata, West Bengal','Pune, Maharashtra','Reefer Trailer',45,44,1,3,39,97.78,88.64,88.66,84.90,86.78,7,0,1,2,86.04,3,4.04,2053.57,2,2.56,0,0,3.1,'C-',34.01,41.44,93.72,81.51,0,1,'Compliant','Monthly performance metrics for September 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(7,'CAR-002','Gati Ltd','Monthly','2024-09-05','2024-09-30','September 2024','LANE-11-02','Mumbai, Maharashtra','Delhi, Delhi','32ft SXL',36,26,10,1,25,72.22,96.15,83.62,82.59,83.11,6,1,3,2,87.07,3,7.65,2952.38,2,8.00,0,1,3.0,'C',43.70,40.62,78.08,95.17,0,0,'Compliant','Monthly performance metrics for September 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(8,'CAR-003','South Express','Monthly','2024-09-05','2024-09-30','September 2024','LANE-11-03','Pune, Maharashtra','Ahmedabad, Gujarat','Flatbed Trailer',35,35,0,1,30,100.00,85.71,96.50,89.13,92.81,3,7,6,0,94.90,1,7.83,2265.73,2,3.33,2,0,3.2,'C-',43.76,27.12,85.46,89.79,0,1,'Compliant','Monthly performance metrics for September 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(9,'CAR-004','Cold Chain Express','Monthly','2024-09-05','2024-09-30','September 2024','LANE-11-04','Mumbai, Maharashtra','Delhi, Delhi','20ft Container',23,21,2,0,17,91.30,80.95,87.42,85.83,86.62,4,2,1,1,89.70,2,6.56,1384.57,1,11.76,0,1,3.8,'B+',17.51,24.12,83.92,79.27,0,1,'Compliant','Monthly performance metrics for September 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(10,'CAR-005','East West Cargo','Monthly','2024-09-05','2024-09-30','September 2024','LANE-11-05','Gurgaon, Haryana','Bangalore, Karnataka','32ft Trailer',28,27,1,0,25,96.43,92.59,92.45,88.30,90.38,6,5,4,2,97.71,1,2.21,2111.22,2,0.00,2,0,2.9,'C',38.64,47.04,84.97,90.44,0,1,'Compliant','Monthly performance metrics for September 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(11,'CAR-001','ABC Transport Ltd','Monthly','2024-10-05','2024-10-31','October 2024','LANE-10-01','Kolkata, West Bengal','Pune, Maharashtra','32ft SXL',40,28,12,0,24,70.00,85.71,83.90,86.27,85.09,7,4,5,0,91.65,2,2.82,1974.82,1,0.00,0,0,4.8,'A',0.00,65.13,78.68,76.65,0,1,'Compliant','Monthly performance metrics for October 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(12,'CAR-002','Gati Ltd','Monthly','2024-10-05','2024-10-31','October 2024','LANE-10-02','Kolkata, West Bengal','Pune, Maharashtra','Reefer Trailer',31,23,8,2,23,74.19,100.00,83.06,92.47,87.77,4,0,4,0,88.24,3,6.46,2668.10,1,8.70,2,0,2.6,'C-',55.32,50.45,73.37,85.77,0,0,'Compliant','Monthly performance metrics for October 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(13,'CAR-003','South Express','Monthly','2024-10-05','2024-10-31','October 2024','LANE-10-03','Mumbai, Maharashtra','Delhi, Delhi','32ft SXL',38,27,11,0,22,71.05,81.48,76.27,80.06,78.16,1,3,0,0,90.10,1,7.32,3656.38,2,9.09,2,1,4.2,'B',21.34,49.50,83.37,85.45,0,0,'Compliant','Monthly performance metrics for October 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(14,'CAR-004','Cold Chain Express','Monthly','2024-10-05','2024-10-31','October 2024','LANE-10-04','Gurgaon, Haryana','Bangalore, Karnataka','Reefer Trailer',32,22,10,1,19,68.75,86.36,76.08,85.41,80.75,4,1,2,2,95.33,2,3.14,3126.64,2,5.26,2,0,3.3,'C-',39.01,71.03,83.36,84.41,0,1,'Compliant','Monthly performance metrics for October 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(15,'CAR-005','East West Cargo','Monthly','2024-10-05','2024-10-31','October 2024','LANE-10-05','Kolkata, West Bengal','Pune, Maharashtra','32ft SXL',35,32,3,3,30,91.43,93.75,91.17,93.06,92.12,5,3,5,4,97.38,1,7.06,222.76,0,3.33,1,0,4.5,'A+',14.61,57.24,86.18,81.42,0,1,'Compliant','Monthly performance metrics for October 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(16,'CAR-001','ABC Transport Ltd','Monthly','2024-11-04','2024-11-30','November 2024','LANE-09-01','Kolkata, West Bengal','Pune, Maharashtra','20ft Container',43,34,9,1,34,79.07,100.00,97.20,93.27,95.23,9,3,5,0,87.64,0,5.05,2869.67,0,5.88,0,1,3.1,'C+',31.60,28.22,94.23,83.98,0,1,'Compliant','Monthly performance metrics for November 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(17,'CAR-002','Gati Ltd','Monthly','2024-11-04','2024-11-30','November 2024','LANE-09-02','Kolkata, West Bengal','Pune, Maharashtra','Flatbed Trailer',48,40,8,4,40,83.33,100.00,96.17,88.06,92.12,6,8,7,5,88.74,2,5.45,4829.24,2,0.00,2,0,3.4,'C',26.99,28.55,78.76,97.32,0,0,'Compliant','Monthly performance metrics for November 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(18,'CAR-003','South Express','Monthly','2024-11-04','2024-11-30','November 2024','LANE-09-03','Mumbai, Maharashtra','Delhi, Delhi','Flatbed Trailer',22,19,3,1,19,86.36,100.00,77.91,86.88,82.39,1,2,0,2,87.75,1,7.12,3563.50,2,5.26,0,1,4.7,'A+',3.08,34.11,86.69,78.48,0,0,'Compliant','Monthly performance metrics for November 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(19,'CAR-004','Cold Chain Express','Monthly','2024-11-04','2024-11-30','November 2024','LANE-09-04','Pune, Maharashtra','Ahmedabad, Gujarat','32ft SXL',37,37,0,2,33,100.00,89.19,96.63,94.98,95.81,4,5,1,3,90.61,0,7.47,1350.09,1,3.03,0,0,3.9,'B-',24.23,68.15,73.36,76.81,0,1,'Compliant','Monthly performance metrics for November 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(20,'CAR-005','East West Cargo','Monthly','2024-11-04','2024-11-30','November 2024','LANE-09-05','Pune, Maharashtra','Ahmedabad, Gujarat','20ft Container',32,23,9,0,23,71.88,100.00,93.38,81.29,87.34,2,0,3,3,94.40,0,7.56,4551.57,2,0.00,0,0,3.7,'B+',31.81,62.68,83.86,77.14,0,0,'Compliant','Monthly performance metrics for November 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(21,'CAR-001','ABC Transport Ltd','Monthly','2024-12-04','2024-12-31','December 2024','LANE-08-01','Kolkata, West Bengal','Pune, Maharashtra','32ft SXL',38,26,12,2,25,68.42,96.15,79.00,88.02,83.51,7,2,1,3,87.95,1,5.42,4357.98,2,0.00,1,0,3.5,'B+',38.72,67.65,85.29,80.89,0,0,'Compliant','Monthly performance metrics for December 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(22,'CAR-002','Gati Ltd','Monthly','2024-12-04','2024-12-31','December 2024','LANE-08-02','Chennai, Tamil Nadu','Hyderabad, Telangana','Flatbed Trailer',41,33,8,3,30,80.49,90.91,85.17,89.65,87.41,6,5,4,4,91.91,0,6.16,4948.13,2,0.00,1,0,4.3,'B-',6.95,27.74,91.16,82.51,0,0,'Compliant','Monthly performance metrics for December 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(23,'CAR-003','South Express','Monthly','2024-12-04','2024-12-31','December 2024','LANE-08-03','Mumbai, Maharashtra','Delhi, Delhi','Reefer Trailer',45,44,1,1,40,97.78,90.91,91.62,83.58,87.60,0,8,2,5,88.84,1,5.85,4185.90,2,5.00,1,1,3.0,'C+',34.15,57.55,87.23,81.97,0,0,'Compliant','Monthly performance metrics for December 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(24,'CAR-004','Cold Chain Express','Monthly','2024-12-04','2024-12-31','December 2024','LANE-08-04','Mumbai, Maharashtra','Delhi, Delhi','32ft SXL',36,36,0,0,36,100.00,100.00,97.75,87.43,92.59,9,4,7,1,89.40,0,4.28,2908.62,0,0.00,1,0,3.2,'C',31.39,55.84,93.70,86.24,0,1,'Compliant','Monthly performance metrics for December 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(25,'CAR-005','East West Cargo','Monthly','2024-12-04','2024-12-31','December 2024','LANE-08-05','Pune, Maharashtra','Ahmedabad, Gujarat','32ft SXL',23,22,1,1,18,95.65,81.82,91.50,81.57,86.53,1,1,2,0,98.98,0,5.28,2339.82,1,5.56,0,0,3.7,'B-',21.74,35.40,81.01,90.95,0,1,'Compliant','Monthly performance metrics for December 2024','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(26,'CAR-001','ABC Transport Ltd','Monthly','2025-01-03','2025-01-31','January 2025','LANE-07-01','Pune, Maharashtra','Ahmedabad, Gujarat','32ft Trailer',29,25,4,1,25,86.21,100.00,79.22,81.40,80.31,4,1,5,0,85.09,1,7.87,2282.55,1,0.00,1,1,4.2,'B-',25.54,32.07,72.68,94.88,0,1,'Compliant','Monthly performance metrics for January 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(27,'CAR-002','Gati Ltd','Monthly','2025-01-03','2025-01-31','January 2025','LANE-07-02','Chennai, Tamil Nadu','Hyderabad, Telangana','20ft Container',45,39,6,2,38,86.67,97.44,81.35,82.13,81.74,6,9,5,1,94.87,3,2.30,3220.71,1,0.00,1,0,3.6,'B+',26.48,61.35,74.89,89.72,0,0,'Compliant','Monthly performance metrics for January 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(28,'CAR-003','South Express','Monthly','2025-01-03','2025-01-31','January 2025','LANE-07-03','Gurgaon, Haryana','Bangalore, Karnataka','32ft SXL',48,40,8,0,34,83.33,85.00,86.12,84.35,85.23,7,2,8,0,88.43,1,5.19,4744.93,0,0.00,2,1,2.8,'C+',44.80,26.82,72.12,87.30,0,0,'Compliant','Monthly performance metrics for January 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(29,'CAR-004','Cold Chain Express','Monthly','2025-01-03','2025-01-31','January 2025','LANE-07-04','Chennai, Tamil Nadu','Hyderabad, Telangana','20ft Container',44,42,2,0,40,95.45,95.24,97.10,94.08,95.59,7,2,2,0,85.12,2,6.10,4805.88,0,2.50,0,0,4.1,'B',25.50,55.73,74.08,83.97,0,1,'Compliant','Monthly performance metrics for January 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(30,'CAR-005','East West Cargo','Monthly','2025-01-03','2025-01-31','January 2025','LANE-07-05','Chennai, Tamil Nadu','Hyderabad, Telangana','32ft Trailer',44,41,3,1,36,93.18,87.80,90.99,83.92,87.45,12,3,4,0,85.21,0,5.53,2926.44,0,5.56,2,1,4.3,'B+',16.68,26.52,85.45,97.57,0,0,'Compliant','Monthly performance metrics for January 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(31,'CAR-001','ABC Transport Ltd','Monthly','2025-02-02','2025-02-28','February 2025','LANE-06-01','Chennai, Tamil Nadu','Hyderabad, Telangana','32ft SXL',42,35,7,3,31,83.33,88.57,94.56,81.26,87.91,1,6,5,0,93.27,2,3.45,2005.68,1,0.00,2,1,4.1,'B+',17.73,65.58,70.99,91.40,0,0,'Compliant','Monthly performance metrics for February 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(32,'CAR-002','Gati Ltd','Monthly','2025-02-02','2025-02-28','February 2025','LANE-06-02','Pune, Maharashtra','Ahmedabad, Gujarat','Flatbed Trailer',33,24,9,1,23,72.73,95.83,77.98,89.56,83.77,5,5,4,0,95.32,0,6.49,3500.34,1,0.00,0,1,3.1,'C',46.35,26.09,82.51,94.11,0,0,'Compliant','Monthly performance metrics for February 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(33,'CAR-003','South Express','Monthly','2025-02-02','2025-02-28','February 2025','LANE-06-03','Kolkata, West Bengal','Pune, Maharashtra','Reefer Trailer',41,33,8,1,33,80.49,100.00,76.24,90.77,83.50,3,8,6,1,88.54,3,6.58,4093.53,1,6.06,2,0,3.0,'C',35.18,65.46,85.93,81.33,0,0,'Compliant','Monthly performance metrics for February 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(34,'CAR-004','Cold Chain Express','Monthly','2025-02-02','2025-02-28','February 2025','LANE-06-04','Pune, Maharashtra','Ahmedabad, Gujarat','32ft Trailer',23,16,7,0,15,69.57,93.75,97.48,94.87,96.18,2,3,1,2,88.11,3,6.74,4630.06,2,13.33,2,0,4.3,'B',13.97,60.87,94.05,79.81,0,1,'Compliant','Monthly performance metrics for February 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(35,'CAR-005','East West Cargo','Monthly','2025-02-02','2025-02-28','February 2025','LANE-06-05','Pune, Maharashtra','Ahmedabad, Gujarat','Reefer Trailer',40,31,9,3,30,77.50,96.77,75.65,92.72,84.19,6,5,5,1,90.92,3,5.60,2312.01,0,6.67,1,0,4.7,'A+',6.22,45.97,71.92,91.67,0,0,'Compliant','Monthly performance metrics for February 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(36,'CAR-001','ABC Transport Ltd','Monthly','2025-03-04','2025-03-31','March 2025','LANE-05-01','Kolkata, West Bengal','Pune, Maharashtra','20ft Container',37,25,12,0,21,67.57,84.00,76.11,89.90,83.00,1,2,5,3,85.71,0,3.70,2474.75,2,9.52,0,0,3.6,'B',23.36,64.63,74.98,79.62,0,1,'Compliant','Monthly performance metrics for March 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(37,'CAR-002','Gati Ltd','Monthly','2025-03-04','2025-03-31','March 2025','LANE-05-02','Gurgaon, Haryana','Bangalore, Karnataka','20ft Container',24,19,5,1,17,79.17,89.47,83.65,89.05,86.35,2,0,0,1,95.89,2,6.72,462.48,0,5.88,1,1,3.5,'B-',38.81,33.26,85.26,75.54,0,0,'Compliant','Monthly performance metrics for March 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(38,'CAR-003','South Express','Monthly','2025-03-04','2025-03-31','March 2025','LANE-05-03','Pune, Maharashtra','Ahmedabad, Gujarat','20ft Container',41,39,2,1,38,95.12,97.44,86.53,80.63,83.58,11,3,6,2,98.29,1,3.65,4619.26,0,5.26,0,0,3.5,'B-',34.36,56.85,71.85,91.61,0,0,'Compliant','Monthly performance metrics for March 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(39,'CAR-004','Cold Chain Express','Monthly','2025-03-04','2025-03-31','March 2025','LANE-05-04','Mumbai, Maharashtra','Delhi, Delhi','Flatbed Trailer',27,19,8,0,18,70.37,94.74,77.73,87.22,82.47,1,0,2,1,90.55,2,6.11,2911.22,0,11.11,2,0,4.4,'B-',14.90,41.29,94.84,82.79,0,1,'Compliant','Monthly performance metrics for March 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(40,'CAR-005','East West Cargo','Monthly','2025-03-04','2025-03-31','March 2025','LANE-05-05','Chennai, Tamil Nadu','Hyderabad, Telangana','20ft Container',29,20,9,0,17,68.97,85.00,93.91,88.57,91.24,1,1,3,2,92.54,2,7.73,2226.15,2,0.00,1,0,3.6,'B',18.92,53.00,90.94,92.82,0,1,'Compliant','Monthly performance metrics for March 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(41,'CAR-001','ABC Transport Ltd','Monthly','2025-04-03','2025-04-30','April 2025','LANE-04-01','Kolkata, West Bengal','Pune, Maharashtra','20ft Container',31,29,2,1,29,93.55,100.00,96.84,81.13,88.98,7,0,3,2,85.07,3,4.66,911.17,0,0.00,0,0,3.5,'B+',21.96,52.87,86.86,87.23,0,0,'Compliant','Monthly performance metrics for April 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(42,'CAR-002','Gati Ltd','Monthly','2025-04-03','2025-04-30','April 2025','LANE-04-02','Gurgaon, Haryana','Bangalore, Karnataka','32ft Trailer',44,37,7,1,32,84.09,86.49,78.52,86.50,82.51,5,3,1,0,88.00,2,6.65,2335.93,0,6.25,2,1,3.9,'B-',31.60,32.46,80.25,78.39,0,0,'Compliant','Monthly performance metrics for April 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(43,'CAR-003','South Express','Monthly','2025-04-03','2025-04-30','April 2025','LANE-04-03','Chennai, Tamil Nadu','Hyderabad, Telangana','Reefer Trailer',17,13,4,1,12,76.47,92.31,92.45,87.82,90.13,0,2,0,0,88.48,1,3.72,2856.62,2,0.00,0,1,3.1,'C',30.78,25.31,75.72,93.03,0,0,'Compliant','Monthly performance metrics for April 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(44,'CAR-004','Cold Chain Express','Monthly','2025-04-03','2025-04-30','April 2025','LANE-04-04','Pune, Maharashtra','Ahmedabad, Gujarat','Flatbed Trailer',26,25,1,0,25,96.15,100.00,85.47,87.42,86.44,3,3,3,3,92.17,0,2.44,3390.00,1,8.00,1,1,3.2,'C',45.48,70.69,92.14,79.81,0,0,'Compliant','Monthly performance metrics for April 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(45,'CAR-005','East West Cargo','Monthly','2025-04-03','2025-04-30','April 2025','LANE-04-05','Mumbai, Maharashtra','Delhi, Delhi','20ft Container',27,19,8,1,19,70.37,100.00,85.90,85.69,85.80,2,2,2,0,85.13,0,2.82,2203.64,1,0.00,2,1,3.3,'C-',27.59,36.06,83.89,88.74,0,0,'Compliant','Monthly performance metrics for April 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(46,'CAR-001','ABC Transport Ltd','Monthly','2025-05-03','2025-05-31','May 2025','LANE-03-01','Chennai, Tamil Nadu','Hyderabad, Telangana','20ft Container',43,36,7,3,32,83.72,88.89,95.49,91.20,93.34,0,1,4,2,89.23,0,2.54,3490.46,0,3.12,0,1,2.6,'C+',50.89,64.43,94.15,95.88,0,0,'Compliant','Monthly performance metrics for May 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(47,'CAR-002','Gati Ltd','Monthly','2025-05-03','2025-05-31','May 2025','LANE-03-02','Mumbai, Maharashtra','Delhi, Delhi','Flatbed Trailer',37,32,5,3,27,86.49,84.38,80.18,85.75,82.97,3,6,3,0,95.13,2,3.05,4432.30,1,3.70,0,0,4.5,'A',9.20,46.43,89.98,87.05,0,1,'Compliant','Monthly performance metrics for May 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(48,'CAR-003','South Express','Monthly','2025-05-03','2025-05-31','May 2025','LANE-03-03','Kolkata, West Bengal','Pune, Maharashtra','Flatbed Trailer',16,16,0,0,13,100.00,81.25,93.42,82.37,87.90,0,0,1,0,87.98,0,2.08,4988.41,1,15.38,1,1,2.7,'C-',46.24,62.39,89.68,95.68,0,0,'Compliant','Monthly performance metrics for May 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(49,'CAR-004','Cold Chain Express','Monthly','2025-05-03','2025-05-31','May 2025','LANE-03-04','Gurgaon, Haryana','Bangalore, Karnataka','20ft Container',42,32,10,2,31,76.19,96.88,81.13,81.07,81.10,6,3,2,0,94.23,3,4.17,3310.42,1,3.23,1,0,3.5,'B',25.01,48.90,87.06,88.90,0,1,'Compliant','Monthly performance metrics for May 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(50,'CAR-005','East West Cargo','Monthly','2025-05-03','2025-05-31','May 2025','LANE-03-05','Chennai, Tamil Nadu','Hyderabad, Telangana','20ft Container',50,41,9,3,38,82.00,92.68,88.02,81.33,84.67,5,4,7,1,91.51,0,5.87,2129.84,2,0.00,0,1,4.2,'B-',9.07,43.89,82.83,84.90,0,1,'Compliant','Monthly performance metrics for May 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(51,'CAR-001','ABC Transport Ltd','Monthly','2025-06-02','2025-06-30','June 2025','LANE-02-01','Pune, Maharashtra','Ahmedabad, Gujarat','32ft Trailer',33,23,10,2,23,69.70,100.00,84.11,89.70,86.91,3,0,1,0,92.78,1,6.15,4703.06,2,4.35,0,1,2.7,'C-',50.98,62.89,87.26,95.52,0,1,'Compliant','Monthly performance metrics for June 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(52,'CAR-002','Gati Ltd','Monthly','2025-06-02','2025-06-30','June 2025','LANE-02-02','Kolkata, West Bengal','Pune, Maharashtra','Flatbed Trailer',35,33,2,3,30,94.29,90.91,76.03,81.84,78.94,6,5,4,4,96.22,0,2.95,2772.63,0,0.00,0,0,4.7,'A+',0.00,61.55,73.70,86.79,0,0,'Compliant','Monthly performance metrics for June 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(53,'CAR-003','South Express','Monthly','2025-06-02','2025-06-30','June 2025','LANE-02-03','Pune, Maharashtra','Ahmedabad, Gujarat','Reefer Trailer',20,16,4,1,15,80.00,93.75,96.37,85.95,91.16,4,1,0,2,89.84,0,7.16,2486.82,2,0.00,2,0,3.0,'C+',48.89,65.69,83.52,93.33,0,0,'Compliant','Monthly performance metrics for June 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(54,'CAR-004','Cold Chain Express','Monthly','2025-06-02','2025-06-30','June 2025','LANE-02-04','Kolkata, West Bengal','Pune, Maharashtra','32ft Trailer',34,24,10,0,24,70.59,100.00,76.66,80.80,78.73,3,2,3,0,91.34,1,2.95,227.49,1,0.00,1,1,4.2,'B+',7.24,56.39,82.89,95.79,0,1,'Compliant','Monthly performance metrics for June 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(55,'CAR-005','East West Cargo','Monthly','2025-06-02','2025-06-30','June 2025','LANE-02-05','Mumbai, Maharashtra','Delhi, Delhi','32ft SXL',19,18,1,1,16,94.74,88.89,90.97,89.53,90.25,2,2,1,0,97.48,2,4.46,1003.62,0,6.25,0,0,3.1,'C-',46.61,59.13,81.90,75.68,0,0,'Compliant','Monthly performance metrics for June 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(56,'CAR-001','ABC Transport Ltd','Monthly','2025-07-02','2025-07-31','July 2025','LANE-01-01','Pune, Maharashtra','Ahmedabad, Gujarat','32ft SXL',39,27,12,1,26,69.23,96.30,89.88,93.09,91.48,2,0,2,2,98.78,0,4.09,3017.23,1,7.69,2,1,4.7,'A-',6.48,64.52,71.74,92.89,0,1,'Compliant','Monthly performance metrics for July 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(57,'CAR-002','Gati Ltd','Monthly','2025-07-02','2025-07-31','July 2025','LANE-01-02','Pune, Maharashtra','Ahmedabad, Gujarat','Flatbed Trailer',29,27,2,2,27,93.10,100.00,97.19,93.01,95.10,3,3,1,2,96.92,2,5.20,180.55,0,7.41,1,1,3.2,'C-',34.87,71.61,86.89,86.95,0,0,'Compliant','Monthly performance metrics for July 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(58,'CAR-003','South Express','Monthly','2025-07-02','2025-07-31','July 2025','LANE-01-03','Pune, Maharashtra','Ahmedabad, Gujarat','32ft SXL',41,33,8,2,28,80.49,84.85,86.96,94.75,90.85,0,1,5,0,86.16,0,3.77,2973.73,2,0.00,0,1,2.6,'C-',49.93,58.88,76.14,84.93,0,0,'Compliant','Monthly performance metrics for July 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(59,'CAR-004','Cold Chain Express','Monthly','2025-07-02','2025-07-31','July 2025','LANE-01-04','Kolkata, West Bengal','Pune, Maharashtra','Flatbed Trailer',34,33,1,1,33,97.06,100.00,88.24,86.90,87.57,2,5,1,1,91.66,3,3.34,18.10,2,0.00,0,1,4.5,'A',16.67,62.35,80.64,84.01,0,1,'Compliant','Monthly performance metrics for July 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL),(60,'CAR-005','East West Cargo','Monthly','2025-07-02','2025-07-31','July 2025','LANE-01-05','Kolkata, West Bengal','Pune, Maharashtra','32ft Trailer',19,19,0,1,18,100.00,94.74,85.27,94.02,89.64,2,4,3,2,98.53,0,6.83,1222.50,1,5.56,0,1,3.5,'B',27.56,35.26,89.35,97.10,0,0,'Compliant','Monthly performance metrics for July 2025','2025-08-09 10:29:02','2025-08-09 10:29:02',NULL,NULL);
/*!40000 ALTER TABLE `carrier_historical_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carrier_master`
--

DROP TABLE IF EXISTS `carrier_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `carrier_master` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `carrier_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique system-generated or assigned ID',
  `carrier_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Registered legal entity name',
  `carrier_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Short code used in TMS/ERP',
  `pan_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Indian tax identification',
  `gstin` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Indian tax registration number',
  `registered_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Carrier''s official address',
  `contact_person_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Primary contact name',
  `contact_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Phone number of POC',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Official communication address',
  `region_coverage` enum('North India','South India','East India','West India','Central India','PAN India','Specific States') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Geographic zones they operate in',
  `fleet_size` int DEFAULT NULL COMMENT 'Total number of vehicles owned',
  `vehicle_types` json DEFAULT NULL COMMENT 'Supported equipment as JSON array',
  `own_market` enum('Own','Market','Mixed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Market' COMMENT 'Whether fleet is owned or brokered',
  `avg_acceptance_rate` decimal(5,2) DEFAULT NULL COMMENT 'Historic load acceptance rate (0-100)',
  `avg_on_time_performance` decimal(5,2) DEFAULT NULL COMMENT 'Pickup and delivery OTP (0-100)',
  `billing_accuracy` decimal(5,2) DEFAULT NULL COMMENT 'Disputes vs total bills (0-100)',
  `compliance_valid_until` date DEFAULT NULL COMMENT 'Latest document (RC, Insurance, Fitness) validity',
  `preferred_carrier` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Internal status flag',
  `contracted` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Whether under active rate contract',
  `rate_expiry_date` date DEFAULT NULL COMMENT 'If applicable',
  `carrier_rating` enum('1','2','3','4','5','A','B','C','D','E') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Internal performance score',
  `payment_terms` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g., 30 days from invoice, COD, Advance',
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'For payments',
  `account_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Carrier''s bank account number',
  `ifsc_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'For electronic transfers',
  `msme_registered` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'MSME registration status in India',
  `last_load_date` date DEFAULT NULL COMMENT 'When they last moved a shipment',
  `blacklisted` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Status if carrier was blocked',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Additional notes',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who created the carrier record',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who last updated the carrier record',
  PRIMARY KEY (`id`),
  UNIQUE KEY `carrier_id` (`carrier_id`),
  UNIQUE KEY `carrier_code` (`carrier_code`),
  KEY `idx_carrier_id` (`carrier_id`),
  KEY `idx_carrier_code` (`carrier_code`),
  KEY `idx_carrier_name` (`carrier_name`),
  KEY `idx_region_coverage` (`region_coverage`),
  KEY `idx_preferred_carrier` (`preferred_carrier`),
  KEY `idx_contracted` (`contracted`),
  KEY `idx_carrier_rating` (`carrier_rating`),
  KEY `idx_blacklisted` (`blacklisted`),
  KEY `idx_compliance_validity` (`compliance_valid_until`),
  KEY `idx_last_load_date` (`last_load_date`),
  KEY `idx_avg_otp` (`avg_on_time_performance`),
  KEY `idx_avg_acceptance` (`avg_acceptance_rate`),
  KEY `idx_billing_accuracy` (`billing_accuracy`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Carrier Master for TL transportation procurement with comprehensive carrier information';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carrier_master`
--

LOCK TABLES `carrier_master` WRITE;
/*!40000 ALTER TABLE `carrier_master` DISABLE KEYS */;
INSERT INTO `carrier_master` VALUES (1,'CAR-001','Gati Ltd','GATI','ABCDE1234F','22AAAAA0000A1Z5','123, Transport Nagar, Gurgaon, Haryana 122001','Rajesh Kumar','+91-9876543210','rajesh.kumar@gati.com','PAN India',500,'[\"32ft SXL\", \"20ft Container\", \"Reefer\"]','Own',95.50,92.30,98.20,'2025-12-31','Yes','Yes','2025-06-30','A','30 days from invoice','HDFC Bank','1234567890','HDFC0001234','Yes','2024-12-15','No','Premium carrier with excellent track record','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(2,'CAR-002','Delhivery','DELHI','BCDEF2345G','33BBBBB0000B2Z6','456, Logistics Park, Delhi, Delhi 110001','Priya Sharma','+91-8765432109','priya.sharma@delhivery.com','PAN India',800,'[\"32ft Trailer\", \"Flatbed\", \"20ft Container\"]','Mixed',88.75,89.45,95.80,'2025-10-31','Yes','Yes','2025-08-31','B','45 days from invoice','ICICI Bank','0987654321','ICIC0000987','No','2024-12-10','No','Large fleet with good coverage','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(3,'CAR-003','Blue Dart Express','BLUED','CDEFG3456H','44CCCCC0000C3Z7','789, Cargo Hub, Mumbai, Maharashtra 400001','Amit Patel','+91-7654321098','amit.patel@bluedart.com','PAN India',1200,'[\"32ft SXL\", \"Reefer\", \"20ft Container\", \"Flatbed\"]','Own',92.30,94.20,97.50,'2025-09-30','Yes','Yes','2025-07-31','A','30 days from invoice','SBI Bank','1122334455','SBIN0001122','No','2024-12-12','No','Express delivery specialist','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(4,'CAR-004','ABC Transport Ltd','ABCT','DEFGH4567I','55DDDDD0000D4Z8','321, Transport Colony, Chennai, Tamil Nadu 600001','Suresh Reddy','+91-6543210987','suresh.reddy@abctransport.com','South India',300,'[\"32ft Trailer\", \"20ft Container\"]','Market',85.60,87.30,93.40,'2025-11-30','No','Yes','2025-05-31','C','60 days from invoice','Canara Bank','2233445566','CNRB0002233','Yes','2024-12-08','No','Regional carrier with good rates','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(5,'CAR-005','XYZ Logistics','XYZL','EFGHI5678J','66EEEEE0000E5Z9','654, Cargo Terminal, Pune, Maharashtra 411001','Meera Desai','+91-5432109876','meera.desai@xyzlogistics.com','West India',450,'[\"32ft SXL\", \"Reefer\", \"Flatbed\"]','Mixed',90.20,91.80,96.70,'2025-08-31','No','Yes','2025-04-30','B','45 days from invoice','Axis Bank','3344556677','UTIB0003344','No','2024-12-05','No','Specialized in temperature-controlled transport','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(6,'CAR-006','Fast Freight Co','FAST','FGHIJ6789K','77FFFFF0000F6Z0','987, Freight Zone, Kolkata, West Bengal 700001','Vikram Singh','+91-4321098765','vikram.singh@fastfreight.com','East India',250,'[\"32ft Trailer\", \"20ft Container\"]','Market',82.40,84.60,91.30,'2025-07-31','No','No',NULL,'D','Advance payment','Punjab National Bank','4455667788','PUNB0004455','Yes','2024-11-28','No','Economy carrier for basic transport needs','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(7,'CAR-007','South Express','SOUTH','GHIJK7890L','88GGGGG0000G7Z1','147, Express Way, Hyderabad, Telangana 500001','Lakshmi Devi','+91-3210987654','lakshmi.devi@southexpress.com','South India',180,'[\"20ft Container\", \"32ft SXL\"]','Own',88.90,86.70,94.20,'2025-06-30','No','Yes','2025-03-31','C','30 days from invoice','Karnataka Bank','5566778899','KARB0005566','No','2024-12-01','No','Small but reliable regional carrier','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(8,'CAR-008','Regional Cargo','REGIO','HIJKL8901M','99HHHHH0000H8Z2','258, Cargo Lane, Ahmedabad, Gujarat 380001','Rahul Mehta','+91-2109876543','rahul.mehta@regionalcargo.com','West India',120,'[\"32ft Trailer\"]','Market',79.30,81.50,89.80,'2025-05-31','No','No',NULL,'E','COD only','Bank of Baroda','6677889900','BARB0006677','Yes','2024-11-25','No','Local carrier for short-haul routes','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(9,'CAR-009','City Connect','CITY','IJKLM9012N','00IIIII0000I9Z3','369, City Hub, Bangalore, Karnataka 560001','Anjali Rao','+91-1098765432','anjali.rao@cityconnect.com','South India',200,'[\"20ft Container\", \"32ft SXL\", \"Flatbed\"]','Mixed',86.70,88.40,92.90,'2025-04-30','No','Yes','2025-02-28','C','45 days from invoice','HDFC Bank','7788990011','HDFC0007788','No','2024-11-30','No','Urban logistics specialist','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin'),(10,'CAR-010','Cold Chain Express','COLD','JKLMN0123O','11JJJJJ0000J0Z4','741, Cold Storage, Pune, Maharashtra 411002','Sanjay Verma','+91-0987654321','sanjay.verma@coldchain.com','West India',80,'[\"Reefer\", \"Temperature-controlled\"]','Own',94.20,96.80,98.90,'2025-03-31','Yes','Yes','2025-01-31','A','30 days from invoice','ICICI Bank','8899001122','ICIC0008899','No','2024-12-03','No','Premium cold chain logistics provider','2025-08-09 09:57:11','2025-08-09 09:57:11','admin','admin');
/*!40000 ALTER TABLE `carrier_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `carrier_performance_summary`
--

DROP TABLE IF EXISTS `carrier_performance_summary`;
/*!50001 DROP VIEW IF EXISTS `carrier_performance_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `carrier_performance_summary` AS SELECT 
 1 AS `carrier_id`,
 1 AS `carrier_name`,
 1 AS `periods_tracked`,
 1 AS `avg_acceptance_rate`,
 1 AS `avg_otp`,
 1 AS `avg_billing_accuracy`,
 1 AS `avg_performance_rating`,
 1 AS `avg_risk_score`,
 1 AS `total_loads_assigned`,
 1 AS `total_loads_accepted`,
 1 AS `total_loads_completed`,
 1 AS `best_grade`,
 1 AS `worst_grade`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `carrier_risk_assessment`
--

DROP TABLE IF EXISTS `carrier_risk_assessment`;
/*!50001 DROP VIEW IF EXISTS `carrier_risk_assessment`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `carrier_risk_assessment` AS SELECT 
 1 AS `carrier_id`,
 1 AS `carrier_name`,
 1 AS `period_label`,
 1 AS `risk_score`,
 1 AS `compliance_status`,
 1 AS `is_blacklisted`,
 1 AS `claim_percentage`,
 1 AS `customer_complaints_count`,
 1 AS `billing_disputes_count`,
 1 AS `risk_category`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `carriers`
--

DROP TABLE IF EXISTS `carriers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `carriers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `company_name` varchar(255) NOT NULL,
  `dot_number` varchar(20) DEFAULT NULL,
  `mc_number` varchar(20) DEFAULT NULL,
  `status` enum('active','inactive','pending') DEFAULT 'pending',
  `insurance_expiry` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_carriers_user_id` (`user_id`),
  CONSTRAINT `carriers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carriers`
--

LOCK TABLES `carriers` WRITE;
/*!40000 ALTER TABLE `carriers` DISABLE KEYS */;
INSERT INTO `carriers` VALUES (1,3,'Test Carrier Company','DOT123456','MC789012','active',NULL,'2025-08-09 07:05:12','2025-08-09 07:05:12');
/*!40000 ALTER TABLE `carriers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `commodities_master`
--

DROP TABLE IF EXISTS `commodities_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `commodities_master` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `commodity_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique system-assigned code',
  `commodity_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Name of the commodity',
  `commodity_category` enum('Perishable','Industrial','FMCG','Hazardous','Electronics','Textiles','Automotive','Pharmaceuticals','Construction','Agriculture') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hsn_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Harmonized System Nomenclature',
  `typical_packaging_type` enum('Palletized','Drums','Loose Cartons','Bags','Bulk','Crates','Barrels','Rolls','Bundles','Individual Units') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `handling_instructions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Special handling requirements',
  `temperature_controlled` tinyint(1) DEFAULT '0' COMMENT 'Needs reefer or climate control',
  `hazmat` tinyint(1) DEFAULT '0' COMMENT 'Hazardous material',
  `value_category` enum('Low','Medium','High','Very High') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Medium',
  `avg_weight_per_load` decimal(8,2) DEFAULT NULL COMMENT 'Average weight per load in MT',
  `avg_volume_per_load` decimal(8,2) DEFAULT NULL COMMENT 'Average volume per load in CFT',
  `insurance_required` tinyint(1) DEFAULT '0' COMMENT 'Special insurance needed',
  `sensitive_cargo` tinyint(1) DEFAULT '0' COMMENT 'Triggers geofencing/tamper alerts',
  `loading_unloading_sla` int DEFAULT NULL COMMENT 'Load/unload time in minutes',
  `min_insurance_amount` decimal(12,2) DEFAULT NULL COMMENT 'Minimum insurance amount in INR',
  `preferred_carrier_types` json DEFAULT NULL COMMENT 'Preferred carrier types',
  `restricted_carrier_types` json DEFAULT NULL COMMENT 'Restricted carrier types',
  `seasonal_peak_start` date DEFAULT NULL COMMENT 'Seasonal peak start date',
  `seasonal_peak_end` date DEFAULT NULL COMMENT 'Seasonal peak end date',
  `commodity_status` enum('Active','Inactive','Seasonal','Discontinued') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Additional notes',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_commodity_id` (`commodity_id`),
  KEY `idx_commodity_id` (`commodity_id`),
  KEY `idx_commodity_category` (`commodity_category`),
  KEY `idx_temperature_controlled` (`temperature_controlled`),
  KEY `idx_hazmat` (`hazmat`),
  KEY `idx_value_category` (`value_category`),
  KEY `idx_commodity_status` (`commodity_status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master reference dataset for commodity types in TL transportation';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `commodities_master`
--

LOCK TABLES `commodities_master` WRITE;
/*!40000 ALTER TABLE `commodities_master` DISABLE KEYS */;
INSERT INTO `commodities_master` VALUES (1,'CMD-001','FMCG Cartons','FMCG','4819','Loose Cartons','Stack max 5 layers, Keep dry',0,0,'Medium',8.50,1200.00,1,0,120,500000.00,'[\"32ft SXL\", \"Closed Body\"]','[\"Open Body\"]',NULL,NULL,'Active','Standard FMCG items','2025-08-09 10:53:04','2025-08-09 10:53:04',NULL,NULL),(2,'CMD-002','Electronics & Gadgets','Electronics','8517','Individual Units','Fragile - Handle with care',0,0,'High',3.20,800.00,1,1,180,2000000.00,'[\"32ft SXL\", \"Air Suspension\"]','[\"Open Body\"]',NULL,NULL,'Active','High-value electronics','2025-08-09 10:53:04','2025-08-09 10:53:04',NULL,NULL),(3,'CMD-003','Pharmaceutical Products','Pharmaceuticals','3004','Palletized','Temperature sensitive, 15-25°C',1,0,'Very High',5.80,950.00,1,1,150,5000000.00,'[\"Reefer\", \"Temperature Controlled\"]','[\"Open Body\"]',NULL,NULL,'Active','Critical temperature control','2025-08-09 10:53:04','2025-08-09 10:53:04',NULL,NULL),(4,'CMD-004','Steel Coils','Industrial','7208','Rolls','Heavy loads, Use cranes',0,0,'Medium',25.00,600.00,0,0,240,100000.00,'[\"Flatbed\", \"Heavy Duty\"]','[\"Closed Body\"]',NULL,NULL,'Active','Heavy industrial material','2025-08-09 10:53:04','2025-08-09 10:53:04',NULL,NULL),(5,'CMD-005','Industrial Chemicals','Hazardous','2811','Drums','HAZMAT - Special handling',0,1,'High',12.50,750.00,1,1,300,3000000.00,'[\"HAZMAT Certified\", \"Closed Body\"]','[\"Open Body\", \"Food Carriers\"]',NULL,NULL,'Active','Dangerous goods','2025-08-09 10:53:04','2025-08-09 10:53:04',NULL,NULL);
/*!40000 ALTER TABLE `commodities_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `compliance_monitoring`
--

DROP TABLE IF EXISTS `compliance_monitoring`;
/*!50001 DROP VIEW IF EXISTS `compliance_monitoring`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `compliance_monitoring` AS SELECT 
 1 AS `carrier_id`,
 1 AS `carrier_name`,
 1 AS `carrier_code`,
 1 AS `compliance_valid_until`,
 1 AS `days_until_expiry`,
 1 AS `compliance_status`,
 1 AS `last_load_date`,
 1 AS `days_since_last_load`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `contract_summary`
--

DROP TABLE IF EXISTS `contract_summary`;
/*!50001 DROP VIEW IF EXISTS `contract_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `contract_summary` AS SELECT 
 1 AS `contract_status`,
 1 AS `contract_count`,
 1 AS `avg_base_rate`,
 1 AS `earliest_start`,
 1 AS `latest_end`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `cost_effective_equipment`
--

DROP TABLE IF EXISTS `cost_effective_equipment`;
/*!50001 DROP VIEW IF EXISTS `cost_effective_equipment`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `cost_effective_equipment` AS SELECT 
 1 AS `equipment_id`,
 1 AS `equipment_name`,
 1 AS `vehicle_body_type`,
 1 AS `vehicle_length_ft`,
 1 AS `payload_capacity_tons`,
 1 AS `volume_capacity_cft`,
 1 AS `standard_rate_per_km`,
 1 AS `tons_per_rupee`,
 1 AS `active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `cost_effective_modes`
--

DROP TABLE IF EXISTS `cost_effective_modes`;
/*!50001 DROP VIEW IF EXISTS `cost_effective_modes`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `cost_effective_modes` AS SELECT 
 1 AS `mode_id`,
 1 AS `mode_name`,
 1 AS `mode_type`,
 1 AS `transit_time_days`,
 1 AS `cost_efficiency_level`,
 1 AS `base_cost_multiplier`,
 1 AS `suitable_commodities`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `current_fuel_surcharge_calculator`
--

DROP TABLE IF EXISTS `current_fuel_surcharge_calculator`;
/*!50001 DROP VIEW IF EXISTS `current_fuel_surcharge_calculator`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `current_fuel_surcharge_calculator` AS SELECT 
 1 AS `effective_date`,
 1 AS `fuel_price_min`,
 1 AS `fuel_price_max`,
 1 AS `fuel_surcharge_percentage`,
 1 AS `base_fuel_price`,
 1 AS `change_per_rupee`,
 1 AS `currency`,
 1 AS `applicable_region`,
 1 AS `surcharge_type`,
 1 AS `notes`,
 1 AS `calculation_method`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `eligible_carriers_for_bidding`
--

DROP TABLE IF EXISTS `eligible_carriers_for_bidding`;
/*!50001 DROP VIEW IF EXISTS `eligible_carriers_for_bidding`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `eligible_carriers_for_bidding` AS SELECT 
 1 AS `carrier_id_3p`,
 1 AS `carrier_name`,
 1 AS `region_of_operation`,
 1 AS `fleet_size`,
 1 AS `equipment_types`,
 1 AS `performance_score_external`,
 1 AS `compliance_validated`,
 1 AS `rating_threshold_met`,
 1 AS `last_active`,
 1 AS `invited_to_bid`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `equipment_availability`
--

DROP TABLE IF EXISTS `equipment_availability`;
/*!50001 DROP VIEW IF EXISTS `equipment_availability`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `equipment_availability` AS SELECT 
 1 AS `location_id`,
 1 AS `location_name`,
 1 AS `location_type`,
 1 AS `city`,
 1 AS `state`,
 1 AS `equipment_access`,
 1 AS `dock_type`,
 1 AS `parking_available`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `equipment_requirements`
--

DROP TABLE IF EXISTS `equipment_requirements`;
/*!50001 DROP VIEW IF EXISTS `equipment_requirements`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `equipment_requirements` AS SELECT 
 1 AS `preferred_equipment_type`,
 1 AS `lane_count`,
 1 AS `avg_distance`,
 1 AS `avg_rate`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `equipment_specific_accessorials`
--

DROP TABLE IF EXISTS `equipment_specific_accessorials`;
/*!50001 DROP VIEW IF EXISTS `equipment_specific_accessorials`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `equipment_specific_accessorials` AS SELECT 
 1 AS `accessorial_id`,
 1 AS `accessorial_name`,
 1 AS `applicable_equipment_types`,
 1 AS `applies_to`,
 1 AS `rate_type`,
 1 AS `rate_value`,
 1 AS `unit`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `equipment_specific_seasons`
--

DROP TABLE IF EXISTS `equipment_specific_seasons`;
/*!50001 DROP VIEW IF EXISTS `equipment_specific_seasons`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `equipment_specific_seasons` AS SELECT 
 1 AS `season_id`,
 1 AS `season_name`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `applicable_equipment_types`,
 1 AS `impact_type`,
 1 AS `capacity_risk_level`,
 1 AS `rate_multiplier_percent`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `equipment_summary`
--

DROP TABLE IF EXISTS `equipment_summary`;
/*!50001 DROP VIEW IF EXISTS `equipment_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `equipment_summary` AS SELECT 
 1 AS `equipment_id`,
 1 AS `equipment_name`,
 1 AS `vehicle_body_type`,
 1 AS `vehicle_length_ft`,
 1 AS `axle_type`,
 1 AS `gross_vehicle_weight_tons`,
 1 AS `payload_capacity_tons`,
 1 AS `volume_capacity_cft`,
 1 AS `temperature_controlled`,
 1 AS `hazmat_certified`,
 1 AS `fuel_type`,
 1 AS `active`,
 1 AS `priority_level`,
 1 AS `standard_rate_per_km`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `equipment_type_analysis`
--

DROP TABLE IF EXISTS `equipment_type_analysis`;
/*!50001 DROP VIEW IF EXISTS `equipment_type_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `equipment_type_analysis` AS SELECT 
 1 AS `primary_equipment`,
 1 AS `carrier_count`,
 1 AS `avg_performance`,
 1 AS `compliant_count`,
 1 AS `total_capacity`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `equipment_types_master`
--

DROP TABLE IF EXISTS `equipment_types_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipment_types_master` (
  `id` int NOT NULL AUTO_INCREMENT,
  `equipment_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique equipment code (e.g., EQP-32FT-CNTNR)',
  `equipment_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Human-readable name (e.g., 32ft Container Truck)',
  `vehicle_body_type` enum('Container','Open Body','Flatbed','Reefer','Tanker','Box Truck','Trailer','Specialized') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Type of vehicle body',
  `vehicle_length_ft` decimal(4,1) NOT NULL COMMENT 'Vehicle length in feet (e.g., 20.0, 32.0, 40.0)',
  `axle_type` enum('Single','Double','Multi-axle','Tandem','Tri-axle') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Axle configuration',
  `gross_vehicle_weight_tons` decimal(5,2) NOT NULL COMMENT 'Maximum GVW in tons',
  `payload_capacity_tons` decimal(5,2) NOT NULL COMMENT 'Net cargo capacity in tons',
  `volume_capacity_cft` int DEFAULT NULL COMMENT 'Volume capacity in cubic feet',
  `volume_capacity_cbm` decimal(6,2) DEFAULT NULL COMMENT 'Volume capacity in cubic meters',
  `door_type` enum('Side-opening','Rear-opening','Top-loading','Roll-up','Side-roll','Multiple','Side-loading') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Type of loading doors',
  `temperature_controlled` tinyint(1) DEFAULT '0' COMMENT 'Whether vehicle has temperature control',
  `hazmat_certified` tinyint(1) DEFAULT '0' COMMENT 'If vehicle is permitted to carry hazardous goods',
  `ideal_commodities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Comma-separated list of ideal commodities',
  `fuel_type` enum('Diesel','CNG','Electric','Hybrid','Biodiesel') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Diesel' COMMENT 'Primary fuel type',
  `has_gps` tinyint(1) DEFAULT '0' COMMENT 'Whether vehicle has GPS for tracking',
  `dock_type_compatibility` enum('Ground-level','Elevated','Ramp-access','All','Specialized') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Dock compatibility',
  `common_routes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Common routes or lanes where this equipment is used',
  `standard_rate_per_km` decimal(8,2) DEFAULT NULL COMMENT 'Internal planning rate per kilometer',
  `max_height_meters` decimal(4,2) DEFAULT NULL COMMENT 'Maximum height in meters',
  `max_width_meters` decimal(4,2) DEFAULT NULL COMMENT 'Maximum width in meters',
  `refrigeration_capacity_btu` int DEFAULT NULL COMMENT 'Refrigeration capacity in BTU (for reefers)',
  `security_features` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Security features like locks, seals, etc.',
  `maintenance_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Maintenance schedule and requirements',
  `regulatory_compliance` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Regulatory compliance requirements',
  `insurance_coverage_type` enum('Basic','Comprehensive','Specialized','High-value') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Basic' COMMENT 'Insurance coverage type',
  `active` tinyint(1) DEFAULT '1' COMMENT 'Whether this equipment type is currently active',
  `priority_level` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium' COMMENT 'Priority for procurement planning',
  `seasonal_availability` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Seasonal restrictions or availability',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Additional notes and limitations',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'system' COMMENT 'User who created the record',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'system' COMMENT 'User who last updated the record',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record update timestamp',
  PRIMARY KEY (`id`),
  UNIQUE KEY `equipment_id` (`equipment_id`),
  KEY `idx_equipment_id` (`equipment_id`),
  KEY `idx_vehicle_body_type` (`vehicle_body_type`),
  KEY `idx_vehicle_length` (`vehicle_length_ft`),
  KEY `idx_axle_type` (`axle_type`),
  KEY `idx_temperature_controlled` (`temperature_controlled`),
  KEY `idx_hazmat_certified` (`hazmat_certified`),
  KEY `idx_active` (`active`),
  KEY `idx_priority_level` (`priority_level`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for transportation equipment types';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment_types_master`
--

LOCK TABLES `equipment_types_master` WRITE;
/*!40000 ALTER TABLE `equipment_types_master` DISABLE KEYS */;
INSERT INTO `equipment_types_master` VALUES (1,'EQP-32SXL','32ft Single Axle Container Truck','Container',32.0,'Single',16.00,11.00,1200,34.00,'Rear-opening',0,0,'FMCG, Retail, General Cargo, Textiles','Diesel',1,'Elevated','Mumbai-Delhi, Bangalore-Chennai, Kolkata-Guwahati',28.50,2.60,2.40,NULL,'Container locks, Seal verification','Monthly inspection, Oil change every 5000 km','RTO compliance, Pollution certificate','Basic',1,'High','Year-round','Most common equipment for general cargo','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(2,'EQP-32MXL','32ft Multi-Axle Container Truck','Container',32.0,'Multi-axle',21.00,16.00,1800,51.00,'Rear-opening',0,0,'FMCG, Retail, Electronics, Industrial goods','Diesel',1,'Elevated','Mumbai-Delhi, Bangalore-Chennai, Pune-Mumbai',30.00,2.60,2.40,NULL,'Container locks, Seal verification, GPS tracking','Monthly inspection, Oil change every 5000 km, Axle maintenance','RTO compliance, Pollution certificate, Multi-axle permit','Comprehensive',1,'High','Year-round','Higher capacity, better fuel efficiency','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(3,'EQP-20OB','20ft Open Body Truck','Open Body',20.0,'Single',12.00,7.00,800,22.70,'Top-loading',0,0,'Construction material, Bulk items, Agricultural produce','Diesel',0,'Ground-level','Local construction sites, Agricultural markets',25.00,2.40,2.20,NULL,'Tarpaulin cover, Rope tie-downs','Weekly inspection, Regular cleaning','RTO compliance, Local transport permit','Basic',1,'Medium','Year-round','Suitable for bulk and construction materials','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(4,'EQP-40FB','40ft Flatbed Trailer','Flatbed',40.0,'Tandem',25.00,20.00,2400,68.00,'Side-loading',0,0,'Machinery, ODC cargo, Industrial equipment, Steel','Diesel',1,'Ground-level','Heavy machinery transport, Industrial corridors',35.00,2.80,2.60,NULL,'Chain tie-downs, Corner protectors','Monthly inspection, Regular cleaning, Chain maintenance','RTO compliance, ODC permit for oversized loads','Specialized',1,'Medium','Year-round','For oversized and heavy machinery','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(5,'EQP-32RF','32ft Refrigerated Container Truck','Reefer',32.0,'Multi-axle',21.00,16.00,1600,45.30,'Rear-opening',1,0,'Pharmaceuticals, Perishable foods, Dairy products, Flowers','Diesel',1,'Elevated','Pharma corridors, Cold chain routes',38.00,2.60,2.40,12000,'Temperature monitoring, GPS tracking, Seal verification','Weekly inspection, Refrigeration system maintenance, Temperature calibration','RTO compliance, Pharma transport license, Temperature monitoring compliance','Specialized',1,'High','Year-round','Critical for temperature-sensitive cargo','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(6,'EQP-32TK','32ft Tanker Truck','Tanker',32.0,'Multi-axle',25.00,20.00,1800,51.00,'Top-loading',0,1,'Oil, Milk, Chemicals, LPG, Industrial liquids','Diesel',1,'Specialized','Oil depots, Chemical plants, Dairy facilities',42.00,2.80,2.40,NULL,'Pressure relief valves, Emergency shutdown, GPS tracking','Weekly inspection, Pressure testing, Valve maintenance','RTO compliance, Hazmat permit, Tanker certification, Pressure vessel compliance','Specialized',1,'Medium','Year-round','Requires special permits and training','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(7,'EQP-24BX','24ft Box Truck','Box Truck',24.0,'Single',14.00,9.00,1000,28.30,'Rear-opening',0,0,'Electronics, Fragile items, Small packages, Documents','Diesel',1,'Ground-level','Last-mile delivery, Urban routes',26.00,2.40,2.20,NULL,'Box locks, Cushioning, GPS tracking','Monthly inspection, Regular cleaning','RTO compliance, Urban transport permit','Basic',1,'Medium','Year-round','Suitable for urban and last-mile delivery','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(8,'EQP-22CNT','22ft Container Truck','Container',22.0,'Single',14.00,9.00,900,25.50,'Rear-opening',0,0,'Small shipments, Regional transport, E-commerce','Diesel',1,'Elevated','Regional routes, E-commerce hubs',27.00,2.40,2.20,NULL,'Container locks, Seal verification','Monthly inspection, Oil change every 5000 km','RTO compliance, Pollution certificate','Basic',1,'Medium','Year-round','Good for regional and smaller shipments','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(9,'EQP-40SP','40ft Specialized Heavy Equipment Trailer','Specialized',40.0,'Tri-axle',35.00,30.00,3000,85.00,'Multiple',0,1,'Heavy machinery, Industrial equipment, Specialized cargo','Diesel',1,'Specialized','Heavy industry routes, Port operations',45.00,3.00,3.00,NULL,'Multiple tie-down points, Load monitoring, GPS tracking','Weekly inspection, Load monitoring system maintenance','RTO compliance, Specialized transport permit, Load monitoring compliance','Specialized',1,'Low','Year-round','For extremely heavy and specialized cargo','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(10,'EQP-32EL','32ft Electric Container Truck','Container',32.0,'Multi-axle',20.00,15.00,1700,48.10,'Rear-opening',0,0,'Green logistics, Urban delivery, Eco-friendly cargo','Electric',1,'Elevated','Green corridors, Urban routes, Eco-friendly zones',32.00,2.60,2.40,NULL,'Container locks, Battery monitoring, GPS tracking','Weekly inspection, Battery maintenance, Charging system check','RTO compliance, Electric vehicle certification, Battery safety compliance','Comprehensive',1,'Medium','Year-round','Environmentally friendly option','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(11,'EQP-32CNG','32ft CNG Container Truck','Container',32.0,'Multi-axle',19.00,14.00,1600,45.30,'Rear-opening',0,0,'General cargo, Regional transport, Eco-friendly options','CNG',1,'Elevated','CNG corridor routes, Regional transport',29.50,2.60,2.40,NULL,'Container locks, CNG monitoring, GPS tracking','Monthly inspection, CNG system maintenance, Regular cleaning','RTO compliance, CNG vehicle certification, Gas safety compliance','Comprehensive',1,'Medium','Year-round','Lower emissions, cost-effective fuel','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(12,'EQP-32HS','32ft High Security Container Truck','Container',32.0,'Multi-axle',21.00,16.00,1800,51.00,'Rear-opening',0,0,'High-value cargo, Electronics, Pharmaceuticals, Precious metals','Diesel',1,'Elevated','High-value cargo routes, Pharma corridors',40.00,2.60,2.40,NULL,'Advanced locks, Security seals, GPS tracking, Alarm system','Weekly inspection, Security system maintenance, Regular cleaning','RTO compliance, Security certification, High-value cargo permit','Specialized',1,'High','Year-round','Enhanced security for valuable cargo','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(13,'EQP-32MM','32ft Multi-Modal Container Truck','Container',32.0,'Multi-axle',21.00,16.00,1800,51.00,'Rear-opening',0,0,'Export cargo, Multi-modal transport, International shipments','Diesel',1,'Elevated','Port routes, Export corridors, Multi-modal hubs',33.00,2.60,2.40,NULL,'Container locks, ISO compliance, GPS tracking','Monthly inspection, ISO compliance check, Regular cleaning','RTO compliance, ISO certification, Export compliance','Comprehensive',1,'Medium','Year-round','Compatible with rail and sea transport','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59'),(14,'EQP-32EX','32ft Express Delivery Container Truck','Container',32.0,'Multi-axle',20.00,15.00,1700,48.10,'Rear-opening',0,0,'Express cargo, Time-critical shipments, Premium services','Diesel',1,'Elevated','Express corridors, Time-critical routes',36.00,2.60,2.40,NULL,'Container locks, GPS tracking, Real-time monitoring','Weekly inspection, Express service maintenance, Regular cleaning','RTO compliance, Express service certification','Comprehensive',1,'High','Year-round','Optimized for fast delivery services','system','system','2025-08-09 12:11:59','2025-08-09 12:11:59');
/*!40000 ALTER TABLE `equipment_types_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fuel_price_tracking`
--

DROP TABLE IF EXISTS `fuel_price_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fuel_price_tracking` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tracking_date` date NOT NULL COMMENT 'Date of fuel price tracking',
  `fuel_price` decimal(8,2) NOT NULL COMMENT 'Current diesel price on tracking date',
  `source` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Source of fuel price (IOC, HP, BP, etc.)',
  `region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Region for which price is tracked',
  `currency` enum('INR','USD','EUR','GBP') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'INR',
  `is_official` tinyint(1) DEFAULT '0' COMMENT 'Whether this is an official published rate',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Additional notes about the price',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_tracking` (`tracking_date`,`source`,`region`,`currency`),
  KEY `idx_tracking_date` (`tracking_date`),
  KEY `idx_fuel_price` (`fuel_price`),
  KEY `idx_source` (`source`),
  KEY `idx_region` (`region`),
  KEY `idx_currency` (`currency`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historical tracking of fuel prices for surcharge calculations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fuel_price_tracking`
--

LOCK TABLES `fuel_price_tracking` WRITE;
/*!40000 ALTER TABLE `fuel_price_tracking` DISABLE KEYS */;
INSERT INTO `fuel_price_tracking` VALUES (1,'2025-06-01',96.50,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(2,'2025-06-02',96.75,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(3,'2025-06-03',97.00,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(4,'2025-06-04',97.25,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(5,'2025-06-05',97.50,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(6,'2025-06-06',97.75,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(7,'2025-06-07',98.00,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(8,'2025-06-08',98.25,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(9,'2025-06-09',98.50,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38'),(10,'2025-06-10',98.75,'IOC','All India','INR',1,'Official IOC diesel rate','2025-08-09 13:07:38','2025-08-09 13:07:38');
/*!40000 ALTER TABLE `fuel_price_tracking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `fuel_price_trend_analysis`
--

DROP TABLE IF EXISTS `fuel_price_trend_analysis`;
/*!50001 DROP VIEW IF EXISTS `fuel_price_trend_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `fuel_price_trend_analysis` AS SELECT 
 1 AS `tracking_date`,
 1 AS `fuel_price`,
 1 AS `source`,
 1 AS `region`,
 1 AS `currency`,
 1 AS `previous_price`,
 1 AS `price_change`,
 1 AS `price_change_percentage`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `fuel_surcharge_calculation_history`
--

DROP TABLE IF EXISTS `fuel_surcharge_calculation_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fuel_surcharge_calculation_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `calculation_date` date NOT NULL COMMENT 'Date when surcharge was calculated',
  `lane_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Lane identifier if applicable',
  `base_freight_amount` decimal(12,2) NOT NULL COMMENT 'Base freight amount before surcharge',
  `current_fuel_price` decimal(8,2) NOT NULL COMMENT 'Fuel price used for calculation',
  `applicable_surcharge_percentage` decimal(5,2) NOT NULL COMMENT 'Surcharge percentage applied',
  `surcharge_amount` decimal(12,2) NOT NULL COMMENT 'Calculated surcharge amount',
  `total_amount` decimal(12,2) NOT NULL COMMENT 'Total amount including surcharge',
  `surcharge_slab_id` bigint DEFAULT NULL COMMENT 'Reference to fuel_surcharge_master',
  `calculation_method` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Method used for calculation',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Calculation notes or exceptions',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_calculation_date` (`calculation_date`),
  KEY `idx_lane_id` (`lane_id`),
  KEY `idx_fuel_price` (`current_fuel_price`),
  KEY `idx_surcharge_slab` (`surcharge_slab_id`),
  CONSTRAINT `fuel_surcharge_calculation_history_ibfk_1` FOREIGN KEY (`surcharge_slab_id`) REFERENCES `fuel_surcharge_master` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='History of fuel surcharge calculations for audit and analysis';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fuel_surcharge_calculation_history`
--

LOCK TABLES `fuel_surcharge_calculation_history` WRITE;
/*!40000 ALTER TABLE `fuel_surcharge_calculation_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `fuel_surcharge_calculation_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fuel_surcharge_master`
--

DROP TABLE IF EXISTS `fuel_surcharge_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fuel_surcharge_master` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `effective_date` date NOT NULL COMMENT 'When the surcharge table comes into effect',
  `fuel_price_min` decimal(8,2) NOT NULL COMMENT 'Lower bound of diesel price slab (e.g., ₹85)',
  `fuel_price_max` decimal(8,2) NOT NULL COMMENT 'Upper bound of the slab (e.g., ₹90)',
  `fuel_surcharge_percentage` decimal(5,2) NOT NULL COMMENT 'Percentage surcharge on base freight',
  `base_fuel_price` decimal(8,2) NOT NULL COMMENT 'Reference fuel price at which no surcharge is applied',
  `change_per_rupee` decimal(5,2) DEFAULT NULL COMMENT 'Optional fixed % change per ₹1 increase above base price',
  `currency` enum('INR','USD','EUR','GBP') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'INR' COMMENT 'Currency for the surcharge',
  `applicable_region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Optional field if table is region-specific',
  `is_active` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Whether this surcharge slab is currently active',
  `surcharge_type` enum('Fixed','Variable','Hybrid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Fixed' COMMENT 'Type of surcharge calculation',
  `min_surcharge_amount` decimal(10,2) DEFAULT NULL COMMENT 'Minimum surcharge amount in currency',
  `max_surcharge_amount` decimal(10,2) DEFAULT NULL COMMENT 'Maximum surcharge amount in currency',
  `surcharge_calculation_method` enum('Percentage','Fixed Amount','Per KM','Per MT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Percentage',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Any remarks (e.g., "Subject to IOC diesel rates")',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'System',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'System',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_price_range` (`effective_date`,`fuel_price_min`,`fuel_price_max`,`currency`,`applicable_region`),
  KEY `idx_effective_date` (`effective_date`),
  KEY `idx_fuel_price_range` (`fuel_price_min`,`fuel_price_max`),
  KEY `idx_base_fuel_price` (`base_fuel_price`),
  KEY `idx_currency` (`currency`),
  KEY `idx_region` (`applicable_region`),
  KEY `idx_active` (`is_active`),
  KEY `idx_surcharge_type` (`surcharge_type`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for fuel surcharge calculations based on diesel price ranges';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fuel_surcharge_master`
--

LOCK TABLES `fuel_surcharge_master` WRITE;
/*!40000 ALTER TABLE `fuel_surcharge_master` DISABLE KEYS */;
INSERT INTO `fuel_surcharge_master` VALUES (1,'2025-06-01',80.00,84.99,0.00,80.00,0.50,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','No surcharge if ≤ ₹84.99','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(2,'2025-06-01',85.00,89.99,2.00,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Standard surcharge for moderate price increase','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(3,'2025-06-01',90.00,94.99,4.00,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Increased surcharge for higher fuel costs','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(4,'2025-06-01',95.00,99.99,6.00,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Most lanes see this slab - significant fuel cost impact','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(5,'2025-06-01',100.00,104.99,8.00,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','High surcharge for expensive fuel','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(6,'2025-06-01',105.00,110.00,10.00,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Maximum surcharge cap - extreme fuel prices','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(7,'2025-06-01',80.00,84.99,0.00,80.00,0.60,'INR','Metro Cities','Yes','Variable',NULL,NULL,'Percentage','Higher sensitivity in metro areas','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(8,'2025-06-01',85.00,89.99,2.50,80.00,NULL,'INR','Metro Cities','Yes','Fixed',NULL,NULL,'Percentage','Metro-specific surcharge rates','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(9,'2025-06-01',90.00,94.99,4.50,80.00,NULL,'INR','Metro Cities','Yes','Fixed',NULL,NULL,'Percentage','Metro-specific surcharge rates','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(10,'2025-06-01',95.00,99.99,6.50,80.00,NULL,'INR','Metro Cities','Yes','Fixed',NULL,NULL,'Percentage','Metro-specific surcharge rates','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(11,'2025-06-01',100.00,104.99,8.50,80.00,NULL,'INR','Metro Cities','Yes','Fixed',NULL,NULL,'Percentage','Metro-specific surcharge rates','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(12,'2025-06-01',105.00,110.00,10.50,80.00,NULL,'INR','Metro Cities','Yes','Fixed',NULL,NULL,'Percentage','Metro-specific surcharge rates','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(13,'2025-07-01',80.00,84.99,0.00,80.00,0.55,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Updated rates effective July 2025','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(14,'2025-07-01',85.00,89.99,2.25,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Updated rates effective July 2025','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(15,'2025-07-01',90.00,94.99,4.25,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Updated rates effective July 2025','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(16,'2025-07-01',95.00,99.99,6.25,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Updated rates effective July 2025','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(17,'2025-07-01',100.00,104.99,8.25,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Updated rates effective July 2025','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System'),(18,'2025-07-01',105.00,110.00,10.25,80.00,NULL,'INR','All India','Yes','Fixed',NULL,NULL,'Percentage','Updated rates effective July 2025','2025-08-09 13:07:38','2025-08-09 13:07:38','System','System');
/*!40000 ALTER TABLE `fuel_surcharge_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `high_capacity_equipment`
--

DROP TABLE IF EXISTS `high_capacity_equipment`;
/*!50001 DROP VIEW IF EXISTS `high_capacity_equipment`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `high_capacity_equipment` AS SELECT 
 1 AS `equipment_id`,
 1 AS `equipment_name`,
 1 AS `vehicle_body_type`,
 1 AS `vehicle_length_ft`,
 1 AS `payload_capacity_tons`,
 1 AS `volume_capacity_cft`,
 1 AS `axle_type`,
 1 AS `standard_rate_per_km`,
 1 AS `active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `high_impact_seasons`
--

DROP TABLE IF EXISTS `high_impact_seasons`;
/*!50001 DROP VIEW IF EXISTS `high_impact_seasons`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `high_impact_seasons` AS SELECT 
 1 AS `season_id`,
 1 AS `season_name`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `impact_type`,
 1 AS `rate_multiplier_percent`,
 1 AS `capacity_risk_level`,
 1 AS `carrier_participation_impact`,
 1 AS `affected_regions`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `high_value_accessorials`
--

DROP TABLE IF EXISTS `high_value_accessorials`;
/*!50001 DROP VIEW IF EXISTS `high_value_accessorials`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `high_value_accessorials` AS SELECT 
 1 AS `accessorial_id`,
 1 AS `accessorial_name`,
 1 AS `applies_to`,
 1 AS `rate_type`,
 1 AS `rate_value`,
 1 AS `unit`,
 1 AS `taxable`,
 1 AS `remarks`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `high_value_commodities`
--

DROP TABLE IF EXISTS `high_value_commodities`;
/*!50001 DROP VIEW IF EXISTS `high_value_commodities`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `high_value_commodities` AS SELECT 
 1 AS `commodity_id`,
 1 AS `commodity_name`,
 1 AS `commodity_category`,
 1 AS `value_category`,
 1 AS `min_insurance_amount`,
 1 AS `temperature_controlled`,
 1 AS `hazmat`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `high_volume_lanes`
--

DROP TABLE IF EXISTS `high_volume_lanes`;
/*!50001 DROP VIEW IF EXISTS `high_volume_lanes`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `high_volume_lanes` AS SELECT 
 1 AS `lane_id`,
 1 AS `origin_city`,
 1 AS `destination_city`,
 1 AS `distance_km`,
 1 AS `avg_load_frequency_month`,
 1 AS `avg_load_volume_tons`,
 1 AS `current_rate_trip`,
 1 AS `preferred_equipment_type`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `insurance_claims`
--

DROP TABLE IF EXISTS `insurance_claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insurance_claims` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bid_response_id` int DEFAULT NULL,
  `claim_type` enum('damage','delay','loss','other') NOT NULL,
  `description` text NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','approved','rejected','resolved') DEFAULT 'pending',
  `filed_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `bid_response_id` (`bid_response_id`),
  KEY `filed_by` (`filed_by`),
  CONSTRAINT `insurance_claims_ibfk_1` FOREIGN KEY (`bid_response_id`) REFERENCES `bid_responses` (`id`) ON DELETE SET NULL,
  CONSTRAINT `insurance_claims_ibfk_2` FOREIGN KEY (`filed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurance_claims`
--

LOCK TABLES `insurance_claims` WRITE;
/*!40000 ALTER TABLE `insurance_claims` DISABLE KEYS */;
/*!40000 ALTER TABLE `insurance_claims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `lane_coverage_analysis`
--

DROP TABLE IF EXISTS `lane_coverage_analysis`;
/*!50001 DROP VIEW IF EXISTS `lane_coverage_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `lane_coverage_analysis` AS SELECT 
 1 AS `lane`,
 1 AS `equipment_type`,
 1 AS `routing_guide_count`,
 1 AS `carriers`,
 1 AS `avg_rate`,
 1 AS `min_rate`,
 1 AS `max_rate`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `lane_performance_analysis`
--

DROP TABLE IF EXISTS `lane_performance_analysis`;
/*!50001 DROP VIEW IF EXISTS `lane_performance_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `lane_performance_analysis` AS SELECT 
 1 AS `lane_id`,
 1 AS `origin_location`,
 1 AS `destination_location`,
 1 AS `equipment_type`,
 1 AS `carriers_used`,
 1 AS `avg_acceptance_rate`,
 1 AS `avg_otp`,
 1 AS `avg_billing_accuracy`,
 1 AS `avg_performance_rating`,
 1 AS `total_loads_assigned`,
 1 AS `total_loads_completed`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `lanes`
--

DROP TABLE IF EXISTS `lanes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lanes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `origin_city` varchar(100) NOT NULL,
  `origin_state` varchar(2) NOT NULL,
  `destination_city` varchar(100) NOT NULL,
  `destination_state` varchar(2) NOT NULL,
  `distance_miles` int DEFAULT NULL,
  `estimated_transit_days` int DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lanes`
--

LOCK TABLES `lanes` WRITE;
/*!40000 ALTER TABLE `lanes` DISABLE KEYS */;
INSERT INTO `lanes` VALUES (1,'New York','NY','Los Angeles','CA',2789,5,'active','2025-08-09 07:05:12','2025-08-09 07:05:12'),(2,'Chicago','IL','Houston','TX',940,2,'active','2025-08-09 07:05:12','2025-08-09 07:05:12'),(3,'Miami','FL','Seattle','WA',3300,7,'active','2025-08-09 07:05:12','2025-08-09 07:05:12');
/*!40000 ALTER TABLE `lanes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lanes_master`
--

DROP TABLE IF EXISTS `lanes_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lanes_master` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `lane_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique identifier (e.g., LANE-000123)',
  `origin_location_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'From the Locations Master',
  `origin_city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Origin city name',
  `origin_state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Origin state name',
  `destination_location_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'From the Locations Master',
  `destination_city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Destination city name',
  `destination_state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Destination state name',
  `lane_type` enum('Primary','Return','Backhaul','Inbound','Outbound') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Primary' COMMENT 'Lane classification',
  `distance_km` decimal(8,2) DEFAULT NULL COMMENT 'Approximate road distance in kilometers',
  `transit_time_days` int DEFAULT NULL COMMENT 'Standard delivery lead time in days',
  `avg_load_frequency_month` decimal(5,2) DEFAULT NULL COMMENT 'Average loads per month from historical data',
  `avg_load_volume_tons` decimal(8,2) DEFAULT NULL COMMENT 'Average load size in tons',
  `avg_load_volume_cft` decimal(8,2) DEFAULT NULL COMMENT 'Average load volume in cubic feet',
  `preferred_equipment_type` enum('32ft SXL','32ft Container','Reefer','Flatbed','20ft Container','40ft Container','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Preferred equipment type',
  `mode` enum('TL','LTL','Rail','Multimodal') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'TL' COMMENT 'Transportation mode',
  `service_level` enum('Standard','Express','Scheduled','Premium') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Standard' COMMENT 'Service level offered',
  `seasonality` tinyint(1) DEFAULT '0' COMMENT 'Whether the lane has peak/off-peak trends',
  `peak_months` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Peak months (comma-separated)',
  `primary_carriers` json DEFAULT NULL COMMENT 'Current preferred carriers on this lane',
  `current_rate_trip` decimal(10,2) DEFAULT NULL COMMENT 'Current rate per trip in INR',
  `current_rate_ton` decimal(8,2) DEFAULT NULL COMMENT 'Current rate per ton in INR',
  `benchmark_rate_trip` decimal(10,2) DEFAULT NULL COMMENT 'Benchmark rate per trip based on market intelligence',
  `benchmark_rate_ton` decimal(8,2) DEFAULT NULL COMMENT 'Benchmark rate per ton based on market intelligence',
  `fuel_surcharge_applied` tinyint(1) DEFAULT '0' COMMENT 'If dynamic fuel surcharge applies',
  `accessorials_expected` json DEFAULT NULL COMMENT 'Expected accessorials (e.g., Unloading, Waiting, Escort)',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'Flag for deprecating unused lanes',
  `last_used_date` date DEFAULT NULL COMMENT 'When the lane last had an executed shipment',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Notes like risk-prone area, toll-heavy route, etc.',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lane_id` (`lane_id`),
  KEY `idx_origin` (`origin_location_id`),
  KEY `idx_destination` (`destination_location_id`),
  KEY `idx_origin_city_state` (`origin_city`,`origin_state`),
  KEY `idx_dest_city_state` (`destination_city`,`destination_state`),
  KEY `idx_lane_type` (`lane_type`),
  KEY `idx_distance` (`distance_km`),
  KEY `idx_equipment` (`preferred_equipment_type`),
  KEY `idx_mode` (`mode`),
  KEY `idx_active` (`is_active`),
  KEY `idx_last_used` (`last_used_date`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lanes_master`
--

LOCK TABLES `lanes_master` WRITE;
/*!40000 ALTER TABLE `lanes_master` DISABLE KEYS */;
INSERT INTO `lanes_master` VALUES (1,'LANE-BHW-HYD-001','WH-MUM-01','Bhiwandi','Maharashtra','CUST-HYD-01','Hyderabad','Telangana','Primary',725.50,2,30.00,15.50,450.00,'32ft Container','TL','Standard',1,'March,October','[\"ABC Logistics\", \"XYZ Transport\"]',28000.00,1806.45,30000.00,1935.48,1,'[\"Unloading\", \"Waiting\"]',1,'2024-12-15','High volume lane, toll-heavy route','2025-08-09 11:18:50','2025-08-09 11:18:50',NULL,NULL),(2,'LANE-BLR-CHN-002','WH-BLR-01','Bangalore','Karnataka','FACTORY-CHN-01','Chennai','Tamil Nadu','Primary',350.25,1,25.00,12.00,350.00,'32ft SXL','TL','Express',0,NULL,'[\"South Express\", \"Karnataka Logistics\"]',22000.00,1833.33,24000.00,2000.00,0,'[\"Unloading\"]',1,'2024-12-18','Express corridor, good road conditions','2025-08-09 11:18:50','2025-08-09 11:18:50',NULL,NULL),(3,'LANE-MUM-BLR-003','WH-MUM-01','Mumbai','Maharashtra','WH-BLR-01','Bangalore','Karnataka','Return',980.75,3,20.00,18.00,520.00,'32ft Container','TL','Standard',1,'January,July','[\"Western Express\", \"Maharashtra Cargo\"]',35000.00,1944.44,38000.00,2111.11,1,'[\"Unloading\", \"Waiting\", \"Escort\"]',1,'2024-12-12','Long distance, mountainous terrain','2025-08-09 11:18:50','2025-08-09 11:18:50',NULL,NULL),(4,'LANE-CHN-HYD-004','FACTORY-CHN-01','Chennai','Tamil Nadu','CUST-HYD-01','Hyderabad','Telangana','Primary',625.30,2,15.00,14.00,400.00,'32ft SXL','TL','Standard',0,NULL,'[\"Tamil Nadu Express\", \"Telangana Cargo\"]',25000.00,1785.71,27000.00,1928.57,0,'[\"Unloading\"]',1,'2024-12-16','Medium volume, good connectivity','2025-08-09 11:18:50','2025-08-09 11:18:50',NULL,NULL),(5,'LANE-HYD-MUM-005','CUST-HYD-01','Hyderabad','Telangana','PORT-MUM-01','Mumbai','Maharashtra','Outbound',750.45,2,12.00,16.00,480.00,'32ft Container','TL','Scheduled',1,'February,August','[\"Telangana Express\", \"Port Connect\"]',30000.00,1875.00,32000.00,2000.00,1,'[\"Unloading\", \"Port Charges\"]',1,'2024-12-10','Export route, port handling required','2025-08-09 11:18:50','2025-08-09 11:18:50',NULL,NULL);
/*!40000 ALTER TABLE `lanes_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `latest_fuel_prices`
--

DROP TABLE IF EXISTS `latest_fuel_prices`;
/*!50001 DROP VIEW IF EXISTS `latest_fuel_prices`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `latest_fuel_prices` AS SELECT 
 1 AS `region`,
 1 AS `currency`,
 1 AS `fuel_price`,
 1 AS `source`,
 1 AS `tracking_date`,
 1 AS `is_official`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `locations_by_zone`
--

DROP TABLE IF EXISTS `locations_by_zone`;
/*!50001 DROP VIEW IF EXISTS `locations_by_zone`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `locations_by_zone` AS SELECT 
 1 AS `zone`,
 1 AS `total_locations`,
 1 AS `warehouses`,
 1 AS `factories`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `locations_master`
--

DROP TABLE IF EXISTS `locations_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locations_master` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `location_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `location_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `location_type` enum('Factory','Warehouse','Customer','Port','CFS','Depot','Hub','Transit Point','Distribution Center','Retail Store','Office','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line_1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pincode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'India',
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `zone` enum('North India','South India','East India','West India','Central India','Export Hub','Import Hub','Transit Zone','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gstin` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location_contact_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `working_hours` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `loading_unloading_sla` int DEFAULT NULL,
  `dock_type` enum('Ground-level','Hydraulic','Ramp','Platform','Container','Bulk','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parking_available` enum('Yes','No','Limited') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No',
  `equipment_access` json DEFAULT NULL,
  `is_consolidation_hub` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No',
  `preferred_mode` enum('TL','LTL','Rail','Multimodal','Any') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Any',
  `hazmat_allowed` enum('Yes','No','Limited') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No',
  `auto_scheduling_enabled` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No',
  `location_status` enum('Active','Inactive','Temporary','Under Maintenance') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Active',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `location_id` (`location_id`),
  KEY `idx_location_type` (`location_type`),
  KEY `idx_city_state` (`city`,`state`),
  KEY `idx_zone` (`zone`),
  KEY `idx_status` (`location_status`),
  KEY `idx_coordinates` (`latitude`,`longitude`),
  KEY `idx_gstin` (`gstin`),
  KEY `idx_dock_type` (`dock_type`),
  KEY `idx_preferred_mode` (`preferred_mode`),
  KEY `idx_hazmat` (`hazmat_allowed`),
  KEY `idx_consolidation` (`is_consolidation_hub`),
  KEY `idx_auto_scheduling` (`auto_scheduling_enabled`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations_master`
--

LOCK TABLES `locations_master` WRITE;
/*!40000 ALTER TABLE `locations_master` DISABLE KEYS */;
INSERT INTO `locations_master` VALUES (11,'WH-BLR-01','Bangalore Central Warehouse','Warehouse','Plot No. 45, Industrial Area','Bangalore','Karnataka','560100','India',12.93520000,77.61450000,'South India','29ABCDE1234Z5F','Rajesh Kumar','+91-9876543210','rajesh.kumar@company.com','9AM-7PM, Mon-Sat',90,'Ground-level','Yes','[\"Forklift\", \"Pallet Jack\", \"Crane\"]','Yes','Any','No','Yes','Active','Primary distribution center for South India','2025-08-09 11:06:13','2025-08-09 11:06:13',NULL,NULL),(12,'WH-MUM-01','Mumbai Western Warehouse','Warehouse','A-123, MIDC Industrial Area','Mumbai','Maharashtra','400069','India',19.07600000,72.87770000,'West India','27FGHIJ6789K1L2','Priya Sharma','+91-8765432109','priya.sharma@company.com','8AM-6PM, Mon-Sat',75,'Hydraulic','Yes','[\"Forklift\", \"Crane\", \"Conveyor\"]','Yes','Any','Limited','Yes','Active','Export hub with customs clearance facility','2025-08-09 11:06:13','2025-08-09 11:06:13',NULL,NULL),(13,'FACTORY-CHN-01','Chennai Manufacturing Plant','Factory','Plot 78, SIPCOT Industrial Park','Chennai','Tamil Nadu','602105','India',12.97160000,79.59460000,'South India','33RSTUV9012W3X4','Senthil Kumar','+91-6543210987','senthil.kumar@company.com','24/7 Operations',120,'Platform','Yes','[\"Crane\", \"Forklift\", \"Automated System\"]','No','TL','Limited','Yes','Active','Automotive parts manufacturing, heavy machinery access','2025-08-09 11:06:13','2025-08-09 11:06:13',NULL,NULL),(14,'CUST-HYD-01','Hyderabad Customer DC','Customer','Customer Distribution Center','Hyderabad','Telangana','500032','India',17.38500000,78.48670000,'South India',NULL,'Customer Logistics Team','+91-4321098765','logistics@customer.com','9AM-5PM, Mon-Fri',60,'Ground-level','No','[\"Basic Equipment\"]','No','Any','No','No','Active','Customer-owned facility, appointment required','2025-08-09 11:06:13','2025-08-09 11:06:13',NULL,NULL),(15,'PORT-MUM-01','Mumbai Port Terminal','Port','Mumbai Port Trust','Mumbai','Maharashtra','400001','India',18.94900000,72.83450000,'Export Hub',NULL,'Port Operations','+91-2109876543','operations@mumbaiport.gov.in','24/7 Operations',180,'Container','Yes','[\"Gantry Crane\", \"Reach Stacker\", \"Forklift\"]','Yes','Multimodal','Limited','Yes','Active','Major container port, customs clearance available','2025-08-09 11:06:13','2025-08-09 11:06:13',NULL,NULL);
/*!40000 ALTER TABLE `locations_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `mode_capabilities`
--

DROP TABLE IF EXISTS `mode_capabilities`;
/*!50001 DROP VIEW IF EXISTS `mode_capabilities`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `mode_capabilities` AS SELECT 
 1 AS `mode_id`,
 1 AS `mode_name`,
 1 AS `mode_type`,
 1 AS `transit_time_days`,
 1 AS `cost_efficiency_level`,
 1 AS `speed_level`,
 1 AS `supports_time_definite`,
 1 AS `supports_multileg_planning`,
 1 AS `real_time_tracking_support`,
 1 AS `base_cost_multiplier`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `modes_master`
--

DROP TABLE IF EXISTS `modes_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `modes_master` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mode_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique identifier (e.g., MODE-TL-01)',
  `mode_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Descriptive name (e.g., Full Truckload, Rail, Air, LTL)',
  `mode_type` enum('TL','LTL','Rail','Air','Multimodal','Dedicated','Containerized','Specialized') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Transportation mode classification',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Short explanation of the mode and its use cases',
  `transit_time_days` decimal(4,1) DEFAULT NULL COMMENT 'Average days required for movement',
  `typical_use_cases` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'E.g., High-volume outbound, regional shipments',
  `cost_efficiency_level` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Cost efficiency for planning tools',
  `speed_level` enum('Fast','Moderate','Slow') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Speed classification',
  `suitable_commodities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Free text or linked to commodity master',
  `equipment_type_required` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'E.g., 32ft MXL, Reefer, ISO container',
  `carrier_pool_available` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Whether carrier options exist for this mode',
  `supports_time_definite` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Whether fixed-time delivery can be promised',
  `supports_multileg_planning` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Can be used in multi-leg routing setups',
  `real_time_tracking_support` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Helps plan monitoring features',
  `green_score_emission_class` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'For ESG-compliant companies (e.g., Euro 6, Tier 4)',
  `penalty_matrix_linked` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'If penalties differ by mode',
  `contract_type_default` enum('Spot','Rate Card','Tendered','Contract') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Default contract type',
  `active` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Whether it''s currently in use',
  `priority_level` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium' COMMENT 'Planning priority level',
  `seasonal_availability` enum('Year-round','Seasonal','Limited') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Year-round' COMMENT 'Availability throughout the year',
  `minimum_volume_requirement` decimal(10,2) DEFAULT NULL COMMENT 'Minimum volume in kg or pallets',
  `maximum_volume_capacity` decimal(10,2) DEFAULT NULL COMMENT 'Maximum volume capacity',
  `weight_restrictions` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Weight limitations and restrictions',
  `dimension_restrictions` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Size and dimension limitations',
  `base_cost_multiplier` decimal(4,2) DEFAULT '1.00' COMMENT 'Cost multiplier compared to standard TL',
  `fuel_surcharge_applicable` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Whether fuel surcharge applies',
  `detention_charges_applicable` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Whether detention charges apply',
  `customs_clearance_required` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Whether customs clearance is needed',
  `special_permits_required` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Any special permits or licenses needed',
  `insurance_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Insurance coverage requirements',
  `on_time_performance_target` decimal(4,1) DEFAULT NULL COMMENT 'Target on-time performance percentage',
  `damage_claim_rate` decimal(4,2) DEFAULT NULL COMMENT 'Historical damage claim rate percentage',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Any restrictions, seasonal dependencies, etc.',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'System',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'System',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mode_id` (`mode_id`),
  KEY `idx_mode_id` (`mode_id`),
  KEY `idx_mode_type` (`mode_type`),
  KEY `idx_active` (`active`),
  KEY `idx_cost_efficiency` (`cost_efficiency_level`),
  KEY `idx_speed_level` (`speed_level`),
  KEY `idx_transit_time` (`transit_time_days`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for transportation modes and their characteristics';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modes_master`
--

LOCK TABLES `modes_master` WRITE;
/*!40000 ALTER TABLE `modes_master` DISABLE KEYS */;
INSERT INTO `modes_master` VALUES (1,'MODE-TL-01','Full Truckload Standard','TL','Standard full truckload service for general cargo',2.5,'High-volume outbound, long-haul shipments, general freight','High','Moderate','General cargo, palletized goods, bulk materials','53ft Dry Van, 48ft Flatbed','Yes','Yes','Yes','Yes','Euro 6','Yes','Rate Card','Yes','High','Year-round',10000.00,45000.00,'Up to 45,000 lbs','53ft x 8.5ft x 8.5ft',1.00,'Yes','Yes','No','CDL required, DOT compliance','Minimum $1M liability coverage',95.0,0.50,'Most cost-effective for full loads, excellent carrier availability','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(2,'MODE-TL-02','Full Truckload Express','TL','Fast full truckload service for time-critical shipments',1.5,'Time-critical shipments, high-value goods, urgent deliveries','Medium','Fast','High-value electronics, pharmaceuticals, time-sensitive materials','53ft Dry Van, 48ft Flatbed','Yes','Yes','Yes','Yes','Euro 6','Yes','Tendered','Yes','High','Year-round',10000.00,45000.00,'Up to 45,000 lbs','53ft x 8.5ft x 8.5ft',1.25,'Yes','Yes','No','CDL required, DOT compliance','Minimum $2M liability coverage',98.0,0.30,'Premium service with guaranteed delivery times, higher cost','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(3,'MODE-TL-03','Full Truckload Dedicated','Dedicated','Dedicated truck service with guaranteed capacity',3.0,'High-volume customers, guaranteed capacity, consistent service','Medium','Moderate','Regular shipments, contract customers, high-volume lanes','53ft Dry Van, 48ft Flatbed','Yes','Yes','Yes','Yes','Euro 6','Yes','Contract','Yes','High','Year-round',15000.00,45000.00,'Up to 45,000 lbs','53ft x 8.5ft x 8.5ft',1.15,'Yes','Yes','No','CDL required, DOT compliance','Minimum $1.5M liability coverage',96.0,0.40,'Guaranteed capacity with consistent service, contract-based pricing','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(4,'MODE-LTL-01','Less-Than-Truckload Standard','LTL','Standard LTL service for smaller shipments',4.0,'Small loads, cost efficiency, regional shipments','High','Slow','Small packages, partial pallets, retail goods','Various LTL equipment','Yes','No','Yes','Yes','Euro 6','Yes','Rate Card','Yes','Medium','Year-round',100.00,10000.00,'Up to 10,000 lbs','Various sizes',0.85,'Yes','Yes','No','LTL carrier compliance','Carrier-provided coverage',90.0,1.20,'Cost-effective for small loads, multiple stops, longer transit times','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(5,'MODE-LTL-02','Less-Than-Truckload Express','LTL','Fast LTL service for time-sensitive small shipments',2.5,'Time-sensitive small shipments, high-value goods','Medium','Moderate','High-value small items, urgent documents, samples','Various LTL equipment','Yes','Yes','Yes','Yes','Euro 6','Yes','Tendered','Yes','Medium','Year-round',100.00,10000.00,'Up to 10,000 lbs','Various sizes',1.10,'Yes','Yes','No','LTL carrier compliance','Carrier-provided coverage',95.0,0.80,'Faster delivery for small loads, premium pricing','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(6,'MODE-RAIL-01','Rail Freight Standard','Rail','Standard rail service for long-distance bulk shipments',7.0,'Long-distance bulk shipments, cost optimization, heavy materials','High','Slow','Bulk materials, heavy machinery, industrial goods','Rail cars, containers','Yes','No','Yes','Yes','Low emissions','Yes','Contract','Yes','Medium','Year-round',50000.00,200000.00,'Up to 200,000 lbs','Various rail car sizes',0.70,'No','Yes','No','Rail safety compliance','Rail carrier coverage',85.0,0.80,'Most cost-effective for long distances, slower transit times','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(7,'MODE-INT-01','Rail + Truck Intermodal','Multimodal','Combined rail and truck service for optimal cost and speed',5.0,'Long-distance with cost savings, time-sensitive bulk shipments','High','Moderate','Bulk materials, containers, long-distance goods','Rail cars, containers, trucks','Yes','Yes','Yes','Yes','Low emissions','Yes','Contract','Yes','High','Year-round',20000.00,100000.00,'Up to 100,000 lbs','Container dimensions',0.80,'Yes','Yes','No','Intermodal compliance, CDL required','Combined coverage',90.0,0.60,'Optimal balance of cost and speed, container-based','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(8,'MODE-AIR-01','Air Freight Express','Air','Fastest air freight service for urgent shipments',1.0,'High-value urgent goods, time-critical shipments, international','Low','Fast','High-value electronics, pharmaceuticals, documents','Cargo aircraft, passenger aircraft','Yes','Yes','Yes','Yes','High emissions','Yes','Tendered','Yes','High','Year-round',1.00,1000.00,'Up to 1,000 lbs','Various aircraft capacities',3.50,'No','Yes','Yes','Air freight compliance, customs clearance','Air freight coverage',99.0,0.20,'Fastest delivery option, highest cost, limited capacity','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(9,'MODE-AIR-02','Air Freight Economy','Air','Economy air freight for cost-conscious urgent shipments',2.0,'Urgent shipments with cost consideration, international trade','Medium','Fast','Urgent goods, international shipments, time-sensitive','Cargo aircraft, passenger aircraft','Yes','No','Yes','Yes','High emissions','Yes','Rate Card','Yes','Medium','Year-round',1.00,1000.00,'Up to 1,000 lbs','Various aircraft capacities',2.50,'No','Yes','Yes','Air freight compliance, customs clearance','Air freight coverage',95.0,0.30,'Faster than surface, more affordable than express air','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(10,'MODE-SPEC-01','Temperature Controlled','Specialized','Refrigerated transport for temperature-sensitive goods',3.0,'Pharmaceuticals, food products, chemicals, temperature-sensitive materials','Medium','Moderate','Perishable goods, pharmaceuticals, food','Reefer trailers, temperature-controlled containers','Yes','Yes','Yes','Yes','Euro 6','Yes','Contract','Yes','High','Year-round',5000.00,40000.00,'Up to 40,000 lbs','53ft x 8.5ft x 8.5ft',1.40,'Yes','Yes','No','Temperature control certification, food safety compliance','Temperature control coverage',96.0,0.40,'Specialized equipment, temperature monitoring, higher cost','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(11,'MODE-SPEC-02','Oversized Cargo','Specialized','Transport for oversized and heavy equipment',5.0,'Heavy machinery, industrial equipment, oversized loads','Low','Slow','Construction equipment, industrial machinery, oversized loads','Flatbed trailers, specialized equipment','Yes','No','Yes','Yes','Euro 6','Yes','Contract','Yes','Medium','Year-round',10000.00,100000.00,'Up to 100,000 lbs','Various oversized dimensions',2.00,'Yes','Yes','No','Oversized load permits, escort vehicles','Heavy haul coverage',90.0,1.00,'Specialized permits required, escort vehicles, highest cost','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(12,'MODE-SPEC-03','White Glove Service','Specialized','High-touch handling for valuable and fragile items',3.5,'High-value electronics, art, antiques, fragile items','Low','Moderate','Electronics, artwork, antiques, fragile items','Specialized equipment, climate control','Yes','Yes','Yes','Yes','Euro 6','Yes','Tendered','Yes','High','Year-round',1000.00,20000.00,'Up to 20,000 lbs','Various specialized equipment',2.50,'Yes','Yes','No','Specialized handling certification, insurance requirements','High-value coverage',98.0,0.20,'Specialized handling, climate control, highest service level','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(13,'MODE-CON-01','Containerized TL','Containerized','Container-based truckload service for export-bound goods',2.5,'Export shipments, containerized goods, international trade','Medium','Moderate','Export goods, containerized cargo, international shipments','ISO containers, specialized chassis','Yes','Yes','Yes','Yes','Euro 6','Yes','Contract','Yes','High','Year-round',5000.00,30000.00,'Up to 30,000 lbs','20ft/40ft container dimensions',1.20,'Yes','Yes','Yes','Container handling certification, export compliance','Export coverage',95.0,0.50,'Container-based, export-ready, customs clearance support','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37'),(14,'MODE-CON-02','Intermodal Container','Multimodal','Combined container and rail service for long-distance',6.0,'Long-distance container shipments, cost optimization, international trade','High','Slow','Containerized goods, international shipments, bulk materials','ISO containers, rail cars, trucks','Yes','No','Yes','Yes','Low emissions','Yes','Contract','Yes','Medium','Year-round',10000.00,50000.00,'Up to 50,000 lbs','20ft/40ft container dimensions',0.90,'Yes','Yes','Yes','Intermodal compliance, export compliance','Combined coverage',88.0,0.60,'Container-based, rail optimization, customs clearance support','System','System','2025-08-09 11:59:37','2025-08-09 11:59:37');
/*!40000 ALTER TABLE `modes_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `performance_tier_analysis`
--

DROP TABLE IF EXISTS `performance_tier_analysis`;
/*!50001 DROP VIEW IF EXISTS `performance_tier_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `performance_tier_analysis` AS SELECT 
 1 AS `performance_tier`,
 1 AS `carrier_count`,
 1 AS `avg_fleet_size`,
 1 AS `compliant_count`,
 1 AS `invited_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `procurement_decision_support`
--

DROP TABLE IF EXISTS `procurement_decision_support`;
/*!50001 DROP VIEW IF EXISTS `procurement_decision_support`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `procurement_decision_support` AS SELECT 
 1 AS `carrier_id`,
 1 AS `carrier_name`,
 1 AS `equipment_type`,
 1 AS `origin_location`,
 1 AS `destination_location`,
 1 AS `acceptance_rate`,
 1 AS `overall_on_time_performance`,
 1 AS `billing_accuracy_rate`,
 1 AS `performance_rating`,
 1 AS `scorecard_grade`,
 1 AS `risk_score`,
 1 AS `compliance_status`,
 1 AS `procurement_recommendation`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `rate_analysis`
--

DROP TABLE IF EXISTS `rate_analysis`;
/*!50001 DROP VIEW IF EXISTS `rate_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `rate_analysis` AS SELECT 
 1 AS `lane_id`,
 1 AS `origin_city`,
 1 AS `destination_city`,
 1 AS `distance_km`,
 1 AS `current_rate_trip`,
 1 AS `benchmark_rate_trip`,
 1 AS `rate_variance_percent`,
 1 AS `fuel_surcharge_applied`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `rate_type_analysis`
--

DROP TABLE IF EXISTS `rate_type_analysis`;
/*!50001 DROP VIEW IF EXISTS `rate_type_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `rate_type_analysis` AS SELECT 
 1 AS `rate_type`,
 1 AS `total_accessorials`,
 1 AS `taxable_count`,
 1 AS `avg_rate_value`,
 1 AS `min_rate_value`,
 1 AS `max_rate_value`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `regional_carrier_distribution`
--

DROP TABLE IF EXISTS `regional_carrier_distribution`;
/*!50001 DROP VIEW IF EXISTS `regional_carrier_distribution`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `regional_carrier_distribution` AS SELECT 
 1 AS `region_of_operation`,
 1 AS `total_carriers`,
 1 AS `compliant_carriers`,
 1 AS `eligible_carriers`,
 1 AS `invited_carriers`,
 1 AS `avg_performance_score`,
 1 AS `total_fleet_capacity`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `regional_coverage_analysis`
--

DROP TABLE IF EXISTS `regional_coverage_analysis`;
/*!50001 DROP VIEW IF EXISTS `regional_coverage_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `regional_coverage_analysis` AS SELECT 
 1 AS `region_coverage`,
 1 AS `carrier_count`,
 1 AS `avg_otp`,
 1 AS `avg_acceptance`,
 1 AS `avg_fleet_size`,
 1 AS `available_ratings`,
 1 AS `preferred_carriers`,
 1 AS `contracted_carriers`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `regional_season_impact`
--

DROP TABLE IF EXISTS `regional_season_impact`;
/*!50001 DROP VIEW IF EXISTS `regional_season_impact`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `regional_season_impact` AS SELECT 
 1 AS `affected_regions`,
 1 AS `total_seasons`,
 1 AS `high_risk_seasons`,
 1 AS `medium_risk_seasons`,
 1 AS `avg_rate_impact`,
 1 AS `avg_sla_adjustment`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `routing_guide_summary`
--

DROP TABLE IF EXISTS `routing_guide_summary`;
/*!50001 DROP VIEW IF EXISTS `routing_guide_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `routing_guide_summary` AS SELECT 
 1 AS `routing_guide_status`,
 1 AS `guide_count`,
 1 AS `avg_primary_rate`,
 1 AS `earliest_validity`,
 1 AS `latest_validity`,
 1 AS `unique_equipment_types`,
 1 AS `unique_carriers`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `routing_guides`
--

DROP TABLE IF EXISTS `routing_guides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `routing_guides` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `routing_guide_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique reference for the routing guide',
  `origin_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'City, state, pin code, or facility ID',
  `destination_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Same format as origin',
  `lane_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Optional if standardized lane identification',
  `equipment_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'E.g., 32ft SXL, reefer, flatbed, 20ft container',
  `service_level` enum('Standard','Express','Next-day','Same-day','Economy','Premium') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Standard',
  `mode` enum('TL','LTL','Rail','Intermodal','Partial') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'TL',
  `primary_carrier_id` bigint DEFAULT NULL COMMENT 'Reference to carriers table - default/preferred carrier',
  `primary_carrier_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Name of primary carrier for quick reference',
  `primary_carrier_rate` decimal(15,2) NOT NULL COMMENT 'Rate applicable for primary carrier',
  `primary_carrier_rate_type` enum('Per KM','Per Load','Slab-based','Per Ton','Fixed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `backup_carrier_1_id` bigint DEFAULT NULL COMMENT 'Reference to carriers table - secondary carrier',
  `backup_carrier_1_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Name of backup carrier 1',
  `backup_carrier_1_rate` decimal(15,2) DEFAULT NULL COMMENT 'Rate for backup carrier 1',
  `backup_carrier_1_rate_type` enum('Per KM','Per Load','Slab-based','Per Ton','Fixed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `backup_carrier_2_id` bigint DEFAULT NULL COMMENT 'Reference to carriers table - tertiary carrier',
  `backup_carrier_2_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Name of backup carrier 2',
  `backup_carrier_2_rate` decimal(15,2) DEFAULT NULL COMMENT 'Rate for backup carrier 2',
  `backup_carrier_2_rate_type` enum('Per KM','Per Load','Slab-based','Per Ton','Fixed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tender_sequence` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Order in which carriers should be tendered (e.g., 1-2-3)',
  `tender_lead_time_hours` int NOT NULL COMMENT 'How early carrier must be informed (in hours)',
  `transit_sla_days` int DEFAULT NULL COMMENT 'Agreed time to deliver (in days)',
  `transit_sla_hours` int DEFAULT NULL COMMENT 'Agreed time to deliver (in hours)',
  `fuel_surcharge_percentage` decimal(8,4) DEFAULT '0.0000' COMMENT 'Dynamic or fixed fuel surcharge value',
  `fuel_surcharge_type` enum('Percentage','Fixed','Indexed','None') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'None',
  `accessorials_included` enum('Yes','No','Partial') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'For loading/unloading/etc.',
  `accessorial_charges` json DEFAULT NULL COMMENT 'Detailed breakdown of accessorial charges as JSON',
  `load_commitment_type` enum('Fixed','Variable','Spot','Guaranteed','Best-effort') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Variable',
  `load_volume_commitment` int DEFAULT NULL COMMENT 'Volume guarantee or minimums in trips/tonnes',
  `valid_from` date NOT NULL COMMENT 'Start of routing guide validity',
  `valid_to` date NOT NULL COMMENT 'End date of routing guide validity',
  `tender_via_api` tinyint(1) DEFAULT '0' COMMENT 'Whether to tender via TMS API',
  `load_type` enum('Regular','High-value','Fragile','Hazardous','Temperature-controlled','Oversized') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Regular',
  `auto_tender_rule` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'e.g., tender to carrier X unless carrier Y offers <90% OTP',
  `penalty_missed_tender_percentage` decimal(5,2) DEFAULT NULL COMMENT 'Penalty if primary rejects more than X%',
  `exceptions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Special notes (e.g., night ban, regional blackout, seasonal restrictions)',
  `business_rules` json DEFAULT NULL COMMENT 'Additional business rules and constraints as JSON',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Any other business rules or notes',
  `routing_guide_status` enum('Active','Inactive','Draft','Under Review','Expired') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `compliance_score` decimal(5,2) DEFAULT NULL COMMENT 'Performance compliance score (0-100)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who created the routing guide',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who last updated the routing guide',
  PRIMARY KEY (`id`),
  UNIQUE KEY `routing_guide_id` (`routing_guide_id`),
  KEY `idx_routing_guide_id` (`routing_guide_id`),
  KEY `idx_lane` (`origin_location`,`destination_location`),
  KEY `idx_equipment_type` (`equipment_type`),
  KEY `idx_service_level` (`service_level`),
  KEY `idx_primary_carrier` (`primary_carrier_id`),
  KEY `idx_routing_guide_status` (`routing_guide_status`),
  KEY `idx_validity_period` (`valid_from`,`valid_to`),
  KEY `idx_lane_equipment` (`origin_location`,`destination_location`,`equipment_type`),
  KEY `idx_carrier_rates` (`primary_carrier_rate`,`backup_carrier_1_rate`,`backup_carrier_2_rate`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Routing guides for TL transportation procurement with carrier selection rules';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routing_guides`
--

LOCK TABLES `routing_guides` WRITE;
/*!40000 ALTER TABLE `routing_guides` DISABLE KEYS */;
INSERT INTO `routing_guides` VALUES (1,'RG-2024-001','Gurgaon, Haryana','Bangalore, Karnataka','LANE-GUR-BLR-001','32ft SXL','Standard','TL',NULL,'Gati Ltd',25000.00,'Per Load',NULL,'Delhivery',27000.00,'Per Load',NULL,'Blue Dart',30000.00,'Per Load','1-2-3',24,3,NULL,12.5000,'None','Partial',NULL,'Variable',NULL,'2024-01-01','2024-12-31',0,'Regular',NULL,NULL,NULL,NULL,NULL,'Active',NULL,'2025-08-09 09:38:22','2025-08-09 09:38:22',NULL,NULL),(2,'RG-2024-002','Mumbai, Maharashtra','Delhi, Delhi','LANE-MUM-DEL-001','32ft Trailer','Express','TL',NULL,'ABC Transport Ltd',35000.00,'Per Load',NULL,'XYZ Logistics',38000.00,'Per Load',NULL,'Fast Freight Co',42000.00,'Per Load','1-2-3',12,2,NULL,15.0000,'None','Yes',NULL,'Fixed',NULL,'2024-02-01','2025-01-31',0,'Regular',NULL,NULL,NULL,NULL,NULL,'Active',NULL,'2025-08-09 09:38:22','2025-08-09 09:38:22',NULL,NULL),(3,'RG-2024-003','Chennai, Tamil Nadu','Hyderabad, Telangana','LANE-CHE-HYD-001','20ft Container','Standard','TL',NULL,'South Express',18000.00,'Per Load',NULL,'Regional Cargo',20000.00,'Per Load',NULL,'City Connect',22000.00,'Per Load','1-2-3',48,1,NULL,10.0000,'None','No',NULL,'Variable',NULL,'2024-03-01','2024-08-31',0,'Regular',NULL,NULL,NULL,NULL,NULL,'Active',NULL,'2025-08-09 09:38:22','2025-08-09 09:38:22',NULL,NULL),(4,'RG-2024-004','Pune, Maharashtra','Ahmedabad, Gujarat','LANE-PUN-AHM-001','Reefer Trailer','Premium','TL',NULL,'Cold Chain Express',45000.00,'Per Load',NULL,'Frozen Logistics',48000.00,'Per Load',NULL,'Chill Transport',52000.00,'Per Load','1-2-3',36,2,NULL,18.0000,'None','Yes',NULL,'Guaranteed',NULL,'2024-04-01','2025-03-31',0,'Regular',NULL,NULL,NULL,NULL,NULL,'Active',NULL,'2025-08-09 09:38:22','2025-08-09 09:38:22',NULL,NULL),(5,'RG-2024-005','Kolkata, West Bengal','Pune, Maharashtra','LANE-KOL-PUN-001','Flatbed Trailer','Economy','TL',NULL,'East West Cargo',28000.00,'Per Load',NULL,'Bharat Transport',30000.00,'Per Load',NULL,'National Logistics',32000.00,'Per Load','1-2-3',72,4,NULL,8.5000,'None','Partial',NULL,'Variable',NULL,'2024-05-01','2024-10-31',0,'Regular',NULL,NULL,NULL,NULL,NULL,'Active',NULL,'2025-08-09 09:38:22','2025-08-09 09:38:22',NULL,NULL);
/*!40000 ALTER TABLE `routing_guides` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `seasonal_cost_analysis`
--

DROP TABLE IF EXISTS `seasonal_cost_analysis`;
/*!50001 DROP VIEW IF EXISTS `seasonal_cost_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `seasonal_cost_analysis` AS SELECT 
 1 AS `season_id`,
 1 AS `season_name`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `impact_type`,
 1 AS `rate_multiplier_percent`,
 1 AS `cost_impact`,
 1 AS `affected_regions`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `seasonal_lanes`
--

DROP TABLE IF EXISTS `seasonal_lanes`;
/*!50001 DROP VIEW IF EXISTS `seasonal_lanes`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `seasonal_lanes` AS SELECT 
 1 AS `lane_id`,
 1 AS `origin_city`,
 1 AS `destination_city`,
 1 AS `peak_months`,
 1 AS `avg_load_frequency_month`,
 1 AS `distance_km`,
 1 AS `transit_time_days`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `seasons_master`
--

DROP TABLE IF EXISTS `seasons_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seasons_master` (
  `id` int NOT NULL AUTO_INCREMENT,
  `season_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique season identifier (e.g., SEASON-01)',
  `season_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Human-readable season name (e.g., Monsoon, Peak Festive)',
  `start_date` date NOT NULL COMMENT 'Season start date',
  `end_date` date NOT NULL COMMENT 'Season end date',
  `impact_type` enum('Cost Increase','Capacity Shortage','SLA Risk','None','Mixed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primary impact of the season',
  `affected_regions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Comma-separated list of affected regions/states',
  `affected_lanes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Optional list of Lane IDs impacted (comma-separated)',
  `rate_multiplier_percent` decimal(5,2) DEFAULT NULL COMMENT 'Rate premium percentage (e.g., 5.00 for 5%)',
  `sla_adjustment_days` int DEFAULT '0' COMMENT 'Buffer days to add to SLA (can be negative)',
  `capacity_risk_level` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium' COMMENT 'Expected capacity risk level',
  `carrier_participation_impact` decimal(5,2) DEFAULT NULL COMMENT 'Expected drop in carrier availability (%)',
  `applicable_equipment_types` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Comma-separated list of affected equipment types',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'Whether this season is currently active',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Additional descriptive information about the season',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'system' COMMENT 'User who created the record',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'system' COMMENT 'User who last updated the record',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record update timestamp',
  PRIMARY KEY (`id`),
  UNIQUE KEY `season_id` (`season_id`),
  KEY `idx_season_id` (`season_id`),
  KEY `idx_season_name` (`season_name`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_end_date` (`end_date`),
  KEY `idx_impact_type` (`impact_type`),
  KEY `idx_capacity_risk` (`capacity_risk_level`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_date_range` (`start_date`,`end_date`),
  CONSTRAINT `chk_carrier_impact` CHECK (((`carrier_participation_impact` >= -(100.00)) and (`carrier_participation_impact` <= 100.00))),
  CONSTRAINT `chk_dates` CHECK ((`end_date` >= `start_date`)),
  CONSTRAINT `chk_rate_multiplier` CHECK (((`rate_multiplier_percent` >= -(50.00)) and (`rate_multiplier_percent` <= 100.00)))
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for seasonal variations in transport procurement';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seasons_master`
--

LOCK TABLES `seasons_master` WRITE;
/*!40000 ALTER TABLE `seasons_master` DISABLE KEYS */;
INSERT INTO `seasons_master` VALUES (1,'SEASON-MONSOON-2025','Monsoon Season','2025-07-01','2025-09-30','SLA Risk','Maharashtra, Karnataka, Kerala, Goa, Coastal Regions','MUM-BLR, MUM-GOA, BLR-MAA',3.50,2,'High',15.00,'Container, Open Body, Flatbed',1,'Heavy rainfall affects road conditions, especially in Western Ghats and coastal areas','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(2,'SEASON-FESTIVE-2025','Diwali Peak','2025-10-15','2025-11-10','Cost Increase','All India','All Major Lanes',8.00,1,'High',25.00,'Container, Box Truck, Reefer',1,'Festival congestion + high FMCG/e-commerce demand, peak retail season','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(3,'SEASON-HARVEST-2025','Harvest Season','2025-03-01','2025-05-31','Capacity Shortage','Punjab, Haryana, Uttar Pradesh, Madhya Pradesh, Maharashtra','DEL-CHD, MUM-NAG, BLR-HYD',5.00,1,'Medium',20.00,'Open Body, Flatbed, Container',1,'Agricultural freight spikes for grains, cotton, sugarcane; rural road congestion','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(4,'SEASON-YEAREND-2025','Year-End Rush','2025-02-01','2025-03-31','Cost Increase','All India','All Major Lanes',4.00,1,'Medium',15.00,'All Equipment Types',1,'Quarter-end and fiscal year-end push; corporate shipping deadlines','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(5,'SEASON-SUMMER-2025','Summer Peak','2025-04-01','2025-06-30','Mixed','North India, Central India','DEL-MUM, DEL-BLR, DEL-CHD',2.50,0,'Low',10.00,'Reefer, Container',1,'High temperature affects perishable goods; increased reefer demand','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(6,'SEASON-PRE-MONSOON-2025','Pre-Monsoon','2025-06-01','2025-06-30','SLA Risk','Western India, Southern India','MUM-BLR, MUM-GOA, BLR-MAA',1.50,1,'Medium',8.00,'All Equipment Types',1,'Road preparation and pre-monsoon maintenance affects transit times','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(7,'SEASON-POST-MONSOON-2025','Post-Monsoon','2025-10-01','2025-10-14','SLA Risk','Maharashtra, Karnataka, Kerala','MUM-BLR, BLR-MAA, MUM-GOA',2.00,1,'Medium',12.00,'All Equipment Types',1,'Road damage assessment and repair work affects certain routes','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(8,'SEASON-WINTER-2025','Winter Peak','2025-12-01','2026-01-31','Cost Increase','North India, Northeast India','DEL-CHD, DEL-KOL, DEL-GUW',3.00,1,'Medium',18.00,'Container, Box Truck, Reefer',1,'Winter weather affects northern routes; increased heating fuel transport','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(9,'SEASON-ELECTION-2025','Election Season','2025-04-01','2025-05-31','Capacity Shortage','All India','All Major Lanes',6.00,2,'High',30.00,'All Equipment Types',1,'Political rallies and security measures affect road transport and capacity','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(10,'SEASON-EXPORT-2025','Export Peak','2025-09-01','2025-12-31','Cost Increase','Mumbai, Chennai, Kolkata, Cochin','MUM-JNPT, CHN-PORT, KOL-PORT',4.50,1,'Medium',20.00,'Container, Reefer',1,'Peak export season; port congestion and container shortage','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(11,'SEASON-CONSTRUCTION-2025','Construction Season','2025-03-01','2025-06-30','Capacity Shortage','Metro Cities, Industrial Zones','MUM-PUN, BLR-HYD, DEL-NCR',3.50,1,'Medium',15.00,'Flatbed, Open Body, Heavy Equipment',1,'Infrastructure projects peak; heavy equipment and material transport','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(12,'SEASON-ECOMMERCE-2025','E-commerce Peak','2025-11-01','2025-12-31','Cost Increase','All India','All Major Lanes',7.00,1,'High',25.00,'Box Truck, Container, Last Mile Vehicles',1,'Black Friday, Cyber Monday, and holiday shopping peak','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(13,'SEASON-AGRI-OFF-2025','Agricultural Off-Season','2025-01-01','2025-02-28','None','Rural Areas, Agricultural States','Rural Routes',0.00,0,'Low',5.00,'Open Body, Flatbed',1,'Low agricultural activity; reduced rural freight demand','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42'),(14,'SEASON-MONSOON-RECOVERY-2025','Monsoon Recovery','2025-10-01','2025-10-31','SLA Risk','Western India, Southern India','MUM-BLR, BLR-MAA',1.00,1,'Low',8.00,'All Equipment Types',1,'Post-monsoon road recovery; gradual improvement in transit times','system','system','2025-08-09 12:20:42','2025-08-09 12:20:42');
/*!40000 ALTER TABLE `seasons_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `service_level_pricing_tiers`
--

DROP TABLE IF EXISTS `service_level_pricing_tiers`;
/*!50001 DROP VIEW IF EXISTS `service_level_pricing_tiers`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `service_level_pricing_tiers` AS SELECT 
 1 AS `service_level_id`,
 1 AS `service_level_name`,
 1 AS `service_category`,
 1 AS `priority_tag`,
 1 AS `max_transit_time_days`,
 1 AS `pricing_tier`,
 1 AS `penalty_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `service_level_summary`
--

DROP TABLE IF EXISTS `service_level_summary`;
/*!50001 DROP VIEW IF EXISTS `service_level_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `service_level_summary` AS SELECT 
 1 AS `service_category`,
 1 AS `total_service_levels`,
 1 AS `penalty_applicable_count`,
 1 AS `hard_sla_count`,
 1 AS `avg_transit_time`,
 1 AS `avg_response_time`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `service_levels_master`
--

DROP TABLE IF EXISTS `service_levels_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_levels_master` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `service_level_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique service level identifier (e.g., SL-001)',
  `service_level_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Descriptive name (e.g., Standard, Express, Scheduled)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Detailed description of service level expectations',
  `max_transit_time_days` decimal(3,1) NOT NULL COMMENT 'Maximum allowed transit time in days',
  `allowed_delay_buffer_hours` decimal(4,1) DEFAULT '0.0' COMMENT 'Permissible delay threshold in hours',
  `fixed_departure_time` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Is pickup expected at a fixed hour/day?',
  `fixed_delivery_time` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Is delivery time-specific?',
  `mode` enum('TL','LTL','Rail-Road','Intermodal','Express','Dedicated') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'TL' COMMENT 'Transportation mode',
  `carrier_response_time_hours` decimal(4,1) DEFAULT '24.0' COMMENT 'Expected time for carrier to accept the load',
  `sla_type` enum('Hard SLA','Soft SLA','Target SLA') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Soft SLA' COMMENT 'SLA enforcement type',
  `penalty_applicable` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Is penalty applied for failure to meet SLA?',
  `penalty_rule_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Link to penalty definition (e.g., % of freight)',
  `priority_tag` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Medium' COMMENT 'Planning preference priority',
  `enabled_for_bidding` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Whether this service level can be selected in RFPs',
  `service_category` enum('Standard','Premium','Express','Dedicated','Specialized') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Standard' COMMENT 'Service category classification',
  `pickup_time_window_start` time DEFAULT NULL COMMENT 'Preferred pickup time window start (HH:MM)',
  `pickup_time_window_end` time DEFAULT NULL COMMENT 'Preferred pickup time window end (HH:MM)',
  `delivery_time_window_start` time DEFAULT NULL COMMENT 'Preferred delivery time window start (HH:MM)',
  `delivery_time_window_end` time DEFAULT NULL COMMENT 'Preferred delivery time window end (HH:MM)',
  `weekend_operations` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Does service operate on weekends?',
  `holiday_operations` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Does service operate on holidays?',
  `temperature_controlled` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Requires temperature-controlled equipment?',
  `security_required` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'No' COMMENT 'Requires security escort or special handling?',
  `insurance_coverage` decimal(10,2) DEFAULT NULL COMMENT 'Minimum insurance coverage required (in INR)',
  `fuel_surcharge_applicable` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Is fuel surcharge applicable?',
  `detention_charges_applicable` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Yes' COMMENT 'Are detention charges applicable?',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Additional notes and special requirements',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who created the service level',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who last updated the service level',
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_level_id` (`service_level_id`),
  KEY `idx_service_level_id` (`service_level_id`),
  KEY `idx_service_level_name` (`service_level_name`),
  KEY `idx_mode` (`mode`),
  KEY `idx_service_category` (`service_category`),
  KEY `idx_sla_type` (`sla_type`),
  KEY `idx_priority_tag` (`priority_tag`),
  KEY `idx_enabled_for_bidding` (`enabled_for_bidding`),
  KEY `idx_max_transit_time` (`max_transit_time_days`),
  KEY `idx_penalty_applicable` (`penalty_applicable`),
  KEY `idx_temperature_controlled` (`temperature_controlled`),
  KEY `idx_security_required` (`security_required`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Service Levels Master for TL transportation procurement with comprehensive SLA definitions';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_levels_master`
--

LOCK TABLES `service_levels_master` WRITE;
/*!40000 ALTER TABLE `service_levels_master` DISABLE KEYS */;
INSERT INTO `service_levels_master` VALUES (3,'SL-STD-01','Standard Delivery','Regular TL service with standard transit times and normal operating conditions',3.0,4.0,'No','No','TL',24.0,'Soft SLA','No',NULL,'Medium','Yes','Standard',NULL,NULL,NULL,NULL,'No','No','No','No',50000.00,'Yes','Yes','Standard service for regular shipments','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(4,'SL-EXP-01','Express Delivery','Fast turnaround priority service for time-critical shipments',1.5,2.0,'Yes','Yes','TL',12.0,'Hard SLA','Yes','PEN-EXP-01','High','Yes','Express','08:00:00','10:00:00','16:00:00','18:00:00','Yes','Yes','No','No',100000.00,'Yes','Yes','Used for high-value pharma shipments and urgent deliveries','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(5,'SL-SCH-01','Scheduled Pickup/Delivery','Pre-booked time slots at dock to reduce wait time and improve efficiency',2.5,3.0,'Yes','Yes','TL',18.0,'Hard SLA','Yes','PEN-SCH-01','Medium','Yes','Premium','09:00:00','11:00:00','14:00:00','16:00:00','No','No','No','No',75000.00,'Yes','Yes','Fixed time slots for better dock management','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(6,'SL-TD-01','Time-Definite','Delivery or pickup must happen at a defined time window with strict adherence',2.0,1.0,'Yes','Yes','TL',6.0,'Hard SLA','Yes','PEN-TD-01','High','Yes','Premium','10:00:00','10:30:00','15:00:00','15:30:00','Yes','Yes','No','No',150000.00,'Yes','Yes','Critical for just-in-time manufacturing and retail','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(7,'SL-DED-01','Dedicated Service','Specific vehicle assigned with no load sharing, guaranteed capacity',4.0,6.0,'No','No','Dedicated',48.0,'Soft SLA','No',NULL,'Medium','Yes','Dedicated',NULL,NULL,NULL,NULL,'No','No','No','No',200000.00,'Yes','Yes','For high-volume shippers requiring guaranteed capacity','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(8,'SL-WG-01','White Glove Service','High-touch handling with security, extra personnel, and special care',3.5,2.0,'Yes','Yes','TL',12.0,'Hard SLA','Yes','PEN-WG-01','High','Yes','Specialized','08:00:00','09:00:00','17:00:00','18:00:00','Yes','Yes','No','Yes',250000.00,'Yes','Yes','For high-value electronics, art, and sensitive cargo','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(9,'SL-TEMP-01','Temperature Controlled','Specialized service for perishable goods requiring temperature monitoring',2.5,3.0,'Yes','Yes','TL',18.0,'Hard SLA','Yes','PEN-TEMP-01','High','Yes','Specialized','06:00:00','08:00:00','18:00:00','20:00:00','Yes','Yes','Yes','No',300000.00,'Yes','Yes','For pharmaceuticals, food, and chemicals','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(10,'SL-OVS-01','Oversized Cargo','Special handling for oversized and overweight shipments',5.0,8.0,'No','No','TL',36.0,'Soft SLA','No',NULL,'Medium','Yes','Specialized',NULL,NULL,NULL,NULL,'No','No','No','No',500000.00,'Yes','Yes','Requires special permits and route planning','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(11,'SL-ECO-01','Economy Service','Cost-effective option with longer transit times',5.0,6.0,'No','No','TL',48.0,'Soft SLA','No',NULL,'Low','Yes','Standard',NULL,NULL,NULL,NULL,'No','No','No','No',25000.00,'Yes','Yes','Budget-friendly option for non-urgent shipments','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System'),(12,'SL-INT-01','Intermodal Service','Combined rail and road transportation for long distances',7.0,12.0,'No','No','Intermodal',72.0,'Soft SLA','No',NULL,'Low','Yes','Specialized',NULL,NULL,NULL,NULL,'No','No','No','No',100000.00,'Yes','Yes','For long-haul shipments with cost optimization','2025-08-09 11:45:13','2025-08-09 11:45:13','System','System');
/*!40000 ALTER TABLE `service_levels_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `sla_compliance_analysis`
--

DROP TABLE IF EXISTS `sla_compliance_analysis`;
/*!50001 DROP VIEW IF EXISTS `sla_compliance_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `sla_compliance_analysis` AS SELECT 
 1 AS `sla_type`,
 1 AS `total_levels`,
 1 AS `penalty_enabled`,
 1 AS `penalty_disabled`,
 1 AS `avg_transit_time`,
 1 AS `avg_delay_buffer`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `sourcing_recommendations`
--

DROP TABLE IF EXISTS `sourcing_recommendations`;
/*!50001 DROP VIEW IF EXISTS `sourcing_recommendations`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `sourcing_recommendations` AS SELECT 
 1 AS `carrier_id_3p`,
 1 AS `carrier_name`,
 1 AS `region_of_operation`,
 1 AS `equipment_types`,
 1 AS `performance_score_external`,
 1 AS `fleet_size`,
 1 AS `sourcing_priority`,
 1 AS `activity_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `specialized_equipment`
--

DROP TABLE IF EXISTS `specialized_equipment`;
/*!50001 DROP VIEW IF EXISTS `specialized_equipment`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `specialized_equipment` AS SELECT 
 1 AS `equipment_id`,
 1 AS `equipment_name`,
 1 AS `vehicle_body_type`,
 1 AS `hazmat_certified`,
 1 AS `security_features`,
 1 AS `regulatory_compliance`,
 1 AS `ideal_commodities`,
 1 AS `standard_rate_per_km`,
 1 AS `active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `specialized_modes`
--

DROP TABLE IF EXISTS `specialized_modes`;
/*!50001 DROP VIEW IF EXISTS `specialized_modes`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `specialized_modes` AS SELECT 
 1 AS `mode_id`,
 1 AS `mode_name`,
 1 AS `mode_type`,
 1 AS `suitable_commodities`,
 1 AS `equipment_type_required`,
 1 AS `special_permits_required`,
 1 AS `insurance_requirements`,
 1 AS `base_cost_multiplier`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `surcharge_impact_analysis`
--

DROP TABLE IF EXISTS `surcharge_impact_analysis`;
/*!50001 DROP VIEW IF EXISTS `surcharge_impact_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `surcharge_impact_analysis` AS SELECT 
 1 AS `applicable_region`,
 1 AS `currency`,
 1 AS `total_slabs`,
 1 AS `min_surcharge`,
 1 AS `max_surcharge`,
 1 AS `avg_surcharge`,
 1 AS `no_surcharge_slabs`,
 1 AS `surcharge_slabs`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `targeted_carriers`
--

DROP TABLE IF EXISTS `targeted_carriers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `targeted_carriers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `carrier_id_3p` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique ID from TruckStop/DAT/etc',
  `carrier_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Legal entity or display name',
  `dot_mc_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'US-based registration number (or Indian equivalent like RC/GSTIN)',
  `region_of_operation` enum('North India','South India','East India','West India','Central India','PAN India','East Coast','West Coast','Central US','Northeast US','Southeast US','Northwest US','Southwest US') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `origin_preference` json DEFAULT NULL COMMENT 'Preferred origin regions as JSON array',
  `destination_preference` json DEFAULT NULL COMMENT 'Preferred delivery zones as JSON array',
  `fleet_size` int DEFAULT NULL COMMENT 'Total number of trucks they own/operate',
  `equipment_types` json DEFAULT NULL COMMENT 'Equipment types as JSON array (e.g., Reefer, Flatbed, 32ft, Container)',
  `mode` enum('TL','LTL','Multimodal') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'TL',
  `compliance_validated` tinyint(1) DEFAULT '0' COMMENT 'Has the 3rd-party verified documents (RC, insurance)',
  `performance_score_external` decimal(3,1) DEFAULT NULL COMMENT 'Score from 3rd-party platform (1-5 or A-D converted to numeric)',
  `preferred_commodity_types` json DEFAULT NULL COMMENT 'Preferred commodity types as JSON array (e.g., pharma, FMCG)',
  `technology_enabled` tinyint(1) DEFAULT '0' COMMENT 'GPS, ePOD, integrations supported',
  `rating_threshold_met` tinyint(1) DEFAULT '0' COMMENT 'Filter result from system rule (e.g., only >80% rating carriers)',
  `last_active` date DEFAULT NULL COMMENT 'Date of last seen load or activity',
  `invited_to_bid` tinyint(1) DEFAULT '0' COMMENT 'Whether included in current RFP invite',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Additional metadata, e.g., blacklist, preferred, rejected',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_carrier_id_3p` (`carrier_id_3p`),
  KEY `idx_carrier_id_3p` (`carrier_id_3p`),
  KEY `idx_region` (`region_of_operation`),
  KEY `idx_compliance` (`compliance_validated`),
  KEY `idx_performance` (`performance_score_external`),
  KEY `idx_rating_threshold` (`rating_threshold_met`),
  KEY `idx_last_active` (`last_active`),
  KEY `idx_invited` (`invited_to_bid`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='External 3rd-party carriers for dynamic sourcing during procurement events';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `targeted_carriers`
--

LOCK TABLES `targeted_carriers` WRITE;
/*!40000 ALTER TABLE `targeted_carriers` DISABLE KEYS */;
INSERT INTO `targeted_carriers` VALUES (1,'TS001','Delhi Express Logistics','DL01AB1234','North India','[\"Delhi NCR\", \"Haryana\", \"Punjab\", \"Uttar Pradesh\"]','[\"Mumbai\", \"Bangalore\", \"Chennai\", \"Kolkata\"]',45,'[\"32ft SXL\", \"Reefer\", \"Flatbed\"]','TL',1,4.2,'[\"FMCG\", \"Electronics\", \"Textiles\"]',1,1,'2025-08-07',1,'Preferred carrier for Delhi-Mumbai route','2025-08-09 10:36:10','2025-08-09 10:36:10'),(2,'TS002','Punjab Roadways Ltd','PB02CD5678','North India','[\"Punjab\", \"Himachal Pradesh\", \"Jammu & Kashmir\"]','[\"Delhi NCR\", \"Gujarat\", \"Maharashtra\"]',32,'[\"20ft Container\", \"32ft SXL\", \"Reefer\"]','TL',1,3.8,'[\"Agriculture\", \"FMCG\", \"Pharma\"]',0,1,'2025-08-04',0,'Good for agricultural commodities','2025-08-09 10:36:10','2025-08-09 10:36:10'),(3,'TS003','Chennai Cargo Solutions','TN03EF9012','South India','[\"Tamil Nadu\", \"Karnataka\", \"Kerala\"]','[\"Mumbai\", \"Delhi NCR\", \"Gujarat\"]',28,'[\"Reefer\", \"32ft SXL\", \"Flatbed\"]','TL',1,4.5,'[\"Pharma\", \"FMCG\", \"Electronics\"]',1,1,'2025-08-08',1,'Premium pharma carrier','2025-08-09 10:36:10','2025-08-09 10:36:10'),(4,'TS004','Mumbai Freight Services','MH04GH3456','West India','[\"Maharashtra\", \"Gujarat\", \"Madhya Pradesh\"]','[\"Delhi NCR\", \"Karnataka\", \"Tamil Nadu\"]',67,'[\"32ft SXL\", \"20ft Container\", \"Reefer\", \"Flatbed\"]','Multimodal',1,4.8,'[\"FMCG\", \"Electronics\", \"Textiles\", \"Pharma\"]',1,1,'2025-08-09',1,'Top performer, preferred for all routes','2025-08-09 10:36:10','2025-08-09 10:36:10'),(5,'TS005','Kolkata Transport Co','WB05IJ7890','East India','[\"West Bengal\", \"Bihar\", \"Odisha\"]','[\"Delhi NCR\", \"Mumbai\", \"Bangalore\"]',23,'[\"32ft SXL\", \"Reefer\"]','TL',0,3.2,'[\"Textiles\", \"Agriculture\"]',0,0,'2025-08-01',0,'Compliance issues, needs verification','2025-08-09 10:36:10','2025-08-09 10:36:10'),(6,'TS006','Bhopal Logistics','MP06KL1234','Central India','[\"Madhya Pradesh\", \"Chhattisgarh\", \"Rajasthan\"]','[\"Mumbai\", \"Delhi NCR\", \"Gujarat\"]',18,'[\"32ft SXL\", \"Flatbed\"]','TL',1,3.9,'[\"Agriculture\", \"Mining\", \"FMCG\"]',0,1,'2025-08-06',1,'Reliable for central India routes','2025-08-09 10:36:10','2025-08-09 10:36:10'),(7,'DAT001','Atlantic Freight Solutions','MC123456','East Coast','[\"New York\", \"New Jersey\", \"Pennsylvania\", \"Maryland\"]','[\"Florida\", \"Georgia\", \"South Carolina\", \"North Carolina\"]',89,'[\"53ft Dry Van\", \"Reefer\", \"Flatbed\", \"Power Only\"]','TL',1,4.6,'[\"Electronics\", \"FMCG\", \"Pharma\", \"Automotive\"]',1,1,'2025-08-08',1,'Premium US East Coast carrier','2025-08-09 10:36:10','2025-08-09 10:36:10'),(8,'DAT002','Pacific Coast Transport','MC789012','West Coast','[\"California\", \"Oregon\", \"Washington\"]','[\"Nevada\", \"Arizona\", \"Utah\", \"Colorado\"]',156,'[\"53ft Dry Van\", \"Reefer\", \"Flatbed\", \"Step Deck\", \"Power Only\"]','Multimodal',1,4.9,'[\"Technology\", \"Agriculture\", \"FMCG\", \"Automotive\"]',1,1,'2025-08-09',1,'Top US West Coast performer','2025-08-09 10:36:10','2025-08-09 10:36:10');
/*!40000 ALTER TABLE `targeted_carriers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `taxable_accessorials_analysis`
--

DROP TABLE IF EXISTS `taxable_accessorials_analysis`;
/*!50001 DROP VIEW IF EXISTS `taxable_accessorials_analysis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `taxable_accessorials_analysis` AS SELECT 
 1 AS `taxable`,
 1 AS `total_accessorials`,
 1 AS `avg_rate_value`,
 1 AS `pickup_count`,
 1 AS `delivery_count`,
 1 AS `in_transit_count`,
 1 AS `general_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `temperature_controlled_equipment`
--

DROP TABLE IF EXISTS `temperature_controlled_equipment`;
/*!50001 DROP VIEW IF EXISTS `temperature_controlled_equipment`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `temperature_controlled_equipment` AS SELECT 
 1 AS `equipment_id`,
 1 AS `equipment_name`,
 1 AS `vehicle_body_type`,
 1 AS `vehicle_length_ft`,
 1 AS `refrigeration_capacity_btu`,
 1 AS `ideal_commodities`,
 1 AS `standard_rate_per_km`,
 1 AS `active`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `time_critical_modes`
--

DROP TABLE IF EXISTS `time_critical_modes`;
/*!50001 DROP VIEW IF EXISTS `time_critical_modes`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `time_critical_modes` AS SELECT 
 1 AS `mode_id`,
 1 AS `mode_name`,
 1 AS `mode_type`,
 1 AS `transit_time_days`,
 1 AS `speed_level`,
 1 AS `supports_time_definite`,
 1 AS `on_time_performance_target`,
 1 AS `base_cost_multiplier`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `time_critical_services`
--

DROP TABLE IF EXISTS `time_critical_services`;
/*!50001 DROP VIEW IF EXISTS `time_critical_services`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `time_critical_services` AS SELECT 
 1 AS `service_level_id`,
 1 AS `service_level_name`,
 1 AS `max_transit_time_days`,
 1 AS `allowed_delay_buffer_hours`,
 1 AS `fixed_departure_time`,
 1 AS `fixed_delivery_time`,
 1 AS `pickup_time_window_start`,
 1 AS `delivery_time_window_end`,
 1 AS `sla_type`,
 1 AS `penalty_applicable`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `transport_contracts`
--

DROP TABLE IF EXISTS `transport_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transport_contracts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique identifier for the contract',
  `contract_status` enum('Active','Expired','In Review','Draft','Terminated') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Draft',
  `carrier_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Name of the transportation provider',
  `carrier_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Internal or industry carrier code',
  `origin_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Start of the lane (city/state/pincode)',
  `origin_facility_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Internal plant/warehouse code',
  `origin_pincode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Origin pincode for precise location',
  `origin_state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Origin state',
  `destination_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'End of the lane',
  `destination_facility_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Internal code',
  `destination_pincode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Destination pincode for precise location',
  `destination_state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Destination state',
  `lane_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'System-generated or defined lane code',
  `mode` enum('FTL','LTL','Partial','Intermodal') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'FTL',
  `equipment_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Vehicle type: 32ft, 20ft, reefer, etc.',
  `service_level` enum('Express','Standard','Guaranteed','Premium','Economy') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Standard',
  `transit_time_hours` int DEFAULT NULL COMMENT 'Agreed delivery time in hours',
  `transit_time_days` int DEFAULT NULL COMMENT 'Agreed delivery time in days',
  `rate_type` enum('Per Trip','Per KM','Slab-based','Per Ton','Per Pallet','Fixed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_rate` decimal(15,2) NOT NULL COMMENT 'Fixed or variable rate per unit',
  `rate_currency` enum('INR','USD','EUR') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'INR',
  `minimum_charges` decimal(15,2) DEFAULT '0.00' COMMENT 'Minimum freight applicable',
  `fuel_surcharge_type` enum('Percentage','Indexed','Fixed','None') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'None',
  `fuel_surcharge_value` decimal(8,4) DEFAULT NULL COMMENT 'Percentage or fixed value',
  `fuel_surcharge_index` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Reference to fuel index if applicable',
  `accessorial_charges` json DEFAULT NULL COMMENT 'Extra fees (waiting, loading, etc.) as JSON',
  `waiting_charges_per_hour` decimal(10,2) DEFAULT '0.00',
  `loading_charges` decimal(10,2) DEFAULT '0.00',
  `unloading_charges` decimal(10,2) DEFAULT '0.00',
  `effective_from` date NOT NULL COMMENT 'Contract start date',
  `effective_to` date NOT NULL COMMENT 'Contract expiry date',
  `payment_terms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g., 30 days, advance, COD',
  `tender_type` enum('Spot','Annual','Quarterly','Monthly','Project-based') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Annual',
  `load_volume_commitment` int DEFAULT NULL COMMENT 'Volume guarantee or minimums in trips/tonnes',
  `carrier_performance_clause` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Linked to performance KPIs',
  `penalty_clause` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Conditions for delay/failure',
  `penalty_amount` decimal(15,2) DEFAULT NULL COMMENT 'Penalty amount if applicable',
  `billing_method` enum('POD-based','Digital','Milestone-based','Advance') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'POD-based',
  `tariff_slab_attachment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Path to tariff slab file if applicable',
  `attachment_link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Path or link to scanned PDF/MSA',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Any special terms or conditions',
  `special_instructions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Special handling or delivery instructions',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who created the contract',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User who last updated the contract',
  PRIMARY KEY (`id`),
  UNIQUE KEY `contract_id` (`contract_id`),
  KEY `idx_contract_id` (`contract_id`),
  KEY `idx_carrier_name` (`carrier_name`),
  KEY `idx_origin_location` (`origin_location`),
  KEY `idx_destination_location` (`destination_location`),
  KEY `idx_contract_status` (`contract_status`),
  KEY `idx_effective_dates` (`effective_from`,`effective_to`),
  KEY `idx_lane` (`origin_location`,`destination_location`),
  KEY `idx_carrier_code` (`carrier_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Transportation contracts with lanes, rates, and service levels';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transport_contracts`
--

LOCK TABLES `transport_contracts` WRITE;
/*!40000 ALTER TABLE `transport_contracts` DISABLE KEYS */;
INSERT INTO `transport_contracts` VALUES (1,'CON-2024-001','Active','ABC Transport Ltd','ABC001','Mumbai, Maharashtra',NULL,NULL,NULL,'Delhi, Delhi',NULL,NULL,NULL,NULL,'FTL','32ft Trailer','Standard',NULL,NULL,'Per Trip',25000.00,'INR',0.00,'None',NULL,NULL,NULL,0.00,0.00,0.00,'2024-01-01','2024-12-31','30 days','Annual',NULL,NULL,NULL,NULL,'POD-based',NULL,NULL,NULL,NULL,'2025-08-09 09:15:40','2025-08-09 09:15:40',NULL,NULL),(2,'CON-2024-002','Active','XYZ Logistics','XYZ002','Bangalore, Karnataka',NULL,NULL,NULL,'Chennai, Tamil Nadu',NULL,NULL,NULL,NULL,'FTL','20ft Container','Express',NULL,NULL,'Per KM',15.50,'INR',0.00,'None',NULL,NULL,NULL,0.00,0.00,0.00,'2024-02-01','2025-01-31','15 days','Annual',NULL,NULL,NULL,NULL,'POD-based',NULL,NULL,NULL,NULL,'2025-08-09 09:15:40','2025-08-09 09:15:40',NULL,NULL),(3,'CON-2024-003','Active','Fast Freight Co','FFC003','Pune, Maharashtra',NULL,NULL,NULL,'Hyderabad, Telangana',NULL,NULL,NULL,NULL,'FTL','Reefer Trailer','Guaranteed',NULL,NULL,'Per Trip',18000.00,'INR',0.00,'None',NULL,NULL,NULL,0.00,0.00,0.00,'2024-03-01','2024-08-31','45 days','Annual',NULL,NULL,NULL,NULL,'POD-based',NULL,NULL,NULL,NULL,'2025-08-09 09:15:40','2025-08-09 09:15:40',NULL,NULL);
/*!40000 ALTER TABLE `transport_contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role` enum('admin','user','carrier') DEFAULT 'user',
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin@routecraft.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8Q8jK8i','Admin','User','RouteCraft Admin',NULL,'admin','active','2025-08-09 07:05:12','2025-08-09 07:05:12'),(2,'user@routecraft.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8Q8jK8i','Test','User','Test Company',NULL,'user','active','2025-08-09 07:05:12','2025-08-09 07:05:12'),(3,'carrier@routecraft.com','$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8Q8jK8i','Test','Carrier','Test Carrier',NULL,'carrier','active','2025-08-09 07:05:12','2025-08-09 07:05:12');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `accessorial_summary_by_category`
--

/*!50001 DROP VIEW IF EXISTS `accessorial_summary_by_category`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `accessorial_summary_by_category` AS select `accessorial_definitions_master`.`applies_to` AS `applies_to`,count(0) AS `total_accessorials`,count((case when (`accessorial_definitions_master`.`taxable` = 'Yes') then 1 end)) AS `taxable_count`,count((case when (`accessorial_definitions_master`.`included_in_base` = 'Yes') then 1 end)) AS `included_in_base_count`,count((case when (`accessorial_definitions_master`.`carrier_editable_in_bid` = 'Yes') then 1 end)) AS `carrier_editable_count`,avg(`accessorial_definitions_master`.`rate_value`) AS `avg_rate_value` from `accessorial_definitions_master` where (`accessorial_definitions_master`.`is_active` = 'Yes') group by `accessorial_definitions_master`.`applies_to` order by `accessorial_definitions_master`.`applies_to` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_accessorials`
--

/*!50001 DROP VIEW IF EXISTS `active_accessorials`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_accessorials` AS select `accessorial_definitions_master`.`accessorial_id` AS `accessorial_id`,`accessorial_definitions_master`.`accessorial_name` AS `accessorial_name`,`accessorial_definitions_master`.`applies_to` AS `applies_to`,`accessorial_definitions_master`.`rate_type` AS `rate_type`,`accessorial_definitions_master`.`rate_value` AS `rate_value`,`accessorial_definitions_master`.`unit` AS `unit`,`accessorial_definitions_master`.`taxable` AS `taxable`,`accessorial_definitions_master`.`included_in_base` AS `included_in_base`,`accessorial_definitions_master`.`carrier_editable_in_bid` AS `carrier_editable_in_bid` from `accessorial_definitions_master` where ((`accessorial_definitions_master`.`is_active` = 'Yes') and ((`accessorial_definitions_master`.`effective_to` is null) or (`accessorial_definitions_master`.`effective_to` >= curdate()))) order by `accessorial_definitions_master`.`applies_to`,`accessorial_definitions_master`.`accessorial_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_bids`
--

/*!50001 DROP VIEW IF EXISTS `active_bids`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_bids` AS select `bm`.`id` AS `id`,`bm`.`bid_reference` AS `bid_reference`,`bm`.`bid_title` AS `bid_title`,`bm`.`description` AS `description`,`bm`.`bid_type` AS `bid_type`,`bm`.`priority` AS `priority`,`bm`.`bid_start_date` AS `bid_start_date`,`bm`.`bid_end_date` AS `bid_end_date`,`bm`.`submission_deadline` AS `submission_deadline`,`bm`.`award_date` AS `award_date`,`bm`.`contract_start_date` AS `contract_start_date`,`bm`.`contract_end_date` AS `contract_end_date`,`bm`.`budget_amount` AS `budget_amount`,`bm`.`currency` AS `currency`,`bm`.`estimated_cost` AS `estimated_cost`,`bm`.`min_bid_amount` AS `min_bid_amount`,`bm`.`max_bid_amount` AS `max_bid_amount`,`bm`.`status` AS `status`,`bm`.`bid_category` AS `bid_category`,`bm`.`equipment_requirements` AS `equipment_requirements`,`bm`.`service_level_requirements` AS `service_level_requirements`,`bm`.`insurance_requirements` AS `insurance_requirements`,`bm`.`compliance_requirements` AS `compliance_requirements`,`bm`.`origin_regions` AS `origin_regions`,`bm`.`destination_regions` AS `destination_regions`,`bm`.`applicable_lanes` AS `applicable_lanes`,`bm`.`target_carrier_types` AS `target_carrier_types`,`bm`.`max_carriers_per_lane` AS `max_carriers_per_lane`,`bm`.`min_carrier_rating` AS `min_carrier_rating`,`bm`.`evaluation_criteria` AS `evaluation_criteria`,`bm`.`scoring_matrix` AS `scoring_matrix`,`bm`.`is_template` AS `is_template`,`bm`.`allow_partial_awards` AS `allow_partial_awards`,`bm`.`auto_extend` AS `auto_extend`,`bm`.`extension_days` AS `extension_days`,`bm`.`created_by` AS `created_by`,`bm`.`created_at` AS `created_at`,`bm`.`updated_at` AS `updated_at`,`bm`.`published_by` AS `published_by`,`bm`.`published_at` AS `published_at`,`bm`.`closed_by` AS `closed_by`,`bm`.`closed_at` AS `closed_at`,`bm`.`awarded_by` AS `awarded_by`,`bm`.`awarded_at` AS `awarded_at`,`bm`.`external_reference` AS `external_reference`,`bm`.`notes` AS `notes`,`bm`.`attachments` AS `attachments`,count(distinct `bl`.`lane_id`) AS `total_lanes`,count(distinct `bc`.`carrier_id`) AS `total_invited_carriers`,count(distinct `br`.`carrier_id`) AS `total_responses` from (((`bids_master` `bm` left join `bid_lanes` `bl` on((`bm`.`id` = `bl`.`bid_id`))) left join `bid_carriers` `bc` on((`bm`.`id` = `bc`.`bid_id`))) left join `bid_responses` `br` on(((`bm`.`id` = `br`.`bid_id`) and (`br`.`status` in ('submitted','under_review','shortlisted'))))) where (`bm`.`status` in ('published','open','evaluating')) group by `bm`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_carriers`
--

/*!50001 DROP VIEW IF EXISTS `active_carriers`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_carriers` AS select `carrier_master`.`carrier_id` AS `carrier_id`,`carrier_master`.`carrier_name` AS `carrier_name`,`carrier_master`.`carrier_code` AS `carrier_code`,`carrier_master`.`region_coverage` AS `region_coverage`,`carrier_master`.`fleet_size` AS `fleet_size`,`carrier_master`.`vehicle_types` AS `vehicle_types`,`carrier_master`.`avg_on_time_performance` AS `avg_on_time_performance`,`carrier_master`.`avg_acceptance_rate` AS `avg_acceptance_rate`,`carrier_master`.`billing_accuracy` AS `billing_accuracy`,`carrier_master`.`carrier_rating` AS `carrier_rating`,`carrier_master`.`preferred_carrier` AS `preferred_carrier`,`carrier_master`.`contracted` AS `contracted`,`carrier_master`.`compliance_valid_until` AS `compliance_valid_until`,`carrier_master`.`last_load_date` AS `last_load_date` from `carrier_master` where ((`carrier_master`.`blacklisted` = 'No') and ((`carrier_master`.`compliance_valid_until` is null) or (`carrier_master`.`compliance_valid_until` >= curdate()))) order by `carrier_master`.`carrier_rating`,`carrier_master`.`avg_on_time_performance` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_carriers_recent_performance`
--

/*!50001 DROP VIEW IF EXISTS `active_carriers_recent_performance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_carriers_recent_performance` AS select `chm`.`carrier_id` AS `carrier_id`,`chm`.`carrier_name` AS `carrier_name`,`chm`.`period_label` AS `period_label`,`chm`.`total_loads_assigned` AS `total_loads_assigned`,`chm`.`loads_accepted` AS `loads_accepted`,`chm`.`acceptance_rate` AS `acceptance_rate`,`chm`.`overall_on_time_performance` AS `overall_on_time_performance`,`chm`.`billing_accuracy_rate` AS `billing_accuracy_rate`,`chm`.`performance_rating` AS `performance_rating`,`chm`.`scorecard_grade` AS `scorecard_grade`,`chm`.`risk_score` AS `risk_score`,`chm`.`compliance_status` AS `compliance_status` from `carrier_historical_metrics` `chm` where (`chm`.`period_start_date` >= (curdate() - interval 3 month)) order by `chm`.`carrier_id`,`chm`.`period_start_date` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_commodities_by_category`
--

/*!50001 DROP VIEW IF EXISTS `active_commodities_by_category`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_commodities_by_category` AS select `commodities_master`.`commodity_category` AS `commodity_category`,count(0) AS `count`,avg(`commodities_master`.`avg_weight_per_load`) AS `avg_weight`,count((case when (`commodities_master`.`temperature_controlled` = true) then 1 end)) AS `temp_controlled_count` from `commodities_master` where (`commodities_master`.`commodity_status` = 'Active') group by `commodities_master`.`commodity_category` order by `count` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_contracts`
--

/*!50001 DROP VIEW IF EXISTS `active_contracts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_contracts` AS select `transport_contracts`.`contract_id` AS `contract_id`,`transport_contracts`.`carrier_name` AS `carrier_name`,`transport_contracts`.`carrier_code` AS `carrier_code`,`transport_contracts`.`origin_location` AS `origin_location`,`transport_contracts`.`destination_location` AS `destination_location`,`transport_contracts`.`mode` AS `mode`,`transport_contracts`.`equipment_type` AS `equipment_type`,`transport_contracts`.`service_level` AS `service_level`,`transport_contracts`.`rate_type` AS `rate_type`,`transport_contracts`.`base_rate` AS `base_rate`,`transport_contracts`.`rate_currency` AS `rate_currency`,`transport_contracts`.`effective_from` AS `effective_from`,`transport_contracts`.`effective_to` AS `effective_to`,`transport_contracts`.`contract_status` AS `contract_status` from `transport_contracts` where ((`transport_contracts`.`contract_status` = 'Active') and (curdate() between `transport_contracts`.`effective_from` and `transport_contracts`.`effective_to`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_fuel_surcharges`
--

/*!50001 DROP VIEW IF EXISTS `active_fuel_surcharges`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_fuel_surcharges` AS select `fuel_surcharge_master`.`effective_date` AS `effective_date`,`fuel_surcharge_master`.`fuel_price_min` AS `fuel_price_min`,`fuel_surcharge_master`.`fuel_price_max` AS `fuel_price_max`,`fuel_surcharge_master`.`fuel_surcharge_percentage` AS `fuel_surcharge_percentage`,`fuel_surcharge_master`.`base_fuel_price` AS `base_fuel_price`,`fuel_surcharge_master`.`change_per_rupee` AS `change_per_rupee`,`fuel_surcharge_master`.`currency` AS `currency`,`fuel_surcharge_master`.`applicable_region` AS `applicable_region`,`fuel_surcharge_master`.`surcharge_type` AS `surcharge_type`,`fuel_surcharge_master`.`notes` AS `notes` from `fuel_surcharge_master` where (`fuel_surcharge_master`.`is_active` = 'Yes') order by `fuel_surcharge_master`.`effective_date` desc,`fuel_surcharge_master`.`fuel_price_min` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_lanes_by_type`
--

/*!50001 DROP VIEW IF EXISTS `active_lanes_by_type`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_lanes_by_type` AS select `lanes_master`.`lane_type` AS `lane_type`,count(0) AS `total_lanes`,avg(`lanes_master`.`distance_km`) AS `avg_distance_km`,avg(`lanes_master`.`transit_time_days`) AS `avg_transit_days`,avg(`lanes_master`.`avg_load_frequency_month`) AS `avg_monthly_frequency` from `lanes_master` where (`lanes_master`.`is_active` = true) group by `lanes_master`.`lane_type` order by `total_lanes` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_locations_by_type`
--

/*!50001 DROP VIEW IF EXISTS `active_locations_by_type`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_locations_by_type` AS select `locations_master`.`location_type` AS `location_type`,count(0) AS `count`,avg(`locations_master`.`loading_unloading_sla`) AS `avg_sla`,count((case when (`locations_master`.`parking_available` = 'Yes') then 1 end)) AS `parking_available_count` from `locations_master` where (`locations_master`.`location_status` = 'Active') group by `locations_master`.`location_type` order by `count` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_modes_summary`
--

/*!50001 DROP VIEW IF EXISTS `active_modes_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_modes_summary` AS select `modes_master`.`mode_type` AS `mode_type`,count(0) AS `total_modes`,count((case when (`modes_master`.`supports_time_definite` = 'Yes') then 1 end)) AS `time_definite_modes`,count((case when (`modes_master`.`supports_multileg_planning` = 'Yes') then 1 end)) AS `multileg_modes`,avg(`modes_master`.`transit_time_days`) AS `avg_transit_time`,count((case when (`modes_master`.`cost_efficiency_level` = 'High') then 1 end)) AS `high_efficiency_modes` from `modes_master` where (`modes_master`.`active` = 'Yes') group by `modes_master`.`mode_type` order by `modes_master`.`mode_type` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_routing_guides`
--

/*!50001 DROP VIEW IF EXISTS `active_routing_guides`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_routing_guides` AS select `routing_guides`.`routing_guide_id` AS `routing_guide_id`,`routing_guides`.`origin_location` AS `origin_location`,`routing_guides`.`destination_location` AS `destination_location`,`routing_guides`.`lane_id` AS `lane_id`,`routing_guides`.`equipment_type` AS `equipment_type`,`routing_guides`.`service_level` AS `service_level`,`routing_guides`.`mode` AS `mode`,`routing_guides`.`primary_carrier_name` AS `primary_carrier_name`,`routing_guides`.`primary_carrier_rate` AS `primary_carrier_rate`,`routing_guides`.`primary_carrier_rate_type` AS `primary_carrier_rate_type`,`routing_guides`.`backup_carrier_1_name` AS `backup_carrier_1_name`,`routing_guides`.`backup_carrier_2_name` AS `backup_carrier_2_name`,`routing_guides`.`tender_sequence` AS `tender_sequence`,`routing_guides`.`tender_lead_time_hours` AS `tender_lead_time_hours`,`routing_guides`.`transit_sla_days` AS `transit_sla_days`,`routing_guides`.`routing_guide_status` AS `routing_guide_status`,`routing_guides`.`valid_from` AS `valid_from`,`routing_guides`.`valid_to` AS `valid_to` from `routing_guides` where ((`routing_guides`.`routing_guide_status` = 'Active') and (curdate() between `routing_guides`.`valid_from` and `routing_guides`.`valid_to`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_seasons_overview`
--

/*!50001 DROP VIEW IF EXISTS `active_seasons_overview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_seasons_overview` AS select `seasons_master`.`season_id` AS `season_id`,`seasons_master`.`season_name` AS `season_name`,`seasons_master`.`start_date` AS `start_date`,`seasons_master`.`end_date` AS `end_date`,`seasons_master`.`impact_type` AS `impact_type`,`seasons_master`.`capacity_risk_level` AS `capacity_risk_level`,`seasons_master`.`rate_multiplier_percent` AS `rate_multiplier_percent`,`seasons_master`.`sla_adjustment_days` AS `sla_adjustment_days`,`seasons_master`.`affected_regions` AS `affected_regions` from `seasons_master` where (`seasons_master`.`is_active` = true) order by `seasons_master`.`start_date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `active_service_levels`
--

/*!50001 DROP VIEW IF EXISTS `active_service_levels`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_service_levels` AS select `service_levels_master`.`service_level_id` AS `service_level_id`,`service_levels_master`.`service_level_name` AS `service_level_name`,`service_levels_master`.`service_category` AS `service_category`,`service_levels_master`.`max_transit_time_days` AS `max_transit_time_days`,`service_levels_master`.`sla_type` AS `sla_type`,`service_levels_master`.`priority_tag` AS `priority_tag`,`service_levels_master`.`mode` AS `mode`,`service_levels_master`.`enabled_for_bidding` AS `enabled_for_bidding` from `service_levels_master` where (`service_levels_master`.`enabled_for_bidding` = 'Yes') order by `service_levels_master`.`priority_tag` desc,`service_levels_master`.`max_transit_time_days` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `bid_statistics`
--

/*!50001 DROP VIEW IF EXISTS `bid_statistics`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `bid_statistics` AS select `bids_master`.`bid_type` AS `bid_type`,`bids_master`.`status` AS `status`,count(0) AS `bid_count`,avg(`bids_master`.`budget_amount`) AS `avg_budget`,avg(`bids_master`.`estimated_cost`) AS `avg_estimated_cost`,min(`bids_master`.`budget_amount`) AS `min_budget`,max(`bids_master`.`budget_amount`) AS `max_budget` from `bids_master` group by `bids_master`.`bid_type`,`bids_master`.`status` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `carrier_editable_accessorials`
--

/*!50001 DROP VIEW IF EXISTS `carrier_editable_accessorials`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `carrier_editable_accessorials` AS select `accessorial_definitions_master`.`accessorial_id` AS `accessorial_id`,`accessorial_definitions_master`.`accessorial_name` AS `accessorial_name`,`accessorial_definitions_master`.`applies_to` AS `applies_to`,`accessorial_definitions_master`.`rate_type` AS `rate_type`,`accessorial_definitions_master`.`rate_value` AS `rate_value`,`accessorial_definitions_master`.`unit` AS `unit`,`accessorial_definitions_master`.`remarks` AS `remarks` from `accessorial_definitions_master` where ((`accessorial_definitions_master`.`carrier_editable_in_bid` = 'Yes') and (`accessorial_definitions_master`.`is_active` = 'Yes')) order by `accessorial_definitions_master`.`applies_to`,`accessorial_definitions_master`.`accessorial_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `carrier_performance_summary`
--

/*!50001 DROP VIEW IF EXISTS `carrier_performance_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `carrier_performance_summary` AS select `chm`.`carrier_id` AS `carrier_id`,`chm`.`carrier_name` AS `carrier_name`,count(distinct `chm`.`period_label`) AS `periods_tracked`,avg(`chm`.`acceptance_rate`) AS `avg_acceptance_rate`,avg(`chm`.`overall_on_time_performance`) AS `avg_otp`,avg(`chm`.`billing_accuracy_rate`) AS `avg_billing_accuracy`,avg(`chm`.`performance_rating`) AS `avg_performance_rating`,avg(`chm`.`risk_score`) AS `avg_risk_score`,sum(`chm`.`total_loads_assigned`) AS `total_loads_assigned`,sum(`chm`.`loads_accepted`) AS `total_loads_accepted`,sum(`chm`.`loads_completed`) AS `total_loads_completed`,max(`chm`.`scorecard_grade`) AS `best_grade`,min(`chm`.`scorecard_grade`) AS `worst_grade` from `carrier_historical_metrics` `chm` where (`chm`.`period_start_date` >= (curdate() - interval 6 month)) group by `chm`.`carrier_id`,`chm`.`carrier_name` order by `avg_performance_rating` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `carrier_risk_assessment`
--

/*!50001 DROP VIEW IF EXISTS `carrier_risk_assessment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `carrier_risk_assessment` AS select `chm`.`carrier_id` AS `carrier_id`,`chm`.`carrier_name` AS `carrier_name`,`chm`.`period_label` AS `period_label`,`chm`.`risk_score` AS `risk_score`,`chm`.`compliance_status` AS `compliance_status`,`chm`.`is_blacklisted` AS `is_blacklisted`,`chm`.`claim_percentage` AS `claim_percentage`,`chm`.`customer_complaints_count` AS `customer_complaints_count`,`chm`.`billing_disputes_count` AS `billing_disputes_count`,(case when (`chm`.`risk_score` <= 20) then 'Low Risk' when (`chm`.`risk_score` <= 40) then 'Medium-Low Risk' when (`chm`.`risk_score` <= 60) then 'Medium Risk' when (`chm`.`risk_score` <= 80) then 'High Risk' else 'Very High Risk' end) AS `risk_category` from `carrier_historical_metrics` `chm` where (`chm`.`period_start_date` >= (curdate() - interval 6 month)) order by `chm`.`risk_score` desc,`chm`.`period_start_date` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `compliance_monitoring`
--

/*!50001 DROP VIEW IF EXISTS `compliance_monitoring`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `compliance_monitoring` AS select `carrier_master`.`carrier_id` AS `carrier_id`,`carrier_master`.`carrier_name` AS `carrier_name`,`carrier_master`.`carrier_code` AS `carrier_code`,`carrier_master`.`compliance_valid_until` AS `compliance_valid_until`,(to_days(`carrier_master`.`compliance_valid_until`) - to_days(curdate())) AS `days_until_expiry`,(case when ((to_days(`carrier_master`.`compliance_valid_until`) - to_days(curdate())) <= 30) then 'Expiring Soon' when ((to_days(`carrier_master`.`compliance_valid_until`) - to_days(curdate())) <= 90) then 'Warning' else 'Valid' end) AS `compliance_status`,`carrier_master`.`last_load_date` AS `last_load_date`,(to_days(curdate()) - to_days(`carrier_master`.`last_load_date`)) AS `days_since_last_load` from `carrier_master` where (`carrier_master`.`compliance_valid_until` is not null) order by `carrier_master`.`compliance_valid_until` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `contract_summary`
--

/*!50001 DROP VIEW IF EXISTS `contract_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `contract_summary` AS select `transport_contracts`.`contract_status` AS `contract_status`,count(0) AS `contract_count`,avg(`transport_contracts`.`base_rate`) AS `avg_base_rate`,min(`transport_contracts`.`effective_from`) AS `earliest_start`,max(`transport_contracts`.`effective_to`) AS `latest_end` from `transport_contracts` group by `transport_contracts`.`contract_status` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `cost_effective_equipment`
--

/*!50001 DROP VIEW IF EXISTS `cost_effective_equipment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cost_effective_equipment` AS select `equipment_types_master`.`equipment_id` AS `equipment_id`,`equipment_types_master`.`equipment_name` AS `equipment_name`,`equipment_types_master`.`vehicle_body_type` AS `vehicle_body_type`,`equipment_types_master`.`vehicle_length_ft` AS `vehicle_length_ft`,`equipment_types_master`.`payload_capacity_tons` AS `payload_capacity_tons`,`equipment_types_master`.`volume_capacity_cft` AS `volume_capacity_cft`,`equipment_types_master`.`standard_rate_per_km` AS `standard_rate_per_km`,(`equipment_types_master`.`payload_capacity_tons` / nullif(`equipment_types_master`.`standard_rate_per_km`,0)) AS `tons_per_rupee`,`equipment_types_master`.`active` AS `active` from `equipment_types_master` where ((`equipment_types_master`.`standard_rate_per_km` is not null) and (`equipment_types_master`.`active` = true)) order by (`equipment_types_master`.`payload_capacity_tons` / nullif(`equipment_types_master`.`standard_rate_per_km`,0)) desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `cost_effective_modes`
--

/*!50001 DROP VIEW IF EXISTS `cost_effective_modes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cost_effective_modes` AS select `modes_master`.`mode_id` AS `mode_id`,`modes_master`.`mode_name` AS `mode_name`,`modes_master`.`mode_type` AS `mode_type`,`modes_master`.`transit_time_days` AS `transit_time_days`,`modes_master`.`cost_efficiency_level` AS `cost_efficiency_level`,`modes_master`.`base_cost_multiplier` AS `base_cost_multiplier`,`modes_master`.`suitable_commodities` AS `suitable_commodities` from `modes_master` where ((`modes_master`.`active` = 'Yes') and (`modes_master`.`cost_efficiency_level` in ('High','Medium'))) order by `modes_master`.`base_cost_multiplier`,`modes_master`.`transit_time_days` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `current_fuel_surcharge_calculator`
--

/*!50001 DROP VIEW IF EXISTS `current_fuel_surcharge_calculator`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `current_fuel_surcharge_calculator` AS select `fs`.`effective_date` AS `effective_date`,`fs`.`fuel_price_min` AS `fuel_price_min`,`fs`.`fuel_price_max` AS `fuel_price_max`,`fs`.`fuel_surcharge_percentage` AS `fuel_surcharge_percentage`,`fs`.`base_fuel_price` AS `base_fuel_price`,`fs`.`change_per_rupee` AS `change_per_rupee`,`fs`.`currency` AS `currency`,`fs`.`applicable_region` AS `applicable_region`,`fs`.`surcharge_type` AS `surcharge_type`,`fs`.`notes` AS `notes`,(case when (`fs`.`change_per_rupee` is not null) then concat('Variable: ',`fs`.`change_per_rupee`,'% per ₹1 above ₹',`fs`.`base_fuel_price`) else concat('Fixed: ',`fs`.`fuel_surcharge_percentage`,'% for ₹',`fs`.`fuel_price_min`,' - ₹',`fs`.`fuel_price_max`) end) AS `calculation_method` from `fuel_surcharge_master` `fs` where (`fs`.`is_active` = 'Yes') order by `fs`.`effective_date` desc,`fs`.`fuel_price_min` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `eligible_carriers_for_bidding`
--

/*!50001 DROP VIEW IF EXISTS `eligible_carriers_for_bidding`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `eligible_carriers_for_bidding` AS select `targeted_carriers`.`carrier_id_3p` AS `carrier_id_3p`,`targeted_carriers`.`carrier_name` AS `carrier_name`,`targeted_carriers`.`region_of_operation` AS `region_of_operation`,`targeted_carriers`.`fleet_size` AS `fleet_size`,`targeted_carriers`.`equipment_types` AS `equipment_types`,`targeted_carriers`.`performance_score_external` AS `performance_score_external`,`targeted_carriers`.`compliance_validated` AS `compliance_validated`,`targeted_carriers`.`rating_threshold_met` AS `rating_threshold_met`,`targeted_carriers`.`last_active` AS `last_active`,`targeted_carriers`.`invited_to_bid` AS `invited_to_bid` from `targeted_carriers` where ((`targeted_carriers`.`compliance_validated` = true) and (`targeted_carriers`.`rating_threshold_met` = true) and (`targeted_carriers`.`last_active` >= (curdate() - interval 30 day))) order by `targeted_carriers`.`performance_score_external` desc,`targeted_carriers`.`fleet_size` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `equipment_availability`
--

/*!50001 DROP VIEW IF EXISTS `equipment_availability`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `equipment_availability` AS select `locations_master`.`location_id` AS `location_id`,`locations_master`.`location_name` AS `location_name`,`locations_master`.`location_type` AS `location_type`,`locations_master`.`city` AS `city`,`locations_master`.`state` AS `state`,`locations_master`.`equipment_access` AS `equipment_access`,`locations_master`.`dock_type` AS `dock_type`,`locations_master`.`parking_available` AS `parking_available` from `locations_master` where (`locations_master`.`location_status` = 'Active') order by `locations_master`.`location_type`,`locations_master`.`city` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `equipment_requirements`
--

/*!50001 DROP VIEW IF EXISTS `equipment_requirements`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `equipment_requirements` AS select `lanes_master`.`preferred_equipment_type` AS `preferred_equipment_type`,count(0) AS `lane_count`,avg(`lanes_master`.`distance_km`) AS `avg_distance`,avg(`lanes_master`.`current_rate_trip`) AS `avg_rate` from `lanes_master` where (`lanes_master`.`is_active` = true) group by `lanes_master`.`preferred_equipment_type` order by `lane_count` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `equipment_specific_accessorials`
--

/*!50001 DROP VIEW IF EXISTS `equipment_specific_accessorials`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `equipment_specific_accessorials` AS select `accessorial_definitions_master`.`accessorial_id` AS `accessorial_id`,`accessorial_definitions_master`.`accessorial_name` AS `accessorial_name`,`accessorial_definitions_master`.`applicable_equipment_types` AS `applicable_equipment_types`,`accessorial_definitions_master`.`applies_to` AS `applies_to`,`accessorial_definitions_master`.`rate_type` AS `rate_type`,`accessorial_definitions_master`.`rate_value` AS `rate_value`,`accessorial_definitions_master`.`unit` AS `unit` from `accessorial_definitions_master` where ((`accessorial_definitions_master`.`applicable_equipment_types` <> 'All equipment types') and (`accessorial_definitions_master`.`is_active` = 'Yes')) order by `accessorial_definitions_master`.`applicable_equipment_types`,`accessorial_definitions_master`.`accessorial_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `equipment_specific_seasons`
--

/*!50001 DROP VIEW IF EXISTS `equipment_specific_seasons`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `equipment_specific_seasons` AS select `seasons_master`.`season_id` AS `season_id`,`seasons_master`.`season_name` AS `season_name`,`seasons_master`.`start_date` AS `start_date`,`seasons_master`.`end_date` AS `end_date`,`seasons_master`.`applicable_equipment_types` AS `applicable_equipment_types`,`seasons_master`.`impact_type` AS `impact_type`,`seasons_master`.`capacity_risk_level` AS `capacity_risk_level`,`seasons_master`.`rate_multiplier_percent` AS `rate_multiplier_percent` from `seasons_master` where ((`seasons_master`.`is_active` = true) and (`seasons_master`.`applicable_equipment_types` is not null) and (`seasons_master`.`applicable_equipment_types` <> '')) order by `seasons_master`.`start_date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `equipment_summary`
--

/*!50001 DROP VIEW IF EXISTS `equipment_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `equipment_summary` AS select `equipment_types_master`.`equipment_id` AS `equipment_id`,`equipment_types_master`.`equipment_name` AS `equipment_name`,`equipment_types_master`.`vehicle_body_type` AS `vehicle_body_type`,`equipment_types_master`.`vehicle_length_ft` AS `vehicle_length_ft`,`equipment_types_master`.`axle_type` AS `axle_type`,`equipment_types_master`.`gross_vehicle_weight_tons` AS `gross_vehicle_weight_tons`,`equipment_types_master`.`payload_capacity_tons` AS `payload_capacity_tons`,`equipment_types_master`.`volume_capacity_cft` AS `volume_capacity_cft`,`equipment_types_master`.`temperature_controlled` AS `temperature_controlled`,`equipment_types_master`.`hazmat_certified` AS `hazmat_certified`,`equipment_types_master`.`fuel_type` AS `fuel_type`,`equipment_types_master`.`active` AS `active`,`equipment_types_master`.`priority_level` AS `priority_level`,`equipment_types_master`.`standard_rate_per_km` AS `standard_rate_per_km` from `equipment_types_master` where (`equipment_types_master`.`active` = true) order by `equipment_types_master`.`priority_level` desc,`equipment_types_master`.`vehicle_length_ft` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `equipment_type_analysis`
--

/*!50001 DROP VIEW IF EXISTS `equipment_type_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `equipment_type_analysis` AS select json_unquote(json_extract(`targeted_carriers`.`equipment_types`,'$[0]')) AS `primary_equipment`,count(0) AS `carrier_count`,avg(`targeted_carriers`.`performance_score_external`) AS `avg_performance`,count((case when (`targeted_carriers`.`compliance_validated` = true) then 1 end)) AS `compliant_count`,sum(`targeted_carriers`.`fleet_size`) AS `total_capacity` from `targeted_carriers` where (`targeted_carriers`.`equipment_types` is not null) group by json_unquote(json_extract(`targeted_carriers`.`equipment_types`,'$[0]')) order by `carrier_count` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fuel_price_trend_analysis`
--

/*!50001 DROP VIEW IF EXISTS `fuel_price_trend_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `fuel_price_trend_analysis` AS select `fuel_price_tracking`.`tracking_date` AS `tracking_date`,`fuel_price_tracking`.`fuel_price` AS `fuel_price`,`fuel_price_tracking`.`source` AS `source`,`fuel_price_tracking`.`region` AS `region`,`fuel_price_tracking`.`currency` AS `currency`,lag(`fuel_price_tracking`.`fuel_price`) OVER (ORDER BY `fuel_price_tracking`.`tracking_date` )  AS `previous_price`,(`fuel_price_tracking`.`fuel_price` - lag(`fuel_price_tracking`.`fuel_price`) OVER (ORDER BY `fuel_price_tracking`.`tracking_date` ) ) AS `price_change`,round((((`fuel_price_tracking`.`fuel_price` - lag(`fuel_price_tracking`.`fuel_price`) OVER (ORDER BY `fuel_price_tracking`.`tracking_date` ) ) / lag(`fuel_price_tracking`.`fuel_price`) OVER (ORDER BY `fuel_price_tracking`.`tracking_date` ) ) * 100),2) AS `price_change_percentage` from `fuel_price_tracking` where (`fuel_price_tracking`.`is_official` = true) order by `fuel_price_tracking`.`tracking_date` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `high_capacity_equipment`
--

/*!50001 DROP VIEW IF EXISTS `high_capacity_equipment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `high_capacity_equipment` AS select `equipment_types_master`.`equipment_id` AS `equipment_id`,`equipment_types_master`.`equipment_name` AS `equipment_name`,`equipment_types_master`.`vehicle_body_type` AS `vehicle_body_type`,`equipment_types_master`.`vehicle_length_ft` AS `vehicle_length_ft`,`equipment_types_master`.`payload_capacity_tons` AS `payload_capacity_tons`,`equipment_types_master`.`volume_capacity_cft` AS `volume_capacity_cft`,`equipment_types_master`.`axle_type` AS `axle_type`,`equipment_types_master`.`standard_rate_per_km` AS `standard_rate_per_km`,`equipment_types_master`.`active` AS `active` from `equipment_types_master` where ((`equipment_types_master`.`payload_capacity_tons` >= 15) and (`equipment_types_master`.`active` = true)) order by `equipment_types_master`.`payload_capacity_tons` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `high_impact_seasons`
--

/*!50001 DROP VIEW IF EXISTS `high_impact_seasons`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `high_impact_seasons` AS select `seasons_master`.`season_id` AS `season_id`,`seasons_master`.`season_name` AS `season_name`,`seasons_master`.`start_date` AS `start_date`,`seasons_master`.`end_date` AS `end_date`,`seasons_master`.`impact_type` AS `impact_type`,`seasons_master`.`rate_multiplier_percent` AS `rate_multiplier_percent`,`seasons_master`.`capacity_risk_level` AS `capacity_risk_level`,`seasons_master`.`carrier_participation_impact` AS `carrier_participation_impact`,`seasons_master`.`affected_regions` AS `affected_regions` from `seasons_master` where ((`seasons_master`.`is_active` = true) and ((`seasons_master`.`capacity_risk_level` = 'High') or (`seasons_master`.`rate_multiplier_percent` > 5.00))) order by `seasons_master`.`start_date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `high_value_accessorials`
--

/*!50001 DROP VIEW IF EXISTS `high_value_accessorials`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `high_value_accessorials` AS select `accessorial_definitions_master`.`accessorial_id` AS `accessorial_id`,`accessorial_definitions_master`.`accessorial_name` AS `accessorial_name`,`accessorial_definitions_master`.`applies_to` AS `applies_to`,`accessorial_definitions_master`.`rate_type` AS `rate_type`,`accessorial_definitions_master`.`rate_value` AS `rate_value`,`accessorial_definitions_master`.`unit` AS `unit`,`accessorial_definitions_master`.`taxable` AS `taxable`,`accessorial_definitions_master`.`remarks` AS `remarks` from `accessorial_definitions_master` where ((`accessorial_definitions_master`.`rate_value` > 1000) and (`accessorial_definitions_master`.`is_active` = 'Yes')) order by `accessorial_definitions_master`.`rate_value` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `high_value_commodities`
--

/*!50001 DROP VIEW IF EXISTS `high_value_commodities`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `high_value_commodities` AS select `commodities_master`.`commodity_id` AS `commodity_id`,`commodities_master`.`commodity_name` AS `commodity_name`,`commodities_master`.`commodity_category` AS `commodity_category`,`commodities_master`.`value_category` AS `value_category`,`commodities_master`.`min_insurance_amount` AS `min_insurance_amount`,`commodities_master`.`temperature_controlled` AS `temperature_controlled`,`commodities_master`.`hazmat` AS `hazmat` from `commodities_master` where ((`commodities_master`.`value_category` in ('High','Very High')) and (`commodities_master`.`commodity_status` = 'Active')) order by `commodities_master`.`min_insurance_amount` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `high_volume_lanes`
--

/*!50001 DROP VIEW IF EXISTS `high_volume_lanes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `high_volume_lanes` AS select `lanes_master`.`lane_id` AS `lane_id`,`lanes_master`.`origin_city` AS `origin_city`,`lanes_master`.`destination_city` AS `destination_city`,`lanes_master`.`distance_km` AS `distance_km`,`lanes_master`.`avg_load_frequency_month` AS `avg_load_frequency_month`,`lanes_master`.`avg_load_volume_tons` AS `avg_load_volume_tons`,`lanes_master`.`current_rate_trip` AS `current_rate_trip`,`lanes_master`.`preferred_equipment_type` AS `preferred_equipment_type` from `lanes_master` where ((`lanes_master`.`is_active` = true) and (`lanes_master`.`avg_load_frequency_month` >= 20)) order by `lanes_master`.`avg_load_frequency_month` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `lane_coverage_analysis`
--

/*!50001 DROP VIEW IF EXISTS `lane_coverage_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `lane_coverage_analysis` AS select concat(`routing_guides`.`origin_location`,' → ',`routing_guides`.`destination_location`) AS `lane`,`routing_guides`.`equipment_type` AS `equipment_type`,count(0) AS `routing_guide_count`,group_concat(distinct `routing_guides`.`primary_carrier_name` order by `routing_guides`.`primary_carrier_name` ASC separator ', ') AS `carriers`,avg(`routing_guides`.`primary_carrier_rate`) AS `avg_rate`,min(`routing_guides`.`primary_carrier_rate`) AS `min_rate`,max(`routing_guides`.`primary_carrier_rate`) AS `max_rate` from `routing_guides` where (`routing_guides`.`routing_guide_status` = 'Active') group by `routing_guides`.`origin_location`,`routing_guides`.`destination_location`,`routing_guides`.`equipment_type` order by `routing_guide_count` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `lane_performance_analysis`
--

/*!50001 DROP VIEW IF EXISTS `lane_performance_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `lane_performance_analysis` AS select `chm`.`lane_id` AS `lane_id`,`chm`.`origin_location` AS `origin_location`,`chm`.`destination_location` AS `destination_location`,`chm`.`equipment_type` AS `equipment_type`,count(distinct `chm`.`carrier_id`) AS `carriers_used`,avg(`chm`.`acceptance_rate`) AS `avg_acceptance_rate`,avg(`chm`.`overall_on_time_performance`) AS `avg_otp`,avg(`chm`.`billing_accuracy_rate`) AS `avg_billing_accuracy`,avg(`chm`.`performance_rating`) AS `avg_performance_rating`,sum(`chm`.`total_loads_assigned`) AS `total_loads_assigned`,sum(`chm`.`loads_completed`) AS `total_loads_completed` from `carrier_historical_metrics` `chm` where (`chm`.`lane_id` is not null) group by `chm`.`lane_id`,`chm`.`origin_location`,`chm`.`destination_location`,`chm`.`equipment_type` order by `total_loads_assigned` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `latest_fuel_prices`
--

/*!50001 DROP VIEW IF EXISTS `latest_fuel_prices`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `latest_fuel_prices` AS select `fpt1`.`region` AS `region`,`fpt1`.`currency` AS `currency`,`fpt1`.`fuel_price` AS `fuel_price`,`fpt1`.`source` AS `source`,`fpt1`.`tracking_date` AS `tracking_date`,`fpt1`.`is_official` AS `is_official` from `fuel_price_tracking` `fpt1` where (`fpt1`.`tracking_date` = (select max(`fpt2`.`tracking_date`) from `fuel_price_tracking` `fpt2` where ((`fpt2`.`region` = `fpt1`.`region`) and (`fpt2`.`currency` = `fpt1`.`currency`)))) order by `fpt1`.`region`,`fpt1`.`currency` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `locations_by_zone`
--

/*!50001 DROP VIEW IF EXISTS `locations_by_zone`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `locations_by_zone` AS select `locations_master`.`zone` AS `zone`,count(0) AS `total_locations`,count((case when (`locations_master`.`location_type` = 'Warehouse') then 1 end)) AS `warehouses`,count((case when (`locations_master`.`location_type` = 'Factory') then 1 end)) AS `factories` from `locations_master` where (`locations_master`.`location_status` = 'Active') group by `locations_master`.`zone` order by `total_locations` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `mode_capabilities`
--

/*!50001 DROP VIEW IF EXISTS `mode_capabilities`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `mode_capabilities` AS select `modes_master`.`mode_id` AS `mode_id`,`modes_master`.`mode_name` AS `mode_name`,`modes_master`.`mode_type` AS `mode_type`,`modes_master`.`transit_time_days` AS `transit_time_days`,`modes_master`.`cost_efficiency_level` AS `cost_efficiency_level`,`modes_master`.`speed_level` AS `speed_level`,`modes_master`.`supports_time_definite` AS `supports_time_definite`,`modes_master`.`supports_multileg_planning` AS `supports_multileg_planning`,`modes_master`.`real_time_tracking_support` AS `real_time_tracking_support`,`modes_master`.`base_cost_multiplier` AS `base_cost_multiplier` from `modes_master` where (`modes_master`.`active` = 'Yes') order by `modes_master`.`mode_type`,`modes_master`.`transit_time_days` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `performance_tier_analysis`
--

/*!50001 DROP VIEW IF EXISTS `performance_tier_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `performance_tier_analysis` AS select (case when (`targeted_carriers`.`performance_score_external` >= 4.5) then 'Premium (4.5+)' when (`targeted_carriers`.`performance_score_external` >= 4.0) then 'High (4.0-4.4)' when (`targeted_carriers`.`performance_score_external` >= 3.5) then 'Good (3.5-3.9)' when (`targeted_carriers`.`performance_score_external` >= 3.0) then 'Average (3.0-3.4)' else 'Below Average (<3.0)' end) AS `performance_tier`,count(0) AS `carrier_count`,avg(`targeted_carriers`.`fleet_size`) AS `avg_fleet_size`,count((case when (`targeted_carriers`.`compliance_validated` = true) then 1 end)) AS `compliant_count`,count((case when (`targeted_carriers`.`invited_to_bid` = true) then 1 end)) AS `invited_count` from `targeted_carriers` where (`targeted_carriers`.`performance_score_external` is not null) group by `performance_tier` order by (case `performance_tier` when 'Premium (4.5+)' then 1 when 'High (4.0-4.4)' then 2 when 'Good (3.5-3.9)' then 3 when 'Average (3.0-3.4)' then 4 else 5 end) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `procurement_decision_support`
--

/*!50001 DROP VIEW IF EXISTS `procurement_decision_support`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `procurement_decision_support` AS select `chm`.`carrier_id` AS `carrier_id`,`chm`.`carrier_name` AS `carrier_name`,`chm`.`equipment_type` AS `equipment_type`,`chm`.`origin_location` AS `origin_location`,`chm`.`destination_location` AS `destination_location`,`chm`.`acceptance_rate` AS `acceptance_rate`,`chm`.`overall_on_time_performance` AS `overall_on_time_performance`,`chm`.`billing_accuracy_rate` AS `billing_accuracy_rate`,`chm`.`performance_rating` AS `performance_rating`,`chm`.`scorecard_grade` AS `scorecard_grade`,`chm`.`risk_score` AS `risk_score`,`chm`.`compliance_status` AS `compliance_status`,(case when ((`chm`.`acceptance_rate` >= 90) and (`chm`.`overall_on_time_performance` >= 95) and (`chm`.`billing_accuracy_rate` >= 95) and (`chm`.`performance_rating` >= 4.0)) then 'Preferred - High Priority' when ((`chm`.`acceptance_rate` >= 80) and (`chm`.`overall_on_time_performance` >= 90) and (`chm`.`billing_accuracy_rate` >= 90) and (`chm`.`performance_rating` >= 3.5)) then 'Preferred - Standard Priority' when ((`chm`.`acceptance_rate` >= 70) and (`chm`.`overall_on_time_performance` >= 85) and (`chm`.`billing_accuracy_rate` >= 85) and (`chm`.`performance_rating` >= 3.0)) then 'Acceptable - Monitor' when ((`chm`.`acceptance_rate` < 70) or (`chm`.`overall_on_time_performance` < 85) or (`chm`.`billing_accuracy_rate` < 85) or (`chm`.`performance_rating` < 3.0)) then 'Review Required - Low Priority' else 'Evaluate Further' end) AS `procurement_recommendation` from `carrier_historical_metrics` `chm` where (`chm`.`period_start_date` >= (curdate() - interval 3 month)) order by `chm`.`performance_rating` desc,`chm`.`risk_score` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `rate_analysis`
--

/*!50001 DROP VIEW IF EXISTS `rate_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `rate_analysis` AS select `lanes_master`.`lane_id` AS `lane_id`,`lanes_master`.`origin_city` AS `origin_city`,`lanes_master`.`destination_city` AS `destination_city`,`lanes_master`.`distance_km` AS `distance_km`,`lanes_master`.`current_rate_trip` AS `current_rate_trip`,`lanes_master`.`benchmark_rate_trip` AS `benchmark_rate_trip`,round((((`lanes_master`.`current_rate_trip` - `lanes_master`.`benchmark_rate_trip`) / `lanes_master`.`benchmark_rate_trip`) * 100),2) AS `rate_variance_percent`,`lanes_master`.`fuel_surcharge_applied` AS `fuel_surcharge_applied` from `lanes_master` where ((`lanes_master`.`is_active` = true) and (`lanes_master`.`benchmark_rate_trip` is not null)) order by round((((`lanes_master`.`current_rate_trip` - `lanes_master`.`benchmark_rate_trip`) / `lanes_master`.`benchmark_rate_trip`) * 100),2) desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `rate_type_analysis`
--

/*!50001 DROP VIEW IF EXISTS `rate_type_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `rate_type_analysis` AS select `accessorial_definitions_master`.`rate_type` AS `rate_type`,count(0) AS `total_accessorials`,count((case when (`accessorial_definitions_master`.`taxable` = 'Yes') then 1 end)) AS `taxable_count`,avg(`accessorial_definitions_master`.`rate_value`) AS `avg_rate_value`,min(`accessorial_definitions_master`.`rate_value`) AS `min_rate_value`,max(`accessorial_definitions_master`.`rate_value`) AS `max_rate_value` from `accessorial_definitions_master` where (`accessorial_definitions_master`.`is_active` = 'Yes') group by `accessorial_definitions_master`.`rate_type` order by `accessorial_definitions_master`.`rate_type` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `regional_carrier_distribution`
--

/*!50001 DROP VIEW IF EXISTS `regional_carrier_distribution`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `regional_carrier_distribution` AS select `targeted_carriers`.`region_of_operation` AS `region_of_operation`,count(0) AS `total_carriers`,count((case when (`targeted_carriers`.`compliance_validated` = true) then 1 end)) AS `compliant_carriers`,count((case when (`targeted_carriers`.`rating_threshold_met` = true) then 1 end)) AS `eligible_carriers`,count((case when (`targeted_carriers`.`invited_to_bid` = true) then 1 end)) AS `invited_carriers`,avg(`targeted_carriers`.`performance_score_external`) AS `avg_performance_score`,sum(`targeted_carriers`.`fleet_size`) AS `total_fleet_capacity` from `targeted_carriers` group by `targeted_carriers`.`region_of_operation` order by `total_carriers` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `regional_coverage_analysis`
--

/*!50001 DROP VIEW IF EXISTS `regional_coverage_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `regional_coverage_analysis` AS select `carrier_master`.`region_coverage` AS `region_coverage`,count(0) AS `carrier_count`,avg(`carrier_master`.`avg_on_time_performance`) AS `avg_otp`,avg(`carrier_master`.`avg_acceptance_rate`) AS `avg_acceptance`,avg(`carrier_master`.`fleet_size`) AS `avg_fleet_size`,group_concat(distinct `carrier_master`.`carrier_rating` order by `carrier_master`.`carrier_rating` ASC separator ', ') AS `available_ratings`,count((case when (`carrier_master`.`preferred_carrier` = 'Yes') then 1 end)) AS `preferred_carriers`,count((case when (`carrier_master`.`contracted` = 'Yes') then 1 end)) AS `contracted_carriers` from `carrier_master` where (`carrier_master`.`blacklisted` = 'No') group by `carrier_master`.`region_coverage` order by `carrier_count` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `regional_season_impact`
--

/*!50001 DROP VIEW IF EXISTS `regional_season_impact`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `regional_season_impact` AS select `seasons_master`.`affected_regions` AS `affected_regions`,count(0) AS `total_seasons`,sum((case when (`seasons_master`.`capacity_risk_level` = 'High') then 1 else 0 end)) AS `high_risk_seasons`,sum((case when (`seasons_master`.`capacity_risk_level` = 'Medium') then 1 else 0 end)) AS `medium_risk_seasons`,avg(`seasons_master`.`rate_multiplier_percent`) AS `avg_rate_impact`,avg(`seasons_master`.`sla_adjustment_days`) AS `avg_sla_adjustment` from `seasons_master` where (`seasons_master`.`is_active` = true) group by `seasons_master`.`affected_regions` order by `total_seasons` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `routing_guide_summary`
--

/*!50001 DROP VIEW IF EXISTS `routing_guide_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `routing_guide_summary` AS select `routing_guides`.`routing_guide_status` AS `routing_guide_status`,count(0) AS `guide_count`,avg(`routing_guides`.`primary_carrier_rate`) AS `avg_primary_rate`,min(`routing_guides`.`valid_from`) AS `earliest_validity`,max(`routing_guides`.`valid_to`) AS `latest_validity`,count(distinct `routing_guides`.`equipment_type`) AS `unique_equipment_types`,count(distinct `routing_guides`.`primary_carrier_name`) AS `unique_carriers` from `routing_guides` group by `routing_guides`.`routing_guide_status` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `seasonal_cost_analysis`
--

/*!50001 DROP VIEW IF EXISTS `seasonal_cost_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `seasonal_cost_analysis` AS select `seasons_master`.`season_id` AS `season_id`,`seasons_master`.`season_name` AS `season_name`,`seasons_master`.`start_date` AS `start_date`,`seasons_master`.`end_date` AS `end_date`,`seasons_master`.`impact_type` AS `impact_type`,`seasons_master`.`rate_multiplier_percent` AS `rate_multiplier_percent`,(case when (`seasons_master`.`rate_multiplier_percent` > 0) then 'Cost Increase' when (`seasons_master`.`rate_multiplier_percent` < 0) then 'Cost Decrease' else 'No Change' end) AS `cost_impact`,`seasons_master`.`affected_regions` AS `affected_regions` from `seasons_master` where ((`seasons_master`.`is_active` = true) and (`seasons_master`.`rate_multiplier_percent` is not null)) order by `seasons_master`.`rate_multiplier_percent` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `seasonal_lanes`
--

/*!50001 DROP VIEW IF EXISTS `seasonal_lanes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `seasonal_lanes` AS select `lanes_master`.`lane_id` AS `lane_id`,`lanes_master`.`origin_city` AS `origin_city`,`lanes_master`.`destination_city` AS `destination_city`,`lanes_master`.`peak_months` AS `peak_months`,`lanes_master`.`avg_load_frequency_month` AS `avg_load_frequency_month`,`lanes_master`.`distance_km` AS `distance_km`,`lanes_master`.`transit_time_days` AS `transit_time_days` from `lanes_master` where ((`lanes_master`.`is_active` = true) and (`lanes_master`.`seasonality` = true)) order by `lanes_master`.`avg_load_frequency_month` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `service_level_pricing_tiers`
--

/*!50001 DROP VIEW IF EXISTS `service_level_pricing_tiers`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `service_level_pricing_tiers` AS select `service_levels_master`.`service_level_id` AS `service_level_id`,`service_levels_master`.`service_level_name` AS `service_level_name`,`service_levels_master`.`service_category` AS `service_category`,`service_levels_master`.`priority_tag` AS `priority_tag`,`service_levels_master`.`max_transit_time_days` AS `max_transit_time_days`,(case when (`service_levels_master`.`service_category` = 'Premium') then 'High' when (`service_levels_master`.`service_category` = 'Express') then 'High' when (`service_levels_master`.`service_category` = 'Specialized') then 'High' when (`service_levels_master`.`service_category` = 'Standard') then 'Medium' when (`service_levels_master`.`service_category` = 'Dedicated') then 'Medium' else 'Low' end) AS `pricing_tier`,(case when (`service_levels_master`.`penalty_applicable` = 'Yes') then 'Penalty Applicable' else 'No Penalty' end) AS `penalty_status` from `service_levels_master` order by (case when (`service_levels_master`.`service_category` = 'Premium') then 'High' when (`service_levels_master`.`service_category` = 'Express') then 'High' when (`service_levels_master`.`service_category` = 'Specialized') then 'High' when (`service_levels_master`.`service_category` = 'Standard') then 'Medium' when (`service_levels_master`.`service_category` = 'Dedicated') then 'Medium' else 'Low' end) desc,`service_levels_master`.`priority_tag` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `service_level_summary`
--

/*!50001 DROP VIEW IF EXISTS `service_level_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `service_level_summary` AS select `service_levels_master`.`service_category` AS `service_category`,count(0) AS `total_service_levels`,count((case when (`service_levels_master`.`penalty_applicable` = 'Yes') then 1 end)) AS `penalty_applicable_count`,count((case when (`service_levels_master`.`sla_type` = 'Hard SLA') then 1 end)) AS `hard_sla_count`,avg(`service_levels_master`.`max_transit_time_days`) AS `avg_transit_time`,avg(`service_levels_master`.`carrier_response_time_hours`) AS `avg_response_time` from `service_levels_master` group by `service_levels_master`.`service_category` order by `service_levels_master`.`service_category` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `sla_compliance_analysis`
--

/*!50001 DROP VIEW IF EXISTS `sla_compliance_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `sla_compliance_analysis` AS select `service_levels_master`.`sla_type` AS `sla_type`,count(0) AS `total_levels`,count((case when (`service_levels_master`.`penalty_applicable` = 'Yes') then 1 end)) AS `penalty_enabled`,count((case when (`service_levels_master`.`penalty_applicable` = 'No') then 1 end)) AS `penalty_disabled`,avg(`service_levels_master`.`max_transit_time_days`) AS `avg_transit_time`,avg(`service_levels_master`.`allowed_delay_buffer_hours`) AS `avg_delay_buffer` from `service_levels_master` group by `service_levels_master`.`sla_type` order by `service_levels_master`.`sla_type` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `sourcing_recommendations`
--

/*!50001 DROP VIEW IF EXISTS `sourcing_recommendations`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `sourcing_recommendations` AS select `targeted_carriers`.`carrier_id_3p` AS `carrier_id_3p`,`targeted_carriers`.`carrier_name` AS `carrier_name`,`targeted_carriers`.`region_of_operation` AS `region_of_operation`,`targeted_carriers`.`equipment_types` AS `equipment_types`,`targeted_carriers`.`performance_score_external` AS `performance_score_external`,`targeted_carriers`.`fleet_size` AS `fleet_size`,(case when ((`targeted_carriers`.`performance_score_external` >= 4.5) and (`targeted_carriers`.`compliance_validated` = true) and (`targeted_carriers`.`fleet_size` >= 50)) then 'Priority 1 - Premium' when ((`targeted_carriers`.`performance_score_external` >= 4.0) and (`targeted_carriers`.`compliance_validated` = true) and (`targeted_carriers`.`fleet_size` >= 30)) then 'Priority 2 - High' when ((`targeted_carriers`.`performance_score_external` >= 3.5) and (`targeted_carriers`.`compliance_validated` = true) and (`targeted_carriers`.`fleet_size` >= 20)) then 'Priority 3 - Good' when ((`targeted_carriers`.`compliance_validated` = true) and (`targeted_carriers`.`fleet_size` >= 15)) then 'Priority 4 - Standard' else 'Priority 5 - Review Required' end) AS `sourcing_priority`,(case when (`targeted_carriers`.`invited_to_bid` = true) then 'Already Invited' when (`targeted_carriers`.`last_active` >= (curdate() - interval 7 day)) then 'Recently Active' when (`targeted_carriers`.`last_active` >= (curdate() - interval 30 day)) then 'Active' else 'Inactive' end) AS `activity_status` from `targeted_carriers` order by (case `sourcing_priority` when 'Priority 1 - Premium' then 1 when 'Priority 2 - High' then 2 when 'Priority 3 - Good' then 3 when 'Priority 4 - Standard' then 4 else 5 end),`targeted_carriers`.`performance_score_external` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `specialized_equipment`
--

/*!50001 DROP VIEW IF EXISTS `specialized_equipment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `specialized_equipment` AS select `equipment_types_master`.`equipment_id` AS `equipment_id`,`equipment_types_master`.`equipment_name` AS `equipment_name`,`equipment_types_master`.`vehicle_body_type` AS `vehicle_body_type`,`equipment_types_master`.`hazmat_certified` AS `hazmat_certified`,`equipment_types_master`.`security_features` AS `security_features`,`equipment_types_master`.`regulatory_compliance` AS `regulatory_compliance`,`equipment_types_master`.`ideal_commodities` AS `ideal_commodities`,`equipment_types_master`.`standard_rate_per_km` AS `standard_rate_per_km`,`equipment_types_master`.`active` AS `active` from `equipment_types_master` where (((`equipment_types_master`.`hazmat_certified` = true) or (`equipment_types_master`.`vehicle_body_type` in ('Tanker','Specialized'))) and (`equipment_types_master`.`active` = true)) order by `equipment_types_master`.`vehicle_body_type` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `specialized_modes`
--

/*!50001 DROP VIEW IF EXISTS `specialized_modes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `specialized_modes` AS select `modes_master`.`mode_id` AS `mode_id`,`modes_master`.`mode_name` AS `mode_name`,`modes_master`.`mode_type` AS `mode_type`,`modes_master`.`suitable_commodities` AS `suitable_commodities`,`modes_master`.`equipment_type_required` AS `equipment_type_required`,`modes_master`.`special_permits_required` AS `special_permits_required`,`modes_master`.`insurance_requirements` AS `insurance_requirements`,`modes_master`.`base_cost_multiplier` AS `base_cost_multiplier` from `modes_master` where ((`modes_master`.`active` = 'Yes') and (`modes_master`.`mode_type` in ('Specialized','Containerized','Dedicated'))) order by `modes_master`.`mode_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `surcharge_impact_analysis`
--

/*!50001 DROP VIEW IF EXISTS `surcharge_impact_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `surcharge_impact_analysis` AS select `fs`.`applicable_region` AS `applicable_region`,`fs`.`currency` AS `currency`,count(0) AS `total_slabs`,min(`fs`.`fuel_surcharge_percentage`) AS `min_surcharge`,max(`fs`.`fuel_surcharge_percentage`) AS `max_surcharge`,avg(`fs`.`fuel_surcharge_percentage`) AS `avg_surcharge`,sum((case when (`fs`.`fuel_surcharge_percentage` = 0) then 1 else 0 end)) AS `no_surcharge_slabs`,sum((case when (`fs`.`fuel_surcharge_percentage` > 0) then 1 else 0 end)) AS `surcharge_slabs` from `fuel_surcharge_master` `fs` where (`fs`.`is_active` = 'Yes') group by `fs`.`applicable_region`,`fs`.`currency` order by `fs`.`applicable_region`,`fs`.`currency` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `taxable_accessorials_analysis`
--

/*!50001 DROP VIEW IF EXISTS `taxable_accessorials_analysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `taxable_accessorials_analysis` AS select `accessorial_definitions_master`.`taxable` AS `taxable`,count(0) AS `total_accessorials`,avg(`accessorial_definitions_master`.`rate_value`) AS `avg_rate_value`,sum((case when (`accessorial_definitions_master`.`applies_to` = 'Pickup') then 1 else 0 end)) AS `pickup_count`,sum((case when (`accessorial_definitions_master`.`applies_to` = 'Delivery') then 1 else 0 end)) AS `delivery_count`,sum((case when (`accessorial_definitions_master`.`applies_to` = 'In-Transit') then 1 else 0 end)) AS `in_transit_count`,sum((case when (`accessorial_definitions_master`.`applies_to` = 'General') then 1 else 0 end)) AS `general_count` from `accessorial_definitions_master` where (`accessorial_definitions_master`.`is_active` = 'Yes') group by `accessorial_definitions_master`.`taxable` order by `accessorial_definitions_master`.`taxable` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `temperature_controlled_equipment`
--

/*!50001 DROP VIEW IF EXISTS `temperature_controlled_equipment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `temperature_controlled_equipment` AS select `equipment_types_master`.`equipment_id` AS `equipment_id`,`equipment_types_master`.`equipment_name` AS `equipment_name`,`equipment_types_master`.`vehicle_body_type` AS `vehicle_body_type`,`equipment_types_master`.`vehicle_length_ft` AS `vehicle_length_ft`,`equipment_types_master`.`refrigeration_capacity_btu` AS `refrigeration_capacity_btu`,`equipment_types_master`.`ideal_commodities` AS `ideal_commodities`,`equipment_types_master`.`standard_rate_per_km` AS `standard_rate_per_km`,`equipment_types_master`.`active` AS `active` from `equipment_types_master` where ((`equipment_types_master`.`temperature_controlled` = true) and (`equipment_types_master`.`active` = true)) order by `equipment_types_master`.`refrigeration_capacity_btu` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `time_critical_modes`
--

/*!50001 DROP VIEW IF EXISTS `time_critical_modes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `time_critical_modes` AS select `modes_master`.`mode_id` AS `mode_id`,`modes_master`.`mode_name` AS `mode_name`,`modes_master`.`mode_type` AS `mode_type`,`modes_master`.`transit_time_days` AS `transit_time_days`,`modes_master`.`speed_level` AS `speed_level`,`modes_master`.`supports_time_definite` AS `supports_time_definite`,`modes_master`.`on_time_performance_target` AS `on_time_performance_target`,`modes_master`.`base_cost_multiplier` AS `base_cost_multiplier` from `modes_master` where ((`modes_master`.`active` = 'Yes') and ((`modes_master`.`speed_level` = 'Fast') or (`modes_master`.`transit_time_days` <= 2.0))) order by `modes_master`.`transit_time_days`,`modes_master`.`base_cost_multiplier` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `time_critical_services`
--

/*!50001 DROP VIEW IF EXISTS `time_critical_services`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`routecraft_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `time_critical_services` AS select `service_levels_master`.`service_level_id` AS `service_level_id`,`service_levels_master`.`service_level_name` AS `service_level_name`,`service_levels_master`.`max_transit_time_days` AS `max_transit_time_days`,`service_levels_master`.`allowed_delay_buffer_hours` AS `allowed_delay_buffer_hours`,`service_levels_master`.`fixed_departure_time` AS `fixed_departure_time`,`service_levels_master`.`fixed_delivery_time` AS `fixed_delivery_time`,`service_levels_master`.`pickup_time_window_start` AS `pickup_time_window_start`,`service_levels_master`.`delivery_time_window_end` AS `delivery_time_window_end`,`service_levels_master`.`sla_type` AS `sla_type`,`service_levels_master`.`penalty_applicable` AS `penalty_applicable` from `service_levels_master` where ((`service_levels_master`.`fixed_departure_time` = 'Yes') or (`service_levels_master`.`fixed_delivery_time` = 'Yes')) order by `service_levels_master`.`max_transit_time_days`,`service_levels_master`.`allowed_delay_buffer_hours` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-30 14:15:33
