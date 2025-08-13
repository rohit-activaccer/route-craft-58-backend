#!/usr/bin/env python3
"""
Debug Service Levels Table Structure
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

def debug_table_structure():
    """Debug the table structure to understand the INSERT issue"""
    
    load_dotenv()
    
    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }
    
    try:
        connection = mysql.connector.connect(**config)
        
        if connection.is_connected():
            cursor = connection.cursor()
            
            # Get table structure
            cursor.execute("DESCRIBE service_levels_master")
            columns = cursor.fetchall()
            
            print("📋 Table Structure:")
            print(f"{'Field':<35} {'Type':<25} {'Null':<8} {'Key':<8} {'Default':<15} {'Extra'}")
            print("-" * 100)
            
            column_names = []
            for column in columns:
                field, type_name, null, key, default, extra = column
                column_names.append(field)
                print(f"{field:<35} {type_name:<25} {null:<8} {key:<8} {str(default):<15} {extra}")
            
            print(f"\n📊 Total columns: {len(columns)}")
            print(f"📝 Column names: {', '.join(column_names)}")
            
            # Test a simple INSERT with minimal data
            print("\n🧪 Testing minimal INSERT...")
            test_insert_sql = """
            INSERT INTO service_levels_master (
                service_level_id, service_level_name, max_transit_time_days
            ) VALUES (%s, %s, %s)
            """
            
            test_data = ('SL-TEST-01', 'Test Service', 2.0)
            
            try:
                cursor.execute(test_insert_sql, test_data)
                print("✅ Minimal INSERT successful!")
                
                # Clean up test data
                cursor.execute("DELETE FROM service_levels_master WHERE service_level_id = 'SL-TEST-01'")
                print("🧹 Test data cleaned up")
                
            except Error as e:
                print(f"❌ Minimal INSERT failed: {e}")
            
            # Test with all columns except auto-generated ones
            print("\n🧪 Testing full INSERT...")
            full_insert_sql = """
            INSERT INTO service_levels_master (
                service_level_id, service_level_name, description, max_transit_time_days,
                allowed_delay_buffer_hours, fixed_departure_time, fixed_delivery_time,
                mode, carrier_response_time_hours, sla_type, penalty_applicable,
                penalty_rule_id, priority_tag, enabled_for_bidding, service_category,
                pickup_time_window_start, pickup_time_window_end, delivery_time_window_start,
                delivery_time_window_end, weekend_operations, holiday_operations,
                temperature_controlled, security_required, insurance_coverage,
                fuel_surcharge_applicable, detention_charges_applicable, remarks
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            # Count placeholders
            placeholder_count = full_insert_sql.count('%s')
            print(f"🔢 Placeholders in INSERT: {placeholder_count}")
            
            # Count columns in INSERT statement
            columns_in_insert = full_insert_sql.split('(')[1].split(')')[0].split(',')
            columns_in_insert = [col.strip() for col in columns_in_insert]
            print(f"🔢 Columns in INSERT: {len(columns_in_insert)}")
            print(f"📝 Columns: {', '.join(columns_in_insert)}")
            
            # Test with actual data
            test_full_data = (
                'SL-TEST-02', 'Test Full Service', 'Test description', 2.0, 1.0, 'No', 'No',
                'TL', 24.0, 'Soft SLA', 'No', None, 'Medium', 'Yes', 'Standard',
                None, None, None, None, 'No', 'No', 'No', 'No', 50000.00, 'Yes', 'Yes',
                'Test remarks'
            )
            
            print(f"🔢 Data tuple length: {len(test_full_data)}")
            
            try:
                cursor.execute(full_insert_sql, test_full_data)
                print("✅ Full INSERT successful!")
                
                # Clean up test data
                cursor.execute("DELETE FROM service_levels_master WHERE service_level_id = 'SL-TEST-02'")
                print("🧹 Test data cleaned up")
                
            except Error as e:
                print(f"❌ Full INSERT failed: {e}")
            
            connection.commit()
            
    except Error as e:
        print(f"❌ Error: {e}")
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("🔌 Database connection closed")

if __name__ == "__main__":
    debug_table_structure() 