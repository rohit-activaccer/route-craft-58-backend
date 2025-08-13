from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional, Dict, Any
from app.auth.dependencies import get_current_active_user, get_current_manager_user
from app.database import get_db
from app.models.network_analysis import (
    NetworkAnalysis, NetworkAnalysisCreate, NetworkAnalysisUpdate,
    NetworkAnalysisResponse, NetworkAnalysisListResponse, NetworkOptimizationRequest,
    NetworkAnalysisStats, NetworkAnalysisSearchParams, AnalysisResult, AnalysisSummary
)
from app.models.user import User
from supabase import Client
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/network-analysis", tags=["Network Analysis"])


@router.post("/", response_model=NetworkAnalysisResponse, status_code=status.HTTP_201_CREATED)
async def create_network_analysis(
    analysis_data: NetworkAnalysisCreate,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Create a new network analysis"""
    try:
        # Validate date range
        if analysis_data.start_date >= analysis_data.end_date:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Start date must be before end date"
            )
        
        # Check if analysis with same name exists
        existing_analysis = db.table("network_analysis").select("id").eq("name", analysis_data.name).execute()
        if existing_analysis.data:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Analysis with this name already exists"
            )
        
        # Create analysis data
        analysis_dict = analysis_data.dict()
        analysis_dict["created_by"] = str(current_user.id)
        analysis_dict["created_at"] = datetime.utcnow().isoformat()
        analysis_dict["updated_at"] = datetime.utcnow().isoformat()
        analysis_dict["status"] = "pending"
        
        # Insert analysis into database
        response = db.table("network_analysis").insert(analysis_dict).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create network analysis"
            )
        
        created_analysis = NetworkAnalysis(**response.data[0])
        
        logger.info(f"Network analysis '{analysis_data.name}' created by user {current_user.id}")
        
        return NetworkAnalysisResponse(
            network_analysis=created_analysis,
            message="Network analysis created successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating network analysis: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/", response_model=NetworkAnalysisListResponse)
async def get_network_analyses(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(10, ge=1, le=100, description="Number of records to return"),
    analysis_type: Optional[str] = Query(None, description="Filter by analysis type"),
    analysis_status: Optional[str] = Query(None, description="Filter by status"),
    created_by: Optional[str] = Query(None, description="Filter by creator"),
    start_date_from: Optional[datetime] = Query(None, description="Filter by start date from"),
    start_date_to: Optional[datetime] = Query(None, description="Filter by start date to"),
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get list of network analyses with pagination and filtering"""
    try:
        query = db.table("network_analysis").select("*")
        
        # Apply filters
        if analysis_type:
            query = query.eq("analysis_type", analysis_type)
        if analysis_status:
            query = query.eq("status", analysis_status)
        if created_by:
            query = query.eq("created_by", created_by)
        if start_date_from:
            query = query.gte("start_date", start_date_from.isoformat())
        if start_date_to:
            query = query.lte("start_date", start_date_to.isoformat())
        
        # Get total count
        count_response = query.execute()
        total = len(count_response.data)
        
        # Apply pagination
        response = query.range(skip, skip + limit - 1).execute()
        
        analyses = [NetworkAnalysis(**analysis_data) for analysis_data in response.data]
        
        return NetworkAnalysisListResponse(
            network_analyses=analyses,
            total=total,
            page=skip // limit + 1,
            size=limit
        )
        
    except Exception as e:
        logger.error(f"Error getting network analyses: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/{analysis_id}", response_model=NetworkAnalysisResponse)
async def get_network_analysis(
    analysis_id: str,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get a specific network analysis by ID"""
    try:
        response = db.table("network_analysis").select("*").eq("id", analysis_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Network analysis not found"
            )
        
        analysis = NetworkAnalysis(**response.data[0])
        return NetworkAnalysisResponse(
            network_analysis=analysis,
            message="Network analysis retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting network analysis: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.put("/{analysis_id}", response_model=NetworkAnalysisResponse)
async def update_network_analysis(
    analysis_id: str,
    analysis_data: NetworkAnalysisUpdate,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Update a network analysis"""
    try:
        # Check if analysis exists
        existing_analysis = db.table("network_analysis").select("*").eq("id", analysis_id).execute()
        if not existing_analysis.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Network analysis not found"
            )
        
        # Validate date range if both dates are provided
        if analysis_data.start_date and analysis_data.end_date:
            if analysis_data.start_date >= analysis_data.end_date:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Start date must be before end date"
                )
        
        # Check if analysis is in progress or completed (cannot modify)
        current_status = existing_analysis.data[0].get("status")
        if current_status in ["in_progress", "completed"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot modify analysis with status '{current_status}'"
            )
        
        # Prepare update data
        update_dict = analysis_data.dict(exclude_unset=True)
        update_dict["updated_at"] = datetime.utcnow().isoformat()
        
        # Update analysis
        response = db.table("network_analysis").update(update_dict).eq("id", analysis_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update network analysis"
            )
        
        updated_analysis = NetworkAnalysis(**response.data[0])
        logger.info(f"Network analysis {analysis_id} updated by user {current_user.id}")
        
        return NetworkAnalysisResponse(
            network_analysis=updated_analysis,
            message="Network analysis updated successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating network analysis: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.delete("/{analysis_id}")
async def delete_network_analysis(
    analysis_id: str,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Delete a network analysis (managers only)"""
    try:
        # Check if analysis exists
        existing_analysis = db.table("network_analysis").select("*").eq("id", analysis_id).execute()
        if not existing_analysis.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Network analysis not found"
            )
        
        # Check if analysis is in progress (cannot delete)
        current_status = existing_analysis.data[0].get("status")
        if current_status == "in_progress":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot delete analysis that is currently in progress"
            )
        
        # Delete analysis
        db.table("network_analysis").delete().eq("id", analysis_id).execute()
        
        logger.info(f"Network analysis {analysis_id} deleted by user {current_user.id}")
        
        return {"message": "Network analysis deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting network analysis: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{analysis_id}/start")
async def start_network_analysis(
    analysis_id: str,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Start a network analysis execution"""
    try:
        # Check if analysis exists
        existing_analysis = db.table("network_analysis").select("*").eq("id", analysis_id).execute()
        if not existing_analysis.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Network analysis not found"
            )
        
        current_status = existing_analysis.data[0].get("status")
        if current_status != "pending":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot start analysis with status '{current_status}'"
            )
        
        # Update status to in_progress
        update_data = {
            "status": "in_progress",
            "started_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        }
        
        response = db.table("network_analysis").update(update_data).eq("id", analysis_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to start network analysis"
            )
        
        logger.info(f"Network analysis {analysis_id} started by user {current_user.id}")
        
        return {"message": "Network analysis started successfully", "status": "in_progress"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error starting network analysis: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{analysis_id}/complete")
async def complete_network_analysis(
    analysis_id: str,
    results: Dict[str, Any],
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Complete a network analysis with results"""
    try:
        # Check if analysis exists
        existing_analysis = db.table("network_analysis").select("*").eq("id", analysis_id).execute()
        if not existing_analysis.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Network analysis not found"
            )
        
        current_status = existing_analysis.data[0].get("status")
        if current_status != "in_progress":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot complete analysis with status '{current_status}'"
            )
        
        # Calculate execution time
        started_at = datetime.fromisoformat(existing_analysis.data[0].get("started_at", ""))
        execution_time = (datetime.utcnow() - started_at).total_seconds()
        
        # Update status to completed
        update_data = {
            "status": "completed",
            "completed_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat(),
            "results": results,
            "execution_time_seconds": execution_time
        }
        
        response = db.table("network_analysis").update(update_data).eq("id", analysis_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to complete network analysis"
            )
        
        logger.info(f"Network analysis {analysis_id} completed by user {current_user.id}")
        
        return {"message": "Network analysis completed successfully", "status": "completed"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error completing network analysis: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/{analysis_id}/fail")
async def fail_network_analysis(
    analysis_id: str,
    error_message: str,
    current_user: User = Depends(get_current_manager_user),
    db: Client = Depends(get_db)
):
    """Mark a network analysis as failed"""
    try:
        # Check if analysis exists
        existing_analysis = db.table("network_analysis").select("*").eq("id", analysis_id).execute()
        if not existing_analysis.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Network analysis not found"
            )
        
        current_status = existing_analysis.data[0].get("status")
        if current_status not in ["pending", "in_progress"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot fail analysis with status '{current_status}'"
            )
        
        # Update status to failed
        update_data = {
            "status": "failed",
            "failed_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat(),
            "error_message": error_message
        }
        
        response = db.table("network_analysis").update(update_data).eq("id", analysis_id).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to mark network analysis as failed"
            )
        
        logger.warning(f"Network analysis {analysis_id} marked as failed by user {current_user.id}: {error_message}")
        
        return {"message": "Network analysis marked as failed", "status": "failed"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error marking network analysis as failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/stats/summary", response_model=NetworkAnalysisStats)
async def get_network_analysis_stats(
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Get network analysis statistics"""
    try:
        # Get all analyses
        response = db.table("network_analysis").select("*").execute()
        analyses = response.data or []
        
        # Calculate stats
        total_analyses = len(analyses)
        pending_analyses = len([a for a in analyses if a.get("status") == "pending"])
        in_progress_analyses = len([a for a in analyses if a.get("status") == "in_progress"])
        completed_analyses = len([a for a in analyses if a.get("status") == "completed"])
        failed_analyses = len([a for a in analyses if a.get("status") == "failed"])
        
        # Calculate average execution time
        execution_times = [a.get("execution_time_seconds", 0) for a in analyses if a.get("execution_time_seconds")]
        average_execution_time = sum(execution_times) / len(execution_times) if execution_times else 0
        
        # Count by type and status
        analyses_by_type = {}
        analyses_by_status = {}
        
        for analysis in analyses:
            analysis_type = analysis.get("analysis_type", "unknown")
            status = analysis.get("status", "unknown")
            
            analyses_by_type[analysis_type] = analyses_by_type.get(analysis_type, 0) + 1
            analyses_by_status[status] = analyses_by_status.get(status, 0) + 1
        
        # Get top metrics (most used)
        all_metrics = []
        for analysis in analyses:
            if analysis.get("metrics"):
                all_metrics.extend(analysis.get("metrics", []))
        
        metric_counts = {}
        for metric in all_metrics:
            metric_counts[metric] = metric_counts.get(metric, 0) + 1
        
        top_metrics = sorted(metric_counts.items(), key=lambda x: x[1], reverse=True)[:5]
        top_metrics = [metric for metric, count in top_metrics]
        
        return NetworkAnalysisStats(
            total_analyses=total_analyses,
            pending_analyses=pending_analyses,
            in_progress_analyses=in_progress_analyses,
            completed_analyses=completed_analyses,
            failed_analyses=failed_analyses,
            average_execution_time=round(average_execution_time, 2),
            analyses_by_type=analyses_by_type,
            analyses_by_status=analyses_by_status,
            top_metrics=top_metrics
        )
        
    except Exception as e:
        logger.error(f"Error getting network analysis stats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/optimize-routes")
async def optimize_routes(
    optimization_request: NetworkOptimizationRequest,
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Optimize routes based on given parameters"""
    try:
        # Get relevant data for optimization
        lanes_response = db.table("lanes").select("*").eq("status", "active").execute()
        carriers_response = db.table("carriers").select("*").eq("status", "active").execute()
        
        if not lanes_response.data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No active lanes found for optimization"
            )
        
        if not carriers_response.data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No active carriers found for optimization"
            )
        
        # Perform route optimization (simplified algorithm)
        optimized_routes = []
        
        for lane in lanes_response.data:
            # Find best carrier for each lane based on criteria
            best_carrier = None
            best_score = 0
            
            for carrier in carriers_response.data:
                score = 0
                
                # Score based on carrier type match
                if carrier.get("carrier_type") == lane.get("lane_type"):
                    score += 3
                
                # Score based on service level
                if carrier.get("service_level") == "premium":
                    score += 2
                elif carrier.get("service_level") == "express":
                    score += 1
                
                # Score based on rating
                if carrier.get("rating"):
                    score += carrier.get("rating", 0)
                
                # Score based on operating radius
                if carrier.get("operating_radius"):
                    # Calculate distance between origin and carrier location
                    # This is a simplified calculation
                    distance = 500  # Placeholder
                    if distance <= carrier.get("operating_radius", 0):
                        score += 1
                
                if score > best_score:
                    best_score = score
                    best_carrier = carrier
            
            if best_carrier:
                optimized_routes.append({
                    "lane_id": lane["id"],
                    "lane_name": f"{lane.get('origin_city', '')} to {lane.get('destination_city', '')}",
                    "carrier_id": best_carrier["id"],
                    "carrier_name": best_carrier["name"],
                    "score": best_score,
                    "estimated_cost": lane.get("estimated_cost", 0),
                    "estimated_duration": lane.get("estimated_duration", 0)
                })
        
        # Sort by score (highest first)
        optimized_routes.sort(key=lambda x: x["score"], reverse=True)
        
        # Limit results if max_routes specified
        if optimization_request.max_routes:
            optimized_routes = optimized_routes[:optimization_request.max_routes]
        
        logger.info(f"Route optimization completed for user {current_user.id}, found {len(optimized_routes)} routes")
        
        return {
            "message": "Route optimization completed successfully",
            "total_routes": len(optimized_routes),
            "optimized_routes": optimized_routes,
            "optimization_parameters": optimization_request.dict()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error optimizing routes: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/analyze-network-efficiency")
async def analyze_network_efficiency(
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Analyze overall network efficiency"""
    try:
        # Get network data
        lanes_response = db.table("lanes").select("*").execute()
        carriers_response = db.table("carriers").select("*").execute()
        bids_response = db.table("bids").select("*").execute()
        bid_responses_response = db.table("bid_responses").select("*").execute()
        
        lanes = lanes_response.data or []
        carriers = carriers_response.data or []
        bids = bids_response.data or []
        bid_responses = bid_responses_response.data or []
        
        # Calculate efficiency metrics
        total_lanes = len(lanes)
        active_lanes = len([l for l in lanes if l.get("status") == "active"])
        total_carriers = len(carriers)
        active_carriers = len([c for c in carriers if c.get("status") == "active"])
        
        # Calculate lane utilization
        lane_utilization = (active_lanes / total_lanes * 100) if total_lanes > 0 else 0
        
        # Calculate carrier utilization
        carrier_utilization = (active_carriers / total_carriers * 100) if total_carriers > 0 else 0
        
        # Calculate bid success rate
        total_bids = len(bids)
        awarded_bids = len([b for b in bids if b.get("status") == "awarded"])
        bid_success_rate = (awarded_bids / total_bids * 100) if total_bids > 0 else 0
        
        # Calculate average response time
        response_times = []
        for bid in bids:
            if bid.get("status") == "awarded":
                bid_responses_for_bid = [br for br in bid_responses if br.get("bid_id") == bid["id"]]
                if bid_responses_for_bid:
                    # Calculate time between bid creation and first response
                    bid_created = datetime.fromisoformat(bid.get("created_at", ""))
                    first_response = min([datetime.fromisoformat(br.get("created_at", "")) for br in bid_responses_for_bid])
                    response_time = (first_response - bid_created).total_seconds() / 3600  # in hours
                    response_times.append(response_time)
        
        avg_response_time = sum(response_times) / len(response_times) if response_times else 0
        
        # Calculate cost efficiency
        total_bid_value = sum(b.get("estimated_cost", 0) for b in bids)
        total_awarded_value = sum(b.get("estimated_cost", 0) for b in bids if b.get("status") == "awarded")
        cost_efficiency = (total_awarded_value / total_bid_value * 100) if total_bid_value > 0 else 0
        
        logger.info(f"Network efficiency analysis completed for user {current_user.id}")
        
        return {
            "message": "Network efficiency analysis completed",
            "metrics": {
                "lane_utilization_percentage": round(lane_utilization, 2),
                "carrier_utilization_percentage": round(carrier_utilization, 2),
                "bid_success_rate_percentage": round(bid_success_rate, 2),
                "average_response_time_hours": round(avg_response_time, 2),
                "cost_efficiency_percentage": round(cost_efficiency, 2),
                "total_lanes": total_lanes,
                "active_lanes": active_lanes,
                "total_carriers": total_carriers,
                "active_carriers": active_carriers,
                "total_bids": total_bids,
                "awarded_bids": awarded_bids
            }
        }
        
    except Exception as e:
        logger.error(f"Error analyzing network efficiency: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/generate-network-report")
async def generate_network_report(
    report_type: str = Query(..., description="Type of report: summary, detailed, or custom"),
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Generate a comprehensive network report"""
    try:
        if report_type not in ["summary", "detailed", "custom"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid report type. Must be 'summary', 'detailed', or 'custom'"
            )
        
        # Get all relevant data
        lanes_response = db.table("lanes").select("*").execute()
        carriers_response = db.table("carriers").select("*").execute()
        bids_response = db.table("bids").select("*").execute()
        bid_responses_response = db.table("bid_responses").select("*").execute()
        
        lanes = lanes_response.data or []
        carriers = carriers_response.data or []
        bids = bids_response.data or []
        bid_responses = bid_responses_response.data or []
        
        # Generate report based on type
        if report_type == "summary":
            report = {
                "report_type": "summary",
                "generated_at": datetime.utcnow().isoformat(),
                "summary": {
                    "total_lanes": len(lanes),
                    "total_carriers": len(carriers),
                    "total_bids": len(bids),
                    "total_responses": len(bid_responses),
                    "active_lanes": len([l for l in lanes if l.get("status") == "active"]),
                    "active_carriers": len([c for c in carriers if c.get("status") == "active"]),
                    "open_bids": len([b for b in bids if b.get("status") == "open"])
                }
            }
        elif report_type == "detailed":
            report = {
                "report_type": "detailed",
                "generated_at": datetime.utcnow().isoformat(),
                "summary": {
                    "total_lanes": len(lanes),
                    "total_carriers": len(carriers),
                    "total_bids": len(bids),
                    "total_responses": len(bid_responses)
                },
                "lanes_by_status": {},
                "carriers_by_type": {},
                "bids_by_status": {},
                "responses_by_status": {}
            }
            
            # Detailed breakdowns
            for lane in lanes:
                status = lane.get("status", "unknown")
                report["lanes_by_status"][status] = report["lanes_by_status"].get(status, 0) + 1
            
            for carrier in carriers:
                carrier_type = carrier.get("carrier_type", "unknown")
                report["carriers_by_type"][carrier_type] = report["carriers_by_type"].get(carrier_type, 0) + 1
            
            for bid in bids:
                status = bid.get("status", "unknown")
                report["bids_by_status"][status] = report["bids_by_status"].get(status, 0) + 1
            
            for response in bid_responses:
                status = response.get("status", "unknown")
                report["responses_by_status"][status] = report["responses_by_status"].get(status, 0) + 1
        
        else:  # custom
            report = {
                "report_type": "custom",
                "generated_at": datetime.utcnow().isoformat(),
                "message": "Custom report generation not implemented yet"
            }
        
        logger.info(f"Network report '{report_type}' generated for user {current_user.id}")
        
        return {
            "message": f"{report_type.capitalize()} network report generated successfully",
            "report": report
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating network report: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.post("/search")
async def search_network_analyses(
    search_params: NetworkAnalysisSearchParams,
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: Client = Depends(get_db)
):
    """Search network analyses with advanced filtering"""
    try:
        query = db.table("network_analysis").select("*")
        
        # Apply search filters
        if search_params.analysis_type:
            query = query.eq("analysis_type", search_params.analysis_type)
        if search_params.status:
            query = query.eq("status", search_params.status)
        if search_params.created_by:
            query = query.eq("created_by", search_params.created_by)
        if search_params.start_date_from:
            query = query.gte("start_date", search_params.start_date_from.isoformat())
        if search_params.start_date_to:
            query = query.lte("start_date", search_params.start_date_to.isoformat())
        if search_params.end_date_from:
            query = query.gte("end_date", search_params.end_date_from.isoformat())
        if search_params.end_date_to:
            query = query.lte("end_date", search_params.end_date_to.isoformat())
        
        # Get total count
        count_response = query.execute()
        total = len(count_response.data)
        
        # Apply pagination
        response = query.range(skip, skip + limit - 1).execute()
        
        analyses = [NetworkAnalysis(**analysis_data) for analysis_data in response.data]
        
        return {
            "message": "Search completed successfully",
            "total": total,
            "page": skip // limit + 1,
            "size": limit,
            "analyses": analyses,
            "search_parameters": search_params.dict()
        }
        
    except Exception as e:
        logger.error(f"Error searching network analyses: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        ) 