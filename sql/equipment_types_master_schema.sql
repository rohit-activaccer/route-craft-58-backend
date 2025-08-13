-- Equipment Types Master Table Schema
-- This table defines different types of transportation equipment used in truckload transport

-- Drop table if exists (for development/testing)
DROP TABLE IF EXISTS equipment_types_master;

-- Create the main table
CREATE TABLE equipment_types_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Unique equipment code (e.g., EQP-32FT-CNTNR)',
    equipment_name VARCHAR(100) NOT NULL COMMENT 'Human-readable name (e.g., 32ft Container Truck)',
    vehicle_body_type ENUM('Container', 'Open Body', 'Flatbed', 'Reefer', 'Tanker', 'Box Truck', 'Trailer', 'Specialized') NOT NULL COMMENT 'Type of vehicle body',
    vehicle_length_ft DECIMAL(4,1) NOT NULL COMMENT 'Vehicle length in feet (e.g., 20.0, 32.0, 40.0)',
    axle_type ENUM('Single', 'Double', 'Multi-axle', 'Tandem', 'Tri-axle') NOT NULL COMMENT 'Axle configuration',
    gross_vehicle_weight_tons DECIMAL(5,2) NOT NULL COMMENT 'Maximum GVW in tons',
    payload_capacity_tons DECIMAL(5,2) NOT NULL COMMENT 'Net cargo capacity in tons',
    volume_capacity_cft INT COMMENT 'Volume capacity in cubic feet',
    volume_capacity_cbm DECIMAL(6,2) COMMENT 'Volume capacity in cubic meters',
    door_type ENUM('Side-opening', 'Rear-opening', 'Top-loading', 'Roll-up', 'Side-roll', 'Multiple', 'Side-loading') COMMENT 'Type of loading doors',
    temperature_controlled BOOLEAN DEFAULT FALSE COMMENT 'Whether vehicle has temperature control',
    hazmat_certified BOOLEAN DEFAULT FALSE COMMENT 'If vehicle is permitted to carry hazardous goods',
    ideal_commodities TEXT COMMENT 'Comma-separated list of ideal commodities',
    fuel_type ENUM('Diesel', 'CNG', 'Electric', 'Hybrid', 'Biodiesel') DEFAULT 'Diesel' COMMENT 'Primary fuel type',
    has_gps BOOLEAN DEFAULT FALSE COMMENT 'Whether vehicle has GPS for tracking',
    dock_type_compatibility ENUM('Ground-level', 'Elevated', 'Ramp-access', 'All', 'Specialized') COMMENT 'Dock compatibility',
    common_routes TEXT COMMENT 'Common routes or lanes where this equipment is used',
    standard_rate_per_km DECIMAL(8,2) COMMENT 'Internal planning rate per kilometer',
    max_height_meters DECIMAL(4,2) COMMENT 'Maximum height in meters',
    max_width_meters DECIMAL(4,2) COMMENT 'Maximum width in meters',
    refrigeration_capacity_btu INT COMMENT 'Refrigeration capacity in BTU (for reefers)',
    security_features TEXT COMMENT 'Security features like locks, seals, etc.',
    maintenance_requirements TEXT COMMENT 'Maintenance schedule and requirements',
    regulatory_compliance TEXT COMMENT 'Regulatory compliance requirements',
    insurance_coverage_type ENUM('Basic', 'Comprehensive', 'Specialized', 'High-value') DEFAULT 'Basic' COMMENT 'Insurance coverage type',
    active BOOLEAN DEFAULT TRUE COMMENT 'Whether this equipment type is currently active',
    priority_level ENUM('High', 'Medium', 'Low') DEFAULT 'Medium' COMMENT 'Priority for procurement planning',
    seasonal_availability TEXT COMMENT 'Seasonal restrictions or availability',
    remarks TEXT COMMENT 'Additional notes and limitations',
    created_by VARCHAR(50) DEFAULT 'system' COMMENT 'User who created the record',
    updated_by VARCHAR(50) DEFAULT 'system' COMMENT 'User who last updated the record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record update timestamp',
    
    -- Indexes for performance
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_vehicle_body_type (vehicle_body_type),
    INDEX idx_vehicle_length (vehicle_length_ft),
    INDEX idx_axle_type (axle_type),
    INDEX idx_temperature_controlled (temperature_controlled),
    INDEX idx_hazmat_certified (hazmat_certified),
    INDEX idx_active (active),
    INDEX idx_priority_level (priority_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for transportation equipment types';

-- Create views for common analysis scenarios

-- 1. Equipment Summary View
CREATE OR REPLACE VIEW equipment_summary AS
SELECT 
    equipment_id,
    equipment_name,
    vehicle_body_type,
    vehicle_length_ft,
    axle_type,
    gross_vehicle_weight_tons,
    payload_capacity_tons,
    volume_capacity_cft,
    temperature_controlled,
    hazmat_certified,
    fuel_type,
    active,
    priority_level,
    standard_rate_per_km
FROM equipment_types_master
WHERE active = TRUE
ORDER BY priority_level DESC, vehicle_length_ft DESC;

-- 2. Temperature Controlled Equipment View
CREATE OR REPLACE VIEW temperature_controlled_equipment AS
SELECT 
    equipment_id,
    equipment_name,
    vehicle_body_type,
    vehicle_length_ft,
    refrigeration_capacity_btu,
    ideal_commodities,
    standard_rate_per_km,
    active
FROM equipment_types_master
WHERE temperature_controlled = TRUE AND active = TRUE
ORDER BY refrigeration_capacity_btu DESC;

-- 3. High Capacity Equipment View
CREATE OR REPLACE VIEW high_capacity_equipment AS
SELECT 
    equipment_id,
    equipment_name,
    vehicle_body_type,
    vehicle_length_ft,
    payload_capacity_tons,
    volume_capacity_cft,
    axle_type,
    standard_rate_per_km,
    active
FROM equipment_types_master
WHERE payload_capacity_tons >= 15 AND active = TRUE
ORDER BY payload_capacity_tons DESC;

-- 4. Specialized Equipment View
CREATE OR REPLACE VIEW specialized_equipment AS
SELECT 
    equipment_id,
    equipment_name,
    vehicle_body_type,
    hazmat_certified,
    security_features,
    regulatory_compliance,
    ideal_commodities,
    standard_rate_per_km,
    active
FROM equipment_types_master
WHERE (hazmat_certified = TRUE OR vehicle_body_type IN ('Tanker', 'Specialized')) AND active = TRUE
ORDER BY vehicle_body_type;

-- 5. Cost Effective Equipment View
CREATE OR REPLACE VIEW cost_effective_equipment AS
SELECT 
    equipment_id,
    equipment_name,
    vehicle_body_type,
    vehicle_length_ft,
    payload_capacity_tons,
    volume_capacity_cft,
    standard_rate_per_km,
    (payload_capacity_tons / NULLIF(standard_rate_per_km, 0)) as tons_per_rupee,
    active
FROM equipment_types_master
WHERE standard_rate_per_km IS NOT NULL AND active = TRUE
ORDER BY tons_per_rupee DESC;

-- Insert sample data for common Indian TL equipment types

INSERT INTO equipment_types_master (
    equipment_id, equipment_name, vehicle_body_type, vehicle_length_ft,
    axle_type, gross_vehicle_weight_tons, payload_capacity_tons,
    volume_capacity_cft, volume_capacity_cbm, door_type,
    temperature_controlled, hazmat_certified, ideal_commodities,
    fuel_type, has_gps, dock_type_compatibility, common_routes,
    standard_rate_per_km, max_height_meters, max_width_meters,
    refrigeration_capacity_btu, security_features, maintenance_requirements,
    regulatory_compliance, insurance_coverage_type, active, priority_level,
    seasonal_availability, remarks, created_by, updated_by
) VALUES
-- 32ft Single Axle Container (SXL)
('EQP-32SXL', '32ft Single Axle Container Truck', 'Container', 32.0,
 'Single', 16.0, 11.0, 1200, 34.0, 'Rear-opening',
 FALSE, FALSE, 'FMCG, Retail, General Cargo, Textiles',
 'Diesel', TRUE, 'Elevated', 'Mumbai-Delhi, Bangalore-Chennai, Kolkata-Guwahati',
 28.50, 2.6, 2.4, NULL, 'Container locks, Seal verification',
 'Monthly inspection, Oil change every 5000 km', 'RTO compliance, Pollution certificate',
 'Basic', TRUE, 'High', 'Year-round', 'Most common equipment for general cargo',
 'system', 'system'),

-- 32ft Multi-Axle Container (MXL)
('EQP-32MXL', '32ft Multi-Axle Container Truck', 'Container', 32.0,
 'Multi-axle', 21.0, 16.0, 1800, 51.0, 'Rear-opening',
 FALSE, FALSE, 'FMCG, Retail, Electronics, Industrial goods',
 'Diesel', TRUE, 'Elevated', 'Mumbai-Delhi, Bangalore-Chennai, Pune-Mumbai',
 30.00, 2.6, 2.4, NULL, 'Container locks, Seal verification, GPS tracking',
 'Monthly inspection, Oil change every 5000 km, Axle maintenance',
 'RTO compliance, Pollution certificate, Multi-axle permit',
 'Comprehensive', TRUE, 'High', 'Year-round', 'Higher capacity, better fuel efficiency',
 'system', 'system'),

-- 20ft Open Body Truck
('EQP-20OB', '20ft Open Body Truck', 'Open Body', 20.0,
 'Single', 12.0, 7.0, 800, 22.7, 'Top-loading',
 FALSE, FALSE, 'Construction material, Bulk items, Agricultural produce',
 'Diesel', FALSE, 'Ground-level', 'Local construction sites, Agricultural markets',
 25.00, 2.4, 2.2, NULL, 'Tarpaulin cover, Rope tie-downs',
 'Weekly inspection, Regular cleaning', 'RTO compliance, Local transport permit',
 'Basic', TRUE, 'Medium', 'Year-round', 'Suitable for bulk and construction materials',
 'system', 'system'),

-- 40ft Flatbed Trailer
('EQP-40FB', '40ft Flatbed Trailer', 'Flatbed', 40.0,
 'Tandem', 25.0, 20.0, 2400, 68.0, 'Side-loading',
 FALSE, FALSE, 'Machinery, ODC cargo, Industrial equipment, Steel',
 'Diesel', TRUE, 'Ground-level', 'Heavy machinery transport, Industrial corridors',
 35.00, 2.8, 2.6, NULL, 'Chain tie-downs, Corner protectors',
 'Monthly inspection, Regular cleaning, Chain maintenance',
 'RTO compliance, ODC permit for oversized loads',
 'Specialized', TRUE, 'Medium', 'Year-round', 'For oversized and heavy machinery',
 'system', 'system'),

-- Reefer (Temperature-Controlled)
('EQP-32RF', '32ft Refrigerated Container Truck', 'Reefer', 32.0,
 'Multi-axle', 21.0, 16.0, 1600, 45.3, 'Rear-opening',
 TRUE, FALSE, 'Pharmaceuticals, Perishable foods, Dairy products, Flowers',
 'Diesel', TRUE, 'Elevated', 'Pharma corridors, Cold chain routes',
 38.00, 2.6, 2.4, 12000, 'Temperature monitoring, GPS tracking, Seal verification',
 'Weekly inspection, Refrigeration system maintenance, Temperature calibration',
 'RTO compliance, Pharma transport license, Temperature monitoring compliance',
 'Specialized', TRUE, 'High', 'Year-round', 'Critical for temperature-sensitive cargo',
 'system', 'system'),

-- Tanker (Liquid/Gas)
('EQP-32TK', '32ft Tanker Truck', 'Tanker', 32.0,
 'Multi-axle', 25.0, 20.0, 1800, 51.0, 'Top-loading',
 FALSE, TRUE, 'Oil, Milk, Chemicals, LPG, Industrial liquids',
 'Diesel', TRUE, 'Specialized', 'Oil depots, Chemical plants, Dairy facilities',
 42.00, 2.8, 2.4, NULL, 'Pressure relief valves, Emergency shutdown, GPS tracking',
 'Weekly inspection, Pressure testing, Valve maintenance',
 'RTO compliance, Hazmat permit, Tanker certification, Pressure vessel compliance',
 'Specialized', TRUE, 'Medium', 'Year-round', 'Requires special permits and training',
 'system', 'system'),

-- Box Truck
('EQP-24BX', '24ft Box Truck', 'Box Truck', 24.0,
 'Single', 14.0, 9.0, 1000, 28.3, 'Rear-opening',
 FALSE, FALSE, 'Electronics, Fragile items, Small packages, Documents',
 'Diesel', TRUE, 'Ground-level', 'Last-mile delivery, Urban routes',
 26.00, 2.4, 2.2, NULL, 'Box locks, Cushioning, GPS tracking',
 'Monthly inspection, Regular cleaning', 'RTO compliance, Urban transport permit',
 'Basic', TRUE, 'Medium', 'Year-round', 'Suitable for urban and last-mile delivery',
 'system', 'system'),

-- 22ft Container Truck
('EQP-22CNT', '22ft Container Truck', 'Container', 22.0,
 'Single', 14.0, 9.0, 900, 25.5, 'Rear-opening',
 FALSE, FALSE, 'Small shipments, Regional transport, E-commerce',
 'Diesel', TRUE, 'Elevated', 'Regional routes, E-commerce hubs',
 27.00, 2.4, 2.2, NULL, 'Container locks, Seal verification',
 'Monthly inspection, Oil change every 5000 km', 'RTO compliance, Pollution certificate',
 'Basic', TRUE, 'Medium', 'Year-round', 'Good for regional and smaller shipments',
 'system', 'system'),

-- Specialized Heavy Equipment
('EQP-40SP', '40ft Specialized Heavy Equipment Trailer', 'Specialized', 40.0,
 'Tri-axle', 35.0, 30.0, 3000, 85.0, 'Multiple',
 FALSE, TRUE, 'Heavy machinery, Industrial equipment, Specialized cargo',
 'Diesel', TRUE, 'Specialized', 'Heavy industry routes, Port operations',
 45.00, 3.0, 3.0, NULL, 'Multiple tie-down points, Load monitoring, GPS tracking',
 'Weekly inspection, Load monitoring system maintenance',
 'RTO compliance, Specialized transport permit, Load monitoring compliance',
 'Specialized', TRUE, 'Low', 'Year-round', 'For extremely heavy and specialized cargo',
 'system', 'system'),

-- Electric Container Truck
('EQP-32EL', '32ft Electric Container Truck', 'Container', 32.0,
 'Multi-axle', 20.0, 15.0, 1700, 48.1, 'Rear-opening',
 FALSE, FALSE, 'Green logistics, Urban delivery, Eco-friendly cargo',
 'Electric', TRUE, 'Elevated', 'Green corridors, Urban routes, Eco-friendly zones',
 32.00, 2.6, 2.4, NULL, 'Container locks, Battery monitoring, GPS tracking',
 'Weekly inspection, Battery maintenance, Charging system check',
 'RTO compliance, Electric vehicle certification, Battery safety compliance',
 'Comprehensive', TRUE, 'Medium', 'Year-round', 'Environmentally friendly option',
 'system', 'system'),

-- CNG Container Truck
('EQP-32CNG', '32ft CNG Container Truck', 'Container', 32.0,
 'Multi-axle', 19.0, 14.0, 1600, 45.3, 'Rear-opening',
 FALSE, FALSE, 'General cargo, Regional transport, Eco-friendly options',
 'CNG', TRUE, 'Elevated', 'CNG corridor routes, Regional transport',
 29.50, 2.6, 2.4, NULL, 'Container locks, CNG monitoring, GPS tracking',
 'Monthly inspection, CNG system maintenance, Regular cleaning',
 'RTO compliance, CNG vehicle certification, Gas safety compliance',
 'Comprehensive', TRUE, 'Medium', 'Year-round', 'Lower emissions, cost-effective fuel',
 'system', 'system'),

-- High Security Container Truck
('EQP-32HS', '32ft High Security Container Truck', 'Container', 32.0,
 'Multi-axle', 21.0, 16.0, 1800, 51.0, 'Rear-opening',
 FALSE, FALSE, 'High-value cargo, Electronics, Pharmaceuticals, Precious metals',
 'Diesel', TRUE, 'Elevated', 'High-value cargo routes, Pharma corridors',
 40.00, 2.6, 2.4, NULL, 'Advanced locks, Security seals, GPS tracking, Alarm system',
 'Weekly inspection, Security system maintenance, Regular cleaning',
 'RTO compliance, Security certification, High-value cargo permit',
 'Specialized', TRUE, 'High', 'Year-round', 'Enhanced security for valuable cargo',
 'system', 'system'),

-- Multi-Modal Container Truck
('EQP-32MM', '32ft Multi-Modal Container Truck', 'Container', 32.0,
 'Multi-axle', 21.0, 16.0, 1800, 51.0, 'Rear-opening',
 FALSE, FALSE, 'Export cargo, Multi-modal transport, International shipments',
 'Diesel', TRUE, 'Elevated', 'Port routes, Export corridors, Multi-modal hubs',
 33.00, 2.6, 2.4, NULL, 'Container locks, ISO compliance, GPS tracking',
 'Monthly inspection, ISO compliance check, Regular cleaning',
 'RTO compliance, ISO certification, Export compliance',
 'Comprehensive', TRUE, 'Medium', 'Year-round', 'Compatible with rail and sea transport',
 'system', 'system'),

-- Express Delivery Container Truck
('EQP-32EX', '32ft Express Delivery Container Truck', 'Container', 32.0,
 'Multi-axle', 20.0, 15.0, 1700, 48.1, 'Rear-opening',
 FALSE, FALSE, 'Express cargo, Time-critical shipments, Premium services',
 'Diesel', TRUE, 'Elevated', 'Express corridors, Time-critical routes',
 36.00, 2.6, 2.4, NULL, 'Container locks, GPS tracking, Real-time monitoring',
 'Weekly inspection, Express service maintenance, Regular cleaning',
 'RTO compliance, Express service certification',
 'Comprehensive', TRUE, 'High', 'Year-round', 'Optimized for fast delivery services',
 'system', 'system');

-- Display the created table structure
DESCRIBE equipment_types_master;

-- Display sample data
SELECT 
    equipment_id, 
    equipment_name, 
    vehicle_body_type, 
    vehicle_length_ft,
    payload_capacity_tons,
    temperature_controlled,
    hazmat_certified,
    active
FROM equipment_types_master 
LIMIT 10; 