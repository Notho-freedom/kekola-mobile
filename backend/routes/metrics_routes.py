# routes/metrics_routes.py - Endpoints pour metrics (section 10 specs).
# Pour un débutant : Gère création et lecture des metrics.

from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from schemas.metric_schemas import MetricCreate, Metric, MetricList, Insights
from services.metric_service import create_metric, get_metrics, get_insights
from services.auth_service import get_current_user
from models.database import get_db

# Crée router avec préfixe /v1.
router = APIRouter(prefix="/v1")

# Scheme OAuth2.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# POST /v1/metrics - crée une saisie.
@router.post("/metrics", response_model=Metric)
async def create_metric_endpoint(metric: MetricCreate, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    # Vérifie user via token.
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    # Crée metric en DB.
    db_metric = create_metric(db, metric, user.id)
    # Calcule deltas vs J-1.
    prev_metrics = get_metrics(db, user.id, 1)
    deltas = {"sales": 0.0, "cash": 0.0}
    if prev_metrics:
        prev = prev_metrics[0]
        deltas["sales"] = ((db_metric.sales - prev.sales) / prev.sales * 100) if prev.sales else 0.0
        deltas["cash"] = ((db_metric.cash - prev.cash) / prev.cash * 100) if prev.cash else 0.0
    # Convertit db_metric en Metric et ajoute deltas.
    metric_response = Metric(
        id=db_metric.id,
        date=db_metric.date,
        sales=db_metric.sales,
        cash=db_metric.cash,
        source=db_metric.source,
        deltas=deltas
    )
    return metric_response

# GET /v1/metrics - liste metrics pour range.
@router.get("/metrics", response_model=MetricList)
async def get_metrics_endpoint(range: str = "10d", db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    # Parse range (e.g., 10d -> 10).
    days = int(range[:-1]) if range.endswith('d') else 10
    # Get metrics.
    metrics = get_metrics(db, user.id, days)
    # Convert en schéma.
    return {"metrics": [Metric.from_orm(m) for m in metrics]}


# GET /v1/insights - calcule % pour date.
@router.get("/insights", response_model=Insights)
async def get_insights_endpoint(date: str, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    # Get insights.
    insights = get_insights(db, user.id, date)
    return insights