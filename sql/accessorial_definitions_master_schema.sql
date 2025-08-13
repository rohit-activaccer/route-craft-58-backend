-- Accessorial Definitions Master Table
-- This table defines various additional charges and fees that can be applied during transport operations

-- Drop table if exists (for development/testing)
DROP TABLE IF EXISTS accessorial_definitions_master;

-- Create the main table
CREATE TABLE accessorial_definitions_master (
    accessorial_id VARCHAR(20) PRIMARY KEY COMMENT 'Unique identifier for the accessorial charge',
    accessorial_name VARCHAR(100) NOT NULL COMMENT 'Name of the accessorial charge',
    description TEXT COMMENT 'Detailed explanation of when and how the charge applies',
    applies_to ENUM('Pickup', 'Delivery', 'In-Transit', 'General') NOT NULL COMMENT 'When the charge applies',
    trigger_condition TEXT NOT NULL COMMENT 'Specific condition that triggers this charge',
    rate_type ENUM('Flat Fee', 'Per Hour', 'Per KM', 'Per Attempt', 'Per Pallet', 'Per MT', 'Percentage') NOT NULL COMMENT 'How the rate is calculated',
    rate_value DECIMAL(10,2) NOT NULL COMMENT 'Numeric value for the rate',
    unit ENUM('Hours', 'KM', 'Pallet', 'Stop', 'Attempt', 'MT', 'Percentage', 'Flat') NOT NULL COMMENT 'Unit of measurement for the rate',
    taxable BOOLEAN DEFAULT FALSE COMMENT 'Whether GST or other taxes apply',
    included_in_base BOOLEAN DEFAULT FALSE COMMENT 'Whether charge is bundled in base rate',
    invoice_code VARCHAR(50) COMMENT 'Code for invoice/GL mapping systems',
    applicable_equipment_types TEXT COMMENT 'Equipment types this charge applies to (comma-separated)',
    carrier_editable_in_bid BOOLEAN DEFAULT TRUE COMMENT 'Whether carriers can propose their own rates',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Whether this accessorial is currently active',
    min_charge DECIMAL(10,2) COMMENT 'Minimum charge amount if applicable',
    max_charge DECIMAL(10,2) COMMENT 'Maximum charge amount if applicable',
    free_time_hours INT DEFAULT 0 COMMENT 'Free time before charge applies (for time-based charges)',
    applicable_regions TEXT COMMENT 'Regions where this charge applies (comma-separated)',
    applicable_lanes TEXT COMMENT 'Specific lanes where this charge applies (comma-separated)',
    seasonal_applicability TEXT COMMENT 'Seasonal restrictions or variations',
    documentation_required BOOLEAN DEFAULT FALSE COMMENT 'Whether supporting documents are required',
    approval_required BOOLEAN DEFAULT FALSE COMMENT 'Whether manager approval is needed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record update timestamp',
    created_by VARCHAR(50) DEFAULT 'system' COMMENT 'User who created the record',
    updated_by VARCHAR(50) DEFAULT 'system' COMMENT 'User who last updated the record',
    remarks TEXT COMMENT 'Additional notes or exceptions'
);

-- Create indexes for better performance
CREATE INDEX idx_accessorial_name ON accessorial_definitions_master(accessorial_name);
CREATE INDEX idx_applies_to ON accessorial_definitions_master(applies_to);
CREATE INDEX idx_rate_type ON accessorial_definitions_master(rate_type);
CREATE INDEX idx_is_active ON accessorial_definitions_master(is_active);
CREATE INDEX idx_applicable_equipment ON accessorial_definitions_master(applicable_equipment_types(100));

-- Create views for common queries

-- View 1: Active Accessorial Charges Overview
CREATE VIEW active_accessorial_overview AS
SELECT 
    accessorial_id,
    accessorial_name,
    applies_to,
    rate_type,
    rate_value,
    unit,
    taxable,
    included_in_base,
    is_active
FROM accessorial_definitions_master
WHERE is_active = TRUE
ORDER BY applies_to, accessorial_name;

-- View 2: Time-Based Accessorial Charges
CREATE VIEW time_based_accessorials AS
SELECT 
    accessorial_id,
    accessorial_name,
    trigger_condition,
    rate_value,
    unit,
    free_time_hours,
    applicable_equipment_types
FROM accessorial_definitions_master
WHERE rate_type IN ('Per Hour', 'Per Attempt') AND is_active = TRUE
ORDER BY rate_value DESC;

-- View 3: Equipment-Specific Accessorials
CREATE VIEW equipment_specific_accessorials AS
SELECT 
    accessorial_id,
    accessorial_name,
    applicable_equipment_types,
    rate_type,
    rate_value,
    unit,
    applies_to
FROM accessorial_definitions_master
WHERE applicable_equipment_types IS NOT NULL 
    AND applicable_equipment_types != '' 
    AND is_active = TRUE
ORDER BY applicable_equipment_types, accessorial_name;

-- View 4: High-Value Accessorials
CREATE VIEW high_value_accessorials AS
SELECT 
    accessorial_id,
    accessorial_name,
    rate_value,
    unit,
    rate_type,
    applies_to,
    trigger_condition
FROM accessorial_definitions_master
WHERE rate_value > 1000 AND is_active = TRUE
ORDER BY rate_value DESC;

-- View 5: Regional Accessorials
CREATE VIEW regional_accessorials AS
SELECT 
    accessorial_id,
    accessorial_name,
    applicable_regions,
    rate_value,
    unit,
    applies_to,
    is_active
FROM accessorial_definitions_master
WHERE applicable_regions IS NOT NULL 
    AND applicable_regions != '' 
    AND is_active = TRUE
ORDER BY applicable_regions, accessorial_name;

-- Insert sample data for Indian TL logistics accessorial charges
INSERT INTO accessorial_definitions_master (
    accessorial_id, accessorial_name, description, applies_to, trigger_condition, 
    rate_type, rate_value, unit, taxable, included_in_base, invoice_code, 
    applicable_equipment_types, carrier_editable_in_bid, min_charge, max_charge, 
    free_time_hours, applicable_regions, seasonal_applicability, 
    documentation_required, approval_required, remarks
) VALUES
-- Detention Charges
('ACC-DET-001', 'Detention - Loading Site', 'Charges for waiting time at pickup location beyond free time', 'Pickup', 'After 2 hours of free time', 'Per Hour', 400.00, 'Hours', TRUE, FALSE, 'DET-LOAD', 'All Equipment', TRUE, 200.00, 2000.00, 2, 'All India', 'Year-round', FALSE, FALSE, 'Standard detention charge for loading delays'),

('ACC-DET-002', 'Detention - Delivery Site', 'Charges for waiting time at delivery location beyond free time', 'Delivery', 'After 2 hours of free time', 'Per Hour', 400.00, 'Hours', TRUE, FALSE, 'DET-DEL', 'All Equipment', TRUE, 200.00, 2000.00, 2, 'Metro Cities', 'Year-round', FALSE, FALSE, 'Higher rates for metro zones'),

('ACC-DET-003', 'Detention - Rural Areas', 'Detention charges for rural delivery locations', 'Delivery', 'After 3 hours of free time', 'Per Hour', 300.00, 'Hours', TRUE, FALSE, 'DET-RURAL', 'All Equipment', TRUE, 150.00, 1500.00, 3, 'Rural Areas', 'Year-round', FALSE, FALSE, 'Extended free time for rural locations'),

-- Multi-stop Charges
('ACC-MST-001', 'Multi-Stop Fee - 2 Stops', 'Additional charge for delivery at multiple locations', 'Delivery', 'More than 1 delivery stop', 'Flat Fee', 800.00, 'Flat', TRUE, FALSE, 'MST-2', 'Container, Open Body', TRUE, 800.00, 800.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Standard multi-stop charge'),

('ACC-MST-002', 'Multi-Stop Fee - 3+ Stops', 'Additional charge for 3 or more delivery stops', 'Delivery', '3 or more delivery stops', 'Flat Fee', 1200.00, 'Flat', TRUE, FALSE, 'MST-3', 'Container, Open Body', TRUE, 1200.00, 1200.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Higher charge for multiple stops'),

-- Loading/Unloading Charges
('ACC-LUL-001', 'Driver Assist Loading', 'When driver helps with loading operations', 'Pickup', 'Driver assistance required for loading', 'Per MT', 150.00, 'MT', TRUE, FALSE, 'LUL-DRIVER', 'All Equipment', FALSE, 100.00, 1000.00, 0, 'All India', 'Year-round', TRUE, FALSE, 'Requires loading supervisor signature'),

('ACC-LUL-002', 'Driver Assist Unloading', 'When driver helps with unloading operations', 'Delivery', 'Driver assistance required for unloading', 'Per MT', 150.00, 'MT', TRUE, FALSE, 'LUL-DRIVER', 'All Equipment', FALSE, 100.00, 1000.00, 0, 'All India', 'Year-round', TRUE, FALSE, 'Requires delivery supervisor signature'),

-- Specialized Services
('ACC-ESC-001', 'Escort Vehicle Fee', 'Escort vehicle for high-value or ODC cargo', 'In-Transit', 'Escort vehicle required by regulations', 'Per KM', 25.00, 'KM', TRUE, FALSE, 'ESC-VEHICLE', 'Flatbed, ODC', FALSE, 500.00, 5000.00, 0, 'All India', 'Year-round', TRUE, TRUE, 'Requires police permission and route approval'),

('ACC-ESC-002', 'Pilot Vehicle Fee', 'Pilot vehicle for over-dimensional cargo', 'In-Transit', 'Pilot vehicle required for ODC', 'Per KM', 20.00, 'KM', TRUE, FALSE, 'ESC-PILOT', 'Flatbed, ODC', FALSE, 400.00, 4000.00, 0, 'All India', 'Year-round', TRUE, TRUE, 'For cargo exceeding standard dimensions'),

-- Time-Based Charges
('ACC-NGT-001', 'Night Delivery Charges', 'Additional charge for delivery outside business hours', 'Delivery', 'Delivery between 8 PM and 6 AM', 'Flat Fee', 500.00, 'Flat', TRUE, FALSE, 'NGT-DEL', 'All Equipment', TRUE, 500.00, 500.00, 0, 'Metro Cities', 'Year-round', FALSE, FALSE, 'Night delivery surcharge'),

('ACC-NGT-002', 'Weekend Delivery', 'Additional charge for Saturday/Sunday delivery', 'Delivery', 'Delivery on weekends or holidays', 'Flat Fee', 800.00, 'Flat', TRUE, FALSE, 'NGT-WEEKEND', 'All Equipment', TRUE, 800.00, 800.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Weekend and holiday surcharge'),

-- Fuel and Distance Related
('ACC-FSC-001', 'Fuel Surcharge - High', 'Fuel surcharge when diesel prices exceed threshold', 'General', 'Diesel price > ₹100/liter', 'Percentage', 8.00, 'Percentage', TRUE, FALSE, 'FSC-HIGH', 'All Equipment', FALSE, 0.00, 0.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Variable based on diesel price index'),

('ACC-FSC-002', 'Fuel Surcharge - Medium', 'Fuel surcharge for moderate diesel price increases', 'General', 'Diesel price ₹80-100/liter', 'Percentage', 5.00, 'Percentage', TRUE, FALSE, 'FSC-MED', 'All Equipment', FALSE, 0.00, 0.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Standard fuel surcharge'),

-- Special Equipment Charges
('ACC-REEF-001', 'Reefer Monitoring Fee', 'Additional charge for temperature-controlled transport', 'In-Transit', 'Temperature monitoring required', 'Per Day', 300.00, 'Hours', TRUE, FALSE, 'REEF-MON', 'Reefer', FALSE, 300.00, 300.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Daily monitoring charge for reefer'),

('ACC-REEF-002', 'Reefer Pre-cooling', 'Pre-cooling charge for temperature-sensitive cargo', 'Pickup', 'Pre-cooling required before loading', 'Per Hour', 200.00, 'Hours', TRUE, FALSE, 'REEF-PRECOOL', 'Reefer', FALSE, 200.00, 1000.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Pre-cooling setup charge'),

-- Documentation and Compliance
('ACC-DOC-001', 'Weighbridge Fee', 'Charges for mandatory weighing at checkpoints', 'In-Transit', 'Weighing required at checkpoints', 'Per Stop', 150.00, 'Stop', TRUE, FALSE, 'DOC-WEIGH', 'All Equipment', FALSE, 150.00, 150.00, 0, 'All India', 'Year-round', TRUE, FALSE, 'Standard weighbridge charge'),

('ACC-DOC-002', 'Reattempt Fee', 'Charge for unsuccessful delivery attempts', 'Delivery', 'Delivery attempt unsuccessful', 'Per Attempt', 400.00, 'Attempt', TRUE, FALSE, 'DOC-REATT', 'All Equipment', TRUE, 400.00, 400.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Charge for redelivery attempts'),

-- Regional and Seasonal Charges
('ACC-MON-001', 'Monsoon Surcharge', 'Additional charge during monsoon season', 'General', 'July to September monsoon period', 'Percentage', 5.00, 'Percentage', TRUE, FALSE, 'MON-SURGE', 'All Equipment', FALSE, 0.00, 0.00, 0, 'Coastal, Hilly Regions', 'Monsoon Season', FALSE, FALSE, 'Monsoon season surcharge for affected regions'),

('ACC-FEST-001', 'Festive Season Surcharge', 'Additional charge during peak festive periods', 'General', 'October-November festive season', 'Percentage', 8.00, 'Percentage', TRUE, FALSE, 'FEST-SURGE', 'All Equipment', FALSE, 0.00, 0.00, 0, 'All India', 'Festive Season', FALSE, FALSE, 'Festive season demand surge charge'),

-- Special Handling Charges
('ACC-HAZ-001', 'Hazmat Handling Fee', 'Additional charge for hazardous material transport', 'General', 'Hazmat cargo transport', 'Flat Fee', 1500.00, 'Flat', TRUE, FALSE, 'HAZ-HANDLE', 'Tanker, Specialized', FALSE, 1500.00, 1500.00, 0, 'All India', 'Year-round', TRUE, TRUE, 'Requires special permits and handling'),

('ACC-ODC-001', 'Over-Dimensional Cargo Fee', 'Additional charge for oversized cargo', 'General', 'Cargo exceeds standard dimensions', 'Flat Fee', 2000.00, 'Flat', TRUE, FALSE, 'ODC-CARGO', 'Flatbed, Specialized', FALSE, 2000.00, 2000.00, 0, 'All India', 'Year-round', TRUE, TRUE, 'For cargo requiring special permits'),

-- Toll and Route Charges
('ACC-TOLL-001', 'Toll Charges - Expressway', 'Toll charges for expressway routes', 'In-Transit', 'Route includes expressway sections', 'Per Trip', 800.00, 'Flat', TRUE, FALSE, 'TOLL-EXP', 'All Equipment', FALSE, 800.00, 800.00, 0, 'Expressway Routes', 'Year-round', FALSE, FALSE, 'Standard expressway toll charge'),

('ACC-TOLL-002', 'Toll Charges - State Highways', 'Toll charges for state highway routes', 'In-Transit', 'Route includes state highway sections', 'Per Trip', 400.00, 'Flat', TRUE, FALSE, 'TOLL-SH', 'All Equipment', FALSE, 400.00, 400.00, 0, 'State Highway Routes', 'Year-round', FALSE, FALSE, 'Standard state highway toll charge'),

-- Emergency and Special Services
('ACC-EMG-001', 'Emergency Delivery Fee', 'Urgent delivery outside normal service', 'Delivery', 'Emergency delivery requested', 'Flat Fee', 1000.00, 'Flat', TRUE, FALSE, 'EMG-DEL', 'All Equipment', FALSE, 1000.00, 1000.00, 0, 'All India', 'Year-round', TRUE, TRUE, 'Requires management approval'),

('ACC-EMG-002', 'Same Day Delivery', 'Same day delivery service', 'Delivery', 'Same day delivery requested', 'Flat Fee', 1500.00, 'Flat', TRUE, FALSE, 'EMG-SAME', 'All Equipment', FALSE, 1500.00, 1500.00, 0, 'Metro Cities', 'Year-round', TRUE, TRUE, 'Limited to metro city routes only'),

-- Insurance and Security
('ACC-INS-001', 'High-Value Cargo Insurance', 'Additional insurance for high-value shipments', 'General', 'Cargo value exceeds ₹10 lakhs', 'Percentage', 2.00, 'Percentage', TRUE, FALSE, 'INS-HIGH', 'All Equipment', FALSE, 0.00, 0.00, 0, 'All India', 'Year-round', TRUE, TRUE, 'Additional insurance coverage required'),

('ACC-INS-002', 'Armed Guard Escort', 'Armed security escort for valuable cargo', 'In-Transit', 'Armed escort required by shipper', 'Per Day', 3000.00, 'Hours', TRUE, FALSE, 'INS-ARMED', 'All Equipment', FALSE, 3000.00, 3000.00, 0, 'All India', 'Year-round', TRUE, TRUE, 'Requires special security permits'),

-- Technology and Tracking
('ACC-TECH-001', 'GPS Tracking Fee', 'Additional charge for GPS tracking service', 'In-Transit', 'GPS tracking requested', 'Per Day', 100.00, 'Hours', TRUE, FALSE, 'TECH-GPS', 'All Equipment', FALSE, 100.00, 100.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Daily GPS tracking charge'),

('ACC-TECH-002', 'Real-time Updates', 'Real-time status updates and notifications', 'General', 'Real-time updates requested', 'Flat Fee', 200.00, 'Flat', TRUE, FALSE, 'TECH-REALTIME', 'All Equipment', FALSE, 200.00, 200.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Real-time tracking and notifications'),

-- Documentation and Reporting
('ACC-REP-001', 'Detailed Reporting', 'Comprehensive delivery reports and analytics', 'General', 'Detailed reporting requested', 'Flat Fee', 300.00, 'Flat', TRUE, FALSE, 'REP-DETAIL', 'All Equipment', FALSE, 300.00, 300.00, 0, 'All India', 'Year-round', FALSE, FALSE, 'Detailed delivery reports and analytics'),

('ACC-REP-002', 'Custom Documentation', 'Custom documentation and certificates', 'General', 'Custom documentation required', 'Flat Fee', 500.00, 'Flat', TRUE, FALSE, 'REP-CUSTOM', 'All Equipment', FALSE, 500.00, 500.00, 0, 'All India', 'Year-round', TRUE, FALSE, 'Custom documentation and certificates');

-- Verify the data insertion
SELECT COUNT(*) as total_accessorials FROM accessorial_definitions_master;
SELECT accessorial_name, rate_type, rate_value, unit FROM accessorial_definitions_master LIMIT 10; 