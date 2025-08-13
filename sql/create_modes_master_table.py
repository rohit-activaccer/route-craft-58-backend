#!/usr/bin/env python3
"""
Create Modes Master Table
RouteCraft Transport Procurement System

This script creates the modes_master table and populates it with comprehensive
transportation mode data for TL, LTL, Rail, Air, and specialized services.
"""

import mysql.connector
from mysql.connector import Error
import os
from datetime import datetime

def create_database_connection():
    """Create database connection using environment variables"""
    try:
        connection = mysql.connector.connect(
            host=os.getenv('MYSQL_HOST', 'localhost'),
            user=os.getenv('MYSQL_USER', 'routecraft_user'),
            password=os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
            database=os.getenv('MYSQL_DATABASE', 'routecraft'),
            port=int(os.getenv('MYSQL_PORT', 3306))
        )
        
        if connection.is_connected():
            print("✅ Connected to MySQL database successfully")
            return connection
    except Error as e:
        print(f"❌ Error connecting to MySQL: {e}")
        return None

def execute_sql_file(connection, file_path):
    """Execute SQL file with multiple statements"""
    try:
        cursor = connection.cursor()
        
        # Read the SQL file
        with open(file_path, 'r') as file:
            sql_content = file.read()
        
        # Split by semicolon and execute each statement
        statements = sql_content.split(';')
        
        for statement in statements:
            statement = statement.strip()
            if statement and not statement.startswith('--'):
                try:
                    cursor.execute(statement)
                    print(f"  ✓ Executed: {statement[:50]}...")
                except Error as e:
                    if "already exists" not in str(e).lower():
                        print(f"  ⚠️  Warning: {e}")
        
        connection.commit()
        print("✅ SQL file executed successfully")
        return True
        
    except Error as e:
        print(f"❌ Error executing SQL file: {e}")
        return False

def verify_table_creation(connection):
    """Verify that the table was created successfully"""
    try:
        cursor = connection.cursor()
        
        # Check if table exists
        cursor.execute("SHOW TABLES LIKE 'modes_master'")
        result = cursor.fetchone()
        
        if result:
            print("✅ modes_master table created successfully")
            
            # Check table structure
            cursor.execute("DESCRIBE modes_master")
            columns = cursor.fetchall()
            print(f"📊 Table has {len(columns)} columns")
            
            # Check data count
            cursor.execute("SELECT COUNT(*) FROM modes_master")
            count = cursor.fetchone()[0]
            print(f"📊 Table contains {count} records")
            
            return True
        else:
            print("❌ modes_master table not found")
            return False
            
    except Error as e:
        print(f"❌ Error verifying table: {e}")
        return False

def verify_views_creation(connection):
    """Verify that the views were created successfully"""
    try:
        cursor = connection.cursor()
        
        views = [
            'active_modes_summary',
            'mode_capabilities', 
            'cost_effective_modes',
            'time_critical_modes',
            'specialized_modes'
        ]
        
        print("🔍 Verifying views...")
        for view in views:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {view}")
                count = cursor.fetchone()[0]
                print(f"  ✅ {view}: {count} records")
            except Error as e:
                print(f"  ❌ {view}: {e}")
        
        return True
        
    except Error as e:
        print(f"❌ Error verifying views: {e}")
        return False

def display_sample_data(connection):
    """Display sample data from the modes_master table"""
    try:
        cursor = connection.cursor()
        
        print("\n📋 Sample Modes Data:")
        print("=" * 80)
        
        # Display modes by type
        cursor.execute("""
            SELECT mode_type, COUNT(*) as count 
            FROM modes_master 
            GROUP BY mode_type 
            ORDER BY mode_type
        """)
        
        mode_counts = cursor.fetchall()
        for mode_type, count in mode_counts:
            print(f"  {mode_type}: {count} modes")
        
        print("\n🚚 Mode Details by Type:")
        print("-" * 80)
        
        cursor.execute("""
            SELECT mode_id, mode_name, mode_type, transit_time_days, 
                   cost_efficiency_level, speed_level, base_cost_multiplier
            FROM modes_master 
            ORDER BY mode_type, transit_time_days
        """)
        
        modes = cursor.fetchall()
        for mode in modes:
            mode_id, name, mode_type, transit_time, efficiency, speed, cost_mult = mode
            print(f"  {mode_id:<12} | {name:<25} | {mode_type:<10} | "
                  f"{transit_time:>4.1f} days | {efficiency:<5} | {speed:<8} | {cost_mult:>5.2f}x")
        
        return True
        
    except Error as e:
        print(f"❌ Error displaying sample data: {e}")
        return False

def main():
    """Main function to create and populate the modes_master table"""
    print("🚚 Creating Modes Master Table")
    print("=" * 50)
    
    # Create database connection
    connection = create_database_connection()
    if not connection:
        return
    
    try:
        # Execute the SQL schema file
        sql_file = "modes_master_schema.sql"
        if os.path.exists(sql_file):
            print(f"📝 Executing SQL schema from {sql_file}...")
            if execute_sql_file(connection, sql_file):
                print("✅ Schema execution completed")
            else:
                print("❌ Schema execution failed")
                return
        else:
            print(f"❌ SQL file {sql_file} not found")
            return
        
        # Verify table creation
        if not verify_table_creation(connection):
            print("❌ Table verification failed")
            return
        
        # Verify views creation
        if not verify_views_creation(connection):
            print("❌ Views verification failed")
            return
        
        # Display sample data
        display_sample_data(connection)
        
        print("\n🎉 Modes Master Table Setup Complete!")
        print("=" * 50)
        print("📊 What was created:")
        print("  • modes_master table with comprehensive mode definitions")
        print("  • 5 database views for different analysis needs")
        print("  • 15 transportation modes covering TL, LTL, Rail, Air, and Specialized")
        print("  • Complete operational characteristics and business rules")
        print("\n🔗 Next steps:")
        print("  • Use the database views for mode analysis")
        print("  • Integrate with service levels for comprehensive planning")
        print("  • Link to carrier capabilities for mode-carrier matching")
        
    except Error as e:
        print(f"❌ Error in main execution: {e}")
    
    finally:
        if connection.is_connected():
            connection.close()
            print("\n🔌 Database connection closed")

if __name__ == "__main__":
    main() 