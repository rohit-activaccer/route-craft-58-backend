from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from app.auth.dependencies import get_current_active_user, get_current_manager_user
from app.database import get_db
from app.models.bid_response import (
    BidResponse, BidResponseCreate, BidResponseUpdate, BidResponseResponse, 
    BidResponseListResponse, BidResponseStats
)
from app.models.user import User
from supabase import Client
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/bid-responses", tags=["Bid Responses"])


@router.post("/", response_model=BidResponseResponse, status_code=status.HTTP_201_CREATED)
async def create_bid_response(
    bid_response_data: BidResponseCreate,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Create a new bid response"""
    try:
        # Check if bid exists and is open
        bid_response = db.table("bids").select("*").eq("id", bid_response_data.bid_id).execute()
        if not bid_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid not found"
            )
        
        bid = bid_response.data[0]
        if bid.get("status") != "open":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Bid is not open for responses"
            )
        
        # Check if carrier has already responded to this bid
        existing_response = db.table("bid_responses").select("*").eq("bid_id", bid_response_data.bid_id).eq("carrier_id", bid_response_data.carrier_id).execute()
        if existing_response.data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Carrier has already responded to this bid"
            )
        
        # Create bid response data
        bid_response_dict = bid_response_data.dict()
        bid_response_dict["created_by"] = str(current_user.id)
        bid_response_dict["created_at"] = datetime.utcnow().isoformat()
        bid_response_dict["updated_at"] = datetime.utcnow().isoformat()
        
        # Insert bid response into database
        response = db.table("bid_responses").insert(bid_response_dict).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create bid response"
            )
        
        created_bid_response = BidResponse(**response.data[0])
        
        return BidResponseResponse(
            bid_response=created_bid_response,
            message="Bid response created successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating bid response: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/", response_model=BidResponseListResponse)
async def get_bid_responses(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    bid_id: Optional[str] = None,
    carrier_id: Optional[str] = None,
    response_status: Optional[str] = None,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get list of bid responses with pagination and filtering"""
    try:
        query = db.table("bid_responses").select("*")
        
        # Apply filters
        if bid_id:
            query = query.eq("bid_id", bid_id)
        if carrier_id:
            query = query.eq("carrier_id", carrier_id)
        if response_status:
            query = query.eq("status", response_status)
        
        # Get total count
        count_response = query.execute()
        total = len(count_response.data)
        
        # Apply pagination
        response = query.range(skip, skip + limit - 1).execute()
        
        bid_responses = [BidResponse(**response_data) for response_data in response.data]
        
        return BidResponseListResponse(
            bid_responses=bid_responses,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
        
    except Exception as e:
        logger.error(f"Error getting bid responses: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/{bid_response_id}", response_model=BidResponseResponse)
async def get_bid_response(
    bid_response_id: str,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get a specific bid response by ID"""
    try:
        response = db.table("bid_responses").select("*").eq("id", bid_response_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid response not found"
            )
        
        bid_response = BidResponse(**response.data[0])
        return BidResponseResponse(
            bid_response=bid_response,
            message="Bid response retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting bid response: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.put("/{bid_response_id}", response_model=BidResponseResponse)
async def update_bid_response(
    bid_response_id: str,
    bid_response_data: BidResponseUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Update a bid response"""
    try:
        # Check if bid response exists
        existing_response = db.table("bid_responses").select("*").eq("id", bid_response_id).execute()
        if not existing_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid response not found"
            )
        
        # Only allow updates if bid is still open
        bid_response = existing_response.data[0]
        bid_response_check = db.table("bids").select("status").eq("id", bid_response["bid_id"]).execute()
        if bid_response_check.data and bid_response_check.data[0].get("status") != "open":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot update response for closed bid"
            )
        
        # Prepare update data
        update_dict = bid_response_data.dict(exclude_unset=True)
        update_dict["updated_at"] = datetime.utcnow().isoformat()
        
        # Update bid response
        response = db.table("bid_responses").update(update_dict).eq("id", bid_response_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update bid response"
            )
        
        updated_bid_response = BidResponse(**response.data[0])
        return BidResponseResponse(
            bid_response=updated_bid_response,
            message="Bid response updated successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating bid response: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.delete("/{bid_response_id}")
async def delete_bid_response(
    bid_response_id: str,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Delete a bid response"""
    try:
        # Check if bid response exists
        existing_response = db.table("bid_responses").select("*").eq("id", bid_response_id).execute()
        if not existing_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid response not found"
            )
        
        # Only allow deletion if bid is still open
        bid_response = existing_response.data[0]
        bid_response_check = db.table("bids").select("status").eq("id", bid_response["bid_id"]).execute()
        if bid_response_check.data and bid_response_check.data[0].get("status") != "open":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot delete response for closed bid"
            )
        
        # Delete bid response
        db.table("bid_responses").delete().eq("id", bid_response_id).execute()
        
        return {"message": "Bid response deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting bid response: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{bid_response_id}/accept")
async def accept_bid_response(
    bid_response_id: str,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Accept a bid response (managers only)"""
    try:
        # Check if bid response exists
        existing_response = db.table("bid_responses").select("*").eq("id", bid_response_id).execute()
        if not existing_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid response not found"
            )
        
        bid_response = existing_response.data[0]
        
        # Update bid response status
        update_data = {
            "status": "accepted",
            "accepted_at": datetime.utcnow().isoformat(),
            "accepted_by": str(current_user.id),
            "updated_at": datetime.utcnow().isoformat()
        }
        
        response = db.table("bid_responses").update(update_data).eq("id", bid_response_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to accept bid response"
            )
        
        # Update bid status to awarded
        bid_update_data = {
            "status": "awarded",
            "awarded_to": bid_response["carrier_id"],
            "awarded_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        }
        
        db.table("bids").update(bid_update_data).eq("id", bid_response["bid_id"]).execute()
        
        return {"message": "Bid response accepted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error accepting bid response: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{bid_response_id}/reject")
async def reject_bid_response(
    bid_response_id: str,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Reject a bid response (managers only)"""
    try:
        # Check if bid response exists
        existing_response = db.table("bid_responses").select("*").eq("id", bid_response_id).execute()
        if not existing_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bid response not found"
            )
        
        # Update bid response status
        update_data = {
            "status": "rejected",
            "rejected_at": datetime.utcnow().isoformat(),
            "rejected_by": str(current_user.id),
            "updated_at": datetime.utcnow().isoformat()
        }
        
        response = db.table("bid_responses").update(update_data).eq("id", bid_response_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to reject bid response"
            )
        
        return {"message": "Bid response rejected successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error rejecting bid response: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/stats/summary", response_model=BidResponseStats)
async def get_bid_response_stats(
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get bid response statistics"""
    try:
        # Get all bid responses
        response = db.table("bid_responses").select("*").execute()
        bid_responses = response.data
        
        if not bid_responses:
            return BidResponseStats(
                total_responses=0,
                accepted_responses=0,
                rejected_responses=0,
                pending_responses=0,
                average_bid_amount=0.0,
                total_bid_amount=0.0
            )
        
        # Calculate statistics
        total_responses = len(bid_responses)
        accepted_responses = len([r for r in bid_responses if r.get("status") == "accepted"])
        rejected_responses = len([r for r in bid_responses if r.get("status") == "rejected"])
        pending_responses = len([r for r in bid_responses if r.get("status") == "pending"])
        
        # Calculate bid amounts
        bid_amounts = [r.get("bid_amount", 0) for r in bid_responses if r.get("bid_amount")]
        average_bid_amount = sum(bid_amounts) / len(bid_amounts) if bid_amounts else 0.0
        total_bid_amount = sum(bid_amounts)
        
        return BidResponseStats(
            total_responses=total_responses,
            accepted_responses=accepted_responses,
            rejected_responses=rejected_responses,
            pending_responses=pending_responses,
            average_bid_amount=average_bid_amount,
            total_bid_amount=total_bid_amount
        )
        
    except Exception as e:
        logger.error(f"Error getting bid response stats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 