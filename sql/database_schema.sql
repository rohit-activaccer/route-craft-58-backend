-- RouteCraft Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(20) DEFAULT 'viewer' CHECK (role IN ('admin', 'manager', 'analyst', 'viewer')),
    company VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    hashed_password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended'))
);

-- Carriers table
CREATE TABLE IF NOT EXISTS carriers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    company_name VARCHAR(200),
    contact_person VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    mc_number VARCHAR(50),
    dot_number VARCHAR(50),
    insurance_info JSONB,
    rating DECIMAL(3,2) DEFAULT 0.0,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lanes table
CREATE TABLE IF NOT EXISTS lanes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    origin_city VARCHAR(100) NOT NULL,
    origin_state VARCHAR(100) NOT NULL,
    origin_country VARCHAR(100) NOT NULL,
    destination_city VARCHAR(100) NOT NULL,
    destination_state VARCHAR(100) NOT NULL,
    destination_country VARCHAR(100) NOT NULL,
    distance_miles INTEGER,
    estimated_transit_time_hours INTEGER,
    lane_type VARCHAR(50) DEFAULT 'standard',
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bids table
CREATE TABLE IF NOT EXISTS bids (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    bid_type VARCHAR(50) NOT NULL CHECK (bid_type IN ('contract', 'spot', 'seasonal', 'regional')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    submission_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
    budget DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'USD',
    requirements JSONB,
    terms_conditions TEXT,
    is_template BOOLEAN DEFAULT false,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'open', 'closed', 'awarded', 'cancelled')),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    published_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    awarded_at TIMESTAMP WITH TIME ZONE,
    total_responses INTEGER DEFAULT 0,
    total_lanes INTEGER DEFAULT 0,
    total_carriers INTEGER DEFAULT 0,
    estimated_cost DECIMAL(12,2)
);

-- Bid Responses table
CREATE TABLE IF NOT EXISTS bid_responses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    bid_id UUID REFERENCES bids(id) ON DELETE CASCADE,
    carrier_id UUID REFERENCES carriers(id),
    proposed_rate DECIMAL(12,2) NOT NULL,
    proposed_transit_time_hours INTEGER,
    proposed_equipment_type VARCHAR(100),
    proposed_equipment_count INTEGER,
    additional_services JSONB,
    terms_conditions TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    rejected_at TIMESTAMP WITH TIME ZONE
);

-- Insurance Claims table
CREATE TABLE IF NOT EXISTS insurance_claims (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    claim_number VARCHAR(100) UNIQUE NOT NULL,
    bid_id UUID REFERENCES bids(id),
    carrier_id UUID REFERENCES carriers(id),
    claim_type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    incident_date TIMESTAMP WITH TIME ZONE,
    reported_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'approved', 'rejected', 'settled')),
    assigned_to UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bid-Lane relationships table
CREATE TABLE IF NOT EXISTS bid_lanes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    bid_id UUID REFERENCES bids(id) ON DELETE CASCADE,
    lane_id UUID REFERENCES lanes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(bid_id, lane_id)
);

-- Bid-Carrier relationships table
CREATE TABLE IF NOT EXISTS bid_carriers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    bid_id UUID REFERENCES bids(id) ON DELETE CASCADE,
    carrier_id UUID REFERENCES carriers(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(bid_id, carrier_id)
);

-- Load/Lane History table for transportation procurement analysis
CREATE TABLE IF NOT EXISTS load_lane_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    load_id VARCHAR(100) UNIQUE NOT NULL,
    contract_reference VARCHAR(100),
    
    -- Origin Information
    origin_location VARCHAR(200) NOT NULL,
    origin_country VARCHAR(10) NOT NULL DEFAULT 'IN',
    origin_facility_id VARCHAR(100),
    origin_latitude DECIMAL(10, 8),
    origin_longitude DECIMAL(11, 8),
    
    -- Destination Information
    destination_location VARCHAR(200) NOT NULL,
    destination_country VARCHAR(10) NOT NULL DEFAULT 'IN',
    destination_facility_id VARCHAR(100),
    destination_latitude DECIMAL(10, 8),
    destination_longitude DECIMAL(11, 8),
    
    -- Shipment Details
    load_date TIMESTAMP WITH TIME ZONE NOT NULL,
    delivery_date TIMESTAMP WITH TIME ZONE NOT NULL,
    mode VARCHAR(20) DEFAULT 'TL' CHECK (mode IN ('TL', 'FTL', 'LTL', 'Rail', 'Air', 'Sea')),
    equipment_type VARCHAR(100),
    commodity_type VARCHAR(100),
    weight_kg DECIMAL(10, 2),
    volume_cbm DECIMAL(10, 2),
    distance_km DECIMAL(10, 2),
    
    -- Carrier Information
    carrier_id UUID REFERENCES carriers(id),
    carrier_name VARCHAR(200),
    
    -- Financial Information
    rate_type VARCHAR(20) CHECK (rate_type IN ('per_km', 'per_trip', 'flat')),
    total_cost DECIMAL(12, 2) NOT NULL,
    rate_per_km DECIMAL(10, 2),
    accessorial_charges DECIMAL(10, 2) DEFAULT 0.00,
    fuel_surcharge_percentage DECIMAL(5, 2) DEFAULT 0.00,
    
    -- Procurement Details
    tender_type VARCHAR(20) DEFAULT 'spot' CHECK (tender_type IN ('contracted', 'spot', 'adhoc')),
    carrier_response VARCHAR(20) DEFAULT 'accepted' CHECK (carrier_response IN ('accepted', 'declined', 'auto_assigned')),
    
    -- Performance Metrics
    on_time_pickup BOOLEAN,
    on_time_delivery BOOLEAN,
    billing_accuracy BOOLEAN DEFAULT true,
    
    -- Metadata
    notes TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Indexes for performance
    CONSTRAINT valid_dates CHECK (delivery_date >= load_date),
    CONSTRAINT valid_coordinates CHECK (
        (origin_latitude IS NULL AND origin_longitude IS NULL) OR
        (origin_latitude IS NOT NULL AND origin_longitude IS NOT NULL)
    ),
    CONSTRAINT valid_destination_coordinates CHECK (
        (destination_latitude IS NULL AND destination_longitude IS NULL) OR
        (destination_latitude IS NOT NULL AND destination_longitude IS NOT NULL)
    )
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_load_lane_history_origin ON load_lane_history(origin_location, origin_country);
CREATE INDEX IF NOT EXISTS idx_load_lane_history_destination ON load_lane_history(destination_location, destination_country);
CREATE INDEX IF NOT EXISTS idx_load_lane_history_dates ON load_lane_history(load_date, delivery_date);
CREATE INDEX IF NOT EXISTS idx_load_lane_history_carrier ON load_lane_history(carrier_id, carrier_name);
CREATE INDEX IF NOT EXISTS idx_load_lane_history_mode ON load_lane_history(mode, equipment_type);
CREATE INDEX IF NOT EXISTS idx_load_lane_history_commodity ON load_lane_history(commodity_type);
CREATE INDEX IF NOT EXISTS idx_load_lane_history_contract ON load_lane_history(contract_reference);

-- Insert sample data
INSERT INTO users (email, first_name, last_name, role, company, is_active, hashed_password, status) 
VALUES ('admin@routecraft.com', 'Admin', 'User', 'admin', 'RouteCraft', true, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vHhHwqG', 'active')
ON CONFLICT (email) DO NOTHING;

INSERT INTO carriers (name, company_name, contact_person, email, phone, city, state, country, status) 
VALUES ('Sample Carrier', 'Sample Carrier Co.', 'John Doe', 'john@samplecarrier.com', '+1-555-0123', 'New York', 'NY', 'USA', 'active')
ON CONFLICT DO NOTHING;

INSERT INTO lanes (name, origin_city, origin_state, origin_country, destination_city, destination_state, destination_country, distance_miles, estimated_transit_time_hours, lane_type, status) 
VALUES ('NYC to LA', 'New York', 'NY', 'USA', 'Los Angeles', 'CA', 'USA', 2789, 48, 'standard', 'active')
ON CONFLICT DO NOTHING;

INSERT INTO bids (name, description, bid_type, priority, start_date, end_date, submission_deadline, budget, currency, status, estimated_cost) 
VALUES ('Sample Bid', 'Transportation services from NYC to LA', 'contract', 'medium', '2024-01-01T00:00:00Z', '2024-12-31T23:59:59Z', '2023-12-15T23:59:59Z', 50000.00, 'USD', 'open', 50000.00)
ON CONFLICT DO NOTHING;

-- Insert sample load/lane history data
INSERT INTO load_lane_history (
    load_id, contract_reference, origin_location, origin_country, origin_facility_id,
    destination_location, destination_country, destination_facility_id,
    load_date, delivery_date, mode, equipment_type, commodity_type,
    weight_kg, volume_cbm, distance_km, carrier_name,
    rate_type, total_cost, rate_per_km, accessorial_charges, fuel_surcharge_percentage,
    tender_type, carrier_response, on_time_pickup, on_time_delivery, billing_accuracy
) VALUES 
    ('LOAD-001', 'CONTRACT-2024-001', 'Mumbai', 'IN', 'FAC-MUM-001', 'Delhi', 'IN', 'FAC-DEL-001', 
     '2024-01-15T08:00:00Z', '2024-01-17T18:00:00Z', 'TL', '32ft SXL', 'FMCG', 
     15000.00, 45.50, 1400.00, 'Sample Carrier', 
     'per_trip', 28000.00, 20.00, 2000.00, 5.00, 
     'contracted', 'accepted', true, true, true),
    
    ('LOAD-002', 'CONTRACT-2024-001', 'Bangalore', 'IN', 'FAC-BLR-001', 'Chennai', 'IN', 'FAC-CHE-001', 
     '2024-01-20T10:00:00Z', '2024-01-21T16:00:00Z', 'TL', '32ft SXL', 'Electronics', 
     8000.00, 25.00, 350.00, 'Sample Carrier', 
     'per_trip', 12000.00, 34.29, 1500.00, 5.00, 
     'contracted', 'accepted', true, false, true),
    
    ('LOAD-003', 'SPOT-2024-001', 'Pune', 'IN', 'FAC-PUN-001', 'Hyderabad', 'IN', 'FAC-HYD-001', 
     '2024-01-25T09:00:00Z', '2024-01-26T15:00:00Z', 'TL', '20ft Container', 'Auto Parts', 
     12000.00, 30.00, 500.00, 'Sample Carrier', 
     'per_trip', 18000.00, 36.00, 1000.00, 0.00, 
     'spot', 'accepted', false, true, true);

-- Enable Row Level Security (RLS) for all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE lanes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bids ENABLE ROW LEVEL SECURITY;
ALTER TABLE bid_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurance_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE bid_lanes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bid_carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE load_lane_history ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (for development)
CREATE POLICY "Allow public read access" ON users FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON carriers FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON lanes FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON bids FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON bid_responses FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON insurance_claims FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON bid_lanes FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON bid_carriers FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON load_lane_history FOR SELECT USING (true);

-- Create policies for insert/update/delete (for development)
CREATE POLICY "Allow public insert" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert" ON carriers FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert" ON lanes FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert" ON bids FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert" ON bid_responses FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert" ON insurance_claims FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert" ON bid_lanes FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert" ON bid_carriers FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert" ON load_lane_history FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update" ON users FOR UPDATE USING (true);
CREATE POLICY "Allow public update" ON carriers FOR UPDATE USING (true);
CREATE POLICY "Allow public update" ON lanes FOR UPDATE USING (true);
CREATE POLICY "Allow public update" ON bids FOR UPDATE USING (true);
CREATE POLICY "Allow public update" ON bid_responses FOR UPDATE USING (true);
CREATE POLICY "Allow public update" ON insurance_claims FOR UPDATE USING (true);
CREATE POLICY "Allow public update" ON bid_lanes FOR UPDATE USING (true);
CREATE POLICY "Allow public update" ON bid_carriers FOR UPDATE USING (true);
CREATE POLICY "Allow public update" ON load_lane_history FOR UPDATE USING (true);

CREATE POLICY "Allow public delete" ON users FOR DELETE USING (true);
CREATE POLICY "Allow public delete" ON carriers FOR DELETE USING (true);
CREATE POLICY "Allow public delete" ON lanes FOR DELETE USING (true);
CREATE POLICY "Allow public delete" ON bids FOR DELETE USING (true);
CREATE POLICY "Allow public delete" ON bid_responses FOR DELETE USING (true);
CREATE POLICY "Allow public delete" ON insurance_claims FOR DELETE USING (true);
CREATE POLICY "Allow public delete" ON bid_lanes FOR DELETE USING (true);
CREATE POLICY "Allow public delete" ON bid_carriers FOR DELETE USING (true);
CREATE POLICY "Allow public delete" ON load_lane_history FOR DELETE USING (true); 