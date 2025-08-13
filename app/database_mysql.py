"""
MySQL Database Connection Module for RouteCraft Backend
"""
import mysql.connector
from mysql.connector import Error
from typing import Dict, Any, List, Optional
import logging
from contextlib import contextmanager

logger = logging.getLogger(__name__)

class MySQLDatabase:
    def __init__(self, host: str = None, user: str = None, 
                 password: str = None, database: str = None):
        from app.config import settings
        
        self.config = {
            'host': host or settings.mysql_host,
            'user': user or settings.mysql_user,
            'password': password or settings.mysql_password,
            'database': database or settings.mysql_database,
            'port': settings.mysql_port,
            'charset': 'utf8mb4',
            'autocommit': True,
            'pool_name': 'routecraft_pool',
            'pool_size': 5
        }
    
    @contextmanager
    def get_connection(self):
        """Context manager for database connections"""
        connection = None
        try:
            connection = mysql.connector.connect(**self.config)
            yield connection
        except Error as e:
            logger.error(f"Error connecting to MySQL: {e}")
            raise
        finally:
            if connection and connection.is_connected():
                connection.close()
    
    def execute_query(self, query: str, params: tuple = None) -> List[Dict[str, Any]]:
        """Execute a SELECT query and return results"""
        with self.get_connection() as connection:
            cursor = connection.cursor(dictionary=True)
            try:
                cursor.execute(query, params or ())
                results = cursor.fetchall()
                return results
            except Error as e:
                logger.error(f"Error executing query: {e}")
                raise
            finally:
                cursor.close()
    
    def execute_insert(self, query: str, params: tuple = None) -> int:
        """Execute an INSERT query and return the last insert ID"""
        with self.get_connection() as connection:
            cursor = connection.cursor()
            try:
                cursor.execute(query, params or ())
                connection.commit()
                return cursor.lastrowid
            except Error as e:
                logger.error(f"Error executing insert: {e}")
                connection.rollback()
                raise
            finally:
                cursor.close()
    
    def execute_update(self, query: str, params: tuple = None) -> int:
        """Execute an UPDATE query and return the number of affected rows"""
        with self.get_connection() as connection:
            cursor = connection.cursor()
            try:
                cursor.execute(query, params or ())
                connection.commit()
                return cursor.rowcount
            except Error as e:
                logger.error(f"Error executing update: {e}")
                connection.rollback()
                raise
            finally:
                cursor.close()
    
    def execute_delete(self, query: str, params: tuple = None) -> int:
        """Execute a DELETE query and return the number of affected rows"""
        with self.get_connection() as connection:
            cursor = connection.cursor()
            try:
                cursor.execute(query, params or ())
                connection.commit()
                return cursor.rowcount
            except Error as e:
                logger.error(f"Error executing delete: {e}")
                connection.rollback()
                raise
            finally:
                cursor.close()

# Global database instance
db = MySQLDatabase()

def get_db():
    """Dependency function to get database connection"""
    return db 