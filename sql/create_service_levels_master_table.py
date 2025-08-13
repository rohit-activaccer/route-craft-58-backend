#!/usr/bin/env python3
"""
Create Service Levels Master Table for TL Transportation
=======================================================

This script creates the service_levels_master table which defines service level
configurations for shipments, including quality, speed, and operational expectations
that drive SLA-based performance tracking and differential pricing.
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

def create_service_levels_master_table(cursor):
    """Create the service_levels_master table."""
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS service_levels_master (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        service_level_id VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique ID (e.g., SL-001)',
        service_level_name VARCHAR(100) NOT NULL COMMENT 'Descriptive name: Standard, Express, Scheduled, Time-definite',
        description TEXT COMMENT 'Short detail (e.g., Delivery within 36 hours, or Fixed time slot)',
        max_transit_time_days INT NOT NULL COMMENT 'Maximum transit time in days (e.g., 1, 2, or 3 days)',
        allowed_delay_buffer_hours DECIMAL(4,1) DEFAULT 0.0 COMMENT 'Permissible delay threshold in hours (e.g., 2 hrs)',
        fixed_departure_time BOOLEAN DEFAULT FALSE COMMENT 'Is pickup expected at a fixed hour/day?',
        fixed_delivery_time BOOLEAN DEFAULT FALSE COMMENT 'Is delivery time-specific (e.g., before 10AM)?',
        mode ENUM('TL', 'LTL', 'Rail-Road', 'Multimodal', 'Express', 'Dedicated') DEFAULT 'TL' COMMENT 'Transportation mode',
        carrier_response_time_hours INT DEFAULT 24 COMMENT 'Expected time for carrier to accept the load in hours',
        sla_type ENUM('Hard SLA', 'Soft SLA', 'Advisory') DEFAULT 'Soft SLA' COMMENT 'Hard SLA (mandatory) / Soft SLA (advisory)',
        penalty_applicable BOOLEAN DEFAULT FALSE COMMENT 'Is penalty applied for failure to meet SLA?',
        penalty_rule_id VARCHAR(50) COMMENT 'Link to penalty definition (e.g., % of freight)',
        priority_tag ENUM('High', 'Medium', 'Low') DEFAULT 'Medium' COMMENT 'Priority for planning preference',
        enabled_for_bidding BOOLEAN DEFAULT TRUE COMMENT 'Whether this service level can be selected in RFPs',
        is_active BOOLEAN DEFAULT TRUE COMMENT 'Whether this service level is currently active',
        remarks TEXT COMMENT 'Additional notes (e.g., Used for VIP cargo, applies only on exports)',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        created_by VARCHAR(100),
        updated_by VARCHAR(100),
        
        INDEX idx_service_level_name (service_level_name),
        INDEX idx_transit_time (max_transit_time_days),
        INDEX idx_mode (mode),
        INDEX idx_sla_type (sla_type),
        INDEX idx_priority (priority_tag),
        INDEX idx_bidding_enabled (enabled_for_bidding),
        INDEX idx_active (is_active)
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
    """Insert sample service level data."""
    sample_service_levels = [
        ('SL-STD-01', 'Standard Delivery', 'Delivery within 3-4 days, normal operating conditions', 3, 4.0, False, False, 'TL', 24, 'Soft SLA', False, None, 'Medium', True, True, 'Standard service for regular shipments'),
        ('SL-EXP-01', 'Express Delivery', 'Delivery in 1-2 days, fast turnaround priority', 1, 1.0, False, True, 'Express', 12, 'Hard SLA', True, 'PEN-EXP-01', 'High', True, True, 'Used for high-value pharma shipments'),
        ('SL-TIME-01', 'Time-Definite Delivery', 'Delivery or pickup must happen at a defined time window', 2, 0.5, True, True, 'Dedicated', 6, 'Hard SLA', True, 'PEN-TIME-01', 'High', True, True, 'Critical time-sensitive shipments'),
        ('SL-SCH-01', 'Scheduled Pickup/Delivery', 'Pre-booked time slots at dock - reduces wait time', 2, 2.0, True, True, 'TL', 18, 'Soft SLA', False, None, 'Medium', True, True, 'Reduces dock congestion and wait times'),
        ('SL-DED-01', 'Dedicated Service', 'Specific vehicle assigned, no load sharing', 3, 2.0, False, False, 'Dedicated', 24, 'Soft SLA', False, None, 'Medium', True, True, 'Exclusive vehicle for premium customers'),
        ('SL-WHITE-01', 'White Glove Service', 'High-touch handling, security, extra personnel', 2, 1.0, True, True, 'Dedicated', 12, 'Hard SLA', True, 'PEN-WHITE-01', 'High', True, True, 'Luxury goods and high-value items'),
        ('SL-OVERNIGHT-01', 'Overnight Express', 'Next-day delivery for urgent shipments', 1, 0.5, False, True, 'Express', 6, 'Hard SLA', True, 'PEN-OVERNIGHT-01', 'High', True, True, 'Critical overnight deliveries'),
        ('SL-ECONOMY-01', 'Economy Service', 'Cost-effective delivery with extended transit time', 5, 8.0, False, False, 'TL', 48, 'Advisory', False, None, 'Low', True, True, 'Budget-friendly option for non-urgent shipments'),
        ('SL-REEFER-01', 'Temperature Controlled', 'Maintains specific temperature throughout transit', 3, 2.0, False, False, 'TL', 24, 'Hard SLA', True, 'PEN-REEFER-01', 'Medium', True, True, 'Pharma, food, and chemical shipments'),
        ('SL-HAZMAT-01', 'Hazardous Goods', 'Special handling for dangerous materials', 4, 4.0, True, True, 'Dedicated', 36, 'Hard SLA', True, 'PEN-HAZMAT-01', 'High', True, True, 'Compliance-driven service for dangerous goods')
    ]
    
    insert_sql = """
    INSERT INTO service_levels_master (
        service_level_id, service_level_name, description, max_transit_time_days,
        allowed_delay_buffer_hours, fixed_departure_time, fixed_delivery_time, mode,
        carrier_response_time_hours, sla_type, penalty_applicable, penalty_rule_id,
        priority_tag, enabled_for_bidding, is_active, remarks
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    print("📝 Inserting sample service level data...")
    inserted_count = 0
    
    for service_level in sample_service_levels:
        try:
            cursor.execute(insert_sql, service_level)
            inserted_count += 1
            print(f"  ✓ Inserted {service_level[0]}: {service_level[1]}")
        except Error as e:
            print(f"  ❌ Error inserting {service_level[0]}: {e}")
    
    connection.commit()
    print(f"✅ Inserted {inserted_count} sample service levels")
    return inserted_count

def create_analytical_views(cursor):
    """Create analytical views for service levels analysis."""
    views = [
        ("active_service_levels", """
        CREATE OR REPLACE VIEW active_service_levels AS
        SELECT service_level_id, service_level_name, max_transit_time_days,
               mode, sla_type, priority_tag, enabled_for_bidding
        FROM service_levels_master WHERE is_active = TRUE
        ORDER BY priority_tag DESC, max_transit_time_days ASC;
        """),
        
        ("service_levels_by_mode", """
        CREATE OR REPLACE VIEW service_levels_by_mode AS
        SELECT mode, COUNT(*) as total_levels,
               AVG(max_transit_time_days) as avg_transit_days,
               COUNT(CASE WHEN penalty_applicable = TRUE THEN 1 END) as penalty_enabled_count
        FROM service_levels_master WHERE is_active = TRUE
        GROUP BY mode ORDER BY total_levels DESC;
        """),
        
        ("high_priority_service_levels", """
        CREATE OR REPLACE VIEW high_priority_service_levels AS
        SELECT service_level_id, service_level_name, max_transit_time_days,
               allowed_delay_buffer_hours, sla_type, penalty_applicable
        FROM service_levels_master 
        WHERE is_active = TRUE AND priority_tag = 'High'
        ORDER BY max_transit_time_days ASC;
        """),
        
        ("sla_compliance_analysis", """
        CREATE OR REPLACE VIEW sla_compliance_analysis AS
        SELECT sla_type, COUNT(*) as service_level_count,
               AVG(max_transit_time_days) as avg_transit_time,
               COUNT(CASE WHEN penalty_applicable = TRUE THEN 1 END) as penalty_count
        FROM service_levels_master WHERE is_active = TRUE
        GROUP BY sla_type ORDER BY service_level_count DESC;
        """),
        
        ("bidding_eligible_service_levels", """
        CREATE OR REPLACE VIEW bidding_eligible_service_levels AS
        SELECT service_level_id, service_level_name, max_transit_time_days,
               mode, priority_tag, sla_type, penalty_applicable
        FROM service_levels_master 
        WHERE is_active = TRUE AND enabled_for_bidding = TRUE
        ORDER BY priority_tag DESC, max_transit_time_days ASC;
        """)
    ]
    
    print("👁️ Creating service levels master views...")
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
    print("\n📊 Service Levels Master Table Information:")
    print("=" * 55)
    
    # Show table structure
    cursor.execute("DESCRIBE service_levels_master")
    columns = cursor.fetchall()
    
    print("🏗️ Table Structure:")
    for col in columns:
        field, type_info, null, key, default, extra = col
        print(f"  - {field}: {type_info} {'NO' if null == 'NO' else 'YES'} {key if key else ''} {default if default else 'None'} {extra if extra else ''}")
    
    # Count total service levels
    cursor.execute("SELECT COUNT(*) FROM service_levels_master")
    total_levels = cursor.fetchone()[0]
    print(f"\n📈 Total service levels: {total_levels}")
    
    # Show sample service levels
    cursor.execute("""
        SELECT service_level_id, service_level_name, max_transit_time_days, 
               mode, priority_tag, sla_type, penalty_applicable, enabled_for_bidding
        FROM service_levels_master ORDER BY priority_tag DESC, max_transit_time_days ASC LIMIT 8
    """)
    sample_levels = cursor.fetchall()
    
    print("\n🔍 Sample service levels:")
    for level in sample_levels:
        sl_id, sl_name, transit_days, mode, priority, sla_type, penalty, bidding = level
        priority_emoji = "🔴" if priority == 'High' else "🟡" if priority == 'Medium' else "🟢"
        sla_emoji = "⚡" if sla_type == 'Hard SLA' else "📋" if sla_type == 'Soft SLA' else "💡"
        penalty_emoji = "💰" if penalty else "✅"
        bidding_emoji = "📝" if bidding else "❌"
        print(f"  - {sl_id}: {sl_name} | {transit_days} days | {mode} {priority_emoji} {sla_emoji} {penalty_emoji} {bidding_emoji}")
    
    # Show available views
    cursor.execute("SHOW TABLES LIKE '%view%'")
    views = cursor.fetchall()
    
    print(f"\n👁️ Available Views:")
    for view in views:
        print(f"  - {view[0]}")
    
    print(f"\n✅ All operations completed successfully!")

def main():
    """Main function to create service levels master table."""
    print("🎯 Creating Service Levels Master Table for TL Transportation")
    print("=" * 65)
    
    # Create database connection
    connection = create_database_connection()
    if not connection:
        return
    
    try:
        cursor = connection.cursor()
        
        # Create table
        if not create_service_levels_master_table(cursor):
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