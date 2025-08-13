from fastapi import APIRouter, HTTPException, status, Query, Depends
from typing import List, Optional, Dict, Any
from app.database_mysql import get_db
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/dashboard-dev", tags=["Dashboard Development"])


@router.get("/overview")
async def get_dashboard_overview_dev(
    db = Depends(get_db)
):
    """Get dashboard overview with key metrics (Development version - no auth required)"""
    try:
        # Get counts from all major tables using MySQL
        users_response = db.execute_query("SELECT id FROM users")
        carriers_response = db.execute_query("SELECT id, status FROM carriers")
        lanes_response = db.execute_query("SELECT id, status FROM lanes")
        bids_response = db.execute_query("SELECT id, status, estimated_cost FROM bids")
        bid_responses_response = db.execute_query("SELECT id, status FROM bid_responses")
        claims_response = db.execute_query("SELECT id, status, amount FROM insurance_claims")
        
        # Calculate metrics
        total_users = len(users_response)
        total_carriers = len(carriers_response)
        active_carriers = len([c for c in carriers_response if c.get("status") == "active"])
        total_lanes = len(lanes_response)
        active_lanes = len([l for l in lanes_response if l.get("status") == "active"])
        total_bids = len(bids_response)
        open_bids = len([b for b in bids_response if b.get("status") == "open"])
        awarded_bids = len([b for b in bids_response if b.get("status") == "awarded"])
        total_responses = len(bid_responses_response)
        pending_responses = len([r for r in bid_responses_response if r.get("status") == "pending"])
        total_claims = len(claims_response)
        pending_claims = len([c for c in claims_response if c.get("status") == "pending"])
        
        # Calculate financial metrics
        total_bid_value = sum(b.get("estimated_cost", 0) for b in bids_response)
        total_awarded_value = sum(b.get("estimated_cost", 0) for b in bids_response if b.get("status") == "awarded")
        total_claims_value = sum(c.get("amount", 0) for c in claims_response)
        
        # Calculate utilization percentages
        carrier_utilization = (active_carriers / total_carriers * 100) if total_carriers > 0 else 0
        lane_utilization = (active_lanes / total_lanes * 100) if total_lanes > 0 else 0
        bid_success_rate = (awarded_bids / total_bids * 100) if total_bids > 0 else 0
        
        return {
            "message": "Dashboard overview retrieved successfully",
            "overview": {
                "users": {
                    "total": total_users
                },
                "carriers": {
                    "total": total_carriers,
                    "active": active_carriers,
                    "utilization_percentage": round(carrier_utilization, 2)
                },
                "lanes": {
                    "total": total_lanes,
                    "active": active_lanes,
                    "utilization_percentage": round(lane_utilization, 2)
                },
                "bids": {
                    "total": total_bids,
                    "open": open_bids,
                    "awarded": awarded_bids,
                    "success_rate_percentage": round(bid_success_rate, 2)
                },
                "responses": {
                    "total": total_responses,
                    "pending": pending_responses
                },
                "claims": {
                    "total": total_claims,
                    "pending": pending_claims
                },
                "financial": {
                    "total_bid_value": total_bid_value,
                    "total_awarded_value": total_awarded_value,
                    "total_claims_value": total_claims_value
                }
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting dashboard overview: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/recent-activity")
async def get_recent_activity_dev(
    limit: int = Query(10, ge=1, le=50, description="Number of recent activities to return"),
    db = Depends(get_db)
):
    """Get recent system activities (Development version - no auth required)"""
    try:
        recent_activities = []
        
        # Get recent bids using MySQL
        recent_bids = db.execute_query("SELECT id, title, status, created_at, created_by FROM bids ORDER BY created_at DESC LIMIT %s", (limit,))
        
        # Get recent bid responses
        recent_responses = db.execute_query("SELECT id, bid_id, carrier_id, status, created_at FROM bid_responses ORDER BY created_at DESC LIMIT %s", (limit,))
        
        # Get recent carriers
        recent_carriers = db.execute_query("SELECT id, company_name, status, created_at FROM carriers ORDER BY created_at DESC LIMIT %s", (limit,))
        
        # Get recent claims
        recent_claims = db.execute_query("SELECT id, claim_type, status, amount, created_at FROM insurance_claims ORDER BY created_at DESC LIMIT %s", (limit,))
        
        # Combine and sort all activities
        for bid in recent_bids:
            recent_activities.append({
                "type": "bid",
                "id": bid["id"],
                "title": f"Bid: {bid['title']}",
                "status": bid["status"],
                "timestamp": bid["created_at"],
                "details": {
                    "bid_id": bid["id"],
                    "created_by": bid["created_by"]
                }
            })
        
        for response in recent_responses:
            recent_activities.append({
                "type": "bid_response",
                "id": response["id"],
                "title": f"Bid Response",
                "status": response["status"],
                "timestamp": response["created_at"],
                "details": {
                    "bid_id": response["bid_id"],
                    "carrier_id": response["carrier_id"]
                }
            })
        
        for carrier in recent_carriers:
            recent_activities.append({
                "type": "carrier",
                "id": carrier["id"],
                "title": f"Carrier: {carrier['company_name']}",
                "status": carrier["status"],
                "timestamp": carrier["created_at"],
                "details": {
                    "carrier_id": carrier["id"]
                }
            })
        
        for claim in recent_claims:
            recent_activities.append({
                "type": "claim",
                "id": claim["id"],
                "title": f"Insurance Claim: {claim['claim_type']}",
                "status": claim["status"],
                "timestamp": claim["created_at"],
                "details": {
                    "claim_id": claim["id"],
                    "amount": claim["amount"]
                }
            })
        
        # Sort by timestamp (most recent first)
        recent_activities.sort(key=lambda x: x["timestamp"], reverse=True)
        
        return {
            "message": "Recent activity retrieved successfully",
            "activities": recent_activities[:limit]
        }
        
    except Exception as e:
        logger.error(f"Error getting recent activity: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 