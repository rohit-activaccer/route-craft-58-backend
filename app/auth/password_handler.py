from passlib.context import CryptContext
import logging

logger = logging.getLogger(__name__)

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against a hashed password"""
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception as e:
        logger.error(f"Password verification failed: {e}")
        return False


def get_password_hash(password: str) -> str:
    """Generate password hash from plain password"""
    try:
        return pwd_context.hash(password)
    except Exception as e:
        logger.error(f"Password hashing failed: {e}")
        raise


def validate_password_strength(password: str) -> dict:
    """Validate password strength and return validation result"""
    errors = []
    warnings = []
    
    if len(password) < 8:
        errors.append("Password must be at least 8 characters long")
    
    if not any(c.isupper() for c in password):
        warnings.append("Consider adding uppercase letters")
    
    if not any(c.islower() for c in password):
        warnings.append("Consider adding lowercase letters")
    
    if not any(c.isdigit() for c in password):
        warnings.append("Consider adding numbers")
    
    if not any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password):
        warnings.append("Consider adding special characters")
    
    strength_score = 0
    if len(password) >= 8:
        strength_score += 1
    if any(c.isupper() for c in password):
        strength_score += 1
    if any(c.islower() for c in password):
        strength_score += 1
    if any(c.isdigit() for c in password):
        strength_score += 1
    if any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password):
        strength_score += 1
    
    strength_level = "weak"
    if strength_score >= 4:
        strength_level = "strong"
    elif strength_score >= 3:
        strength_level = "medium"
    
    return {
        "is_valid": len(errors) == 0,
        "strength_score": strength_score,
        "strength_level": strength_level,
        "errors": errors,
        "warnings": warnings
    } 