#!/usr/bin/env python3
"""
Create Lanes Master Table for TL Transportation
==============================================

This script creates the lanes_master table which defines transport corridors
between origin and destination locations, including operational and commercial
characteristics for rate benchmarking, carrier allocation, and route optimization.
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv
from datetime import datetime, date

# Load environment variables
load_dotenv()

def create_database_connection():
    """Create and return a database connection."""
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER', 'routecraft_user'),
            password=os.getenv('DB_PASSWORD', 'routecraft_password'),
            database=os.getenv('DB_NAME', 'routecraft')
        )
        return connection
    except Error as e:
        print(f"❌ Error connecting to MySQL: {e}")
        return None

def create_lanes_master_table(cursor):
    """Create the lanes_master table."""
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS lanes_master (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        lane_id VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique identifier (e.g., LANE-000123)',
        origin_location_id VARCHAR(50) NOT NULL COMMENT 'From the Locations Master',
        origin_city VARCHAR(100) NOT NULL COMMENT 'Origin city name',
        origin_state VARCHAR(100) NOT NULL COMMENT 'Origin state name',
        destination_location_id VARCHAR(50) NOT NULL COMMENT 'From the Locations Master',
        destination_city VARCHAR(100) NOT NULL COMMENT 'Destination city name',
        destination_state VARCHAR(100) NOT NULL COMMENT 'Destination state name',
        lane_type ENUM('Primary', 'Return', 'Backhaul', 'Inbound', 'Outbound') DEFAULT 'Primary' COMMENT 'Lane classification',
        distance_km DECIMAL(8,2) COMMENT 'Approximate road distance in kilometers',
        transit_time_days INT COMMENT 'Standard delivery lead time in days',
        avg_load_frequency_month DECIMAL(5,2) COMMENT 'Average loads per month from historical data',
        avg_load_volume_tons DECIMAL(8,2) COMMENT 'Average load size in tons',
        avg_load_volume_cft DECIMAL(8,2) COMMENT 'Average load volume in cubic feet',
        preferred_equipment_type ENUM('32ft SXL', '32ft Container', 'Reefer', 'Flatbed', '20ft Container', '40ft Container', 'Other') COMMENT 'Preferred equipment type',
        mode ENUM('TL', 'LTL', 'Rail', 'Multimodal') DEFAULT 'TL' COMMENT 'Transportation mode',
        service_level ENUM('Standard', 'Express', 'Scheduled', 'Premium') DEFAULT 'Standard' COMMENT 'Service level offered',
        seasonality BOOLEAN DEFAULT FALSE COMMENT 'Whether the lane has peak/off-peak trends',
        peak_months VARCHAR(100) COMMENT 'Peak months (comma-separated)',
        primary_carriers JSON COMMENT 'Current preferred carriers on this lane',
        current_rate_trip DECIMAL(10,2) COMMENT 'Current rate per trip in INR',
        current_rate_ton DECIMAL(8,2) COMMENT 'Current rate per ton in INR',
        benchmark_rate_trip DECIMAL(10,2) COMMENT 'Benchmark rate per trip based on market intelligence',
        benchmark_rate_ton DECIMAL(8,2) COMMENT 'Benchmark rate per ton based on market intelligence',
        fuel_surcharge_applied BOOLEAN DEFAULT FALSE COMMENT 'If dynamic fuel surcharge applies',
        accessorials_expected JSON COMMENT 'Expected accessorials (e.g., Unloading, Waiting, Escort)',
        is_active BOOLEAN DEFAULT TRUE COMMENT 'Flag for deprecating unused lanes',
        last_used_date DATE COMMENT 'When the lane last had an executed shipment',
        remarks TEXT COMMENT 'Notes like risk-prone area, toll-heavy route, etc.',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        created_by VARCHAR(100),
        updated_by VARCHAR(100),
        
        INDEX idx_origin (origin_location_id),
        INDEX idx_destination (destination_location_id),
        INDEX idx_origin_city_state (origin_city, origin_state),
        INDEX idx_dest_city_state (destination_city, destination_state),
        INDEX idx_lane_type (lane_type),
        INDEX idx_distance (distance_km),
        INDEX idx_equipment (preferred_equipment_type),
        INDEX idx_mode (mode),
        INDEX idx_active (is_active),
        INDEX idx_last_used (last_used_date)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    """
    
    try:
        cursor.execute(create_table_sql)
        print("✅ Table created successfully!")
        return True
    except Error as e:
        print(f"❌ Error creating table: {e}")
        return False

def insert_sample_data(cursor, connection):
    """Insert sample lane data."""
    sample_lanes = [
        ('LANE-BHW-HYD-001', 'WH-MUM-01', 'Bhiwandi', 'Maharashtra', 'CUST-HYD-01', 'Hyderabad', 'Telangana', 'Primary', 725.50, 2, 30.0, 15.5, 450.0, '32ft Container', 'TL', 'Standard', True, 'March,October', '["ABC Logistics", "XYZ Transport"]', 28000.00, 1806.45, 30000.00, 1935.48, True, '["Unloading", "Waiting"]', True, date(2024, 12, 15), 'High volume lane, toll-heavy route'),
        ('LANE-BLR-CHN-002', 'WH-BLR-01', 'Bangalore', 'Karnataka', 'FACTORY-CHN-01', 'Chennai', 'Tamil Nadu', 'Primary', 350.25, 1, 25.0, 12.0, 350.0, '32ft SXL', 'TL', 'Express', False, None, '["South Express", "Karnataka Logistics"]', 22000.00, 1833.33, 24000.00, 2000.00, False, '["Unloading"]', True, date(2024, 12, 18), 'Express corridor, good road conditions'),
        ('LANE-MUM-BLR-003', 'WH-MUM-01', 'Mumbai', 'Maharashtra', 'WH-BLR-01', 'Bangalore', 'Karnataka', 'Return', 980.75, 3, 20.0, 18.0, 520.0, '32ft Container', 'TL', 'Standard', True, 'January,July', '["Western Express", "Maharashtra Cargo"]', 35000.00, 1944.44, 38000.00, 2111.11, True, '["Unloading", "Waiting", "Escort"]', True, date(2024, 12, 12), 'Long distance, mountainous terrain'),
        ('LANE-CHN-HYD-004', 'FACTORY-CHN-01', 'Chennai', 'Tamil Nadu', 'CUST-HYD-01', 'Hyderabad', 'Telangana', 'Primary', 625.30, 2, 15.0, 14.0, 400.0, '32ft SXL', 'TL', 'Standard', False, None, '["Tamil Nadu Express", "Telangana Cargo"]', 25000.00, 1785.71, 27000.00, 1928.57, False, '["Unloading"]', True, date(2024, 12, 16), 'Medium volume, good connectivity'),
        ('LANE-HYD-MUM-005', 'CUST-HYD-01', 'Hyderabad', 'Telangana', 'PORT-MUM-01', 'Mumbai', 'Maharashtra', 'Outbound', 750.45, 2, 12.0, 16.0, 480.0, '32ft Container', 'TL', 'Scheduled', True, 'February,August', '["Telangana Express", "Port Connect"]', 30000.00, 1875.00, 32000.00, 2000.00, True, '["Unloading", "Port Charges"]', True, date(2024, 12, 10), 'Export route, port handling required')
    ]
    
    insert_sql = """
    INSERT INTO lanes_master (
        lane_id, origin_location_id, origin_city, origin_state, destination_location_id, destination_city, destination_state,
        lane_type, distance_km, transit_time_days, avg_load_frequency_month, avg_load_volume_tons, avg_load_volume_cft,
        preferred_equipment_type, mode, service_level, seasonality, peak_months, primary_carriers, current_rate_trip,
        current_rate_ton, benchmark_rate_trip, benchmark_rate_ton, fuel_surcharge_applied, accessorials_expected,
        is_active, last_used_date, remarks
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    print("📝 Inserting sample lane data...")
    inserted_count = 0
    
    for lane in sample_lanes:
        try:
            cursor.execute(insert_sql, lane)
            inserted_count += 1
            print(f"  ✓ Inserted {lane[0]}: {lane[2]} → {lane[5]}")
        except Error as e:
            print(f"  ❌ Error inserting {lane[0]}: {e}")
    
    connection.commit()
    print(f"✅ Inserted {inserted_count} sample lanes")
    return inserted_count

def create_analytical_views(cursor):
    """Create analytical views for lanes analysis."""
    views = [
        ("active_lanes_by_type", """
        CREATE OR REPLACE VIEW active_lanes_by_type AS
        SELECT lane_type, COUNT(*) as total_lanes,
               AVG(distance_km) as avg_distance_km,
               AVG(transit_time_days) as avg_transit_days,
               AVG(avg_load_frequency_month) as avg_monthly_frequency
        FROM lanes_master WHERE is_active = TRUE
        GROUP BY lane_type ORDER BY total_lanes DESC;
        """),
        
        ("high_volume_lanes", """
        CREATE OR REPLACE VIEW high_volume_lanes AS
        SELECT lane_id, origin_city, destination_city, distance_km,
               avg_load_frequency_month, avg_load_volume_tons,
               current_rate_trip, preferred_equipment_type
        FROM lanes_master 
        WHERE is_active = TRUE AND avg_load_frequency_month >= 20
        ORDER BY avg_load_frequency_month DESC;
        """),
        
        ("seasonal_lanes", """
        CREATE OR REPLACE VIEW seasonal_lanes AS
        SELECT lane_id, origin_city, destination_city, peak_months,
               avg_load_frequency_month, distance_km, transit_time_days
        FROM lanes_master 
        WHERE is_active = TRUE AND seasonality = TRUE
        ORDER BY avg_load_frequency_month DESC;
        """),
        
        ("equipment_requirements", """
        CREATE OR REPLACE VIEW equipment_requirements AS
        SELECT preferred_equipment_type, COUNT(*) as lane_count,
               AVG(distance_km) as avg_distance,
               AVG(current_rate_trip) as avg_rate
        FROM lanes_master WHERE is_active = TRUE
        GROUP BY preferred_equipment_type ORDER BY lane_count DESC;
        """),
        
        ("rate_analysis", """
        CREATE OR REPLACE VIEW rate_analysis AS
        SELECT lane_id, origin_city, destination_city, distance_km,
               current_rate_trip, benchmark_rate_trip,
               ROUND(((current_rate_trip - benchmark_rate_trip) / benchmark_rate_trip) * 100, 2) as rate_variance_percent,
               fuel_surcharge_applied
        FROM lanes_master 
        WHERE is_active = TRUE AND benchmark_rate_trip IS NOT NULL
        ORDER BY rate_variance_percent DESC;
        """)
    ]
    
    print("👁️ Creating lanes master views...")
    created_count = 0
    
    for view_name, view_sql in views:
        try:
            cursor.execute(view_sql)
            created_count += 1
            print(f"  ✓ Created {view_name} view")
        except Error as e:
            print(f"  ❌ Error creating {view_name} view: {e}")
    
    return created_count

def display_table_info(cursor):
    """Display table structure and sample data."""
    print("\n📊 Lanes Master Table Information:")
    print("=" * 50)
    
    # Show table structure
    cursor.execute("DESCRIBE lanes_master")
    columns = cursor.fetchall()
    
    print("🏗️ Table Structure:")
    for col in columns:
        field, type_info, null, key, default, extra = col
        print(f"  - {field}: {type_info} {'NO' if null == 'NO' else 'YES'} {key if key else ''} {default if default else 'None'} {extra if extra else ''}")
    
    # Count total lanes
    cursor.execute("SELECT COUNT(*) FROM lanes_master")
    total_lanes = cursor.fetchone()[0]
    print(f"\n📈 Total lanes: {total_lanes}")
    
    # Show sample lanes
    cursor.execute("""
        SELECT lane_id, origin_city, destination_city, lane_type, distance_km, 
               avg_load_frequency_month, is_active, last_used_date
        FROM lanes_master ORDER BY avg_load_frequency_month DESC LIMIT 5
    """)
    sample_lanes = cursor.fetchall()
    
    print("\n🔍 Sample lanes:")
    for lane in sample_lanes:
        lane_id, origin, dest, lane_type, distance, frequency, active, last_used = lane
        status_emoji = "🟢" if active else "🔴"
        type_emoji = "🛣️" if lane_type == 'Primary' else "🔄" if lane_type == 'Return' else "📤" if lane_type == 'Outbound' else "📥" if lane_type == 'Inbound' else "🔄"
        print(f"  - {lane_id}: {origin} → {dest} | {lane_type} | {distance}km | {frequency}/month {status_emoji} {type_emoji}")
    
    # Show available views
    cursor.execute("SHOW TABLES LIKE '%view%'")
    views = cursor.fetchall()
    
    print(f"\n👁️ Available Views:")
    for view in views:
        print(f"  - {view[0]}")
    
    print(f"\n✅ All operations completed successfully!")

def main():
    """Main function to create lanes master table."""
    print("🛣️ Creating Lanes Master Table for TL Transportation")
    print("=" * 60)
    
    # Create database connection
    connection = create_database_connection()
    if not connection:
        return
    
    try:
        cursor = connection.cursor()
        
        # Create table
        if not create_lanes_master_table(cursor):
            return
        
        # Insert sample data
        insert_sample_data(cursor, connection)
        
        # Create views
        create_analytical_views(cursor)
        
        # Display table information
        display_table_info(cursor)
        
    except Error as e:
        print(f"❌ Database error: {e}")
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("🔌 Database connection closed")

if __name__ == "__main__":
    main() 