from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.dashboard_dev import router as dashboard_dev_router
from app.api.bids import router as bids_router
# from app.api.load_lane_history import router as load_lane_history_router
from app.config import settings
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Route Craft API",
    description="Backend API for Route Craft transportation management system",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(dashboard_dev_router, prefix="/api/v1")
app.include_router(bids_router, prefix="/api/v1")
# app.include_router(load_lane_history_router, prefix="/api/v1")

@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Route Craft API is running"}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "Route Craft API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug
    ) 