#!/usr/bin/env python3
"""Locations Master Table Creation Script"""

import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

def create_locations_master_table():
    """Create the locations_master table for TL transportation"""
    
    print("📍 Creating Locations Master Table for TL Transportation")
    print("=" * 60)
    
    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }
    
    try:
        connection = mysql.connector.connect(**config)
        cursor = connection.cursor()
        print("✅ Connected to MySQL database successfully!")
        
        # Create table
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS locations_master (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            location_id VARCHAR(50) NOT NULL UNIQUE,
            location_name VARCHAR(255) NOT NULL,
            location_type ENUM('Factory', 'Warehouse', 'Customer', 'Port', 'CFS', 'Depot', 'Hub', 'Transit Point', 'Distribution Center', 'Retail Store', 'Office', 'Other') NOT NULL,
            address_line_1 VARCHAR(255) NOT NULL,
            city VARCHAR(100) NOT NULL,
            state VARCHAR(100) NOT NULL,
            pincode VARCHAR(10) NOT NULL,
            country VARCHAR(50) DEFAULT 'India',
            latitude DECIMAL(10, 8),
            longitude DECIMAL(11, 8),
            zone ENUM('North India', 'South India', 'East India', 'West India', 'Central India', 'Export Hub', 'Import Hub', 'Transit Zone', 'Other'),
            gstin VARCHAR(15),
            location_contact_name VARCHAR(255),
            phone_number VARCHAR(20),
            email VARCHAR(255),
            working_hours VARCHAR(100),
            loading_unloading_sla INT,
            dock_type ENUM('Ground-level', 'Hydraulic', 'Ramp', 'Platform', 'Container', 'Bulk', 'Other'),
            parking_available ENUM('Yes', 'No', 'Limited') DEFAULT 'No',
            equipment_access JSON,
            is_consolidation_hub ENUM('Yes', 'No') DEFAULT 'No',
            preferred_mode ENUM('TL', 'LTL', 'Rail', 'Multimodal', 'Any') DEFAULT 'Any',
            hazmat_allowed ENUM('Yes', 'No', 'Limited') DEFAULT 'No',
            auto_scheduling_enabled ENUM('Yes', 'No') DEFAULT 'No',
            location_status ENUM('Active', 'Inactive', 'Temporary', 'Under Maintenance') DEFAULT 'Active',
            remarks TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            created_by VARCHAR(100),
            updated_by VARCHAR(100),
            
            INDEX idx_location_type (location_type),
            INDEX idx_city_state (city, state),
            INDEX idx_zone (zone),
            INDEX idx_status (location_status),
            INDEX idx_coordinates (latitude, longitude),
            INDEX idx_gstin (gstin),
            INDEX idx_dock_type (dock_type),
            INDEX idx_preferred_mode (preferred_mode),
            INDEX idx_hazmat (hazmat_allowed),
            INDEX idx_consolidation (is_consolidation_hub),
            INDEX idx_auto_scheduling (auto_scheduling_enabled)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        cursor.execute(create_table_sql)
        print("✅ Table created successfully!")
        
        # Insert sample data
        print("📝 Inserting sample location data...")
        insert_sample_data(cursor)
        
        # Create views
        print("👁️ Creating location master views...")
        create_views(cursor)
        
        show_table_info(cursor)
        print("✅ All operations completed successfully!")
        
    except mysql.connector.Error as err:
        print(f"❌ MySQL Error: {err}")
    except Exception as e:
        print(f"❌ Error: {e}")
    finally:
        if 'connection' in locals() and connection.is_connected():
            cursor.close()
            connection.close()
            print("🔌 Database connection closed")

def insert_sample_data(cursor):
    """Insert sample location data"""
    
    sample_locations = [
        ('WH-BLR-01', 'Bangalore Central Warehouse', 'Warehouse', 'Plot No. 45, Industrial Area', 'Bangalore', 'Karnataka', '560100', 'India', 12.9352, 77.6145, 'South India', '29ABCDE1234Z5F', 'Rajesh Kumar', '+91-9876543210', 'rajesh.kumar@company.com', '9AM-7PM, Mon-Sat', 90, 'Ground-level', 'Yes', '["Forklift", "Pallet Jack", "Crane"]', 'Yes', 'Any', 'No', 'Yes', 'Active', 'Primary distribution center for South India'),
        ('WH-MUM-01', 'Mumbai Western Warehouse', 'Warehouse', 'A-123, MIDC Industrial Area', 'Mumbai', 'Maharashtra', '400069', 'India', 19.0760, 72.8777, 'West India', '27FGHIJ6789K1L2', 'Priya Sharma', '+91-8765432109', 'priya.sharma@company.com', '8AM-6PM, Mon-Sat', 75, 'Hydraulic', 'Yes', '["Forklift", "Crane", "Conveyor"]', 'Yes', 'Any', 'Limited', 'Yes', 'Active', 'Export hub with customs clearance facility'),
        ('FACTORY-CHN-01', 'Chennai Manufacturing Plant', 'Factory', 'Plot 78, SIPCOT Industrial Park', 'Chennai', 'Tamil Nadu', '602105', 'India', 12.9716, 79.5946, 'South India', '33RSTUV9012W3X4', 'Senthil Kumar', '+91-6543210987', 'senthil.kumar@company.com', '24/7 Operations', 120, 'Platform', 'Yes', '["Crane", "Forklift", "Automated System"]', 'No', 'TL', 'Limited', 'Yes', 'Active', 'Automotive parts manufacturing, heavy machinery access'),
        ('CUST-HYD-01', 'Hyderabad Customer DC', 'Customer', 'Customer Distribution Center', 'Hyderabad', 'Telangana', '500032', 'India', 17.3850, 78.4867, 'South India', None, 'Customer Logistics Team', '+91-4321098765', 'logistics@customer.com', '9AM-5PM, Mon-Fri', 60, 'Ground-level', 'No', '["Basic Equipment"]', 'No', 'Any', 'No', 'No', 'Active', 'Customer-owned facility, appointment required'),
        ('PORT-MUM-01', 'Mumbai Port Terminal', 'Port', 'Mumbai Port Trust', 'Mumbai', 'Maharashtra', '400001', 'India', 18.9490, 72.8345, 'Export Hub', None, 'Port Operations', '+91-2109876543', 'operations@mumbaiport.gov.in', '24/7 Operations', 180, 'Container', 'Yes', '["Gantry Crane", "Reach Stacker", "Forklift"]', 'Yes', 'Multimodal', 'Limited', 'Yes', 'Active', 'Major container port, customs clearance available')
    ]
    
    insert_sql = """
    INSERT INTO locations_master (
        location_id, location_name, location_type, address_line_1, city, state, pincode, country,
        latitude, longitude, zone, gstin, location_contact_name, phone_number, email, working_hours,
        loading_unloading_sla, dock_type, parking_available, equipment_access, is_consolidation_hub,
        preferred_mode, hazmat_allowed, auto_scheduling_enabled, location_status, remarks
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    for location in sample_locations:
        try:
            cursor.execute(insert_sql, location)
            print(f"  ✓ Inserted {location[0]}: {location[1]}")
        except mysql.connector.Error as err:
            print(f"  ✗ Error inserting {location[0]}: {err}")
    
    connection.commit()
    print(f"✅ Inserted {len(sample_locations)} sample locations")

def create_views(cursor):
    """Create analytical views"""
    
    views = [
        ("active_locations_by_type", """
        CREATE OR REPLACE VIEW active_locations_by_type AS
        SELECT location_type, COUNT(*) as count, 
               AVG(loading_unloading_sla) as avg_sla,
               COUNT(CASE WHEN parking_available = 'Yes' THEN 1 END) as parking_available_count
        FROM locations_master WHERE location_status = 'Active'
        GROUP BY location_type ORDER BY count DESC;
        """),
        
        ("locations_by_zone", """
        CREATE OR REPLACE VIEW locations_by_zone AS
        SELECT zone, COUNT(*) as total_locations,
               COUNT(CASE WHEN location_type = 'Warehouse' THEN 1 END) as warehouses,
               COUNT(CASE WHEN location_type = 'Factory' THEN 1 END) as factories
        FROM locations_master WHERE location_status = 'Active'
        GROUP BY zone ORDER BY total_locations DESC;
        """),
        
        ("equipment_availability", """
        CREATE OR REPLACE VIEW equipment_availability AS
        SELECT location_id, location_name, location_type, city, state,
               equipment_access, dock_type, parking_available
        FROM locations_master WHERE location_status = 'Active'
        ORDER BY location_type, city;
        """)
    ]
    
    for view_name, view_sql in views:
        try:
            cursor.execute(view_sql)
            print(f"  ✓ Created {view_name} view")
        except mysql.connector.Error as err:
            print(f"  ✗ Error creating {view_name}: {err}")

def show_table_info(cursor):
    """Display table information"""
    
    print("\n📊 Locations Master Table Information:")
    print("=" * 50)
    
    cursor.execute("DESCRIBE locations_master")
    columns = cursor.fetchall()
    
    print("🏗️ Table Structure:")
    for col in columns:
        print(f"  - {col[0]}: {col[1]} {col[2]} {col[3]} {col[4]} {col[5]}")
    
    cursor.execute("SELECT COUNT(*) FROM locations_master")
    count = cursor.fetchone()[0]
    print(f"\n📈 Total locations: {count}")
    
    cursor.execute("""
        SELECT location_id, location_name, location_type, city, state, 
               zone, location_status, auto_scheduling_enabled
        FROM locations_master ORDER BY location_type, city LIMIT 5
    """)
    sample_data = cursor.fetchall()
    
    print("\n🔍 Sample locations:")
    for row in sample_data:
        status_icon = "🟢" if row[6] == 'Active' else "🔴"
        auto_sched = "🤖" if row[7] == 'Yes' else "👤"
        print(f"  - {row[0]}: {row[1]} | {row[2]} | {row[3]}, {row[4]} | {row[5]} {status_icon} {auto_sched}")
    
    cursor.execute("SHOW TABLES LIKE '%view%'")
    views = cursor.fetchall()
    print(f"\n👁️ Available Views:")
    for view in views:
        view_name = view[0]
        cursor.execute(f"SELECT COUNT(*) FROM {view_name}")
        count = cursor.fetchone()[0]
        print(f"  - {view_name}: {count} records")

if __name__ == "__main__":
    create_locations_master_table() 