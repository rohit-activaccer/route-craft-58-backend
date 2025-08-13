from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from app.auth.dependencies import get_current_active_user, get_current_manager_user
from app.database import get_db
from app.models.user import User, UserCreate, UserUpdate, UserResponse, UserListResponse
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/", response_model=UserListResponse)
async def get_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    role: Optional[str] = None,
    user_status: Optional[str] = None,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Get list of users with pagination and filtering"""
    try:
        # Build query with filters
        where_conditions = []
        params = []
        
        if role:
            where_conditions.append("role = %s")
            params.append(role)
        if user_status:
            where_conditions.append("status = %s")
            params.append(user_status)
        
        where_clause = " AND ".join(where_conditions) if where_conditions else "1=1"
        
        # Get total count
        count_query = f"SELECT COUNT(*) as total FROM users WHERE {where_clause}"
        count_result = db.execute_query(count_query, tuple(params))
        total = count_result[0]["total"] if count_result else 0
        
        # Get paginated results
        query = f"SELECT * FROM users WHERE {where_clause} ORDER BY created_at DESC LIMIT %s OFFSET %s"
        params.extend([limit, skip])
        users_data = db.execute_query(query, tuple(params))
        
        users = [User(**user_data) for user_data in users_data]
        
        return UserListResponse(
            users=users,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
        
    except Exception as e:
        logger.error(f"Error getting users: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get a specific user by ID"""
    try:
        # Users can only view their own profile unless they're managers
        if str(current_user.id) != user_id and current_user.role != "manager":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to view this user"
            )
        
        users = db.execute_query("SELECT * FROM users WHERE id = %s", (user_id,))
        
        if not users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        user = User(**users[0])
        return UserResponse(
            user=user,
            message="User retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    user_data: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Update user information"""
    try:
        # Users can only update their own profile unless they're managers
        if str(current_user.id) != user_id and current_user.role != "manager":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to update this user"
            )
        
        # Check if user exists
        existing_users = db.execute_query("SELECT id FROM users WHERE id = %s", (user_id,))
        if not existing_users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Prepare update data
        update_fields = []
        params = []
        
        if user_data.first_name is not None:
            update_fields.append("first_name = %s")
            params.append(user_data.first_name)
        if user_data.last_name is not None:
            update_fields.append("last_name = %s")
            params.append(user_data.last_name)
        if user_data.company is not None:
            update_fields.append("company = %s")
            params.append(user_data.company)
        if user_data.phone is not None:
            update_fields.append("phone = %s")
            params.append(user_data.phone)
        
        if not update_fields:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No fields to update"
            )
        
        update_fields.append("updated_at = %s")
        params.append(datetime.utcnow())
        params.append(user_id)
        
        # Update user
        query = f"UPDATE users SET {', '.join(update_fields)} WHERE id = %s"
        db.execute_update(query, tuple(params))
        
        # Get updated user
        updated_users = db.execute_query("SELECT * FROM users WHERE id = %s", (user_id,))
        updated_user = User(**updated_users[0])
        
        return UserResponse(
            user=updated_user,
            message="User updated successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.delete("/{user_id}")
async def delete_user(
    user_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Delete a user (soft delete by setting status to inactive)"""
    try:
        # Check if user exists
        existing_users = db.execute_query("SELECT id FROM users WHERE id = %s", (user_id,))
        if not existing_users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Soft delete user
        db.execute_update(
            "UPDATE users SET status = 'inactive', updated_at = %s WHERE id = %s",
            (datetime.utcnow(), user_id)
        )
        
        return {"message": "User deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{user_id}/activate")
async def activate_user(
    user_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Activate a user account"""
    try:
        # Check if user exists
        existing_users = db.execute_query("SELECT id FROM users WHERE id = %s", (user_id,))
        if not existing_users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Activate user
        db.execute_update(
            "UPDATE users SET status = 'active', is_active = true, updated_at = %s WHERE id = %s",
            (datetime.utcnow(), user_id)
        )
        
        return {"message": "User activated successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error activating user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{user_id}/deactivate")
async def deactivate_user(
    user_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Deactivate a user account"""
    try:
        # Check if user exists
        existing_users = db.execute_query("SELECT id FROM users WHERE id = %s", (user_id,))
        if not existing_users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Prevent deactivating own account
        if str(current_user.id) == user_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot deactivate your own account"
            )
        
        # Deactivate user
        db.execute_update(
            "UPDATE users SET status = 'inactive', is_active = false, updated_at = %s WHERE id = %s",
            (datetime.utcnow(), user_id)
        )
        
        return {"message": "User deactivated successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deactivating user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 