from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional, Dict, Any
from app.auth.dependencies import get_current_active_user, get_current_manager_user
from app.database import get_db
from app.models.user import User
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/overview")
async def get_dashboard_overview(
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get dashboard overview with key metrics"""
    try:
        # Get counts from all major tables using MySQL with proper error handling
        users_response = db.execute_query("SELECT COUNT(*) as count FROM users WHERE status = 'active'")
        carriers_response = db.execute_query("SELECT COUNT(*) as count, SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_count FROM carriers")
        lanes_response = db.execute_query("SELECT COUNT(*) as count, SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_count FROM lanes")
        bids_response = db.execute_query("SELECT COUNT(*) as count, SUM(CASE WHEN status = 'open' THEN 1 ELSE 0 END) as open_count, SUM(CASE WHEN status = 'awarded' THEN 1 ELSE 0 END) as awarded_count, SUM(estimated_cost) as total_value FROM bids")
        bid_responses_response = db.execute_query("SELECT COUNT(*) as count, SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count FROM bid_responses")
        claims_response = db.execute_query("SELECT COUNT(*) as count, SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count, SUM(amount) as total_amount FROM insurance_claims")
        
        # Extract values safely with defaults
        total_users = users_response[0]["count"] if users_response else 0
        total_carriers = carriers_response[0]["count"] if carriers_response else 0
        active_carriers = carriers_response[0]["active_count"] if carriers_response else 0
        total_lanes = lanes_response[0]["count"] if lanes_response else 0
        active_lanes = lanes_response[0]["active_count"] if lanes_response else 0
        total_bids = bids_response[0]["count"] if bids_response else 0
        open_bids = bids_response[0]["open_count"] if bids_response else 0
        awarded_bids = bids_response[0]["awarded_count"] if bids_response else 0
        total_responses = bid_responses_response[0]["count"] if bid_responses_response else 0
        pending_responses = bid_responses_response[0]["pending_count"] if bid_responses_response else 0
        total_claims = claims_response[0]["count"] if claims_response else 0
        pending_claims = claims_response[0]["pending_count"] if claims_response else 0
        
        # Calculate financial metrics
        total_bid_value = float(bids_response[0]["total_value"] or 0) if bids_response else 0.0
        total_awarded_value = 0.0  # Will be calculated separately for accuracy
        total_claims_value = float(claims_response[0]["total_amount"] or 0) if claims_response else 0.0
        
        # Get awarded bids value separately for accuracy
        if awarded_bids > 0:
            awarded_bids_value = db.execute_query(
                "SELECT SUM(estimated_cost) as total FROM bids WHERE status = 'awarded'"
            )
            total_awarded_value = float(awarded_bids_value[0]["total"] or 0) if awarded_bids_value else 0.0
        
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
async def get_recent_activity(
    limit: int = Query(10, ge=1, le=50, description="Number of recent activities to return"),
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get recent activity across the system"""
    try:
        # Get recent activities from various tables using UNION for better performance
        recent_activities_query = """
            (SELECT 'bid' as type, id, created_at, status, 
                    CONCAT('Bid #', id, ' was ', status) as description
             FROM bids 
             ORDER BY created_at DESC 
             LIMIT %s)
            UNION ALL
            (SELECT 'lane' as type, id, created_at, status,
                    CONCAT('Lane #', id, ' was ', status) as description
             FROM lanes 
             ORDER BY created_at DESC 
             LIMIT %s)
            UNION ALL
            (SELECT 'carrier' as type, id, created_at, status,
                    CONCAT('Carrier #', id, ' was ', status) as description
             FROM carriers 
             ORDER BY created_at DESC 
             LIMIT %s)
            ORDER BY created_at DESC 
            LIMIT %s
        """
        
        limit_per_table = max(1, limit // 3)
        recent_activities = db.execute_query(
            recent_activities_query,
            (limit_per_table, limit_per_table, limit_per_table, limit)
        )
        
        # Format the response
        formatted_activities = []
        for activity in recent_activities:
            formatted_activities.append({
                "type": activity["type"],
                "id": activity["id"],
                "action": f"{activity['type'].title()} {activity['status']}",
                "timestamp": activity["created_at"],
                "description": activity["description"]
            })
        
        return {
            "message": "Recent activity retrieved successfully",
            "activities": formatted_activities,
            "total": len(formatted_activities)
        }
        
    except Exception as e:
        logger.error(f"Error getting recent activity: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/performance-metrics")
async def get_performance_metrics(
    period: str = Query("30d", description="Time period: 7d, 30d, 90d, 1y"),
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get performance metrics for the specified time period"""
    try:
        # Calculate date range based on period
        end_date = datetime.utcnow()
        if period == "7d":
            start_date = end_date - timedelta(days=7)
        elif period == "30d":
            start_date = end_date - timedelta(days=30)
        elif period == "90d":
            start_date = end_date - timedelta(days=90)
        elif period == "1y":
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=30)
        
        # Get metrics for the period using a single optimized query
        metrics_query = """
            SELECT 
                (SELECT COUNT(*) FROM bids WHERE created_at >= %s) as total_bids,
                (SELECT AVG(estimated_cost) FROM bids WHERE created_at >= %s) as avg_bid_cost,
                (SELECT COUNT(*) FROM lanes WHERE created_at >= %s) as total_lanes,
                (SELECT COUNT(*) FROM carriers WHERE created_at >= %s) as total_carriers
        """
        
        metrics_result = db.execute_query(
            metrics_query,
            (start_date, start_date, start_date, start_date)
        )
        
        # Extract metrics safely
        metrics = metrics_result[0] if metrics_result else {}
        total_bids = metrics.get("total_bids", 0)
        avg_bid_cost = float(metrics.get("avg_bid_cost") or 0)
        total_lanes = metrics.get("total_lanes", 0)
        total_carriers = metrics.get("total_carriers", 0)
        
        return {
            "message": "Performance metrics retrieved successfully",
            "period": period,
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "metrics": {
                "bids": {
                    "total": total_bids,
                    "average_cost": round(avg_bid_cost, 2)
                },
                "lanes": {
                    "total": total_lanes
                },
                "carriers": {
                    "total": total_carriers
                }
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting performance metrics: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/carrier-performance")
async def get_carrier_performance(
    current_user: User = Depends(get_current_active_user),
    db = Depends(get_db)
):
    """Get carrier performance metrics"""
    try:
        # Get carrier performance data with improved query
        carrier_stats = db.execute_query("""
            SELECT 
                c.id,
                c.company_name,
                c.rating,
                COUNT(b.id) as total_bids,
                SUM(CASE WHEN b.status = 'awarded' THEN 1 ELSE 0 END) as accepted_bids,
                AVG(b.estimated_cost) as avg_bid_amount
            FROM carriers c
            LEFT JOIN bids b ON c.id = b.carrier_id
            WHERE c.status = 'active'
            GROUP BY c.id, c.company_name, c.rating
            HAVING total_bids > 0
            ORDER BY c.rating DESC, accepted_bids DESC
            LIMIT 10
        """)
        
        # Calculate performance metrics
        performance_data = []
        for carrier in carrier_stats:
            total_bids = carrier["total_bids"]
            accepted_bids = carrier["accepted_bids"]
            success_rate = (accepted_bids / total_bids * 100) if total_bids > 0 else 0
            
            performance_data.append({
                "carrier_id": carrier["id"],
                "company_name": carrier["company_name"],
                "rating": carrier["rating"],
                "total_bids": total_bids,
                "accepted_bids": accepted_bids,
                "success_rate": round(success_rate, 2),
                "average_bid_amount": round(float(carrier["avg_bid_amount"] or 0), 2)
            })
        
        return {
            "message": "Carrier performance metrics retrieved successfully",
            "carriers": performance_data
        }
        
    except Exception as e:
        logger.error(f"Error getting carrier performance: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/financial-summary")
async def get_financial_summary(
    period: str = Query("30d", description="Time period: 7d, 30d, 90d, 1y"),
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Get financial summary for the specified time period (managers only)"""
    try:
        # Calculate date range based on period
        end_date = datetime.utcnow()
        if period == "7d":
            start_date = end_date - timedelta(days=7)
        elif period == "30d":
            start_date = end_date - timedelta(days=30)
        elif period == "90d":
            start_date = end_date - timedelta(days=90)
        elif period == "1y":
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=30)
        
        # Get financial data for the period using optimized query
        financial_query = """
            SELECT 
                (SELECT SUM(estimated_cost) FROM bids WHERE created_at >= %s) as total_bid_value,
                (SELECT AVG(estimated_cost) FROM bids WHERE created_at >= %s) as avg_bid_value,
                (SELECT SUM(estimated_cost) FROM bids WHERE status = 'awarded' AND created_at >= %s) as total_awarded_value,
                (SELECT SUM(amount) FROM insurance_claims WHERE created_at >= %s) as total_claims_value
        """
        
        financial_result = db.execute_query(
            financial_query,
            (start_date, start_date, start_date, start_date)
        )
        
        # Extract financial metrics safely
        financial = financial_result[0] if financial_result else {}
        total_bid_value = float(financial.get("total_bid_value") or 0)
        avg_bid_value = float(financial.get("avg_bid_value") or 0)
        total_awarded_value = float(financial.get("total_awarded_value") or 0)
        total_claims_value = float(financial.get("total_claims_value") or 0)
        
        # Calculate profit margin (simplified)
        profit_margin = total_awarded_value - total_claims_value
        profit_margin_percentage = (profit_margin / total_awarded_value * 100) if total_awarded_value > 0 else 0
        
        return {
            "message": "Financial summary retrieved successfully",
            "period": period,
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "financial_summary": {
                "total_bid_value": round(total_bid_value, 2),
                "average_bid_value": round(avg_bid_value, 2),
                "total_awarded_value": round(total_awarded_value, 2),
                "total_claims_value": round(total_claims_value, 2),
                "profit_margin": round(profit_margin, 2),
                "profit_margin_percentage": round(profit_margin_percentage, 2)
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting financial summary: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/system-health")
async def get_system_health(
    current_user: User = Depends(get_current_manager_user),
    db = Depends(get_db)
):
    """Get system health metrics (managers only)"""
    try:
        # Check database connectivity
        try:
            db.execute_query("SELECT 1 as health_check")
            db_status = "healthy"
        except Exception:
            db_status = "unhealthy"
        
        # Get system metrics using optimized queries
        system_metrics_query = """
            SELECT 
                (SELECT COUNT(*) FROM users WHERE status = 'active') as total_users,
                (SELECT COUNT(*) FROM carriers WHERE status = 'active') as total_carriers,
                (SELECT COUNT(*) FROM lanes WHERE status = 'active') as total_lanes,
                (SELECT COUNT(*) FROM bids WHERE status IN ('open', 'awarded')) as total_bids,
                (SELECT COUNT(*) FROM users WHERE (company_name IS NULL OR company_name = '') AND status = 'active') as users_without_company,
                (SELECT COUNT(*) FROM carriers WHERE (contact_person IS NULL OR contact_person = '') AND status = 'active') as carriers_without_contact
        """
        
        metrics_result = db.execute_query(system_metrics_query)
        metrics = metrics_result[0] if metrics_result else {}
        
        total_users = metrics.get("total_users", 0)
        total_carriers = metrics.get("total_carriers", 0)
        total_lanes = metrics.get("total_lanes", 0)
        total_bids = metrics.get("total_bids", 0)
        users_without_company = metrics.get("users_without_company", 0)
        carriers_without_contact = metrics.get("carriers_without_contact", 0)
        
        # Calculate data quality score
        data_quality_score = 100
        if total_users > 0:
            data_quality_score -= (users_without_company / total_users) * 20
        if total_carriers > 0:
            data_quality_score -= (carriers_without_contact / total_carriers) * 20
        
        return {
            "message": "System health metrics retrieved successfully",
            "system_health": {
                "database": db_status,
                "data_quality_score": round(max(0, data_quality_score), 2),
                "total_records": {
                    "users": total_users,
                    "carriers": total_carriers,
                    "lanes": total_lanes,
                    "bids": total_bids
                },
                "data_issues": {
                    "users_without_company": users_without_company,
                    "carriers_without_contact": carriers_without_contact
                },
                "timestamp": datetime.utcnow().isoformat()
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting system health: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 