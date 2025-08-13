#!/usr/bin/env python3
"""
Simple Accessorial Definitions Master Table Creation Script
"""

import mysql.connector
import os
from mysql.connector import Error

def get_database_connection():
    """Establish connection to MySQL database."""
    try:
        print("🔍 Connecting to MySQL...")
        connection = mysql.connector.connect(
            host=os.getenv('MYSQL_HOST', 'localhost'),
            user=os.getenv('MYSQL_USER', 'routecraft_user'),
            password=os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
            database=os.getenv('MYSQL_DATABASE', 'routecraft'),
            port=int(os.getenv('MYSQL_PORT', 3306))
        )
        print("✅ Database connection successful!")
        return connection
    except Error as e:
        print(f"❌ Error connecting to MySQL: {e}")
        return None

def create_table(connection):
    """Create the accessorial_definitions_master table."""
    try:
        cursor = connection.cursor()
        
        # Drop table if exists
        print("🔧 Dropping table if exists...")
        cursor.execute("DROP TABLE IF EXISTS accessorial_definitions_master")
        print("✅ Table dropped successfully")
        
        # Create table
        print("🔧 Creating accessorial_definitions_master table...")
        create_sql = """
        CREATE TABLE accessorial_definitions_master (
            accessorial_id VARCHAR(20) PRIMARY KEY,
            accessorial_name VARCHAR(100) NOT NULL,
            description TEXT,
            applies_to ENUM('Pickup', 'Delivery', 'In-Transit', 'General') NOT NULL,
            trigger_condition TEXT NOT NULL,
            rate_type ENUM('Flat Fee', 'Per Hour', 'Per KM', 'Per Attempt', 'Per Pallet', 'Per MT', 'Percentage') NOT NULL,
            rate_value DECIMAL(10,2) NOT NULL,
            unit ENUM('Hours', 'KM', 'Pallet', 'Stop', 'Attempt', 'MT', 'Percentage', 'Flat') NOT NULL,
            taxable BOOLEAN DEFAULT FALSE,
            included_in_base BOOLEAN DEFAULT FALSE,
            invoice_code VARCHAR(50),
            applicable_equipment_types TEXT,
            carrier_editable_in_bid BOOLEAN DEFAULT TRUE,
            is_active BOOLEAN DEFAULT TRUE,
            min_charge DECIMAL(10,2),
            max_charge DECIMAL(10,2),
            free_time_hours INT DEFAULT 0,
            applicable_regions TEXT,
            applicable_lanes TEXT,
            seasonal_applicability TEXT,
            documentation_required BOOLEAN DEFAULT FALSE,
            approval_required BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            created_by VARCHAR(50) DEFAULT 'system',
            updated_by VARCHAR(50) DEFAULT 'system',
            remarks TEXT
        )
        """
        cursor.execute(create_sql)
        print("✅ Table created successfully")
        
        connection.commit()
        cursor.close()
        return True
        
    except Error as e:
        print(f"❌ Error creating table: {e}")
        return False

def insert_sample_data(connection):
    """Insert sample data."""
    try:
        cursor = connection.cursor()
        
        print("🔧 Inserting sample data...")
        
        # First, let's check the table structure
        cursor.execute("DESCRIBE accessorial_definitions_master")
        columns = cursor.fetchall()
        print(f"📊 Table has {len(columns)} columns:")
        for col in columns:
            print(f"   - {col[0]} ({col[1]})")
        
        # Sample data - 25 columns total (excluding created_at and updated_at which have defaults)
        sample_data = [
            ('ACC-DET-001', 'Detention - Loading Site', 'Detention charges for loading delays', 'Pickup', 'After 2 hours of free time', 'Per Hour', 400.00, 'Hours', True, False, 'DET-LOAD', 'All Equipment', True, True, 400.00, 4000.00, 2, 'All India', 'All Lanes', 'Year-round', False, False, 'system', 'system', 'Standard detention charge'),
            ('ACC-DET-002', 'Detention - Delivery Site', 'Detention charges for delivery delays', 'Delivery', 'After 2 hours of free time', 'Per Hour', 400.00, 'Hours', True, False, 'DET-DEL', 'All Equipment', True, True, 400.00, 4000.00, 2, 'All India', 'All Lanes', 'Year-round', False, False, 'system', 'system', 'Standard detention charge'),
            ('ACC-MST-001', 'Multi-Stop Fee', 'Additional charge for multiple delivery stops', 'Delivery', 'More than 1 delivery stop', 'Flat Fee', 800.00, 'Flat', True, False, 'MST-2', 'Container, Open Body', True, True, 800.00, 800.00, 0, 'All India', 'All Lanes', 'Year-round', False, False, 'system', 'system', 'Standard multi-stop charge'),
            ('ACC-LUL-001', 'Driver Assist Loading', 'When driver helps with loading', 'Pickup', 'Driver assistance required', 'Per MT', 150.00, 'MT', True, False, 'LUL-DRIVER', 'All Equipment', False, True, 100.00, 1000.00, 0, 'All India', 'All Lanes', 'Year-round', True, False, 'system', 'system', 'Requires supervisor signature'),
            ('ACC-ESC-001', 'Escort Vehicle Fee', 'Escort for high-value cargo', 'In-Transit', 'Escort vehicle required', 'Per KM', 25.00, 'KM', True, False, 'ESC-VEHICLE', 'Flatbed, ODC', False, True, 500.00, 5000.00, 0, 'All India', 'All Lanes', 'Year-round', True, True, 'system', 'system', 'Requires police permission'),
            ('ACC-NGT-001', 'Night Delivery Charges', 'Delivery outside business hours', 'Delivery', 'Delivery between 8 PM and 6 AM', 'Flat Fee', 500.00, 'Flat', True, False, 'NGT-DEL', 'All Equipment', True, True, 500.00, 500.00, 0, 'Metro Cities', 'Metro Lanes', 'Year-round', False, False, 'system', 'system', 'Night delivery surcharge'),
            ('ACC-FSC-001', 'Fuel Surcharge', 'Fuel surcharge for high diesel prices', 'General', 'Diesel price > ₹100/liter', 'Percentage', 8.00, 'Percentage', True, False, 'FSC-HIGH', 'All Equipment', False, True, 0.00, 0.00, 0, 'All India', 'All Lanes', 'Year-round', False, False, 'system', 'system', 'Variable based on diesel price'),
            ('ACC-REEF-001', 'Reefer Monitoring', 'Temperature monitoring for reefer', 'In-Transit', 'Temperature monitoring required', 'Per Hour', 300.00, 'Hours', True, False, 'REEF-MON', 'Reefer', False, True, 300.00, 300.00, 0, 'All India', 'All Lanes', 'Year-round', False, False, 'system', 'system', 'Daily monitoring charge'),
            ('ACC-DOC-001', 'Weighbridge Fee', 'Mandatory weighing at checkpoints', 'In-Transit', 'Weighing required', 'Per Stop', 150.00, 'Stop', True, False, 'DOC-WEIGH', 'All Equipment', False, True, 150.00, 150.00, 0, 'All India', 'All Lanes', 'Year-round', True, False, 'system', 'system', 'Standard weighbridge charge'),
            ('ACC-MON-001', 'Monsoon Surcharge', 'Monsoon season surcharge', 'General', 'July to September', 'Percentage', 5.00, 'Percentage', True, False, 'MON-SURGE', 'All Equipment', False, True, 0.00, 0.00, 0, 'Coastal Regions', 'Coastal Lanes', 'Monsoon Season', False, False, 'system', 'system', 'Monsoon season surcharge')
        ]
        
        # Check the first tuple length
        first_tuple = sample_data[0]
        print(f"📊 First data tuple has {len(first_tuple)} values")
        print(f"📊 Sample tuple: {first_tuple}")
        
        # INSERT statement with 25 columns (excluding created_at and updated_at which have defaults)
        insert_sql = """
        INSERT INTO accessorial_definitions_master (
            accessorial_id, accessorial_name, description, applies_to, trigger_condition,
            rate_type, rate_value, unit, taxable, included_in_base, invoice_code,
            applicable_equipment_types, carrier_editable_in_bid, is_active, min_charge,
            max_charge, free_time_hours, applicable_regions, applicable_lanes,
            seasonal_applicability, documentation_required, approval_required,
            created_by, updated_by, remarks
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        # Count the %s placeholders
        placeholder_count = insert_sql.count('%s')
        print(f"📊 INSERT statement has {placeholder_count} placeholders")
        
        # Verify the data tuples have the right number of values
        print(f"📊 Data tuples have {len(first_tuple)} values")
        if len(first_tuple) == placeholder_count:
            print("✅ Column count matches data tuple count")
        else:
            print(f"❌ Mismatch: {placeholder_count} columns vs {len(first_tuple)} values")
            return False
        
        cursor.executemany(insert_sql, sample_data)
        print(f"✅ Inserted {len(sample_data)} records successfully")
        
        connection.commit()
        cursor.close()
        return True
        
    except Error as e:
        print(f"❌ Error inserting sample data: {e}")
        return False

def verify_table(connection):
    """Verify table creation."""
    try:
        cursor = connection.cursor()
        
        # Check table exists
        cursor.execute("SHOW TABLES LIKE 'accessorial_definitions_master'")
        if cursor.fetchone():
            print("✅ Table exists")
        else:
            print("❌ Table not found")
            return False
        
        # Check record count
        cursor.execute("SELECT COUNT(*) FROM accessorial_definitions_master")
        count = cursor.fetchone()[0]
        print(f"✅ Table has {count} records")
        
        cursor.close()
        return True
        
    except Error as e:
        print(f"❌ Error verifying table: {e}")
        return False

def main():
    """Main function."""
    print("🚀 Creating Accessorial Definitions Master Table")
    print("=" * 50)
    
    connection = get_database_connection()
    if not connection:
        return
    
    try:
        if create_table(connection):
            if insert_sample_data(connection):
                verify_table(connection)
                print("\n🎉 Table created successfully!")
            else:
                print("❌ Failed to insert data")
        else:
            print("❌ Failed to create table")
            
    except Error as e:
        print(f"❌ Error: {e}")
    finally:
        if connection.is_connected():
            connection.close()

if __name__ == "__main__":
    main() 