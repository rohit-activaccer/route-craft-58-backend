#!/usr/bin/env python3
"""
Script to create the transport_contracts table in MySQL database
"""

import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

def load_environment():
    """Load environment variables from .env file"""
    load_dotenv()
    
    return {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }

def read_sql_file(file_path):
    """Read SQL file content"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.read()
    except FileNotFoundError:
        print(f"Error: SQL file not found at {file_path}")
        return None
    except Exception as e:
        print(f"Error reading SQL file: {e}")
        return None

def execute_sql_script(connection, sql_script):
    """Execute SQL script with multiple statements"""
    try:
        cursor = connection.cursor()
        
        # Split SQL script into individual statements
        statements = sql_script.split(';')
        
        for statement in statements:
            statement = statement.strip()
            if statement and not statement.startswith('--'):
                try:
                    cursor.execute(statement)
                    print(f"✓ Executed: {statement[:50]}...")
                except Error as e:
                    if "already exists" in str(e).lower():
                        print(f"⚠ Skipped (already exists): {statement[:50]}...")
                    else:
                        print(f"✗ Error executing: {statement[:50]}...")
                        print(f"  Error: {e}")
        
        connection.commit()
        print("\n✅ SQL script executed successfully!")
        
    except Error as e:
        print(f"✗ Database error: {e}")
        connection.rollback()
    finally:
        if cursor:
            cursor.close()

def test_connection(connection):
    """Test database connection and show table info"""
    try:
        cursor = connection.cursor()
        
        # Show all tables
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        
        print("\n📋 Current tables in database:")
        for table in tables:
            print(f"  - {table[0]}")
        
        # Show contract table structure if it exists
        cursor.execute("SHOW TABLES LIKE 'transport_contracts'")
        if cursor.fetchone():
            print("\n🏗️ Transport contracts table structure:")
            cursor.execute("DESCRIBE transport_contracts")
            columns = cursor.fetchall()
            
            print(f"{'Field':<25} {'Type':<20} {'Null':<8} {'Key':<8} {'Default':<15} {'Extra':<10}")
            print("-" * 90)
            for col in columns:
                print(f"{col[0]:<25} {col[1]:<20} {col[2]:<8} {col[3]:<8} {str(col[4]):<15} {col[5]:<10}")
        
        # Show sample data count
        cursor.execute("SELECT COUNT(*) FROM transport_contracts")
        count = cursor.fetchone()[0]
        print(f"\n📊 Total contracts in table: {count}")
        
        if count > 0:
            print("\n🔍 Sample contracts:")
            cursor.execute("SELECT contract_id, carrier_name, origin_location, destination_location, base_rate FROM transport_contracts LIMIT 3")
            samples = cursor.fetchall()
            for sample in samples:
                print(f"  - {sample[0]}: {sample[1]} ({sample[2]} → {sample[3]}) - ₹{sample[4]}")
        
    except Error as e:
        print(f"✗ Error testing connection: {e}")
    finally:
        if cursor:
            cursor.close()

def main():
    """Main function"""
    print("🚛 Transport Contracts Table Creator")
    print("=" * 50)
    
    # Load environment variables
    config = load_environment()
    print(f"📡 Connecting to MySQL at {config['host']}:{config['port']}")
    print(f"🗄️ Database: {config['database']}")
    print(f"👤 User: {config['user']}")
    
    try:
        # Create connection
        connection = mysql.connector.connect(**config)
        
        if connection.is_connected():
            print("✅ Connected to MySQL database successfully!")
            
            # Read and execute SQL script
            sql_file = "contract_table_schema.sql"
            sql_script = read_sql_file(sql_file)
            
            if sql_script:
                print(f"\n📖 Reading SQL script: {sql_file}")
                execute_sql_script(connection, sql_script)
                
                # Test the connection and show results
                test_connection(connection)
            else:
                print("✗ Failed to read SQL script")
                
        else:
            print("✗ Failed to connect to MySQL database")
            
    except Error as e:
        print(f"✗ Connection error: {e}")
        print("\n💡 Troubleshooting tips:")
        print("  1. Make sure MySQL server is running")
        print("  2. Check your .env file configuration")
        print("  3. Verify database credentials")
        print("  4. Ensure database 'routecraft' exists")
        
    finally:
        if 'connection' in locals() and connection.is_connected():
            connection.close()
            print("\n🔌 Database connection closed")

if __name__ == "__main__":
    main() 