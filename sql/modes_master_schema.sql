-- =====================================================
-- Modes Master Table Schema
-- RouteCraft Transport Procurement System
-- =====================================================

-- Drop table if exists (for development/testing)
DROP TABLE IF EXISTS modes_master;

-- Create Modes Master table
CREATE TABLE modes_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Core Mode Information
    mode_id VARCHAR(20) NOT NULL UNIQUE COMMENT 'Unique identifier (e.g., MODE-TL-01)',
    mode_name VARCHAR(100) NOT NULL COMMENT 'Descriptive name (e.g., Full Truckload, Rail, Air, LTL)',
    mode_type ENUM('TL', 'LTL', 'Rail', 'Air', 'Multimodal', 'Dedicated', 'Containerized', 'Specialized') NOT NULL COMMENT 'Transportation mode classification',
    description TEXT COMMENT 'Short explanation of the mode and its use cases',
    
    -- Operational Characteristics
    transit_time_days DECIMAL(4,1) COMMENT 'Average days required for movement',
    typical_use_cases TEXT COMMENT 'E.g., High-volume outbound, regional shipments',
    cost_efficiency_level ENUM('High', 'Medium', 'Low') COMMENT 'Cost efficiency for planning tools',
    speed_level ENUM('Fast', 'Moderate', 'Slow') COMMENT 'Speed classification',
    
    -- Equipment and Requirements
    suitable_commodities TEXT COMMENT 'Free text or linked to commodity master',
    equipment_type_required VARCHAR(100) COMMENT 'E.g., 32ft MXL, Reefer, ISO container',
    
    -- Operational Capabilities
    carrier_pool_available ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Whether carrier options exist for this mode',
    supports_time_definite ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Whether fixed-time delivery can be promised',
    supports_multileg_planning ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Can be used in multi-leg routing setups',
    
    -- Advanced Parameters
    real_time_tracking_support ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Helps plan monitoring features',
    green_score_emission_class VARCHAR(50) COMMENT 'For ESG-compliant companies (e.g., Euro 6, Tier 4)',
    penalty_matrix_linked ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'If penalties differ by mode',
    contract_type_default ENUM('Spot', 'Rate Card', 'Tendered', 'Contract') COMMENT 'Default contract type',
    
    -- Status and Control
    active ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Whether it\'s currently in use',
    priority_level ENUM('High', 'Medium', 'Low') DEFAULT 'Medium' COMMENT 'Planning priority level',
    seasonal_availability ENUM('Year-round', 'Seasonal', 'Limited') DEFAULT 'Year-round' COMMENT 'Availability throughout the year',
    
    -- Business Rules
    minimum_volume_requirement DECIMAL(10,2) COMMENT 'Minimum volume in kg or pallets',
    maximum_volume_capacity DECIMAL(10,2) COMMENT 'Maximum volume capacity',
    weight_restrictions VARCHAR(100) COMMENT 'Weight limitations and restrictions',
    dimension_restrictions VARCHAR(100) COMMENT 'Size and dimension limitations',
    
    -- Cost and Pricing
    base_cost_multiplier DECIMAL(4,2) DEFAULT 1.00 COMMENT 'Cost multiplier compared to standard TL',
    fuel_surcharge_applicable ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Whether fuel surcharge applies',
    detention_charges_applicable ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Whether detention charges apply',
    
    -- Compliance and Documentation
    customs_clearance_required ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Whether customs clearance is needed',
    special_permits_required TEXT COMMENT 'Any special permits or licenses needed',
    insurance_requirements TEXT COMMENT 'Insurance coverage requirements',
    
    -- Performance Metrics
    on_time_performance_target DECIMAL(4,1) COMMENT 'Target on-time performance percentage',
    damage_claim_rate DECIMAL(4,2) COMMENT 'Historical damage claim rate percentage',
    
    -- Additional Information
    remarks TEXT COMMENT 'Any restrictions, seasonal dependencies, etc.',
    
    -- Audit Fields
    created_by VARCHAR(100) DEFAULT 'System',
    updated_by VARCHAR(100) DEFAULT 'System',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for Performance
    INDEX idx_mode_id (mode_id),
    INDEX idx_mode_type (mode_type),
    INDEX idx_active (active),
    INDEX idx_cost_efficiency (cost_efficiency_level),
    INDEX idx_speed_level (speed_level),
    INDEX idx_transit_time (transit_time_days)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for transportation modes and their characteristics';

-- Create Views for Common Queries

-- 1. Active Modes Summary View
CREATE OR REPLACE VIEW active_modes_summary AS
SELECT 
    mode_type,
    COUNT(*) as total_modes,
    COUNT(CASE WHEN supports_time_definite = 'Yes' THEN 1 END) as time_definite_modes,
    COUNT(CASE WHEN supports_multileg_planning = 'Yes' THEN 1 END) as multileg_modes,
    AVG(transit_time_days) as avg_transit_time,
    COUNT(CASE WHEN cost_efficiency_level = 'High' THEN 1 END) as high_efficiency_modes
FROM modes_master 
WHERE active = 'Yes'
GROUP BY mode_type
ORDER BY mode_type;

-- 2. Mode Capabilities View
CREATE OR REPLACE VIEW mode_capabilities AS
SELECT 
    mode_id,
    mode_name,
    mode_type,
    transit_time_days,
    cost_efficiency_level,
    speed_level,
    supports_time_definite,
    supports_multileg_planning,
    real_time_tracking_support,
    base_cost_multiplier
FROM modes_master 
WHERE active = 'Yes'
ORDER BY mode_type, transit_time_days;

-- 3. Cost-Effective Modes View
CREATE OR REPLACE VIEW cost_effective_modes AS
SELECT 
    mode_id,
    mode_name,
    mode_type,
    transit_time_days,
    cost_efficiency_level,
    base_cost_multiplier,
    suitable_commodities
FROM modes_master 
WHERE active = 'Yes' 
AND cost_efficiency_level IN ('High', 'Medium')
ORDER BY base_cost_multiplier, transit_time_days;

-- 4. Time-Critical Modes View
CREATE OR REPLACE VIEW time_critical_modes AS
SELECT 
    mode_id,
    mode_name,
    mode_type,
    transit_time_days,
    speed_level,
    supports_time_definite,
    on_time_performance_target,
    base_cost_multiplier
FROM modes_master 
WHERE active = 'Yes' 
AND (speed_level = 'Fast' OR transit_time_days <= 2.0)
ORDER BY transit_time_days, base_cost_multiplier;

-- 5. Specialized Modes View
CREATE OR REPLACE VIEW specialized_modes AS
SELECT 
    mode_id,
    mode_name,
    mode_type,
    suitable_commodities,
    equipment_type_required,
    special_permits_required,
    insurance_requirements,
    base_cost_multiplier
FROM modes_master 
WHERE active = 'Yes' 
AND mode_type IN ('Specialized', 'Containerized', 'Dedicated')
ORDER BY mode_name;

-- Insert sample data
INSERT INTO modes_master (
    mode_id, mode_name, mode_type, description, transit_time_days, 
    typical_use_cases, cost_efficiency_level, speed_level, suitable_commodities,
    equipment_type_required, carrier_pool_available, supports_time_definite,
    supports_multileg_planning, real_time_tracking_support, green_score_emission_class,
    penalty_matrix_linked, contract_type_default, active, priority_level,
    seasonal_availability, minimum_volume_requirement, maximum_volume_capacity,
    weight_restrictions, dimension_restrictions, base_cost_multiplier,
    fuel_surcharge_applicable, detention_charges_applicable, customs_clearance_required,
    special_permits_required, insurance_requirements, on_time_performance_target,
    damage_claim_rate, remarks
) VALUES
-- Full Truckload (TL) Modes
('MODE-TL-01', 'Full Truckload Standard', 'TL', 'Standard full truckload service for general cargo', 2.5,
 'High-volume outbound, long-haul shipments, general freight', 'High', 'Moderate', 'General cargo, palletized goods, bulk materials',
 '53ft Dry Van, 48ft Flatbed', 'Yes', 'Yes', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Rate Card', 'Yes', 'High', 'Year-round', 10000.00, 45000.00,
 'Up to 45,000 lbs', '53ft x 8.5ft x 8.5ft', 1.00, 'Yes', 'Yes', 'No',
 'CDL required, DOT compliance', 'Minimum $1M liability coverage', 95.0, 0.5,
 'Most cost-effective for full loads, excellent carrier availability'),

('MODE-TL-02', 'Full Truckload Express', 'TL', 'Fast full truckload service for time-critical shipments', 1.5,
 'Time-critical shipments, high-value goods, urgent deliveries', 'Medium', 'Fast', 'High-value electronics, pharmaceuticals, time-sensitive materials',
 '53ft Dry Van, 48ft Flatbed', 'Yes', 'Yes', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Tendered', 'Yes', 'High', 'Year-round', 10000.00, 45000.00,
 'Up to 45,000 lbs', '53ft x 8.5ft x 8.5ft', 1.25, 'Yes', 'Yes', 'No',
 'CDL required, DOT compliance', 'Minimum $2M liability coverage', 98.0, 0.3,
 'Premium service with guaranteed delivery times, higher cost'),

('MODE-TL-03', 'Full Truckload Dedicated', 'Dedicated', 'Dedicated truck service with guaranteed capacity', 3.0,
 'High-volume customers, guaranteed capacity, consistent service', 'Medium', 'Moderate', 'Regular shipments, contract customers, high-volume lanes',
 '53ft Dry Van, 48ft Flatbed', 'Yes', 'Yes', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Contract', 'Yes', 'High', 'Year-round', 15000.00, 45000.00,
 'Up to 45,000 lbs', '53ft x 8.5ft x 8.5ft', 1.15, 'Yes', 'Yes', 'No',
 'CDL required, DOT compliance', 'Minimum $1.5M liability coverage', 96.0, 0.4,
 'Guaranteed capacity with consistent service, contract-based pricing'),

-- Less Than Truckload (LTL) Modes
('MODE-LTL-01', 'Less-Than-Truckload Standard', 'LTL', 'Standard LTL service for smaller shipments', 4.0,
 'Small loads, cost efficiency, regional shipments', 'High', 'Slow', 'Small packages, partial pallets, retail goods',
 'Various LTL equipment', 'Yes', 'No', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Rate Card', 'Yes', 'Medium', 'Year-round', 100.00, 10000.00,
 'Up to 10,000 lbs', 'Various sizes', 0.85, 'Yes', 'Yes', 'No',
 'LTL carrier compliance', 'Carrier-provided coverage', 90.0, 1.2,
 'Cost-effective for small loads, multiple stops, longer transit times'),

('MODE-LTL-02', 'Less-Than-Truckload Express', 'LTL', 'Fast LTL service for time-sensitive small shipments', 2.5,
 'Time-sensitive small shipments, high-value goods', 'Medium', 'Moderate', 'High-value small items, urgent documents, samples',
 'Various LTL equipment', 'Yes', 'Yes', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Tendered', 'Yes', 'Medium', 'Year-round', 100.00, 10000.00,
 'Up to 10,000 lbs', 'Various sizes', 1.10, 'Yes', 'Yes', 'No',
 'LTL carrier compliance', 'Carrier-provided coverage', 95.0, 0.8,
 'Faster delivery for small loads, premium pricing'),

-- Rail and Intermodal Modes
('MODE-RAIL-01', 'Rail Freight Standard', 'Rail', 'Standard rail service for long-distance bulk shipments', 7.0,
 'Long-distance bulk shipments, cost optimization, heavy materials', 'High', 'Slow', 'Bulk materials, heavy machinery, industrial goods',
 'Rail cars, containers', 'Yes', 'No', 'Yes', 'Yes', 'Low emissions',
 'Yes', 'Contract', 'Yes', 'Medium', 'Year-round', 50000.00, 200000.00,
 'Up to 200,000 lbs', 'Various rail car sizes', 0.70, 'No', 'Yes', 'No',
 'Rail safety compliance', 'Rail carrier coverage', 85.0, 0.8,
 'Most cost-effective for long distances, slower transit times'),

('MODE-INT-01', 'Rail + Truck Intermodal', 'Multimodal', 'Combined rail and truck service for optimal cost and speed', 5.0,
 'Long-distance with cost savings, time-sensitive bulk shipments', 'High', 'Moderate', 'Bulk materials, containers, long-distance goods',
 'Rail cars, containers, trucks', 'Yes', 'Yes', 'Yes', 'Yes', 'Low emissions',
 'Yes', 'Contract', 'Yes', 'High', 'Year-round', 20000.00, 100000.00,
 'Up to 100,000 lbs', 'Container dimensions', 0.80, 'Yes', 'Yes', 'No',
 'Intermodal compliance, CDL required', 'Combined coverage', 90.0, 0.6,
 'Optimal balance of cost and speed, container-based'),

-- Air Freight Modes
('MODE-AIR-01', 'Air Freight Express', 'Air', 'Fastest air freight service for urgent shipments', 1.0,
 'High-value urgent goods, time-critical shipments, international', 'Low', 'Fast', 'High-value electronics, pharmaceuticals, documents',
 'Cargo aircraft, passenger aircraft', 'Yes', 'Yes', 'Yes', 'Yes', 'High emissions',
 'Yes', 'Tendered', 'Yes', 'High', 'Year-round', 1.00, 1000.00,
 'Up to 1,000 lbs', 'Various aircraft capacities', 3.50, 'No', 'Yes', 'Yes',
 'Air freight compliance, customs clearance', 'Air freight coverage', 99.0, 0.2,
 'Fastest delivery option, highest cost, limited capacity'),

('MODE-AIR-02', 'Air Freight Economy', 'Air', 'Economy air freight for cost-conscious urgent shipments', 2.0,
 'Urgent shipments with cost consideration, international trade', 'Medium', 'Fast', 'Urgent goods, international shipments, time-sensitive',
 'Cargo aircraft, passenger aircraft', 'Yes', 'No', 'Yes', 'Yes', 'High emissions',
 'Yes', 'Rate Card', 'Yes', 'Medium', 'Year-round', 1.00, 1000.00,
 'Up to 1,000 lbs', 'Various aircraft capacities', 2.50, 'No', 'Yes', 'Yes',
 'Air freight compliance, customs clearance', 'Air freight coverage', 95.0, 0.3,
 'Faster than surface, more affordable than express air'),

-- Specialized Modes
('MODE-SPEC-01', 'Temperature Controlled', 'Specialized', 'Refrigerated transport for temperature-sensitive goods', 3.0,
 'Pharmaceuticals, food products, chemicals, temperature-sensitive materials', 'Medium', 'Moderate', 'Perishable goods, pharmaceuticals, food',
 'Reefer trailers, temperature-controlled containers', 'Yes', 'Yes', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Contract', 'Yes', 'High', 'Year-round', 5000.00, 40000.00,
 'Up to 40,000 lbs', '53ft x 8.5ft x 8.5ft', 1.40, 'Yes', 'Yes', 'No',
 'Temperature control certification, food safety compliance', 'Temperature control coverage', 96.0, 0.4,
 'Specialized equipment, temperature monitoring, higher cost'),

('MODE-SPEC-02', 'Oversized Cargo', 'Specialized', 'Transport for oversized and heavy equipment', 5.0,
 'Heavy machinery, industrial equipment, oversized loads', 'Low', 'Slow', 'Construction equipment, industrial machinery, oversized loads',
 'Flatbed trailers, specialized equipment', 'Yes', 'No', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Contract', 'Yes', 'Medium', 'Year-round', 10000.00, 100000.00,
 'Up to 100,000 lbs', 'Various oversized dimensions', 2.00, 'Yes', 'Yes', 'No',
 'Oversized load permits, escort vehicles', 'Heavy haul coverage', 90.0, 1.0,
 'Specialized permits required, escort vehicles, highest cost'),

('MODE-SPEC-03', 'White Glove Service', 'Specialized', 'High-touch handling for valuable and fragile items', 3.5,
 'High-value electronics, art, antiques, fragile items', 'Low', 'Moderate', 'Electronics, artwork, antiques, fragile items',
 'Specialized equipment, climate control', 'Yes', 'Yes', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Tendered', 'Yes', 'High', 'Year-round', 1000.00, 20000.00,
 'Up to 20,000 lbs', 'Various specialized equipment', 2.50, 'Yes', 'Yes', 'No',
 'Specialized handling certification, insurance requirements', 'High-value coverage', 98.0, 0.2,
 'Specialized handling, climate control, highest service level'),

-- Containerized Modes
('MODE-CON-01', 'Containerized TL', 'Containerized', 'Container-based truckload service for export-bound goods', 2.5,
 'Export shipments, containerized goods, international trade', 'Medium', 'Moderate', 'Export goods, containerized cargo, international shipments',
 'ISO containers, specialized chassis', 'Yes', 'Yes', 'Yes', 'Yes', 'Euro 6',
 'Yes', 'Contract', 'Yes', 'High', 'Year-round', 5000.00, 30000.00,
 'Up to 30,000 lbs', '20ft/40ft container dimensions', 1.20, 'Yes', 'Yes', 'Yes',
 'Container handling certification, export compliance', 'Export coverage', 95.0, 0.5,
 'Container-based, export-ready, customs clearance support'),

('MODE-CON-02', 'Intermodal Container', 'Multimodal', 'Combined container and rail service for long-distance', 6.0,
 'Long-distance container shipments, cost optimization, international trade', 'High', 'Slow', 'Containerized goods, international shipments, bulk materials',
 'ISO containers, rail cars, trucks', 'Yes', 'No', 'Yes', 'Yes', 'Low emissions',
 'Yes', 'Contract', 'Yes', 'Medium', 'Year-round', 10000.00, 50000.00,
 'Up to 50,000 lbs', '20ft/40ft container dimensions', 0.90, 'Yes', 'Yes', 'Yes',
 'Intermodal compliance, export compliance', 'Combined coverage', 88.0, 0.6,
 'Container-based, rail optimization, customs clearance support');

-- Display the created table structure
DESCRIBE modes_master;

-- Show sample data
SELECT mode_id, mode_name, mode_type, transit_time_days, cost_efficiency_level, speed_level FROM modes_master ORDER BY mode_type, transit_time_days; 