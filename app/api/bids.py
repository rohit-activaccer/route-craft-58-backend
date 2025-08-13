from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from app.auth.dependencies import get_current_active_user, get_current_manager_user
from app.database import get_db
from app.models.bid import (
    Bid, BidCreate, BidUpdate, BidResponse, BidListResponse,
    BidStats
)
from app.models.user import User
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/bids", tags=["Bids"])


@router.post("/", response_model=BidResponse, status_code=status.HTTP_201_CREATED)
async def create_bid(
    bid_data: BidCreate,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Create a new bid"""
    try:
        # Take the first lane_id from the lane_ids list since the simple bids table only supports one lane
        if not bid_data.lane_ids or len(bid_data.lane_ids) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="At least one lane_id is required"
            )
        
        lane_id = bid_data.lane_ids[0]  # Use first lane for simple bids table
        
        # Check if user already has a bid for this lane
        existing_bids = db.execute_query(
            "SELECT id FROM bids WHERE created_by = %s AND lane_id = %s",
            (str(current_user.id), lane_id)
        )
        if existing_bids:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You already have a bid for this lane"
            )
        
        # Create bid data
        bid_dict = bid_data.dict()
        bid_dict["user_id"] = str(current_user.id)
        bid_dict["created_at"] = datetime.utcnow()
        bid_dict["updated_at"] = datetime.utcnow()
        
        # Insert bid into database - map to simple bids table structure
        bid_id = db.execute_insert(
            "INSERT INTO bids (title, description, lane_id, estimated_cost, status, created_by, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
            (bid_data.name, bid_data.description, lane_id, bid_data.budget, "open", bid_dict["user_id"], bid_dict["created_at"], bid_dict["updated_at"])
        )
        
        # Get the created bid
        created_bid_data = db.execute_query("SELECT * FROM bids WHERE id = %s", (bid_id,))[0]
        
        # Create a simplified Bid object that matches the simple table structure
        simplified_bid = {
            "id": str(created_bid_data["id"]),
            "name": created_bid_data["title"],
            "description": created_bid_data["description"],
            "bid_type": bid_data.bid_type,
            "priority": bid_data.priority,
            "start_date": bid_data.start_date,
            "end_date": bid_data.end_date,
            "submission_deadline": bid_data.submission_deadline,
            "budget": created_bid_data["estimated_cost"],
            "currency": bid_data.currency,
            "requirements": bid_data.requirements,
            "terms_conditions": bid_data.terms_conditions,
            "is_template": bid_data.is_template,
            "status": created_bid_data["status"],
            "created_by": str(created_bid_data["created_by"]),
            "created_at": created_bid_data["created_at"],
            "updated_at": created_bid_data["updated_at"],
            "published_at": None,
            "closed_at": None,
            "awarded_at": None,
            "total_responses": 0,
            "total_lanes": 1,
            "total_carriers": 0
        }
        
        created_bid = Bid(**simplified_bid)
        
        return BidResponse(
            bid=created_bid,
            message="Bid created successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating bid: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/dev", response_model=BidResponse, status_code=status.HTTP_201_CREATED)
async def create_bid_dev(
    bid_data: BidCreate,
    db = Depends(get_db)
):
    """Create a new bid (Development endpoint - no authentication required)"""
    try:
        # For development, use a default user ID
        default_user_id = "1"
        
        # Take the first lane_id from the lane_ids list since the simple bids table only supports one lane
        if not bid_data.lane_ids or len(bid_data.lane_ids) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="At least one lane_id is required"
            )
        
        lane_id = bid_data.lane_ids[0]  # Use first lane for simple bids table
        
        # Check if user already has a bid for this lane
        existing_bids = db.execute_query(
            "SELECT id FROM bids WHERE created_by = %s AND lane_id = %s",
            (default_user_id, lane_id)
        )
        if existing_bids:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You already have a bid for this lane"
            )
        
        # Create bid data
        bid_dict = bid_data.dict()
        bid_dict["user_id"] = default_user_id
        bid_dict["created_at"] = datetime.utcnow()
        bid_dict["updated_at"] = datetime.utcnow()
        
        # Insert bid into database - map to simple bids table structure
        bid_id = db.execute_insert(
            "INSERT INTO bids (title, description, lane_id, estimated_cost, status, created_by, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
            (bid_data.name, bid_data.description, lane_id, bid_data.budget, "open", default_user_id, bid_dict["created_at"], bid_dict["updated_at"])
        )
        
        # Get the created bid
        created_bid_data = db.execute_query("SELECT * FROM bids WHERE id = %s", (bid_id,))[0]
        
        # Create a simplified Bid object that matches the simple table structure
        simplified_bid = {
            "id": str(created_bid_data["id"]),
            "name": created_bid_data["title"],
            "description": created_bid_data["description"],
            "bid_type": bid_data.bid_type,
            "priority": bid_data.priority,
            "start_date": bid_data.start_date,
            "end_date": bid_data.end_date,
            "submission_deadline": bid_data.submission_deadline,
            "budget": created_bid_data["estimated_cost"],
            "currency": bid_data.currency,
            "requirements": bid_data.requirements,
            "terms_conditions": bid_data.terms_conditions,
            "is_template": bid_data.is_template,
            "status": created_bid_data["status"],
            "created_by": str(created_bid_data["created_by"]),
            "created_at": created_bid_data["created_at"],
            "updated_at": created_bid_data["updated_at"],
            "published_at": None,
            "closed_at": None,
            "awarded_at": None,
            "total_responses": 0,
            "total_lanes": 1,
            "total_carriers": 0
        }
        
        created_bid = Bid(**simplified_bid)
        
        return BidResponse(
            bid=created_bid,
            message="Bid created successfully (Development mode)"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating bid: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/", response_model=BidListResponse)
async def get_bids(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    bid_status: Optional[str] = None,
    user_id: Optional[str] = None,
    lane_id: Optional[str] = None,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get list of bids with pagination and filtering"""
    try:
        # Build query with filters
        where_conditions = []
        params = []
        
        if bid_status:
            where_conditions.append("b.status = %s")
            params.append(bid_status)
        if user_id:
            where_conditions.append("b.created_by = %s")
            params.append(user_id)
        if lane_id:
            where_conditions.append("b.lane_id = %s")
            params.append(lane_id)
        
        # Regular users can only see their own bids
        if current_user.role != "manager":
            where_conditions.append("b.created_by = %s")
            params.append(str(current_user.id))
        
        where_clause = " AND ".join(where_conditions) if where_conditions else "1=1"
        
        # Build the main query - simplified to work with actual table structure
        query = f"""
            SELECT 
                b.*,
                CONCAT(u.first_name, ' ', u.last_name) as user_name,
                u.email as user_email,
                CONCAT(l.origin_city, ', ', l.origin_state) as origin,
                CONCAT(l.destination_city, ', ', l.destination_state) as destination,
                l.distance_miles as distance,
                'N/A' as volume
            FROM bids b
            LEFT JOIN users u ON b.created_by = u.id
            LEFT JOIN lanes l ON b.lane_id = l.id
            WHERE {where_clause}
            ORDER BY b.created_at DESC
            LIMIT %s OFFSET %s
        """
        
        params.extend([limit, skip])
        
        # Execute query
        bids_data = db.execute_query(query, params)
        
        # Get total count
        count_query = f"SELECT COUNT(*) as total FROM bids b WHERE {where_clause}"
        count_params = params[:-2] if len(params) > 2 else []
        total_count = db.execute_query(count_query, count_params)[0]["total"]
        
        # Convert database results to Bid objects - map to expected structure
        bids = []
        for bid_data in bids_data:
            # Map database columns to Bid model fields
            mapped_bid = {
                "id": str(bid_data["id"]),
                "name": bid_data["title"],
                "description": bid_data["description"],
                "bid_type": "contract",  # Default since simple table doesn't store this
                "priority": "medium",    # Default since simple table doesn't store this
                "start_date": datetime.utcnow(),  # Default since simple table doesn't store this
                "end_date": datetime.utcnow(),    # Default since simple table doesn't store this
                "submission_deadline": datetime.utcnow(),  # Default since simple table doesn't store this
                "budget": bid_data["estimated_cost"],
                "currency": "USD",  # Default since simple table doesn't store this
                "requirements": None,
                "terms_conditions": None,
                "is_template": False,
                "status": bid_data["status"],
                "created_by": str(bid_data["created_by"]),
                "created_at": bid_data["created_at"],
                "updated_at": bid_data["updated_at"],
                "published_at": None,
                "closed_at": None,
                "awarded_at": None,
                "total_responses": 0,
                "total_lanes": 1,
                "total_carriers": 0
            }
            bids.append(Bid(**mapped_bid))
        
        return BidListResponse(
            bids=bids,
            total=total_count,
            skip=skip,
            limit=limit
        )
        
    except Exception as e:
        logger.error(f"Error getting bids: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/dev", response_model=BidListResponse)
async def get_bids_dev(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    bid_status: Optional[str] = None,
    user_id: Optional[str] = None,
    lane_id: Optional[str] = None,
    db = Depends(get_db)
):
    """Get list of bids (Development endpoint - no authentication required)"""
    try:
        # Build query with filters
        where_conditions = []
        params = []
        
        if bid_status:
            where_conditions.append("b.status = %s")
            params.append(bid_status)
        if user_id:
            where_conditions.append("b.created_by = %s")
            params.append(user_id)
        if lane_id:
            where_conditions.append("b.lane_id = %s")
            params.append(lane_id)
        
        where_clause = " AND ".join(where_conditions) if where_conditions else "1=1"
        
        # Build the main query - simplified to work with actual table structure
        query = f"""
            SELECT 
                b.*,
                CONCAT(u.first_name, ' ', u.last_name) as user_name,
                u.email as user_email,
                CONCAT(l.origin_city, ', ', l.origin_state) as origin,
                CONCAT(l.destination_city, ', ', l.destination_state) as destination,
                l.distance_miles as distance,
                'N/A' as volume
            FROM bids b
            LEFT JOIN users u ON b.created_by = u.id
            LEFT JOIN lanes l ON b.lane_id = l.id
            WHERE {where_clause}
            ORDER BY b.created_at DESC
            LIMIT %s OFFSET %s
        """
        
        params.extend([limit, skip])
        
        # Execute query
        bids_data = db.execute_query(query, params)
        
        # Get total count
        count_query = f"SELECT COUNT(*) as total FROM bids b WHERE {where_clause}"
        count_params = params[:-2] if len(params) > 2 else []
        total_count = db.execute_query(count_query, count_params)[0]["total"]
        
        # Convert database results to Bid objects - map to expected structure
        bids = []
        for bid_data in bids_data:
            # Map database columns to Bid model fields
            mapped_bid = {
                "id": str(bid_data["id"]),
                "name": bid_data["title"],
                "description": bid_data["description"],
                "bid_type": "contract",  # Default since simple table doesn't store this
                "priority": "medium",    # Default since simple table doesn't store this
                "start_date": datetime.utcnow(),  # Default since simple table doesn't store this
                "end_date": datetime.utcnow(),    # Default since simple table doesn't store this
                "submission_deadline": datetime.utcnow(),  # Default since simple table doesn't store this
                "budget": bid_data["estimated_cost"],
                "currency": "USD",  # Default since simple table doesn't store this
                "requirements": None,
                "terms_conditions": None,
                "is_template": False,
                "status": bid_data["status"],
                "created_by": str(bid_data["created_by"]),
                "created_at": bid_data["created_at"],
                "updated_at": bid_data["updated_at"],
                "published_at": None,
                "closed_at": None,
                "awarded_at": None,
                "total_responses": 0,
                "total_lanes": 1,
                "total_carriers": 0
            }
            bids.append(Bid(**mapped_bid))
        
        return BidListResponse(
            bids=bids,
            total=total_count,
            skip=skip,
            limit=limit
        )
        
    except Exception as e:
        logger.error(f"Error getting bids: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/{bid_id}", response_model=BidResponse)
async def get_bid(
    bid_id: str,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get a specific bid by ID"""
    try:
        # Build query with user restriction for non-managers
        if current_user.role == "manager":
            query = "SELECT * FROM bids WHERE id = %s"
            params = (bid_id,)
        else:
            query = "SELECT * FROM bids WHERE id = %s AND user_id = %s"
            params = (bid_id, str(current_user.id))
        
        bids = db.execute_query(query, params)
        
        if not bids:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid not found"
            )
        
        bid = Bid(**bids[0])
        return BidResponse(
            bid=bid,
            message="Bid retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting bid: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.put("/{bid_id}", response_model=BidResponse)
async def update_bid(
    bid_id: str,
    bid_data: BidUpdate,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Update bid information"""
    try:
        # Check if bid exists and user has permission
        if current_user.role == "manager":
            existing_bids = db.execute_query("SELECT id FROM bids WHERE id = %s", (bid_id,))
        else:
            existing_bids = db.execute_query(
                "SELECT id FROM bids WHERE id = %s AND user_id = %s",
                (bid_id, str(current_user.id))
            )
        
        if not existing_bids:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid not found"
            )
        
        # Prepare update data
        update_fields = []
        params = []
        
        if bid_data.amount is not None:
            update_fields.append("amount = %s")
            params.append(bid_data.amount)
        if bid_data.notes is not None:
            update_fields.append("notes = %s")
            params.append(bid_data.notes)
        if bid_data.status is not None:
            update_fields.append("status = %s")
            params.append(bid_data.status)
        
        if not update_fields:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No fields to update"
            )
        
        update_fields.append("updated_at = %s")
        params.append(datetime.utcnow())
        params.append(bid_id)
        
        # Update bid
        query = f"UPDATE bids SET {', '.join(update_fields)} WHERE id = %s"
        db.execute_update(query, tuple(params))
        
        # Get updated bid
        updated_bids = db.execute_query("SELECT * FROM bids WHERE id = %s", (bid_id,))
        updated_bid = Bid(**updated_bids[0])
        
        return BidResponse(
            bid=updated_bid,
            message="Bid updated successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating bid: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.delete("/{bid_id}")
async def delete_bid(
    bid_id: str,
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Delete a bid"""
    try:
        # Check if bid exists and user has permission
        if current_user.role == "manager":
            existing_bids = db.execute_query("SELECT id FROM bids WHERE id = %s", (bid_id,))
        else:
            existing_bids = db.execute_query(
                "SELECT id FROM bids WHERE id = %s AND user_id = %s",
                (bid_id, str(current_user.id))
            )
        
        if not existing_bids:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid not found"
            )
        
        # Delete bid
        db.execute_update("DELETE FROM bids WHERE id = %s", (bid_id,))
        
        return {"message": "Bid deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting bid: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{bid_id}/accept")
async def accept_bid(
    bid_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Accept a bid (managers only)"""
    try:
        # Check if bid exists
        existing_bids = db.execute_query("SELECT id FROM bids WHERE id = %s", (bid_id,))
        if not existing_bids:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid not found"
            )
        
        # Accept bid
        db.execute_update(
            "UPDATE bids SET status = 'accepted', updated_at = %s WHERE id = %s",
            (datetime.utcnow(), bid_id)
        )
        
        return {"message": "Bid accepted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error accepting bid: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{bid_id}/reject")
async def reject_bid(
    bid_id: str,
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Reject a bid (managers only)"""
    try:
        # Check if bid exists
        existing_bids = db.execute_query("SELECT id FROM bids WHERE id = %s", (bid_id,))
        if not existing_bids:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid not found"
            )
        
        # Reject bid
        db.execute_update(
            "UPDATE bids SET status = 'rejected', updated_at = %s WHERE id = %s",
            (datetime.utcnow(), bid_id)
        )
        
        return {"message": "Bid rejected successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error rejecting bid: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/stats/summary", response_model=BidStats)
async def get_bid_stats(
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get bid statistics summary"""
    try:
        # Build where clause based on user role
        if current_user.role == "manager":
            where_clause = "1=1"
            params = []
        else:
            where_clause = "user_id = %s"
            params = [str(current_user.id)]
        
        # Get total bids
        total_query = f"SELECT COUNT(*) as total FROM bids WHERE {where_clause}"
        total_result = db.execute_query(total_query, tuple(params))
        total = total_result[0]["total"] if total_result else 0
        
        # Get accepted bids
        accepted_query = f"SELECT COUNT(*) as total FROM bids WHERE status = 'accepted' AND {where_clause}"
        accepted_result = db.execute_query(accepted_query, tuple(params))
        accepted = accepted_result[0]["total"] if accepted_result else 0
        
        # Get pending bids
        pending_query = f"SELECT COUNT(*) as total FROM bids WHERE status = 'pending' AND {where_clause}"
        pending_result = db.execute_query(pending_query, tuple(params))
        pending = pending_result[0]["total"] if pending_result else 0
        
        # Get rejected bids
        rejected_query = f"SELECT COUNT(*) as total FROM bids WHERE status = 'rejected' AND {where_clause}"
        rejected_result = db.execute_query(rejected_query, tuple(params))
        rejected = rejected_result[0]["total"] if rejected_result else 0
        
        # Get average bid amount
        avg_query = f"SELECT AVG(amount) as avg_amount FROM bids WHERE amount IS NOT NULL AND {where_clause}"
        avg_result = db.execute_query(avg_query, tuple(params))
        avg_amount = float(avg_result[0]["avg_amount"]) if avg_result and avg_result[0]["avg_amount"] else 0.0
        
        return BidStats(
            total_bids=total,
            accepted_bids=accepted,
            pending_bids=pending,
            rejected_bids=rejected,
            average_amount=round(avg_amount, 2)
        )
        
    except Exception as e:
        logger.error(f"Error getting bid stats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 