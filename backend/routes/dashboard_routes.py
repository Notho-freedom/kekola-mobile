# routes/dashboard_routes.py - Endpoints pour dashboard et graphiques

from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from schemas.dashboard_schemas import DashboardStats, GraphData
from services.dashboard_service import get_dashboard_stats, get_graph_data
from services.auth_service import get_current_user
from models.database import get_db

router = APIRouter(prefix="/v1")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# GET /v1/dashboard - récupère les stats du dashboard
@router.get("/dashboard", response_model=DashboardStats)
async def get_dashboard_endpoint(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    stats = get_dashboard_stats(db, user.id)
    return {
        "userName": user.name,
        **stats
    }

# GET /v1/graphs - récupère les données pour les graphiques
@router.get("/graphs", response_model=GraphData)
async def get_graphs_endpoint(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return get_graph_data(db, user.id)

