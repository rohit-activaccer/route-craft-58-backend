from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from app.auth.dependencies import get_current_active_user, get_current_manager_user
from app.database import get_db
from app.models.lane import (
    Lane, LaneCreate, LaneUpdate, LaneResponse, LaneListResponse,
    LaneStats, LaneFilter
)
from app.models.user import User
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/lanes", tags=["Lanes"])


@router.post("/", response_model=LaneResponse, status_code=status.HTTP_201_CREATED)
async def create_lane(
    lane_data: LaneCreate,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Create a new lane"""
    try:
        # Create lane data
        lane_dict = lane_data.dict()
        lane_dict["created_by"] = str(current_user.id)
        lane_dict["created_at"] = datetime.utcnow()
        lane_dict["updated_at"] = datetime.utcnow()
        
        # Insert lane into database
        lane_id = db.execute_insert(
            "INSERT INTO lanes (origin, destination, equipment_type, weight, volume, pickup_date, delivery_date, special_requirements, status, created_by, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (lane_data.origin, lane_data.destination, lane_data.equipment_type, lane_data.weight, lane_data.volume, lane_data.pickup_date, lane_data.delivery_date, lane_data.special_requirements, lane_data.status, lane_dict["created_by"], lane_dict["created_at"], lane_dict["updated_at"])
        )
        
        # Get the created lane
        created_lane_data = db.execute_query("SELECT * FROM lanes WHERE id = %s", (lane_id,))[0]
        created_lane = Lane(**created_lane_data)
        
        return LaneResponse(
            lane=created_lane,
            message="Lane created successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating lane: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/", response_model=LaneListResponse)
async def get_lanes(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    lane_status: Optional[str] = None,
    equipment_type: Optional[str] = None,
    origin: Optional[str] = None,
    destination: Optional[str] = None,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get list of lanes with pagination and filtering"""
    try:
        # Build query with filters
        where_conditions = []
        params = []
        
        if lane_status:
            where_conditions.append("status = %s")
            params.append(lane_status)
        if equipment_type:
            where_conditions.append("equipment_type = %s")
            params.append(equipment_type)
        if origin:
            where_conditions.append("origin LIKE %s")
            params.append(f"%{origin}%")
        if destination:
            where_conditions.append("destination LIKE %s")
            params.append(f"%{destination}%")
        
        where_clause = " AND ".join(where_conditions) if where_conditions else "1=1"
        
        # Get total count
        count_query = f"SELECT COUNT(*) as total FROM lanes WHERE {where_clause}"
        count_result = db.execute_query(count_query, tuple(params))
        total = count_result[0]["total"] if count_result else 0
        
        # Get paginated results
        query = f"SELECT * FROM lanes WHERE {where_clause} ORDER BY created_at DESC LIMIT %s OFFSET %s"
        params.extend([limit, skip])
        lanes_data = db.execute_query(query, tuple(params))
        
        lanes = [Lane(**lane_data) for lane_data in lanes_data]
        
        return LaneListResponse(
            lanes=lanes,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
        
    except Exception as e:
        logger.error(f"Error getting lanes: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/{lane_id}", response_model=LaneResponse)
async def get_lane(
    lane_id: str,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get a specific lane by ID"""
    try:
        lanes = db.execute_query("SELECT * FROM lanes WHERE id = %s", (lane_id,))
        
        if not lanes:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Lane not found"
            )
        
        lane = Lane(**lanes[0])
        return LaneResponse(
            lane=lane,
            message="Lane retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting lane: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.put("/{lane_id}", response_model=LaneResponse)
async def update_lane(
    lane_id: str,
    lane_data: LaneUpdate,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Update lane information"""
    try:
        # Check if lane exists
        existing_lanes = db.execute_query("SELECT id FROM lanes WHERE id = %s", (lane_id,))
        if not existing_lanes:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Lane not found"
            )
        
        # Prepare update data
        update_fields = []
        params = []
        
        if lane_data.origin is not None:
            update_fields.append("origin = %s")
            params.append(lane_data.origin)
        if lane_data.destination is not None:
            update_fields.append("destination = %s")
            params.append(lane_data.destination)
        if lane_data.equipment_type is not None:
            update_fields.append("equipment_type = %s")
            params.append(lane_data.equipment_type)
        if lane_data.weight is not None:
            update_fields.append("weight = %s")
            params.append(lane_data.weight)
        if lane_data.volume is not None:
            update_fields.append("volume = %s")
            params.append(lane_data.volume)
        if lane_data.pickup_date is not None:
            update_fields.append("pickup_date = %s")
            params.append(lane_data.pickup_date)
        if lane_data.delivery_date is not None:
            update_fields.append("delivery_date = %s")
            params.append(lane_data.delivery_date)
        if lane_data.special_requirements is not None:
            update_fields.append("special_requirements = %s")
            params.append(lane_data.special_requirements)
        if lane_data.status is not None:
            update_fields.append("status = %s")
            params.append(lane_data.status)
        
        if not update_fields:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No fields to update"
            )
        
        update_fields.append("updated_at = %s")
        params.append(datetime.utcnow())
        params.append(lane_id)
        
        # Update lane
        query = f"UPDATE lanes SET {', '.join(update_fields)} WHERE id = %s"
        db.execute_update(query, tuple(params))
        
        # Get updated lane
        updated_lanes = db.execute_query("SELECT * FROM lanes WHERE id = %s", (lane_id,))
        updated_lane = Lane(**updated_lanes[0])
        
        return LaneResponse(
            lane=updated_lane,
            message="Lane updated successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating lane: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.delete("/{lane_id}")
async def delete_lane(
    lane_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Delete a lane (soft delete by setting status to inactive)"""
    try:
        # Check if lane exists
        existing_lanes = db.execute_query("SELECT id FROM lanes WHERE id = %s", (lane_id,))
        if not existing_lanes:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Lane not found"
            )
        
        # Soft delete lane
        db.execute_update(
            "UPDATE lanes SET status = 'inactive', updated_at = %s WHERE id = %s",
            (datetime.utcnow(), lane_id)
        )
        
        return {"message": "Lane deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting lane: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{lane_id}/publish")
async def publish_lane(
    lane_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Publish a lane to make it visible to carriers"""
    try:
        # Check if lane exists
        existing_lanes = db.execute_query("SELECT id FROM lanes WHERE id = %s", (lane_id,))
        if not existing_lanes:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Lane not found"
            )
        
        lane = existing_lanes[0]
        if lane["status"] != "draft":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only draft lanes can be published"
            )
        
        # Update lane status
        db.execute_update(
            "UPDATE lanes SET status = 'published', published_at = %s, updated_at = %s WHERE id = %s",
            (datetime.utcnow(), datetime.utcnow(), lane_id)
        )
        
        return {"message": "Lane published successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error publishing lane: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{lane_id}/close")
async def close_lane(
    lane_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Close a lane to stop accepting bids"""
    try:
        # Check if lane exists
        existing_lanes = db.execute_query("SELECT id FROM lanes WHERE id = %s", (lane_id,))
        if not existing_lanes:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Lane not found"
            )
        
        lane = existing_lanes[0]
        if lane["status"] not in ["published", "open"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only published or open lanes can be closed"
            )
        
        # Update lane status
        db.execute_update(
            "UPDATE lanes SET status = 'closed', closed_at = %s, updated_at = %s WHERE id = %s",
            (datetime.utcnow(), datetime.utcnow(), lane_id)
        )
        
        return {"message": "Lane closed successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error closing lane: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/stats/summary", response_model=LaneStats)
async def get_lane_stats(
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get lane statistics summary"""
    try:
        # Get total lanes
        total_lanes = db.execute_query("SELECT COUNT(*) as total FROM lanes")
        total = total_lanes[0]["total"] if total_lanes else 0
        
        # Get published lanes
        published_lanes = db.execute_query("SELECT COUNT(*) as total FROM lanes WHERE status = 'published'")
        published = published_lanes[0]["total"] if published_lanes else 0
        
        # Get open lanes
        open_lanes = db.execute_query("SELECT COUNT(*) as total FROM lanes WHERE status = 'open'")
        open_count = open_lanes[0]["total"] if open_lanes else 0
        
        # Get closed lanes
        closed_lanes = db.execute_query("SELECT COUNT(*) as total FROM lanes WHERE status = 'closed'")
        closed = closed_lanes[0]["total"] if closed_lanes else 0
        
        # Get lanes by equipment type
        equipment_stats = db.execute_query(
            "SELECT equipment_type, COUNT(*) as count FROM lanes GROUP BY equipment_type"
        )
        lanes_by_equipment = {row["equipment_type"]: row["count"] for row in equipment_stats}
        
        return LaneStats(
            total_lanes=total,
            published_lanes=published,
            open_lanes=open_count,
            closed_lanes=closed,
            lanes_by_equipment=lanes_by_equipment
        )
        
    except Exception as e:
        logger.error(f"Error getting lane stats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 