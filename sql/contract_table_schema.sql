-- Current Contract Sheet Table Schema
-- This table stores transportation contracts with lanes, rates, and service levels

CREATE TABLE IF NOT EXISTS transport_contracts (
    -- Primary Key
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Contract Identification
    contract_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique identifier for the contract',
    contract_status ENUM('Active', 'Expired', 'In Review', 'Draft', 'Terminated') DEFAULT 'Draft' NOT NULL,
    
    -- Carrier Information
    carrier_name VARCHAR(255) NOT NULL COMMENT 'Name of the transportation provider',
    carrier_code VARCHAR(50) COMMENT 'Internal or industry carrier code',
    
    -- Origin Details
    origin_location VARCHAR(255) NOT NULL COMMENT 'Start of the lane (city/state/pincode)',
    origin_facility_id VARCHAR(100) COMMENT 'Internal plant/warehouse code',
    origin_pincode VARCHAR(10) COMMENT 'Origin pincode for precise location',
    origin_state VARCHAR(100) COMMENT 'Origin state',
    
    -- Destination Details
    destination_location VARCHAR(255) NOT NULL COMMENT 'End of the lane',
    destination_facility_id VARCHAR(100) COMMENT 'Internal code',
    destination_pincode VARCHAR(10) COMMENT 'Destination pincode for precise location',
    destination_state VARCHAR(100) COMMENT 'Destination state',
    
    -- Lane Information
    lane_id VARCHAR(100) COMMENT 'System-generated or defined lane code',
    mode ENUM('FTL', 'LTL', 'Partial', 'Intermodal') DEFAULT 'FTL' NOT NULL,
    equipment_type VARCHAR(100) COMMENT 'Vehicle type: 32ft, 20ft, reefer, etc.',
    
    -- Service Details
    service_level ENUM('Express', 'Standard', 'Guaranteed', 'Premium', 'Economy') DEFAULT 'Standard' NOT NULL,
    transit_time_hours INT COMMENT 'Agreed delivery time in hours',
    transit_time_days INT COMMENT 'Agreed delivery time in days',
    
    -- Rate Structure
    rate_type ENUM('Per Trip', 'Per KM', 'Slab-based', 'Per Ton', 'Per Pallet', 'Fixed') NOT NULL,
    base_rate DECIMAL(15,2) NOT NULL COMMENT 'Fixed or variable rate per unit',
    rate_currency ENUM('INR', 'USD', 'EUR') DEFAULT 'INR' NOT NULL,
    minimum_charges DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Minimum freight applicable',
    
    -- Fuel Surcharge
    fuel_surcharge_type ENUM('Percentage', 'Indexed', 'Fixed', 'None') DEFAULT 'None',
    fuel_surcharge_value DECIMAL(8,4) COMMENT 'Percentage or fixed value',
    fuel_surcharge_index VARCHAR(100) COMMENT 'Reference to fuel index if applicable',
    
    -- Additional Charges
    accessorial_charges JSON COMMENT 'Extra fees (waiting, loading, etc.) as JSON',
    waiting_charges_per_hour DECIMAL(10,2) DEFAULT 0.00,
    loading_charges DECIMAL(10,2) DEFAULT 0.00,
    unloading_charges DECIMAL(10,2) DEFAULT 0.00,
    
    -- Contract Period
    effective_from DATE NOT NULL COMMENT 'Contract start date',
    effective_to DATE NOT NULL COMMENT 'Contract expiry date',
    
    -- Business Terms
    payment_terms VARCHAR(100) COMMENT 'e.g., 30 days, advance, COD',
    tender_type ENUM('Spot', 'Annual', 'Quarterly', 'Monthly', 'Project-based') DEFAULT 'Annual',
    
    -- Volume and Performance
    load_volume_commitment INT COMMENT 'Volume guarantee or minimums in trips/tonnes',
    carrier_performance_clause TEXT COMMENT 'Linked to performance KPIs',
    
    -- Penalties and Conditions
    penalty_clause TEXT COMMENT 'Conditions for delay/failure',
    penalty_amount DECIMAL(15,2) COMMENT 'Penalty amount if applicable',
    
    -- Billing and Documentation
    billing_method ENUM('POD-based', 'Digital', 'Milestone-based', 'Advance') DEFAULT 'POD-based',
    tariff_slab_attachment VARCHAR(500) COMMENT 'Path to tariff slab file if applicable',
    attachment_link VARCHAR(500) COMMENT 'Path or link to scanned PDF/MSA',
    
    -- Additional Information
    remarks TEXT COMMENT 'Any special terms or conditions',
    special_instructions TEXT COMMENT 'Special handling or delivery instructions',
    
    -- System Fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    created_by VARCHAR(100) COMMENT 'User who created the contract',
    updated_by VARCHAR(100) COMMENT 'User who last updated the contract',
    
    -- Indexes for Performance
    INDEX idx_contract_id (contract_id),
    INDEX idx_carrier_name (carrier_name),
    INDEX idx_origin_location (origin_location),
    INDEX idx_destination_location (destination_location),
    INDEX idx_contract_status (contract_status),
    INDEX idx_effective_dates (effective_from, effective_to),
    INDEX idx_lane (origin_location, destination_location),
    INDEX idx_carrier_code (carrier_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Transportation contracts with lanes, rates, and service levels';

-- Create a view for active contracts
CREATE OR REPLACE VIEW active_contracts AS
SELECT 
    contract_id,
    carrier_name,
    carrier_code,
    origin_location,
    destination_location,
    mode,
    equipment_type,
    service_level,
    rate_type,
    base_rate,
    rate_currency,
    effective_from,
    effective_to,
    contract_status
FROM transport_contracts 
WHERE contract_status = 'Active' 
AND CURDATE() BETWEEN effective_from AND effective_to;

-- Create a view for contract summary
CREATE OR REPLACE VIEW contract_summary AS
SELECT 
    contract_status,
    COUNT(*) as contract_count,
    AVG(base_rate) as avg_base_rate,
    MIN(effective_from) as earliest_start,
    MAX(effective_to) as latest_end
FROM transport_contracts 
GROUP BY contract_status;

-- Insert sample data for testing
INSERT INTO transport_contracts (
    contract_id, carrier_name, carrier_code, origin_location, destination_location,
    mode, equipment_type, service_level, rate_type, base_rate, rate_currency,
    effective_from, effective_to, contract_status, payment_terms
) VALUES 
('CON-2024-001', 'ABC Transport Ltd', 'ABC001', 'Mumbai, Maharashtra', 'Delhi, Delhi',
 'FTL', '32ft Trailer', 'Standard', 'Per Trip', 25000.00, 'INR',
 '2024-01-01', '2024-12-31', 'Active', '30 days'),

('CON-2024-002', 'XYZ Logistics', 'XYZ002', 'Bangalore, Karnataka', 'Chennai, Tamil Nadu',
 'FTL', '20ft Container', 'Express', 'Per KM', 15.50, 'INR',
 '2024-02-01', '2025-01-31', 'Active', '15 days'),

('CON-2024-003', 'Fast Freight Co', 'FFC003', 'Pune, Maharashtra', 'Hyderabad, Telangana',
 'FTL', 'Reefer Trailer', 'Guaranteed', 'Per Trip', 18000.00, 'INR',
 '2024-03-01', '2024-08-31', 'Active', '45 days'); 