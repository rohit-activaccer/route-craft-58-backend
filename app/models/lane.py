from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class LaneStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    MAINTENANCE = "maintenance"
    DISCONTINUED = "discontinued"


class LaneType(str, Enum):
    TRUCKLOAD = "truckload"
    LTL = "ltl"
    INTERMODAL = "intermodal"
    SPECIALIZED = "specialized"
    BULK = "bulk"


class VolumeUnit(str, Enum):
    LOADS = "loads"
    POUNDS = "pounds"
    TONS = "tons"
    CUBIC_FEET = "cubic_feet"
    PALLETS = "pallets"


class LaneBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    origin_city: str = Field(..., min_length=1, max_length=100)
    origin_state: str = Field(..., min_length=2, max_length=2)
    origin_zip: str = Field(..., min_length=5, max_length=10)
    destination_city: str = Field(..., min_length=1, max_length=100)
    destination_state: str = Field(..., min_length=2, max_length=2)
    destination_zip: str = Field(..., min_length=5, max_length=10)
    lane_type: LaneType
    distance_miles: float = Field(..., ge=0)
    estimated_transit_time_hours: Optional[int] = Field(None, ge=0)
    volume: float = Field(..., ge=0)
    volume_unit: VolumeUnit
    frequency: str = Field(..., max_length=100)  # e.g., "Daily", "Weekly", "Monthly"
    special_requirements: Optional[List[str]] = None
    equipment_requirements: Optional[List[str]] = None
    hazmat_required: bool = False
    temperature_controlled: bool = False
    notes: Optional[str] = Field(None, max_length=1000)


class LaneCreate(LaneBase):
    pass


class LaneUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    origin_city: Optional[str] = Field(None, min_length=1, max_length=100)
    origin_state: Optional[str] = Field(None, min_length=2, max_length=2)
    origin_zip: Optional[str] = Field(None, min_length=5, max_length=10)
    destination_city: Optional[str] = Field(None, min_length=1, max_length=100)
    destination_state: Optional[str] = Field(None, min_length=2, max_length=2)
    destination_zip: Optional[str] = Field(None, min_length=5, max_length=10)
    lane_type: Optional[LaneType] = None
    distance_miles: Optional[float] = Field(None, ge=0)
    estimated_transit_time_hours: Optional[int] = Field(None, ge=0)
    volume: Optional[float] = Field(None, ge=0)
    volume_unit: Optional[VolumeUnit] = None
    frequency: Optional[str] = Field(None, max_length=100)
    special_requirements: Optional[List[str]] = None
    equipment_requirements: Optional[List[str]] = None
    hazmat_required: Optional[bool] = None
    temperature_controlled: Optional[bool] = None
    notes: Optional[str] = Field(None, max_length=1000)
    status: Optional[LaneStatus] = None


class LaneInDB(LaneBase):
    id: str
    status: LaneStatus = LaneStatus.ACTIVE
    created_at: datetime
    updated_at: datetime
    total_bids: int = 0
    total_awards: int = 0
    average_rate: Optional[float] = Field(None, ge=0)
    total_volume_shipped: float = 0.0
    on_time_performance: Optional[float] = Field(None, ge=0, le=100)
    cost_per_mile: Optional[float] = Field(None, ge=0)


class Lane(LaneBase):
    id: str
    status: LaneStatus = LaneStatus.ACTIVE
    created_at: datetime
    updated_at: datetime
    total_bids: int = 0
    total_awards: int = 0
    average_rate: Optional[float] = Field(None, ge=0)
    total_volume_shipped: float = 0.0
    on_time_performance: Optional[float] = Field(None, ge=0, le=100)
    cost_per_mile: Optional[float] = Field(None, ge=0)


class LaneSummary(BaseModel):
    id: str
    name: str
    origin_city: str
    origin_state: str
    destination_city: str
    destination_state: str
    lane_type: LaneType
    distance_miles: float
    volume: float
    volume_unit: VolumeUnit
    status: LaneStatus
    total_bids: int
    total_awards: int
    average_rate: Optional[float]
    created_at: datetime


class LaneResponse(BaseModel):
    lane: Lane
    message: str = "Lane retrieved successfully"


class LaneListResponse(BaseModel):
    lanes: List[LaneSummary]
    total: int
    page: int
    size: int


class LaneStats(BaseModel):
    total_lanes: int
    active_lanes: int
    inactive_lanes: int
    total_distance: float
    total_volume: float
    average_rate: float
    lanes_by_type: Dict[str, int]
    lanes_by_status: Dict[str, int]
    top_performing_lanes: List[LaneSummary]


class LaneSearchParams(BaseModel):
    origin_state: Optional[str] = None
    destination_state: Optional[str] = None
    lane_type: Optional[LaneType] = None
    status: Optional[LaneStatus] = None
    min_distance: Optional[float] = None
    max_distance: Optional[float] = None
    min_volume: Optional[float] = None
    max_volume: Optional[float] = None 