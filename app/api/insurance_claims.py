from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from app.auth.dependencies import get_current_active_user, get_current_manager_user
from app.database import get_db
from app.models.insurance_claim import (
    InsuranceClaim, InsuranceClaimCreate, InsuranceClaimUpdate, 
    InsuranceClaimResponse, InsuranceClaimListResponse, InsuranceClaimStats
)
from app.models.user import User
from supabase import Client
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/insurance-claims", tags=["Insurance Claims"])


@router.post("/", response_model=InsuranceClaimResponse, status_code=status.HTTP_201_CREATED)
async def create_insurance_claim(
    claim_data: InsuranceClaimCreate,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Create a new insurance claim"""
    try:
        # Create claim data
        claim_dict = claim_data.dict()
        claim_dict["created_by"] = str(current_user.id)
        claim_dict["created_at"] = datetime.utcnow().isoformat()
        claim_dict["updated_at"] = datetime.utcnow().isoformat()
        
        # Insert claim into database
        response = db.table("insurance_claims").insert(claim_dict).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create insurance claim"
            )
        
        created_claim = InsuranceClaim(**response.data[0])
        
        return InsuranceClaimResponse(
            claim=created_claim,
            message="Insurance claim created successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating insurance claim: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/", response_model=InsuranceClaimListResponse)
async def get_insurance_claims(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    claim_status: Optional[str] = None,
    claim_type: Optional[str] = None,
    carrier_id: Optional[str] = None,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get list of insurance claims with pagination and filtering"""
    try:
        query = db.table("insurance_claims").select("*")
        
        # Apply filters
        if claim_status:
            query = query.eq("status", claim_status)
        if claim_type:
            query = query.eq("claim_type", claim_type)
        if carrier_id:
            query = query.eq("carrier_id", carrier_id)
        
        # Get total count
        count_response = query.execute()
        total = len(count_response.data)
        
        # Apply pagination
        response = query.range(skip, skip + limit - 1).execute()
        
        claims = [InsuranceClaim(**claim_data) for claim_data in response.data]
        
        return InsuranceClaimListResponse(
            claims=claims,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
        
    except Exception as e:
        logger.error(f"Error getting insurance claims: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/{claim_id}", response_model=InsuranceClaimResponse)
async def get_insurance_claim(
    claim_id: str,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get a specific insurance claim by ID"""
    try:
        response = db.table("insurance_claims").select("*").eq("id", claim_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Insurance claim not found"
            )
        
        claim = InsuranceClaim(**response.data[0])
        return InsuranceClaimResponse(
            claim=claim,
            message="Insurance claim retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting insurance claim: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.put("/{claim_id}", response_model=InsuranceClaimResponse)
async def update_insurance_claim(
    claim_id: str,
    claim_data: InsuranceClaimUpdate,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Update an insurance claim"""
    try:
        # Check if claim exists
        existing_claim = db.table("insurance_claims").select("*").eq("id", claim_id).execute()
        if not existing_claim.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Insurance claim not found"
            )
        
        # Prepare update data
        update_dict = claim_data.dict(exclude_unset=True)
        update_dict["updated_at"] = datetime.utcnow().isoformat()
        
        # Update claim
        response = db.table("insurance_claims").update(update_dict).eq("id", claim_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update insurance claim"
            )
        
        updated_claim = InsuranceClaim(**response.data[0])
        return InsuranceClaimResponse(
            claim=updated_claim,
            message="Insurance claim updated successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating insurance claim: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.delete("/{claim_id}")
async def delete_insurance_claim(
    claim_id: str,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Delete an insurance claim (managers only)"""
    try:
        # Check if claim exists
        existing_claim = db.table("insurance_claims").select("*").eq("id", claim_id).execute()
        if not existing_claim.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Insurance claim not found"
            )
        
        # Delete claim
        db.table("insurance_claims").delete().eq("id", claim_id).execute()
        
        return {"message": "Insurance claim deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting insurance claim: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{claim_id}/approve")
async def approve_insurance_claim(
    claim_id: str,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Approve an insurance claim (managers only)"""
    try:
        # Check if claim exists
        existing_claim = db.table("insurance_claims").select("*").eq("id", claim_id).execute()
        if not existing_claim.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Insurance claim not found"
            )
        
        # Update claim status
        update_data = {
            "status": "approved",
            "approved_at": datetime.utcnow().isoformat(),
            "approved_by": str(current_user.id),
            "updated_at": datetime.utcnow().isoformat()
        }
        
        response = db.table("insurance_claims").update(update_data).eq("id", claim_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to approve insurance claim"
            )
        
        return {"message": "Insurance claim approved successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error approving insurance claim: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{claim_id}/reject")
async def reject_insurance_claim(
    claim_id: str,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Reject an insurance claim (managers only)"""
    try:
        # Check if claim exists
        existing_claim = db.table("insurance_claims").select("*").eq("id", claim_id).execute()
        if not existing_claim.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Insurance claim not found"
            )
        
        # Update claim status
        update_data = {
            "status": "rejected",
            "rejected_at": datetime.utcnow().isoformat(),
            "rejected_by": str(current_user.id),
            "updated_at": datetime.utcnow().isoformat()
        }
        
        response = db.table("insurance_claims").update(update_data).eq("id", claim_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to reject insurance claim"
            )
        
        return {"message": "Insurance claim rejected successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error rejecting insurance claim: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{claim_id}/settle")
async def settle_insurance_claim(
    claim_id: str,
    settlement_amount: float,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Settle an insurance claim (managers only)"""
    try:
        # Check if claim exists
        existing_claim = db.table("insurance_claims").select("*").eq("id", claim_id).execute()
        if not existing_claim.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Insurance claim not found"
            )
        
        # Update claim status
        update_data = {
            "status": "settled",
            "settlement_amount": settlement_amount,
            "settled_at": datetime.utcnow().isoformat(),
            "settled_by": str(current_user.id),
            "updated_at": datetime.utcnow().isoformat()
        }
        
        response = db.table("insurance_claims").update(update_data).eq("id", claim_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to settle insurance claim"
            )
        
        return {"message": "Insurance claim settled successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error settling insurance claim: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/stats/summary", response_model=InsuranceClaimStats)
async def get_insurance_claim_stats(
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get insurance claim statistics"""
    try:
        # Get all insurance claims
        response = db.table("insurance_claims").select("*").execute()
        claims = response.data
        
        if not claims:
            return InsuranceClaimStats(
                total_claims=0,
                pending_claims=0,
                approved_claims=0,
                rejected_claims=0,
                settled_claims=0,
                claims_by_type={},
                total_claim_amount=0.0,
                total_settlement_amount=0.0
            )
        
        # Calculate statistics
        total_claims = len(claims)
        pending_claims = len([c for c in claims if c.get("status") == "pending"])
        approved_claims = len([c for c in claims if c.get("status") == "approved"])
        rejected_claims = len([c for c in claims if c.get("status") == "rejected"])
        settled_claims = len([c for c in claims if c.get("status") == "settled"])
        
        # Count by type
        claims_by_type = {}
        for claim in claims:
            claim_type = claim.get("claim_type", "unknown")
            claims_by_type[claim_type] = claims_by_type.get(claim_type, 0) + 1
        
        # Calculate amounts
        total_claim_amount = sum(c.get("claim_amount", 0) for c in claims)
        total_settlement_amount = sum(c.get("settlement_amount", 0) for c in claims if c.get("settlement_amount"))
        
        return InsuranceClaimStats(
            total_claims=total_claims,
            pending_claims=pending_claims,
            approved_claims=approved_claims,
            rejected_claims=rejected_claims,
            settled_claims=settled_claims,
            claims_by_type=claims_by_type,
            total_claim_amount=total_claim_amount,
            total_settlement_amount=total_settlement_amount
        )
        
    except Exception as e:
        logger.error(f"Error getting insurance claim stats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 