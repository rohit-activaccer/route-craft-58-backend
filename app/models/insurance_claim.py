from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class ClaimStatus(str, Enum):
    FILED = "filed"
    UNDER_INVESTIGATION = "under_investigation"
    APPROVED = "approved"
    DENIED = "denied"
    SETTLED = "settled"
    CLOSED = "closed"


class ClaimType(str, Enum):
    DAMAGE = "damage"
    LOSS = "loss"
    THEFT = "theft"
    ACCIDENT = "accident"
    DELAY = "delay"
    OTHER = "other"


class ClaimPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"


class InsuranceClaimBase(BaseModel):
    claim_number: str = Field(..., min_length=1, max_length=50)
    claim_type: ClaimType
    priority: ClaimPriority = ClaimPriority.MEDIUM
    description: str = Field(..., min_length=10, max_length=2000)
    incident_date: datetime
    reported_date: datetime
    estimated_loss: float = Field(..., ge=0)
    currency: str = "USD"
    location: str = Field(..., min_length=1, max_length=500)
    involved_parties: List[str] = Field(..., min_items=1)
    policy_number: Optional[str] = Field(None, max_length=50)
    insurance_provider: Optional[str] = Field(None, max_length=200)
    claim_details: Optional[Dict[str, Any]] = None
    supporting_documents: Optional[List[str]] = None
    notes: Optional[str] = Field(None, max_length=2000)


class InsuranceClaimCreate(InsuranceClaimBase):
    pass


class InsuranceClaimUpdate(BaseModel):
    claim_type: Optional[ClaimType] = None
    priority: Optional[ClaimPriority] = None
    description: Optional[str] = Field(None, min_length=10, max_length=2000)
    incident_date: Optional[datetime] = None
    estimated_loss: Optional[float] = Field(None, ge=0)
    currency: Optional[str] = None
    location: Optional[str] = Field(None, min_length=1, max_length=500)
    involved_parties: Optional[List[str]] = None
    policy_number: Optional[str] = Field(None, max_length=50)
    insurance_provider: Optional[str] = Field(None, max_length=200)
    claim_details: Optional[Dict[str, Any]] = None
    supporting_documents: Optional[List[str]] = None
    notes: Optional[str] = Field(None, max_length=2000)
    status: Optional[ClaimStatus] = None


class InsuranceClaimInDB(InsuranceClaimBase):
    id: str
    status: ClaimStatus = ClaimStatus.FILED
    created_by: str
    created_at: datetime
    updated_at: datetime
    assigned_to: Optional[str] = None
    investigation_started_at: Optional[datetime] = None
    investigation_completed_at: Optional[datetime] = None
    approved_at: Optional[datetime] = None
    denied_at: Optional[datetime] = None
    settled_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    final_settlement_amount: Optional[float] = Field(None, ge=0)
    investigation_notes: Optional[str] = Field(None, max_length=2000)
    resolution_notes: Optional[str] = Field(None, max_length=2000)


class InsuranceClaim(InsuranceClaimBase):
    id: str
    status: ClaimStatus = ClaimStatus.FILED
    created_by: str
    created_at: datetime
    updated_at: datetime
    assigned_to: Optional[str] = None
    investigation_started_at: Optional[datetime] = None
    investigation_completed_at: Optional[datetime] = None
    approved_at: Optional[datetime] = None
    denied_at: Optional[datetime] = None
    settled_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    final_settlement_amount: Optional[float] = Field(None, ge=0)
    investigation_notes: Optional[str] = Field(None, max_length=2000)
    resolution_notes: Optional[str] = Field(None, max_length=2000)


class InsuranceClaimSummary(BaseModel):
    id: str
    claim_number: str
    claim_type: ClaimType
    priority: ClaimPriority
    status: ClaimStatus
    incident_date: datetime
    estimated_loss: float
    currency: str
    location: str
    created_at: datetime
    assigned_to: Optional[str]


class InsuranceClaimResponse(BaseModel):
    insurance_claim: InsuranceClaim
    message: str = "Insurance claim retrieved successfully"


class InsuranceClaimListResponse(BaseModel):
    insurance_claims: List[InsuranceClaimSummary]
    total: int
    page: int
    size: int


class InsuranceClaimStats(BaseModel):
    total_claims: int
    filed_claims: int
    under_investigation_claims: int
    approved_claims: int
    denied_claims: int
    settled_claims: int
    closed_claims: int
    total_estimated_loss: float
    total_settled_amount: float
    claims_by_type: Dict[str, int]
    claims_by_status: Dict[str, int]
    claims_by_priority: Dict[str, int]


class InsuranceClaimSearchParams(BaseModel):
    claim_type: Optional[ClaimType] = None
    status: Optional[ClaimStatus] = None
    priority: Optional[ClaimPriority] = None
    created_by: Optional[str] = None
    assigned_to: Optional[str] = None
    min_estimated_loss: Optional[float] = None
    max_estimated_loss: Optional[float] = None
    incident_date_from: Optional[datetime] = None
    incident_date_to: Optional[datetime] = None 