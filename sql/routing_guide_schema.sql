-- Routing Guide Table Schema for TL Transportation Procurement
-- This table manages structured rules for carrier selection, fallback logic, and procurement automation

CREATE TABLE IF NOT EXISTS routing_guides (
    -- Primary Key
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Routing Guide Identification
    routing_guide_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique reference for the routing guide',
    
    -- Lane Information
    origin_location VARCHAR(255) NOT NULL COMMENT 'City, state, pin code, or facility ID',
    destination_location VARCHAR(255) NOT NULL COMMENT 'Same format as origin',
    lane_id VARCHAR(100) COMMENT 'Optional if standardized lane identification',
    
    -- Equipment and Service Specifications
    equipment_type VARCHAR(100) NOT NULL COMMENT 'E.g., 32ft SXL, reefer, flatbed, 20ft container',
    service_level ENUM('Standard', 'Express', 'Next-day', 'Same-day', 'Economy', 'Premium') DEFAULT 'Standard' NOT NULL,
    mode ENUM('TL', 'LTL', 'Rail', 'Intermodal', 'Partial') DEFAULT 'TL' NOT NULL,
    
    -- Primary Carrier (Default/Preferred)
    primary_carrier_id BIGINT COMMENT 'Reference to carriers table - default/preferred carrier',
    primary_carrier_name VARCHAR(255) COMMENT 'Name of primary carrier for quick reference',
    primary_carrier_rate DECIMAL(15,2) NOT NULL COMMENT 'Rate applicable for primary carrier',
    primary_carrier_rate_type ENUM('Per KM', 'Per Load', 'Slab-based', 'Per Ton', 'Fixed') NOT NULL,
    
    -- Backup Carriers (Fallback Options)
    backup_carrier_1_id BIGINT COMMENT 'Reference to carriers table - secondary carrier',
    backup_carrier_1_name VARCHAR(255) COMMENT 'Name of backup carrier 1',
    backup_carrier_1_rate DECIMAL(15,2) COMMENT 'Rate for backup carrier 1',
    backup_carrier_1_rate_type ENUM('Per KM', 'Per Load', 'Slab-based', 'Per Ton', 'Fixed'),
    
    backup_carrier_2_id BIGINT COMMENT 'Reference to carriers table - tertiary carrier',
    backup_carrier_2_name VARCHAR(255) COMMENT 'Name of backup carrier 2',
    backup_carrier_2_rate DECIMAL(15,2) COMMENT 'Rate for backup carrier 2',
    backup_carrier_2_rate_type ENUM('Per KM', 'Per Load', 'Slab-based', 'Per Ton', 'Fixed'),
    
    -- Tender Sequence and Logic
    tender_sequence VARCHAR(50) NOT NULL COMMENT 'Order in which carriers should be tendered (e.g., 1-2-3)',
    tender_lead_time_hours INT NOT NULL COMMENT 'How early carrier must be informed (in hours)',
    transit_sla_days INT COMMENT 'Agreed time to deliver (in days)',
    transit_sla_hours INT COMMENT 'Agreed time to deliver (in hours)',
    
    -- Rate and Cost Details
    fuel_surcharge_percentage DECIMAL(8,4) DEFAULT 0.0000 COMMENT 'Dynamic or fixed fuel surcharge value',
    fuel_surcharge_type ENUM('Percentage', 'Fixed', 'Indexed', 'None') DEFAULT 'None',
    accessorials_included ENUM('Yes', 'No', 'Partial') DEFAULT 'No' COMMENT 'For loading/unloading/etc.',
    accessorial_charges JSON COMMENT 'Detailed breakdown of accessorial charges as JSON',
    
    -- Load and Commitment Details
    load_commitment_type ENUM('Fixed', 'Variable', 'Spot', 'Guaranteed', 'Best-effort') DEFAULT 'Variable',
    load_volume_commitment INT COMMENT 'Volume guarantee or minimums in trips/tonnes',
    
    -- Validity Period
    valid_from DATE NOT NULL COMMENT 'Start of routing guide validity',
    valid_to DATE NOT NULL COMMENT 'End date of routing guide validity',
    
    -- Advanced Features
    tender_via_api BOOLEAN DEFAULT FALSE COMMENT 'Whether to tender via TMS API',
    load_type ENUM('Regular', 'High-value', 'Fragile', 'Hazardous', 'Temperature-controlled', 'Oversized') DEFAULT 'Regular',
    auto_tender_rule TEXT COMMENT 'e.g., tender to carrier X unless carrier Y offers <90% OTP',
    penalty_missed_tender_percentage DECIMAL(5,2) COMMENT 'Penalty if primary rejects more than X%',
    
    -- Business Rules and Constraints
    exceptions TEXT COMMENT 'Special notes (e.g., night ban, regional blackout, seasonal restrictions)',
    business_rules JSON COMMENT 'Additional business rules and constraints as JSON',
    remarks TEXT COMMENT 'Any other business rules or notes',
    
    -- Status and Compliance
    routing_guide_status ENUM('Active', 'Inactive', 'Draft', 'Under Review', 'Expired') DEFAULT 'Active' NOT NULL,
    compliance_score DECIMAL(5,2) COMMENT 'Performance compliance score (0-100)',
    
    -- System Fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    created_by VARCHAR(100) COMMENT 'User who created the routing guide',
    updated_by VARCHAR(100) COMMENT 'User who last updated the routing guide',
    
    -- Indexes for Performance
    INDEX idx_routing_guide_id (routing_guide_id),
    INDEX idx_lane (origin_location, destination_location),
    INDEX idx_equipment_type (equipment_type),
    INDEX idx_service_level (service_level),
    INDEX idx_primary_carrier (primary_carrier_id),
    INDEX idx_routing_guide_status (routing_guide_status),
    INDEX idx_validity_period (valid_from, valid_to),
    INDEX idx_lane_equipment (origin_location, destination_location, equipment_type),
    INDEX idx_carrier_rates (primary_carrier_rate, backup_carrier_1_rate, backup_carrier_2_rate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Routing guides for TL transportation procurement with carrier selection rules';

-- Create a view for active routing guides
CREATE OR REPLACE VIEW active_routing_guides AS
SELECT
    routing_guide_id,
    origin_location,
    destination_location,
    lane_id,
    equipment_type,
    service_level,
    mode,
    primary_carrier_name,
    primary_carrier_rate,
    primary_carrier_rate_type,
    backup_carrier_1_name,
    backup_carrier_2_name,
    tender_sequence,
    tender_lead_time_hours,
    transit_sla_days,
    routing_guide_status,
    valid_from,
    valid_to
FROM routing_guides
WHERE routing_guide_status = 'Active'
AND CURDATE() BETWEEN valid_from AND valid_to;

-- Create a view for routing guide summary
CREATE OR REPLACE VIEW routing_guide_summary AS
SELECT
    routing_guide_status,
    COUNT(*) as guide_count,
    AVG(primary_carrier_rate) as avg_primary_rate,
    MIN(valid_from) as earliest_validity,
    MAX(valid_to) as latest_validity,
    COUNT(DISTINCT equipment_type) as unique_equipment_types,
    COUNT(DISTINCT primary_carrier_name) as unique_carriers
FROM routing_guides
GROUP BY routing_guide_status;

-- Create a view for lane coverage analysis
CREATE OR REPLACE VIEW lane_coverage_analysis AS
SELECT
    CONCAT(origin_location, ' → ', destination_location) as lane,
    equipment_type,
    COUNT(*) as routing_guide_count,
    GROUP_CONCAT(DISTINCT primary_carrier_name ORDER BY primary_carrier_name SEPARATOR ', ') as carriers,
    AVG(primary_carrier_rate) as avg_rate,
    MIN(primary_carrier_rate) as min_rate,
    MAX(primary_carrier_rate) as max_rate
FROM routing_guides
WHERE routing_guide_status = 'Active'
GROUP BY origin_location, destination_location, equipment_type
ORDER BY routing_guide_count DESC;

-- Insert sample data for testing
INSERT INTO routing_guides (
    routing_guide_id, origin_location, destination_location, lane_id, equipment_type, service_level, mode,
    primary_carrier_name, primary_carrier_rate, primary_carrier_rate_type,
    backup_carrier_1_name, backup_carrier_1_rate, backup_carrier_1_rate_type,
    backup_carrier_2_name, backup_carrier_2_rate, backup_carrier_2_rate_type,
    tender_sequence, tender_lead_time_hours, transit_sla_days, fuel_surcharge_percentage,
    accessorials_included, load_commitment_type, valid_from, valid_to, routing_guide_status
) VALUES
('RG-2024-001', 'Gurgaon, Haryana', 'Bangalore, Karnataka', 'LANE-GUR-BLR-001', '32ft SXL', 'Standard', 'TL',
 'Gati Ltd', 25000.00, 'Per Load',
 'Delhivery', 27000.00, 'Per Load',
 'Blue Dart', 30000.00, 'Per Load',
 '1-2-3', 24, 3, 12.50,
 'Partial', 'Variable', '2024-01-01', '2024-12-31', 'Active'),

('RG-2024-002', 'Mumbai, Maharashtra', 'Delhi, Delhi', 'LANE-MUM-DEL-001', '32ft Trailer', 'Express', 'TL',
 'ABC Transport Ltd', 35000.00, 'Per Load',
 'XYZ Logistics', 38000.00, 'Per Load',
 'Fast Freight Co', 42000.00, 'Per Load',
 '1-2-3', 12, 2, 15.00,
 'Yes', 'Fixed', '2024-02-01', '2025-01-31', 'Active'),

('RG-2024-003', 'Chennai, Tamil Nadu', 'Hyderabad, Telangana', 'LANE-CHE-HYD-001', '20ft Container', 'Standard', 'TL',
 'South Express', 18000.00, 'Per Load',
 'Regional Cargo', 20000.00, 'Per Load',
 'City Connect', 22000.00, 'Per Load',
 '1-2-3', 48, 1, 10.00,
 'No', 'Variable', '2024-03-01', '2024-08-31', 'Active'),

('RG-2024-004', 'Pune, Maharashtra', 'Ahmedabad, Gujarat', 'LANE-PUN-AHM-001', 'Reefer Trailer', 'Premium', 'TL',
 'Cold Chain Express', 45000.00, 'Per Load',
 'Frozen Logistics', 48000.00, 'Per Load',
 'Chill Transport', 52000.00, 'Per Load',
 '1-2-3', 36, 2, 18.00,
 'Yes', 'Guaranteed', '2024-04-01', '2025-03-31', 'Active'),

('RG-2024-005', 'Kolkata, West Bengal', 'Pune, Maharashtra', 'LANE-KOL-PUN-001', 'Flatbed Trailer', 'Economy', 'TL',
 'East West Cargo', 28000.00, 'Per Load',
 'Bharat Transport', 30000.00, 'Per Load',
 'National Logistics', 32000.00, 'Per Load',
 '1-2-3', 72, 4, 8.50,
 'Partial', 'Variable', '2024-05-01', '2024-10-31', 'Active'); 