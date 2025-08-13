-- Service Levels Master Table Schema
-- RouteCraft TL Transportation Procurement System
-- Version: 1.0
-- Created: January 2025

-- Drop table if exists (for clean installation)
DROP TABLE IF EXISTS service_levels_master;

-- Create Service Levels Master Table
CREATE TABLE service_levels_master (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    service_level_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique service level identifier (e.g., SL-001)',
    service_level_name VARCHAR(255) NOT NULL COMMENT 'Descriptive name (e.g., Standard, Express, Scheduled)',
    description TEXT COMMENT 'Detailed description of service level expectations',
    max_transit_time_days DECIMAL(3,1) NOT NULL COMMENT 'Maximum allowed transit time in days',
    allowed_delay_buffer_hours DECIMAL(4,1) DEFAULT 0 COMMENT 'Permissible delay threshold in hours',
    fixed_departure_time ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Is pickup expected at a fixed hour/day?',
    fixed_delivery_time ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Is delivery time-specific?',
    mode ENUM('TL', 'LTL', 'Rail-Road', 'Intermodal', 'Express', 'Dedicated') DEFAULT 'TL' COMMENT 'Transportation mode',
    carrier_response_time_hours DECIMAL(4,1) DEFAULT 24 COMMENT 'Expected time for carrier to accept the load',
    sla_type ENUM('Hard SLA', 'Soft SLA', 'Target SLA') DEFAULT 'Soft SLA' COMMENT 'SLA enforcement type',
    penalty_applicable ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Is penalty applied for failure to meet SLA?',
    penalty_rule_id VARCHAR(100) COMMENT 'Link to penalty definition (e.g., % of freight)',
    priority_tag ENUM('High', 'Medium', 'Low') DEFAULT 'Medium' COMMENT 'Planning preference priority',
    enabled_for_bidding ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Whether this service level can be selected in RFPs',
    service_category ENUM('Standard', 'Premium', 'Express', 'Dedicated', 'Specialized') DEFAULT 'Standard' COMMENT 'Service category classification',
    pickup_time_window_start TIME COMMENT 'Preferred pickup time window start (HH:MM)',
    pickup_time_window_end TIME COMMENT 'Preferred pickup time window end (HH:MM)',
    delivery_time_window_start TIME COMMENT 'Preferred delivery time window start (HH:MM)',
    delivery_time_window_end TIME COMMENT 'Preferred delivery time window end (HH:MM)',
    weekend_operations ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Does service operate on weekends?',
    holiday_operations ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Does service operate on holidays?',
    temperature_controlled ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Requires temperature-controlled equipment?',
    security_required ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Requires security escort or special handling?',
    insurance_coverage DECIMAL(10,2) COMMENT 'Minimum insurance coverage required (in INR)',
    fuel_surcharge_applicable ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Is fuel surcharge applicable?',
    detention_charges_applicable ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Are detention charges applicable?',
    remarks TEXT COMMENT 'Additional notes and special requirements',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    created_by VARCHAR(100) COMMENT 'User who created the service level',
    updated_by VARCHAR(100) COMMENT 'User who last updated the service level',
    
    -- Indexes for Performance
    INDEX idx_service_level_id (service_level_id),
    INDEX idx_service_level_name (service_level_name),
    INDEX idx_mode (mode),
    INDEX idx_service_category (service_category),
    INDEX idx_sla_type (sla_type),
    INDEX idx_priority_tag (priority_tag),
    INDEX idx_enabled_for_bidding (enabled_for_bidding),
    INDEX idx_max_transit_time (max_transit_time_days),
    INDEX idx_penalty_applicable (penalty_applicable),
    INDEX idx_temperature_controlled (temperature_controlled),
    INDEX idx_security_required (security_required)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Service Levels Master for TL transportation procurement with comprehensive SLA definitions';

-- Insert Sample Data
INSERT INTO service_levels_master (
    service_level_id, service_level_name, description, max_transit_time_days,
    allowed_delay_buffer_hours, fixed_departure_time, fixed_delivery_time,
    mode, carrier_response_time_hours, sla_type, penalty_applicable,
    penalty_rule_id, priority_tag, enabled_for_bidding, service_category,
    pickup_time_window_start, pickup_time_window_end, delivery_time_window_start,
    delivery_time_window_end, weekend_operations, holiday_operations,
    temperature_controlled, security_required, insurance_coverage,
    fuel_surcharge_applicable, detention_charges_applicable, remarks
) VALUES 
-- Standard Service Levels
('SL-STD-01', 'Standard Delivery', 'Regular TL service with standard transit times and normal operating conditions', 3.0, 4.0, 'No', 'No', 'TL', 24.0, 'Soft SLA', 'No', NULL, 'Medium', 'Yes', 'Standard', NULL, NULL, NULL, NULL, 'No', 'No', 'No', 'No', 50000.00, 'Yes', 'Yes', 'Standard service for regular shipments'),

-- Express Service Levels
('SL-EXP-01', 'Express Delivery', 'Fast turnaround priority service for time-critical shipments', 1.5, 2.0, 'Yes', 'Yes', 'TL', 12.0, 'Hard SLA', 'Yes', 'PEN-EXP-01', 'High', 'Yes', 'Express', '08:00:00', '10:00:00', '16:00:00', '18:00:00', 'Yes', 'Yes', 'No', 'No', 100000.00, 'Yes', 'Yes', 'Used for high-value pharma shipments and urgent deliveries'),

-- Scheduled Service Levels
('SL-SCH-01', 'Scheduled Pickup/Delivery', 'Pre-booked time slots at dock to reduce wait time and improve efficiency', 2.5, 3.0, 'Yes', 'Yes', 'TL', 18.0, 'Hard SLA', 'Yes', 'PEN-SCH-01', 'Medium', 'Yes', 'Premium', '09:00:00', '11:00:00', '14:00:00', '16:00:00', 'No', 'No', 'No', 'No', 75000.00, 'Yes', 'Yes', 'Fixed time slots for better dock management'),

-- Time-Definite Service Levels
('SL-TD-01', 'Time-Definite', 'Delivery or pickup must happen at a defined time window with strict adherence', 2.0, 1.0, 'Yes', 'Yes', 'TL', 6.0, 'Hard SLA', 'Yes', 'PEN-TD-01', 'High', 'Yes', 'Premium', '10:00:00', '10:30:00', '15:00:00', '15:30:00', 'Yes', 'Yes', 'No', 'No', 150000.00, 'Yes', 'Yes', 'Critical for just-in-time manufacturing and retail'),

-- Dedicated Service Levels
('SL-DED-01', 'Dedicated Service', 'Specific vehicle assigned with no load sharing, guaranteed capacity', 4.0, 6.0, 'No', 'No', 'Dedicated', 48.0, 'Soft SLA', 'No', NULL, 'Medium', 'Yes', 'Dedicated', NULL, NULL, NULL, NULL, 'No', 'No', 'No', 'No', 200000.00, 'Yes', 'Yes', 'For high-volume shippers requiring guaranteed capacity'),

-- White Glove Service Levels
('SL-WG-01', 'White Glove Service', 'High-touch handling with security, extra personnel, and special care', 3.5, 2.0, 'Yes', 'Yes', 'TL', 12.0, 'Hard SLA', 'Yes', 'PEN-WG-01', 'High', 'Yes', 'Specialized', '08:00:00', '09:00:00', '17:00:00', '18:00:00', 'Yes', 'Yes', 'No', 'Yes', 250000.00, 'Yes', 'Yes', 'For high-value electronics, art, and sensitive cargo'),

-- Temperature Controlled Service Levels
('SL-TEMP-01', 'Temperature Controlled', 'Specialized service for perishable goods requiring temperature monitoring', 2.5, 3.0, 'Yes', 'Yes', 'TL', 18.0, 'Hard SLA', 'Yes', 'PEN-TEMP-01', 'High', 'Yes', 'Specialized', '06:00:00', '08:00:00', '18:00:00', '20:00:00', 'Yes', 'Yes', 'Yes', 'No', 300000.00, 'Yes', 'Yes', 'For pharmaceuticals, food, and chemicals'),

-- Oversized Cargo Service Levels
('SL-OVS-01', 'Oversized Cargo', 'Special handling for oversized and overweight shipments', 5.0, 8.0, 'No', 'No', 'TL', 36.0, 'Soft SLA', 'No', NULL, 'Medium', 'Yes', 'Specialized', NULL, NULL, NULL, NULL, 'No', 'No', 'No', 'No', 500000.00, 'Yes', 'Yes', 'Requires special permits and route planning'),

-- Economy Service Levels
('SL-ECO-01', 'Economy Service', 'Cost-effective option with longer transit times', 5.0, 6.0, 'No', 'No', 'TL', 48.0, 'Soft SLA', 'No', NULL, 'Low', 'Yes', 'Standard', NULL, NULL, NULL, NULL, 'No', 'No', 'No', 'No', 25000.00, 'Yes', 'Yes', 'Budget-friendly option for non-urgent shipments'),

-- Intermodal Service Levels
('SL-INT-01', 'Intermodal Service', 'Combined rail and road transportation for long distances', 7.0, 12.0, 'No', 'No', 'Intermodal', 72.0, 'Soft SLA', 'No', NULL, 'Low', 'Yes', 'Specialized', NULL, NULL, NULL, NULL, 'No', 'No', 'No', 'No', 100000.00, 'Yes', 'Yes', 'For long-haul shipments with cost optimization');

-- Create Views for Analysis and Reporting

-- 1. Active Service Levels View
CREATE OR REPLACE VIEW active_service_levels AS
SELECT 
    service_level_id,
    service_level_name,
    service_category,
    max_transit_time_days,
    sla_type,
    priority_tag,
    mode,
    enabled_for_bidding
FROM service_levels_master
WHERE enabled_for_bidding = 'Yes'
ORDER BY priority_tag DESC, max_transit_time_days ASC;

-- 2. Service Level Performance Summary View
CREATE OR REPLACE VIEW service_level_summary AS
SELECT 
    service_category,
    COUNT(*) as total_service_levels,
    COUNT(CASE WHEN penalty_applicable = 'Yes' THEN 1 END) as penalty_applicable_count,
    COUNT(CASE WHEN sla_type = 'Hard SLA' THEN 1 END) as hard_sla_count,
    AVG(max_transit_time_days) as avg_transit_time,
    AVG(carrier_response_time_hours) as avg_response_time
FROM service_levels_master
GROUP BY service_category
ORDER BY service_category;

-- 3. SLA Compliance Analysis View
CREATE OR REPLACE VIEW sla_compliance_analysis AS
SELECT 
    sla_type,
    COUNT(*) as total_levels,
    COUNT(CASE WHEN penalty_applicable = 'Yes' THEN 1 END) as penalty_enabled,
    COUNT(CASE WHEN penalty_applicable = 'No' THEN 1 END) as penalty_disabled,
    AVG(max_transit_time_days) as avg_transit_time,
    AVG(allowed_delay_buffer_hours) as avg_delay_buffer
FROM service_levels_master
GROUP BY sla_type
ORDER BY sla_type;

-- 4. Service Level Pricing Tiers View
CREATE OR REPLACE VIEW service_level_pricing_tiers AS
SELECT 
    service_level_id,
    service_level_name,
    service_category,
    priority_tag,
    max_transit_time_days,
    CASE 
        WHEN service_category = 'Premium' THEN 'High'
        WHEN service_category = 'Express' THEN 'High'
        WHEN service_category = 'Specialized' THEN 'High'
        WHEN service_category = 'Standard' THEN 'Medium'
        WHEN service_category = 'Dedicated' THEN 'Medium'
        ELSE 'Low'
    END as pricing_tier,
    CASE 
        WHEN penalty_applicable = 'Yes' THEN 'Penalty Applicable'
        ELSE 'No Penalty'
    END as penalty_status
FROM service_levels_master
ORDER BY pricing_tier DESC, priority_tag DESC;

-- 5. Time-Critical Services View
CREATE OR REPLACE VIEW time_critical_services AS
SELECT 
    service_level_id,
    service_level_name,
    max_transit_time_days,
    allowed_delay_buffer_hours,
    fixed_departure_time,
    fixed_delivery_time,
    pickup_time_window_start,
    delivery_time_window_end,
    sla_type,
    penalty_applicable
FROM service_levels_master
WHERE fixed_departure_time = 'Yes' OR fixed_delivery_time = 'Yes'
ORDER BY max_transit_time_days ASC, allowed_delay_buffer_hours ASC;

-- 6. Premium Services View
CREATE OR REPLACE VIEW premium_services AS
SELECT 
    service_level_id,
    service_level_name,
    service_category,
    max_transit_time_days,
    sla_type,
    penalty_applicable,
    insurance_coverage,
    temperature_controlled,
    security_required
FROM service_levels_master
WHERE service_category IN ('Premium', 'Express', 'Specialized')
ORDER BY max_transit_time_days ASC;

-- 7. Cost-Effective Services View
CREATE OR REPLACE VIEW cost_effective_services AS
SELECT 
    service_level_id,
    service_level_name,
    service_category,
    max_transit_time_days,
    sla_type,
    penalty_applicable,
    insurance_coverage
FROM service_levels_master
WHERE service_category IN ('Standard', 'Economy')
ORDER BY max_transit_time_days DESC;

-- Show table information
SELECT 
    'Service Levels Master Table Created Successfully' as status,
    COUNT(*) as total_service_levels,
    COUNT(CASE WHEN enabled_for_bidding = 'Yes' THEN 1 END) as active_for_bidding,
    COUNT(CASE WHEN penalty_applicable = 'Yes' THEN 1 END) as penalty_enabled,
    COUNT(CASE WHEN sla_type = 'Hard SLA' THEN 1 END) as hard_sla_count
FROM service_levels_master; 