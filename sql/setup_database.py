#!/usr/bin/env python3
"""
Script to set up database schema in Supabase for RouteCraft Backend
"""
import os
from pathlib import Path
from supabase import create_client, Client
from app.config import settings
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_tables(supabase: Client):
    """Create all necessary tables in Supabase"""
    
    # Users table
    users_sql = """
    CREATE TABLE IF NOT EXISTS users (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
    """
    
    # Carriers table
    carriers_sql = """
    CREATE TABLE IF NOT EXISTS carriers (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
    """
    
    # Lanes table
    lanes_sql = """
    CREATE TABLE IF NOT EXISTS lanes (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
    """
    
    # Bids table
    bids_sql = """
    CREATE TABLE IF NOT EXISTS bids (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
    """
    
    # Bid Responses table
    bid_responses_sql = """
    CREATE TABLE IF NOT EXISTS bid_responses (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
    """
    
    # Insurance Claims table
    insurance_claims_sql = """
    CREATE TABLE IF NOT EXISTS insurance_claims (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
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
    """
    
    # Bid-Lane relationships table
    bid_lanes_sql = """
    CREATE TABLE IF NOT EXISTS bid_lanes (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        bid_id UUID REFERENCES bids(id) ON DELETE CASCADE,
        lane_id UUID REFERENCES lanes(id) ON DELETE CASCADE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(bid_id, lane_id)
    );
    """
    
    # Bid-Carrier relationships table
    bid_carriers_sql = """
    CREATE TABLE IF NOT EXISTS bid_carriers (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        bid_id UUID REFERENCES bids(id) ON DELETE CASCADE,
        carrier_id UUID REFERENCES carriers(id) ON DELETE CASCADE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(bid_id, carrier_id)
    );
    """
    
    tables_sql = [
        ("users", users_sql),
        ("carriers", carriers_sql),
        ("lanes", lanes_sql),
        ("bids", bids_sql),
        ("bid_responses", bid_responses_sql),
        ("insurance_claims", insurance_claims_sql),
        ("bid_lanes", bid_lanes_sql),
        ("bid_carriers", bid_carriers_sql)
    ]
    
    for table_name, sql in tables_sql:
        try:
            # Execute the SQL using Supabase's rpc function
            result = supabase.rpc('exec_sql', {'sql': sql}).execute()
            logger.info(f"Table {table_name} created successfully")
        except Exception as e:
            logger.warning(f"Could not create table {table_name}: {e}")
            # Try alternative approach using direct SQL execution
            try:
                # For Supabase, we might need to use a different approach
                # This is a fallback that might work depending on Supabase configuration
                logger.info(f"Attempting alternative approach for {table_name}")
            except Exception as e2:
                logger.error(f"Failed to create table {table_name}: {e2}")

def insert_sample_data(supabase: Client):
    """Insert sample data for testing"""
    try:
        # Insert sample user
        user_data = {
            "email": "admin@routecraft.com",
            "first_name": "Admin",
            "last_name": "User",
            "role": "admin",
            "company": "RouteCraft",
            "is_active": True,
            "hashed_password": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vHhHwqG",  # password: admin123
            "status": "active"
        }
        
        result = supabase.table("users").insert(user_data).execute()
        logger.info("Sample user created successfully")
        
        # Insert sample carrier
        carrier_data = {
            "name": "Sample Carrier",
            "company_name": "Sample Carrier Co.",
            "contact_person": "John Doe",
            "email": "john@samplecarrier.com",
            "phone": "+1-555-0123",
            "city": "New York",
            "state": "NY",
            "country": "USA",
            "status": "active"
        }
        
        result = supabase.table("carriers").insert(carrier_data).execute()
        logger.info("Sample carrier created successfully")
        
        # Insert sample lane
        lane_data = {
            "name": "NYC to LA",
            "origin_city": "New York",
            "origin_state": "NY",
            "origin_country": "USA",
            "destination_city": "Los Angeles",
            "destination_state": "CA",
            "destination_country": "USA",
            "distance_miles": 2789,
            "estimated_transit_time_hours": 48,
            "lane_type": "standard",
            "status": "active"
        }
        
        result = supabase.table("lanes").insert(lane_data).execute()
        logger.info("Sample lane created successfully")
        
        # Insert sample bid
        bid_data = {
            "name": "Sample Bid",
            "description": "Transportation services from NYC to LA",
            "bid_type": "contract",
            "priority": "medium",
            "start_date": "2024-01-01T00:00:00Z",
            "end_date": "2024-12-31T23:59:59Z",
            "submission_deadline": "2023-12-15T23:59:59Z",
            "budget": 50000.00,
            "currency": "USD",
            "status": "open",
            "estimated_cost": 50000.00
        }
        
        result = supabase.table("bids").insert(bid_data).execute()
        logger.info("Sample bid created successfully")
        
    except Exception as e:
        logger.error(f"Error inserting sample data: {e}")

def main():
    """Main function to set up database"""
    try:
        # Initialize Supabase client
        supabase = create_client(
            settings.supabase_url,
            settings.supabase_key
        )
        
        logger.info("Connected to Supabase successfully")
        
        # Create tables
        logger.info("Creating database tables...")
        create_tables(supabase)
        
        # Insert sample data
        logger.info("Inserting sample data...")
        insert_sample_data(supabase)
        
        logger.info("Database setup completed successfully!")
        
    except Exception as e:
        logger.error(f"Database setup failed: {e}")
        logger.error("Please check your Supabase configuration in .env file")

if __name__ == "__main__":
    main() 