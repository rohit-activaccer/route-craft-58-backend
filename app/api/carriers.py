from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from app.auth.dependencies import get_current_active_user, get_current_manager_user
from app.database import get_db
from app.models.carrier import (
    Carrier, CarrierCreate, CarrierUpdate, CarrierResponse, 
    CarrierListResponse, CarrierStats
)
from app.models.user import User
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/carriers", tags=["Carriers"])


@router.post("/", response_model=CarrierResponse, status_code=status.HTTP_201_CREATED)
async def create_carrier(
    carrier_data: CarrierCreate,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Create a new carrier"""
    try:
        # Check if carrier already exists
        existing_carriers = db.execute_query("SELECT id FROM carriers WHERE email = %s", (carrier_data.email,))
        if existing_carriers:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Carrier with this email already exists"
            )
        
        # Create carrier data
        carrier_dict = carrier_data.dict()
        carrier_dict["created_by"] = str(current_user.id)
        carrier_dict["created_at"] = datetime.utcnow()
        carrier_dict["updated_at"] = datetime.utcnow()
        
        # Insert carrier into database
        carrier_id = db.execute_insert(
            "INSERT INTO carriers (company_name, contact_person, email, phone, address, city, state, country, postal_code, mc_number, dot_number, insurance_info, rating, status, created_by, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (carrier_data.company_name, carrier_data.contact_person, carrier_data.email, carrier_data.phone, carrier_data.address, carrier_data.city, carrier_data.state, carrier_data.country, carrier_data.postal_code, carrier_data.mc_number, carrier_data.dot_number, carrier_data.insurance_info, carrier_data.rating, carrier_data.status, carrier_dict["created_by"], carrier_dict["created_at"], carrier_dict["updated_at"])
        )
        
        # Get the created carrier
        created_carrier_data = db.execute_query("SELECT * FROM carriers WHERE id = %s", (carrier_id,))[0]
        created_carrier = Carrier(**created_carrier_data)
        
        return CarrierResponse(
            carrier=created_carrier,
            message="Carrier created successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating carrier: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/", response_model=CarrierListResponse)
async def get_carriers(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    carrier_status: Optional[str] = None,
    carrier_type: Optional[str] = None,
    service_level: Optional[str] = None,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get list of carriers with pagination and filtering"""
    try:
        # Build query with filters
        where_conditions = []
        params = []
        
        if carrier_status:
            where_conditions.append("status = %s")
            params.append(carrier_status)
        if carrier_type:
            where_conditions.append("carrier_type = %s")
            params.append(carrier_type)
        if service_level:
            where_conditions.append("service_level = %s")
            params.append(service_level)
        
        where_clause = " AND ".join(where_conditions) if where_conditions else "1=1"
        
        # Get total count
        count_query = f"SELECT COUNT(*) as total FROM carriers WHERE {where_clause}"
        count_result = db.execute_query(count_query, tuple(params))
        total = count_result[0]["total"] if count_result else 0
        
        # Get paginated results
        query = f"SELECT * FROM carriers WHERE {where_clause} ORDER BY created_at DESC LIMIT %s OFFSET %s"
        params.extend([limit, skip])
        carriers_data = db.execute_query(query, tuple(params))
        
        carriers = [Carrier(**carrier_data) for carrier_data in carriers_data]
        
        return CarrierListResponse(
            carriers=carriers,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
        
    except Exception as e:
        logger.error(f"Error getting carriers: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/{carrier_id}", response_model=CarrierResponse)
async def get_carrier(
    carrier_id: str,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get a specific carrier by ID"""
    try:
        carriers = db.execute_query("SELECT * FROM carriers WHERE id = %s", (carrier_id,))
        
        if not carriers:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Carrier not found"
            )
        
        carrier = Carrier(**carriers[0])
        return CarrierResponse(
            carrier=carrier,
            message="Carrier retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting carrier: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.put("/{carrier_id}", response_model=CarrierResponse)
async def update_carrier(
    carrier_id: str,
    carrier_data: CarrierUpdate,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Update carrier information"""
    try:
        # Check if carrier exists
        existing_carriers = db.execute_query("SELECT id FROM carriers WHERE id = %s", (carrier_id,))
        if not existing_carriers:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Carrier not found"
            )
        
        # Prepare update data
        update_fields = []
        params = []
        
        if carrier_data.company_name is not None:
            update_fields.append("company_name = %s")
            params.append(carrier_data.company_name)
        if carrier_data.contact_person is not None:
            update_fields.append("contact_person = %s")
            params.append(carrier_data.contact_person)
        if carrier_data.email is not None:
            update_fields.append("email = %s")
            params.append(carrier_data.email)
        if carrier_data.phone is not None:
            update_fields.append("phone = %s")
            params.append(carrier_data.phone)
        if carrier_data.address is not None:
            update_fields.append("address = %s")
            params.append(carrier_data.address)
        if carrier_data.city is not None:
            update_fields.append("city = %s")
            params.append(carrier_data.city)
        if carrier_data.state is not None:
            update_fields.append("state = %s")
            params.append(carrier_data.state)
        if carrier_data.country is not None:
            update_fields.append("country = %s")
            params.append(carrier_data.country)
        if carrier_data.postal_code is not None:
            update_fields.append("postal_code = %s")
            params.append(carrier_data.postal_code)
        if carrier_data.mc_number is not None:
            update_fields.append("mc_number = %s")
            params.append(carrier_data.mc_number)
        if carrier_data.dot_number is not None:
            update_fields.append("dot_number = %s")
            params.append(carrier_data.dot_number)
        if carrier_data.insurance_info is not None:
            update_fields.append("insurance_info = %s")
            params.append(carrier_data.insurance_info)
        if carrier_data.rating is not None:
            update_fields.append("rating = %s")
            params.append(carrier_data.rating)
        if carrier_data.status is not None:
            update_fields.append("status = %s")
            params.append(carrier_data.status)
        
        if not update_fields:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No fields to update"
            )
        
        update_fields.append("updated_at = %s")
        params.append(datetime.utcnow())
        params.append(carrier_id)
        
        # Update carrier
        query = f"UPDATE carriers SET {', '.join(update_fields)} WHERE id = %s"
        db.execute_update(query, tuple(params))
        
        # Get updated carrier
        updated_carriers = db.execute_query("SELECT * FROM carriers WHERE id = %s", (carrier_id,))
        updated_carrier = Carrier(**updated_carriers[0])
        
        return CarrierResponse(
            carrier=updated_carrier,
            message="Carrier updated successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating carrier: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.delete("/{carrier_id}")
async def delete_carrier(
    carrier_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Delete a carrier (soft delete by setting status to inactive)"""
    try:
        # Check if carrier exists
        existing_carriers = db.execute_query("SELECT id FROM carriers WHERE id = %s", (carrier_id,))
        if not existing_carriers:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Carrier not found"
            )
        
        # Soft delete carrier
        db.execute_update(
            "UPDATE carriers SET status = 'inactive', updated_at = %s WHERE id = %s",
            (datetime.utcnow(), carrier_id)
        )
        
        return {"message": "Carrier deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting carrier: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{carrier_id}/approve")
async def approve_carrier(
    carrier_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Approve a carrier account"""
    try:
        # Check if carrier exists
        existing_carriers = db.execute_query("SELECT id FROM carriers WHERE id = %s", (carrier_id,))
        if not existing_carriers:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Carrier not found"
            )
        
        # Approve carrier
        db.execute_update(
            "UPDATE carriers SET status = 'active', updated_at = %s WHERE id = %s",
            (datetime.utcnow(), carrier_id)
        )
        
        return {"message": "Carrier approved successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error approving carrier: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{carrier_id}/suspend")
async def suspend_carrier(
    carrier_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Suspend a carrier account"""
    try:
        # Check if carrier exists
        existing_carriers = db.execute_query("SELECT id FROM carriers WHERE id = %s", (carrier_id,))
        if not existing_carriers:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Carrier not found"
            )
        
        # Suspend carrier
        db.execute_update(
            "UPDATE carriers SET status = 'suspended', updated_at = %s WHERE id = %s",
            (datetime.utcnow(), carrier_id)
        )
        
        return {"message": "Carrier suspended successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error suspending carrier: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/stats/summary", response_model=CarrierStats)
async def get_carrier_stats(
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get carrier statistics summary"""
    try:
        # Get total carriers
        total_carriers = db.execute_query("SELECT COUNT(*) as total FROM carriers")
        total = total_carriers[0]["total"] if total_carriers else 0
        
        # Get active carriers
        active_carriers = db.execute_query("SELECT COUNT(*) as total FROM carriers WHERE status = 'active'")
        active = active_carriers[0]["total"] if active_carriers else 0
        
        # Get pending carriers
        pending_carriers = db.execute_query("SELECT COUNT(*) as total FROM carriers WHERE status = 'pending'")
        pending = pending_carriers[0]["total"] if pending_carriers else 0
        
        # Get suspended carriers
        suspended_carriers = db.execute_query("SELECT COUNT(*) as total FROM carriers WHERE status = 'suspended'")
        suspended = suspended_carriers[0]["total"] if suspended_carriers else 0
        
        # Get average rating
        rating_result = db.execute_query("SELECT AVG(rating) as avg_rating FROM carriers WHERE rating IS NOT NULL")
        avg_rating = float(rating_result[0]["avg_rating"]) if rating_result and rating_result[0]["avg_rating"] else 0.0
        
        return CarrierStats(
            total_carriers=total,
            active_carriers=active,
            pending_carriers=pending,
            suspended_carriers=suspended,
            average_rating=round(avg_rating, 2)
        )
        
    except Exception as e:
        logger.error(f"Error getting carrier stats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 