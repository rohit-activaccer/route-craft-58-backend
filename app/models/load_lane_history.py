from datetime import datetime
from decimal import Decimal
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, Field, validator
from sqlalchemy import Column, String, DateTime, Boolean, Numeric, Text, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class LoadLaneHistoryDB(Base):
    """Database model for load/lane history"""
    __tablename__ = "load_lane_history"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True)
    load_id = Column(String(100), unique=True, nullable=False)
    contract_reference = Column(String(100))
    
    # Origin Information
    origin_location = Column(String(200), nullable=False)
    origin_country = Column(String(10), nullable=False, default='IN')
    origin_facility_id = Column(String(100))
    origin_latitude = Column(Numeric(10, 8))
    origin_longitude = Column(Numeric(11, 8))
    
    # Destination Information
    destination_location = Column(String(200), nullable=False)
    destination_country = Column(String(10), nullable=False, default='IN')
    destination_facility_id = Column(String(100))
    destination_latitude = Column(Numeric(10, 8))
    destination_longitude = Column(Numeric(11, 8))
    
    # Shipment Details
    load_date = Column(DateTime(timezone=True), nullable=False)
    delivery_date = Column(DateTime(timezone=True), nullable=False)
    mode = Column(String(20), default='TL')
    equipment_type = Column(String(100))
    commodity_type = Column(String(100))
    weight_kg = Column(Numeric(10, 2))
    volume_cbm = Column(Numeric(10, 2))
    distance_km = Column(Numeric(10, 2))
    
    # Carrier Information
    carrier_id = Column(PostgresUUID(as_uuid=True), ForeignKey('carriers.id'))
    carrier_name = Column(String(200))
    
    # Financial Information
    rate_type = Column(String(20))
    total_cost = Column(Numeric(12, 2), nullable=False)
    rate_per_km = Column(Numeric(10, 2))
    accessorial_charges = Column(Numeric(10, 2), default=0.00)
    fuel_surcharge_percentage = Column(Numeric(5, 2), default=0.00)
    
    # Procurement Details
    tender_type = Column(String(20), default='spot')
    carrier_response = Column(String(20), default='accepted')
    
    # Performance Metrics
    on_time_pickup = Column(Boolean)
    on_time_delivery = Column(Boolean)
    billing_accuracy = Column(Boolean, default=True)
    
    # Metadata
    notes = Column(Text)
    created_by = Column(PostgresUUID(as_uuid=True), ForeignKey('users.id'))
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

# Pydantic models for API
class LoadLaneHistoryBase(BaseModel):
    """Base model for load/lane history"""
    load_id: str = Field(..., description="Unique load identifier")
    contract_reference: Optional[str] = Field(None, description="Contract or rate agreement reference")
    
    # Origin Information
    origin_location: str = Field(..., description="Origin city, state, or location")
    origin_country: str = Field(default="IN", description="Origin country code")
    origin_facility_id: Optional[str] = Field(None, description="Internal plant/warehouse code")
    origin_latitude: Optional[Decimal] = Field(None, description="Origin latitude coordinate")
    origin_longitude: Optional[Decimal] = Field(None, description="Origin longitude coordinate")
    
    # Destination Information
    destination_location: str = Field(..., description="Destination city, state, or location")
    destination_country: str = Field(default="IN", description="Destination country code")
    destination_facility_id: Optional[str] = Field(None, description="Internal plant/warehouse code")
    destination_latitude: Optional[Decimal] = Field(None, description="Destination latitude coordinate")
    destination_longitude: Optional[Decimal] = Field(None, description="Destination longitude coordinate")
    
    # Shipment Details
    load_date: datetime = Field(..., description="Shipment pickup date")
    delivery_date: datetime = Field(..., description="Delivery date at destination")
    mode: str = Field(default="TL", description="Transportation mode")
    equipment_type: Optional[str] = Field(None, description="Equipment type (e.g., 32ft SXL, 20ft container)")
    commodity_type: Optional[str] = Field(None, description="Product category")
    weight_kg: Optional[Decimal] = Field(None, description="Shipment weight in kilograms")
    volume_cbm: Optional[Decimal] = Field(None, description="Shipment volume in cubic meters")
    distance_km: Optional[Decimal] = Field(None, description="Route distance in kilometers")
    
    # Carrier Information
    carrier_id: Optional[UUID] = Field(None, description="Reference to carrier table")
    carrier_name: Optional[str] = Field(None, description="Name of the transporter/carrier")
    
    # Financial Information
    rate_type: Optional[str] = Field(None, description="Rate type (per_km, per_trip, flat)")
    total_cost: Decimal = Field(..., description="Total freight cost")
    rate_per_km: Optional[Decimal] = Field(None, description="Rate per kilometer")
    accessorial_charges: Optional[Decimal] = Field(default=0.00, description="Additional charges")
    fuel_surcharge_percentage: Optional[Decimal] = Field(default=0.00, description="Fuel surcharge percentage")
    
    # Procurement Details
    tender_type: str = Field(default="spot", description="Tender type (contracted, spot, adhoc)")
    carrier_response: str = Field(default="accepted", description="Carrier response status")
    
    # Performance Metrics
    on_time_pickup: Optional[bool] = Field(None, description="On-time pickup indicator")
    on_time_delivery: Optional[bool] = Field(None, description="On-time delivery indicator")
    billing_accuracy: Optional[bool] = Field(default=True, description="Billing accuracy flag")
    
    # Metadata
    notes: Optional[str] = Field(None, description="Additional notes")
    created_by: Optional[UUID] = Field(None, description="User who created the record")

    @validator('delivery_date')
    def delivery_date_must_be_after_load_date(cls, v, values):
        if 'load_date' in values and v <= values['load_date']:
            raise ValueError('delivery_date must be after load_date')
        return v
    
    @validator('origin_latitude', 'origin_longitude')
    def validate_origin_coordinates(cls, v, values):
        if 'origin_latitude' in values and 'origin_longitude' in values:
            if (values['origin_latitude'] is not None) != (values['origin_longitude'] is not None):
                raise ValueError('Both origin latitude and longitude must be provided together')
        return v
    
    @validator('destination_latitude', 'destination_longitude')
    def validate_destination_coordinates(cls, v, values):
        if 'destination_latitude' in values and 'destination_longitude' in values:
            if (values['destination_latitude'] is not None) != (values['destination_longitude'] is not None):
                raise ValueError('Both destination latitude and longitude must be provided together')
        return v

class LoadLaneHistoryCreate(LoadLaneHistoryBase):
    """Model for creating new load/lane history records"""
    pass

class LoadLaneHistoryUpdate(BaseModel):
    """Model for updating load/lane history records"""
    contract_reference: Optional[str] = None
    origin_location: Optional[str] = None
    origin_country: Optional[str] = None
    origin_facility_id: Optional[str] = None
    origin_latitude: Optional[Decimal] = None
    origin_longitude: Optional[Decimal] = None
    destination_location: Optional[str] = None
    destination_country: Optional[str] = None
    destination_facility_id: Optional[str] = None
    destination_latitude: Optional[Decimal] = None
    destination_longitude: Optional[Decimal] = None
    load_date: Optional[datetime] = None
    delivery_date: Optional[datetime] = None
    mode: Optional[str] = None
    equipment_type: Optional[str] = None
    commodity_type: Optional[str] = None
    weight_kg: Optional[Decimal] = None
    volume_cbm: Optional[Decimal] = None
    distance_km: Optional[Decimal] = None
    carrier_id: Optional[UUID] = None
    carrier_name: Optional[str] = None
    rate_type: Optional[str] = None
    total_cost: Optional[Decimal] = None
    rate_per_km: Optional[Decimal] = None
    accessorial_charges: Optional[Decimal] = None
    fuel_surcharge_percentage: Optional[Decimal] = None
    tender_type: Optional[str] = None
    carrier_response: Optional[str] = None
    on_time_pickup: Optional[bool] = None
    on_time_delivery: Optional[bool] = None
    billing_accuracy: Optional[bool] = None
    notes: Optional[str] = None

class LoadLaneHistoryResponse(LoadLaneHistoryBase):
    """Model for load/lane history API responses"""
    id: UUID
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class LoadLaneHistorySummary(BaseModel):
    """Summary model for load/lane history analytics"""
    total_loads: int
    total_cost: Decimal
    average_rate_per_km: Optional[Decimal]
    on_time_delivery_rate: Optional[float]
    top_commodities: list[dict]
    top_lanes: list[dict]
    top_carriers: list[dict]
    
    class Config:
        from_attributes = True 