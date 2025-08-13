#!/usr/bin/env python3
"""
Equipment Types Master Table Creation Script
This script creates the equipment_types_master table and populates it with sample data.
"""

import mysql.connector
import os
from mysql.connector import Error

def create_database_connection():
    """Create and return a database connection."""
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER', 'routecraft_user'),
            password=os.getenv('DB_PASSWORD', ''),
            database=os.getenv('DB_NAME', 'routecraft'),
            charset='utf8mb4'
        )
        if connection.is_connected():
            print("✅ Successfully connected to MySQL database")
            return connection
    except Error as e:
        print(f"❌ Error connecting to MySQL: {e}")
        return None

def execute_sql_file(connection, sql_file_path):
    """Execute SQL commands from a file."""
    try:
        cursor = connection.cursor()
        
        # Read the SQL file
        with open(sql_file_path, 'r', encoding='utf-8') as file:
            sql_content = file.read()
        
        # Split by semicolon and execute each statement
        statements = sql_content.split(';')
        
        for statement in statements:
            statement = statement.strip()
            if statement and not statement.startswith('--'):
                try:
                    cursor.execute(statement)
                    print(f"✅ Executed: {statement[:50]}...")
                except Error as e:
                    print(f"⚠️  Warning executing statement: {e}")
                    print(f"Statement: {statement[:100]}...")
        
        connection.commit()
        print("✅ SQL file execution completed")
        return True
        
    except Error as e:
        print(f"❌ Error executing SQL file: {e}")
        return False
    finally:
        if cursor:
            cursor.close()

def verify_table_creation(connection):
    """Verify that the table was created successfully."""
    try:
        cursor = connection.cursor()
        
        # Check if table exists
        cursor.execute("SHOW TABLES LIKE 'equipment_types_master'")
        table_exists = cursor.fetchone()
        
        if table_exists:
            print("✅ equipment_types_master table found")
            
            # Get table structure
            cursor.execute("DESCRIBE equipment_types_master")
            columns = cursor.fetchall()
            print(f"✅ Table has {len(columns)} columns")
            
            # Get row count
            cursor.execute("SELECT COUNT(*) FROM equipment_types_master")
            row_count = cursor.fetchone()[0]
            print(f"✅ Table contains {row_count} rows")
            
            return True
        else:
            print("❌ equipment_types_master table not found")
            return False
            
    except Error as e:
        print(f"❌ Error verifying table: {e}")
        return False
    finally:
        if cursor:
            cursor.close()

def verify_views_creation(connection):
    """Verify that the views were created successfully."""
    try:
        cursor = connection.cursor()
        
        views_to_check = [
            'equipment_summary',
            'temperature_controlled_equipment',
            'high_capacity_equipment',
            'specialized_equipment',
            'cost_effective_equipment'
        ]
        
        created_views = []
        for view in views_to_check:
            cursor.execute(f"SHOW TABLES LIKE '{view}'")
            if cursor.fetchone():
                created_views.append(view)
                print(f"✅ View '{view}' created successfully")
            else:
                print(f"❌ View '{view}' not found")
        
        print(f"✅ {len(created_views)} out of {len(views_to_check)} views created")
        return len(created_views) == len(views_to_check)
        
    except Error as e:
        print(f"❌ Error verifying views: {e}")
        return False
    finally:
        if cursor:
            cursor.close()

def display_sample_data(connection):
    """Display sample data from the table."""
    try:
        cursor = connection.cursor()
        
        print("\n📊 Sample Equipment Types Data:")
        print("-" * 80)
        
        cursor.execute("""
            SELECT 
                equipment_id, 
                equipment_name, 
                vehicle_body_type, 
                vehicle_length_ft,
                payload_capacity_tons,
                temperature_controlled,
                hazmat_certified,
                active
            FROM equipment_types_master 
            LIMIT 10
        """)
        
        rows = cursor.fetchall()
        for row in rows:
            print(f"ID: {row[0]:<12} | Name: {row[1]:<35} | Type: {row[2]:<12} | Length: {row[3]:<4}ft | Payload: {row[4]:<4} tons | Temp: {row[5]:<5} | Hazmat: {row[6]:<5} | Active: {row[7]}")
        
        print("-" * 80)
        
    except Error as e:
        print(f"❌ Error displaying sample data: {e}")
    finally:
        if cursor:
            cursor.close()

def main():
    """Main function to create the equipment types master table."""
    print("🚛 Creating Equipment Types Master Table")
    print("=" * 50)
    
    # Create database connection
    connection = create_database_connection()
    if not connection:
        return
    
    try:
        # Execute SQL schema file
        sql_file = "equipment_types_master_schema.sql"
        if os.path.exists(sql_file):
            print(f"📁 Executing SQL schema from: {sql_file}")
            success = execute_sql_file(connection, sql_file)
            
            if success:
                # Verify table creation
                print("\n🔍 Verifying table creation...")
                if verify_table_creation(connection):
                    print("✅ Table verification successful")
                    
                    # Verify views creation
                    print("\n🔍 Verifying views creation...")
                    if verify_views_creation(connection):
                        print("✅ Views verification successful")
                        
                        # Display sample data
                        display_sample_data(connection)
                        
                        print("\n🎉 Equipment Types Master table created successfully!")
                        print("\n📋 Summary:")
                        print("   • Table: equipment_types_master")
                        print("   • Views: 5 analytical views")
                        print("   • Sample Data: 15 equipment types")
                        print("   • Features: Comprehensive equipment specifications")
                    else:
                        print("❌ Views verification failed")
                else:
                    print("❌ Table verification failed")
            else:
                print("❌ SQL file execution failed")
        else:
            print(f"❌ SQL file not found: {sql_file}")
    
    except Error as e:
        print(f"❌ Database operation error: {e}")
    
    finally:
        if connection and connection.is_connected():
            connection.close()
            print("🔌 Database connection closed")

if __name__ == "__main__":
    main() 