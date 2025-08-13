"""
Database Connection Module for RouteCraft Backend
Uses MySQL as the primary database
"""
from app.database_mysql import MySQLDatabase
from app.config import settings
import logging

logger = logging.getLogger(__name__)

# Global database instance
db_instance = MySQLDatabase()

def get_db():
    """Dependency to get database connection"""
    return db_instance

def get_connection():
    """Get a database connection context manager"""
    return db_instance.get_connection() 