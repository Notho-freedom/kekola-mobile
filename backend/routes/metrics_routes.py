# routes/metrics_routes.py - Endpoints pour metrics (section 10 specs).
# Pour un débutant : Gère création et lecture des metrics.

from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from schemas.metric_schemas import MetricCreate, Metric, MetricList, Insights
from services.metric_service import create_metric, get_metrics, get_insights
from services.auth_service import get_current_user
from models.database import get_db
from models.metric_model import DailyMetric

# Crée router avec préfixe /v1.
router = APIRouter(prefix="/v1")

# Scheme OAuth2.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# POST /v1/metrics - crée une saisie.
@router.post("/metrics", response_model=Metric)
async def create_metric_endpoint(metric: MetricCreate, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    try:
        # Vérifie user via token.
        user = get_current_user(db, token)
        if not user:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Vérifier si une métrique existe déjà pour cette date et cet utilisateur
        existing_metric = db.query(DailyMetric).filter(
            DailyMetric.user_id == user.id,
            DailyMetric.date == metric.date
        ).first()
        
        if existing_metric:
            # Mettre à jour la métrique existante au lieu de créer une nouvelle
            existing_metric.sales = metric.sales
            existing_metric.cash = metric.cash
            existing_metric.source = metric.source
            db.commit()
            db.refresh(existing_metric)
            db_metric = existing_metric
        else:
            # Crée metric en DB.
            db_metric = create_metric(db, metric, user.id)
        
        # Calcule deltas vs J-1.
        from datetime import datetime, timedelta
        try:
            prev_date = (datetime.strptime(metric.date, "%Y-%m-%d") - timedelta(days=1)).strftime("%Y-%m-%d")
            prev_metric = db.query(DailyMetric).filter(
                DailyMetric.user_id == user.id,
                DailyMetric.date == prev_date
            ).first()
        except ValueError:
            # Si la date est invalide, pas de métrique précédente
            prev_metric = None
        
        deltas = {"sales": 0.0, "cash": 0.0}
        if prev_metric:
            deltas["sales"] = ((db_metric.sales - prev_metric.sales) / prev_metric.sales * 100) if prev_metric.sales else 0.0
            deltas["cash"] = ((db_metric.cash - prev_metric.cash) / prev_metric.cash * 100) if prev_metric.cash else 0.0
        
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
    except HTTPException:
        raise
    except Exception as e:
        # Log l'erreur pour le débogage
        import traceback
        print(f"Erreur lors de la création de métrique: {e}")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Erreur serveur: {str(e)}")

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
    return {"metrics": [Metric(
        id=m.id,
        date=m.date,
        sales=m.sales,
        cash=m.cash,
        source=m.source,
        deltas=None  # Les deltas ne sont pas calculés dans la liste
    ) for m in metrics]}


# GET /v1/insights - calcule % pour date.
@router.get("/insights", response_model=Insights)
async def get_insights_endpoint(date: str, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    # Get insights.
    insights = get_insights(db, user.id, date)
    return insights