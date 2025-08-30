#!/usr/bin/env python3
"""
Script to create admin user with specified credentials
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database_mysql import MySQLDatabase
from app.auth import get_password_hash
from datetime import datetime

def create_admin_user():
    """Create admin user with specified credentials"""
    try:
        # Initialize database connection
        db = MySQLDatabase()
        
        # Check if user already exists
        existing_users = db.execute_query("SELECT id FROM users WHERE email = %s", ("admin@company.com",))
        
        if existing_users:
            print("User admin@company.com already exists!")
            return
        
        # Hash the password
        hashed_password = get_password_hash("admin@company.com")
        
        # Create user data
        user_data = {
            "email": "admin@company.com",
            "first_name": "Admin",
            "last_name": "User",
            "role": "admin",
            "company_name": "Company",
            "status": "active",
            "password_hash": hashed_password
        }
        
        # Insert user into database
        user_id = db.execute_insert(
            """INSERT INTO users 
               (email, first_name, last_name, role, company_name, status, password_hash) 
               VALUES (%s, %s, %s, %s, %s, %s, %s)""",
            (user_data["email"], user_data["first_name"], user_data["last_name"], 
             user_data["role"], user_data["company_name"], user_data["status"], 
             user_data["password_hash"])
        )
        
        print(f"Admin user created successfully with ID: {user_id}")
        print("Credentials:")
        print("Email: admin@company.com")
        print("Password: admin@company.com")
        
    except Exception as e:
        print(f"Error creating admin user: {e}")
        raise

if __name__ == "__main__":
    create_admin_user() 