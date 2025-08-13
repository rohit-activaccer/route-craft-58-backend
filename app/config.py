from pydantic_settings import BaseSettings
from typing import List, Optional
import os
from pydantic import Field


class Settings(BaseSettings):
    # FastAPI Configuration
    app_name: str = Field("RouteCraft Backend", alias="APP_NAME")
    debug: bool = Field(True, alias="DEBUG")
    host: str = Field("0.0.0.0", alias="HOST")
    port: int = Field(8000, alias="PORT")
    
    # Security
    secret_key: str = Field("your-secret-key-here", alias="SECRET_KEY")
    algorithm: str = Field("HS256", alias="ALGORITHM")
    access_token_expire_minutes: int = Field(30, alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    
    # MySQL Configuration
    mysql_host: str = Field("localhost", alias="MYSQL_HOST")
    mysql_user: str = Field("routecraft_user", alias="MYSQL_USER")
    mysql_password: str = Field("routecraft_password", alias="MYSQL_PASSWORD")
    mysql_database: str = Field("routecraft", alias="MYSQL_DATABASE")
    mysql_port: int = Field(3306, alias="MYSQL_PORT")
    
    # Redis Configuration
    redis_url: str = Field("redis://localhost:6379", alias="REDIS_URL")
    
    # CORS Configuration
    allowed_origins: List[str] = Field(["http://localhost:3000", "http://localhost:5173", "http://localhost:8080"], alias="ALLOWED_ORIGINS")
    
    # Logging
    log_level: str = Field("INFO", alias="LOG_LEVEL")
    log_file: str = Field("logs/app.log", alias="LOG_FILE")
    
    # Email Configuration
    smtp_host: str = Field("smtp.gmail.com", alias="SMTP_HOST")
    smtp_port: int = Field(587, alias="SMTP_PORT")
    smtp_user: str = Field("your-email@gmail.com", alias="SMTP_USER")
    smtp_password: str = Field("your-app-password", alias="SMTP_PASSWORD")
    
    # File Upload
    max_file_size: int = Field(10485760, alias="MAX_FILE_SIZE")  # 10MB
    upload_dir: str = Field("uploads/", alias="UPLOAD_DIR")
    
    class Config:
        env_file = ".env"
        case_sensitive = False


# Create settings instance
settings = Settings()

# Ensure upload directory exists
os.makedirs(settings.upload_dir, exist_ok=True)
os.makedirs("logs", exist_ok=True) 