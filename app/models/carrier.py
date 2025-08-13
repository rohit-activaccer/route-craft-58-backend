from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class CarrierStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    SUSPENDED = "suspended"
    PENDING_APPROVAL = "pending_approval"


class CarrierType(str, Enum):
    TRUCKLOAD = "truckload"
    LTL = "ltl"
    INTERMODAL = "intermodal"
    SPECIALIZED = "specialized"
    BULK = "bulk"


class ServiceLevel(str, Enum):
    STANDARD = "standard"
    EXPRESS = "express"
    PREMIUM = "premium"
    ECONOMY = "economy"


class CarrierBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    company_name: str = Field(..., min_length=1, max_length=200)
    email: EmailStr
    phone: str = Field(..., min_length=10, max_length=20)
    address: str = Field(..., min_length=10, max_length=500)
    city: str = Field(..., min_length=1, max_length=100)
    state: str = Field(..., min_length=2, max_length=2)
    zip_code: str = Field(..., min_length=5, max_length=10)
    country: str = Field(..., min_length=2, max_length=2)
    carrier_type: CarrierType
    service_level: ServiceLevel = ServiceLevel.STANDARD
    mc_number: Optional[str] = Field(None, max_length=20)
    dot_number: Optional[str] = Field(None, max_length=20)
    tax_id: Optional[str] = Field(None, max_length=20)
    insurance_coverage: Optional[float] = Field(None, ge=0)
    fleet_size: Optional[int] = Field(None, ge=0)
    operating_radius: Optional[int] = Field(None, ge=0)  # in miles
    specialties: Optional[List[str]] = None
    certifications: Optional[List[str]] = None
    notes: Optional[str] = Field(None, max_length=1000)


class CarrierCreate(CarrierBase):
    contact_person: str = Field(..., min_length=1, max_length=100)
    contact_title: Optional[str] = Field(None, max_length=100)


class CarrierUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    company_name: Optional[str] = Field(None, min_length=1, max_length=200)
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, min_length=10, max_length=20)
    address: Optional[str] = Field(None, min_length=10, max_length=500)
    city: Optional[str] = Field(None, min_length=1, max_length=100)
    state: Optional[str] = Field(None, min_length=2, max_length=2)
    zip_code: Optional[str] = Field(None, min_length=5, max_length=10)
    country: Optional[str] = Field(None, min_length=2, max_length=2)
    carrier_type: Optional[CarrierType] = None
    service_level: Optional[ServiceLevel] = None
    mc_number: Optional[str] = Field(None, max_length=20)
    dot_number: Optional[str] = Field(None, max_length=20)
    tax_id: Optional[str] = Field(None, max_length=20)
    insurance_coverage: Optional[float] = Field(None, ge=0)
    fleet_size: Optional[int] = Field(None, ge=0)
    operating_radius: Optional[int] = Field(None, ge=0)
    specialties: Optional[List[str]] = None
    certifications: Optional[List[str]] = None
    notes: Optional[str] = Field(None, max_length=1000)
    status: Optional[CarrierStatus] = None
    contact_person: Optional[str] = Field(None, min_length=1, max_length=100)
    contact_title: Optional[str] = Field(None, max_length=100)


class CarrierInDB(CarrierBase):
    id: str
    status: CarrierStatus = CarrierStatus.PENDING_APPROVAL
    contact_person: str
    contact_title: Optional[str]
    created_at: datetime
    updated_at: datetime
    approved_at: Optional[datetime] = None
    approved_by: Optional[str] = None
    total_bids: int = 0
    total_awards: int = 0
    total_revenue: float = 0.0
    rating: Optional[float] = Field(None, ge=0, le=5)


class Carrier(CarrierBase):
    id: str
    status: CarrierStatus = CarrierStatus.PENDING_APPROVAL
    contact_person: str
    contact_title: Optional[str]
    created_at: datetime
    updated_at: datetime
    approved_at: Optional[datetime] = None
    approved_by: Optional[str] = None
    total_bids: int = 0
    total_awards: int = 0
    total_revenue: float = 0.0
    rating: Optional[float] = Field(None, ge=0, le=5)


class CarrierSummary(BaseModel):
    id: str
    name: str
    company_name: str
    carrier_type: CarrierType
    service_level: ServiceLevel
    status: CarrierStatus
    city: str
    state: str
    total_bids: int
    total_awards: int
    rating: Optional[float]
    created_at: datetime


class CarrierResponse(BaseModel):
    carrier: Carrier
    message: str = "Carrier retrieved successfully"


class CarrierListResponse(BaseModel):
    carriers: List[CarrierSummary]
    total: int
    page: int
    size: int


class CarrierStats(BaseModel):
    total_carriers: int
    active_carriers: int
    pending_carriers: int
    suspended_carriers: int
    carriers_by_type: Dict[str, int]
    carriers_by_service_level: Dict[str, int]
    average_rating: float
    total_revenue: float 