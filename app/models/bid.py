from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class BidStatus(str, Enum):
    DRAFT = "draft"
    PUBLISHED = "published"
    OPEN = "open"
    CLOSED = "closed"
    AWARDED = "awarded"
    CANCELLED = "cancelled"


class BidType(str, Enum):
    CONTRACT = "contract"
    SPOT = "spot"
    SEASONAL = "seasonal"
    REGIONAL = "regional"


class BidPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"


class BidBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    bid_type: BidType
    priority: BidPriority = BidPriority.MEDIUM
    start_date: datetime
    end_date: datetime
    submission_deadline: datetime
    budget: Optional[float] = Field(None, ge=0)
    currency: str = "USD"
    requirements: Optional[Dict[str, Any]] = None
    terms_conditions: Optional[str] = Field(None, max_length=2000)
    is_template: bool = False


class BidCreate(BidBase):
    lane_ids: List[str] = Field(..., min_items=1)
    carrier_ids: Optional[List[str]] = None


class BidUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    bid_type: Optional[BidType] = None
    priority: Optional[BidPriority] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    submission_deadline: Optional[datetime] = None
    budget: Optional[float] = Field(None, ge=0)
    currency: Optional[str] = None
    requirements: Optional[Dict[str, Any]] = None
    terms_conditions: Optional[str] = Field(None, max_length=2000)
    status: Optional[BidStatus] = None
    lane_ids: Optional[List[str]] = None
    carrier_ids: Optional[List[str]] = None


class BidInDB(BidBase):
    id: str
    status: BidStatus = BidStatus.DRAFT
    created_by: str
    created_at: datetime
    updated_at: datetime
    published_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    awarded_at: Optional[datetime] = None
    total_responses: int = 0
    total_lanes: int = 0
    total_carriers: int = 0


class Bid(BidBase):
    id: str
    status: BidStatus = BidStatus.DRAFT
    created_by: str
    created_at: datetime
    updated_at: datetime
    published_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    awarded_at: Optional[datetime] = None
    total_responses: int = 0
    total_lanes: int = 0
    total_carriers: int = 0


class BidSummary(BaseModel):
    id: str
    name: str
    bid_type: BidType
    status: BidStatus
    priority: BidPriority
    start_date: datetime
    end_date: datetime
    submission_deadline: datetime
    total_responses: int
    total_lanes: int
    total_carriers: int
    created_at: datetime


class BidResponse(BaseModel):
    bid: Bid
    message: str = "Bid retrieved successfully"


class BidListResponse(BaseModel):
    bids: List[BidSummary]
    total: int
    page: int
    size: int


class BidStats(BaseModel):
    total_bids: int
    active_bids: int
    closed_bids: int
    awarded_bids: int
    total_value: float
    currency: str
    bids_by_type: Dict[str, int]
    bids_by_status: Dict[str, int] 