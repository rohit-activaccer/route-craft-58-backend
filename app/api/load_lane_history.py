from datetime import datetime, timedelta
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, desc, and_
from decimal import Decimal

from app.database import get_db
from app.models.load_lane_history import (
    LoadLaneHistoryCreate,
    LoadLaneHistoryUpdate,
    LoadLaneHistoryResponse,
    LoadLaneHistorySummary,
    LoadLaneHistoryDB
)
from app.auth.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/api/v1/load-lane-history", tags=["Load/Lane History"])

@router.post("/", response_model=LoadLaneHistoryResponse)
async def create_load_lane_history(
    load_data: LoadLaneHistoryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new load/lane history record"""
    try:
        # Check if load_id already exists
        existing_load = db.query(LoadLaneHistoryDB).filter(
            LoadLaneHistoryDB.load_id == load_data.load_id
        ).first()
        
        if existing_load:
            raise HTTPException(
                status_code=400,
                detail=f"Load ID '{load_data.load_id}' already exists"
            )
        
        # Create new record
        db_load = LoadLaneHistoryDB(
            **load_data.dict(),
            created_by=current_user.id
        )
        
        db.add(db_load)
        db.commit()
        db.refresh(db_load)
        
        return db_load
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/", response_model=List[LoadLaneHistoryResponse])
async def get_load_lane_history(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    origin_location: Optional[str] = None,
    destination_location: Optional[str] = None,
    carrier_name: Optional[str] = None,
    commodity_type: Optional[str] = None,
    mode: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get load/lane history records with optional filtering"""
    try:
        query = db.query(LoadLaneHistoryDB)
        
        # Apply filters
        if origin_location:
            query = query.filter(LoadLaneHistoryDB.origin_location.ilike(f"%{origin_location}%"))
        
        if destination_location:
            query = query.filter(LoadLaneHistoryDB.destination_location.ilike(f"%{destination_location}%"))
        
        if carrier_name:
            query = query.filter(LoadLaneHistoryDB.carrier_name.ilike(f"%{carrier_name}%"))
        
        if commodity_type:
            query = query.filter(LoadLaneHistoryDB.commodity_type.ilike(f"%{commodity_type}%"))
        
        if mode:
            query = query.filter(LoadLaneHistoryDB.mode == mode)
        
        if start_date:
            query = query.filter(LoadLaneHistoryDB.load_date >= start_date)
        
        if end_date:
            query = query.filter(LoadLaneHistoryDB.load_date <= end_date)
        
        # Order by most recent first
        query = query.order_by(desc(LoadLaneHistoryDB.load_date))
        
        # Apply pagination
        total = query.count()
        loads = query.offset(skip).limit(limit).all()
        
        return loads
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{load_id}", response_model=LoadLaneHistoryResponse)
async def get_load_lane_history_by_id(
    load_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get a specific load/lane history record by load_id"""
    try:
        load = db.query(LoadLaneHistoryDB).filter(
            LoadLaneHistoryDB.load_id == load_id
        ).first()
        
        if not load:
            raise HTTPException(
                status_code=404,
                detail=f"Load with ID '{load_id}' not found"
            )
        
        return load
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{load_id}", response_model=LoadLaneHistoryResponse)
async def update_load_lane_history(
    load_id: str,
    load_update: LoadLaneHistoryUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update an existing load/lane history record"""
    try:
        # Find existing record
        db_load = db.query(LoadLaneHistoryDB).filter(
            LoadLaneHistoryDB.load_id == load_id
        ).first()
        
        if not db_load:
            raise HTTPException(
                status_code=404,
                detail=f"Load with ID '{load_id}' not found"
            )
        
        # Update fields
        update_data = load_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_load, field, value)
        
        db_load.updated_at = datetime.utcnow()
        
        db.commit()
        db.refresh(db_load)
        
        return db_load
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{load_id}")
async def delete_load_lane_history(
    load_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a load/lane history record"""
    try:
        db_load = db.query(LoadLaneHistoryDB).filter(
            LoadLaneHistoryDB.load_id == load_id
        ).first()
        
        if not db_load:
            raise HTTPException(
                status_code=404,
                detail=f"Load with ID '{load_id}' not found"
            )
        
        db.delete(db_load)
        db.commit()
        
        return {"message": f"Load '{load_id}' deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/summary", response_model=LoadLaneHistorySummary)
async def get_load_lane_history_summary(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get analytics summary for load/lane history"""
    try:
        query = db.query(LoadLaneHistoryDB)
        
        # Apply date filters if provided
        if start_date:
            query = query.filter(LoadLaneHistoryDB.load_date >= start_date)
        if end_date:
            query = query.filter(LoadLaneHistoryDB.load_date <= end_date)
        
        # Get total counts and costs
        total_loads = query.count()
        total_cost = query.with_entities(
            func.coalesce(func.sum(LoadLaneHistoryDB.total_cost), Decimal('0'))
        ).scalar()
        
        # Calculate average rate per km
        avg_rate_query = query.filter(LoadLaneHistoryDB.rate_per_km.isnot(None))
        average_rate_per_km = avg_rate_query.with_entities(
            func.avg(LoadLaneHistoryDB.rate_per_km)
        ).scalar()
        
        # Calculate on-time delivery rate
        delivery_query = query.filter(LoadLaneHistoryDB.on_time_delivery.isnot(None))
        total_deliveries = delivery_query.count()
        on_time_deliveries = delivery_query.filter(
            LoadLaneHistoryDB.on_time_delivery == True
        ).count()
        
        on_time_delivery_rate = (
            (on_time_deliveries / total_deliveries * 100) if total_deliveries > 0 else None
        )
        
        # Get top commodities
        top_commodities = db.query(
            LoadLaneHistoryDB.commodity_type,
            func.count(LoadLaneHistoryDB.id).label('count'),
            func.sum(LoadLaneHistoryDB.total_cost).label('total_cost')
        ).filter(
            LoadLaneHistoryDB.commodity_type.isnot(None)
        ).group_by(
            LoadLaneHistoryDB.commodity_type
        ).order_by(
            desc('count')
        ).limit(5).all()
        
        # Get top lanes (origin-destination pairs)
        top_lanes = db.query(
            LoadLaneHistoryDB.origin_location,
            LoadLaneHistoryDB.destination_location,
            func.count(LoadLaneHistoryDB.id).label('count'),
            func.avg(LoadLaneHistoryDB.rate_per_km).label('avg_rate')
        ).filter(
            LoadLaneHistoryDB.origin_location.isnot(None),
            LoadLaneHistoryDB.destination_location.isnot(None)
        ).group_by(
            LoadLaneHistoryDB.origin_location,
            LoadLaneHistoryDB.destination_location
        ).order_by(
            desc('count')
        ).limit(5).all()
        
        # Get top carriers
        top_carriers = db.query(
            LoadLaneHistoryDB.carrier_name,
            func.count(LoadLaneHistoryDB.id).label('count'),
            func.sum(LoadLaneHistoryDB.total_cost).label('total_cost'),
            func.avg(LoadLaneHistoryDB.rate_per_km).label('avg_rate')
        ).filter(
            LoadLaneHistoryDB.carrier_name.isnot(None)
        ).group_by(
            LoadLaneHistoryDB.carrier_name
        ).order_by(
            desc('count')
        ).limit(5).all()
        
        return LoadLaneHistorySummary(
            total_loads=total_loads,
            total_cost=total_cost,
            average_rate_per_km=average_rate_per_km,
            on_time_delivery_rate=on_time_delivery_rate,
            top_commodities=[
                {
                    "commodity_type": item.commodity_type,
                    "count": item.count,
                    "total_cost": float(item.total_cost) if item.total_cost else 0
                }
                for item in top_commodities
            ],
            top_lanes=[
                {
                    "origin": item.origin_location,
                    "destination": item.destination_location,
                    "count": item.count,
                    "avg_rate": float(item.avg_rate) if item.avg_rate else 0
                }
                for item in top_lanes
            ],
            top_carriers=[
                {
                    "carrier_name": item.carrier_name,
                    "count": item.count,
                    "total_cost": float(item.total_cost) if item.total_cost else 0,
                    "avg_rate": float(item.avg_rate) if item.avg_rate else 0
                }
                for item in top_carriers
            ]
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/lane-performance")
async def get_lane_performance_analytics(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get lane performance analytics for rate benchmarking"""
    try:
        query = db.query(LoadLaneHistoryDB)
        
        if start_date:
            query = query.filter(LoadLaneHistoryDB.load_date >= start_date)
        if end_date:
            query = query.filter(LoadLaneHistoryDB.load_date <= end_date)
        
        # Get lane performance data
        lane_performance = db.query(
            LoadLaneHistoryDB.origin_location,
            LoadLaneHistoryDB.destination_location,
            LoadLaneHistoryDB.mode,
            LoadLaneHistoryDB.equipment_type,
            func.count(LoadLaneHistoryDB.id).label('total_loads'),
            func.avg(LoadLaneHistoryDB.rate_per_km).label('avg_rate_per_km'),
            func.min(LoadLaneHistoryDB.rate_per_km).label('min_rate_per_km'),
            func.max(LoadLaneHistoryDB.rate_per_km).label('max_rate_per_km'),
            func.avg(LoadLaneHistoryDB.total_cost).label('avg_total_cost'),
            func.avg(LoadLaneHistoryDB.distance_km).label('avg_distance'),
            func.avg(
                func.case(
                    (LoadLaneHistoryDB.on_time_delivery == True, 1),
                    else_=0
                )
            ).label('on_time_delivery_rate')
        ).filter(
            LoadLaneHistoryDB.origin_location.isnot(None),
            LoadLaneHistoryDB.destination_location.isnot(None),
            LoadLaneHistoryDB.rate_per_km.isnot(None)
        ).group_by(
            LoadLaneHistoryDB.origin_location,
            LoadLaneHistoryDB.destination_location,
            LoadLaneHistoryDB.mode,
            LoadLaneHistoryDB.equipment_type
        ).order_by(
            desc('total_loads')
        ).all()
        
        return [
            {
                "origin": item.origin_location,
                "destination": item.destination_location,
                "mode": item.mode,
                "equipment_type": item.equipment_type,
                "total_loads": item.total_loads,
                "avg_rate_per_km": float(item.avg_rate_per_km) if item.avg_rate_per_km else 0,
                "min_rate_per_km": float(item.min_rate_per_km) if item.min_rate_per_km else 0,
                "max_rate_per_km": float(item.max_rate_per_km) if item.max_rate_per_km else 0,
                "avg_total_cost": float(item.avg_total_cost) if item.avg_total_cost else 0,
                "avg_distance": float(item.avg_distance) if item.avg_distance else 0,
                "on_time_delivery_rate": float(item.on_time_delivery_rate * 100) if item.on_time_delivery_rate else 0
            }
            for item in lane_performance
        ]
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 