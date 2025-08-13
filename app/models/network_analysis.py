from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class AnalysisType(str, Enum):
    PERFORMANCE = "performance"
    COST = "cost"
    EFFICIENCY = "efficiency"
    OPTIMIZATION = "optimization"
    COMPARATIVE = "comparative"


class AnalysisStatus(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"


class MetricType(str, Enum):
    COST_PER_MILE = "cost_per_mile"
    ON_TIME_PERFORMANCE = "on_time_performance"
    DAMAGE_RATE = "damage_rate"
    UTILIZATION_RATE = "utilization_rate"
    CARRIER_PERFORMANCE = "carrier_performance"
    LANE_EFFICIENCY = "lane_efficiency"


class NetworkAnalysisBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    analysis_type: AnalysisType
    description: Optional[str] = Field(None, max_length=1000)
    start_date: datetime
    end_date: datetime
    metrics: List[MetricType] = Field(..., min_items=1)
    filters: Optional[Dict[str, Any]] = None
    parameters: Optional[Dict[str, Any]] = None
    notes: Optional[str] = Field(None, max_length=2000)


class NetworkAnalysisCreate(NetworkAnalysisBase):
    pass


class NetworkAnalysisUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    analysis_type: Optional[AnalysisType] = None
    description: Optional[str] = Field(None, max_length=1000)
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    metrics: Optional[List[MetricType]] = None
    filters: Optional[Dict[str, Any]] = None
    parameters: Optional[Dict[str, Any]] = None
    notes: Optional[str] = Field(None, max_length=2000)
    status: Optional[AnalysisStatus] = None


class NetworkAnalysisInDB(NetworkAnalysisBase):
    id: str
    status: AnalysisStatus = AnalysisStatus.PENDING
    created_by: str
    created_at: datetime
    updated_at: datetime
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    failed_at: Optional[datetime] = None
    error_message: Optional[str] = None
    results: Optional[Dict[str, Any]] = None
    summary: Optional[Dict[str, Any]] = None
    recommendations: Optional[List[str]] = None
    execution_time_seconds: Optional[float] = Field(None, ge=0)


class NetworkAnalysis(NetworkAnalysisBase):
    id: str
    status: AnalysisStatus = AnalysisStatus.PENDING
    created_by: str
    created_at: datetime
    updated_at: datetime
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    failed_at: Optional[datetime] = None
    error_message: Optional[str] = None
    results: Optional[Dict[str, Any]] = None
    summary: Optional[Dict[str, Any]] = None
    recommendations: Optional[List[str]] = None
    execution_time_seconds: Optional[float] = Field(None, ge=0)


class NetworkAnalysisSummary(BaseModel):
    id: str
    name: str
    analysis_type: AnalysisType
    status: AnalysisStatus
    start_date: datetime
    end_date: datetime
    created_at: datetime
    completed_at: Optional[datetime]
    execution_time_seconds: Optional[float]


class NetworkAnalysisResponse(BaseModel):
    network_analysis: NetworkAnalysis
    message: str = "Network analysis retrieved successfully"


class NetworkAnalysisListResponse(BaseModel):
    network_analyses: List[NetworkAnalysisSummary]
    total: int
    page: int
    size: int


class NetworkAnalysisStats(BaseModel):
    total_analyses: int
    pending_analyses: int
    in_progress_analyses: int
    completed_analyses: int
    failed_analyses: int
    average_execution_time: float
    analyses_by_type: Dict[str, int]
    analyses_by_status: Dict[str, int]
    top_metrics: List[str]


class NetworkAnalysisSearchParams(BaseModel):
    analysis_type: Optional[AnalysisType] = None
    status: Optional[AnalysisStatus] = None
    created_by: Optional[str] = None
    start_date_from: Optional[datetime] = None
    start_date_to: Optional[datetime] = None
    end_date_from: Optional[datetime] = None
    end_date_to: Optional[datetime] = None


class AnalysisResult(BaseModel):
    metric: MetricType
    value: float
    unit: str
    trend: str  # "increasing", "decreasing", "stable"
    change_percentage: float
    benchmark: Optional[float] = None
    status: str  # "good", "warning", "critical"


class AnalysisSummary(BaseModel):
    total_metrics: int
    improving_metrics: int
    declining_metrics: int
    stable_metrics: int
    critical_metrics: int
    average_performance: float
    top_improvements: List[AnalysisResult]
    top_declines: List[AnalysisResult]
    recommendations: List[str]


class NetworkOptimizationRequest(BaseModel):
    optimization_type: str = Field(..., description="Type of optimization: cost, time, efficiency, or balanced")
    max_routes: Optional[int] = Field(None, ge=1, le=100, description="Maximum number of routes to return")
    cost_weight: Optional[float] = Field(0.5, ge=0.0, le=1.0, description="Weight for cost optimization")
    time_weight: Optional[float] = Field(0.3, ge=0.0, le=1.0, description="Weight for time optimization")
    efficiency_weight: Optional[float] = Field(0.2, ge=0.0, le=1.0, description="Weight for efficiency optimization")
    include_inactive: bool = Field(False, description="Include inactive lanes and carriers in optimization")
    filters: Optional[Dict[str, Any]] = Field(None, description="Additional filters for optimization") 