from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class ResponseStatus(str, Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDER_REVIEW = "under_review"
    APPROVED = "approved"
    REJECTED = "rejected"
    AWARDED = "awarded"
    WITHDRAWN = "withdrawn"


class RateType(str, Enum):
    PER_MILE = "per_mile"
    PER_LOAD = "per_load"
    PER_POUND = "per_pound"
    PER_TON = "per_ton"
    FLAT_RATE = "flat_rate"


class BidResponseBase(BaseModel):
    bid_id: str
    carrier_id: str
    rate: float = Field(..., ge=0)
    rate_type: RateType
    transit_time_hours: Optional[int] = Field(None, ge=0)
    service_level: str = Field(..., max_length=100)
    equipment_available: List[str] = Field(..., min_items=1)
    capacity_available: float = Field(..., ge=0)
    insurance_coverage: Optional[float] = Field(None, ge=0)
    special_requirements: Optional[List[str]] = None
    additional_services: Optional[List[str]] = None
    notes: Optional[str] = Field(None, max_length=1000)
    terms_conditions: Optional[str] = Field(None, max_length=2000)


class BidResponseCreate(BidResponseBase):
    pass


class BidResponseUpdate(BaseModel):
    rate: Optional[float] = Field(None, ge=0)
    rate_type: Optional[RateType] = None
    transit_time_hours: Optional[int] = Field(None, ge=0)
    service_level: Optional[str] = Field(None, max_length=100)
    equipment_available: Optional[List[str]] = None
    capacity_available: Optional[float] = Field(None, ge=0)
    insurance_coverage: Optional[float] = Field(None, ge=0)
    special_requirements: Optional[List[str]] = None
    additional_services: Optional[List[str]] = None
    notes: Optional[str] = Field(None, max_length=1000)
    terms_conditions: Optional[str] = Field(None, max_length=2000)
    status: Optional[ResponseStatus] = None


class BidResponseInDB(BidResponseBase):
    id: str
    status: ResponseStatus = ResponseStatus.DRAFT
    created_at: datetime
    updated_at: datetime
    submitted_at: Optional[datetime] = None
    reviewed_at: Optional[datetime] = None
    reviewed_by: Optional[str] = None
    review_notes: Optional[str] = Field(None, max_length=1000)
    award_date: Optional[datetime] = None
    total_value: Optional[float] = Field(None, ge=0)
    score: Optional[float] = Field(None, ge=0, le=100)


class BidResponse(BidResponseBase):
    id: str
    status: ResponseStatus = ResponseStatus.DRAFT
    created_at: datetime
    updated_at: datetime
    submitted_at: Optional[datetime] = None
    reviewed_at: Optional[datetime] = None
    reviewed_by: Optional[str] = None
    review_notes: Optional[str] = Field(None, max_length=1000)
    award_date: Optional[datetime] = None
    total_value: Optional[float] = Field(None, ge=0)
    score: Optional[float] = Field(None, ge=0, le=100)


class BidResponseSummary(BaseModel):
    id: str
    bid_id: str
    carrier_id: str
    rate: float
    rate_type: RateType
    transit_time_hours: Optional[int]
    service_level: str
    status: ResponseStatus
    total_value: Optional[float]
    score: Optional[float]
    created_at: datetime
    submitted_at: Optional[datetime]


class BidResponseResponse(BaseModel):
    bid_response: BidResponse
    message: str = "Bid response retrieved successfully"


class BidResponseListResponse(BaseModel):
    bid_responses: List[BidResponseSummary]
    total: int
    page: int
    size: int


class BidResponseStats(BaseModel):
    total_responses: int
    submitted_responses: int
    approved_responses: int
    rejected_responses: int
    awarded_responses: int
    average_rate: float
    average_transit_time: float
    responses_by_status: Dict[str, int]
    responses_by_rate_type: Dict[str, int]


class BidResponseSearchParams(BaseModel):
    bid_id: Optional[str] = None
    carrier_id: Optional[str] = None
    status: Optional[ResponseStatus] = None
    rate_type: Optional[RateType] = None
    min_rate: Optional[float] = None
    max_rate: Optional[float] = None
    min_score: Optional[float] = None
    max_score: Optional[float] = None 