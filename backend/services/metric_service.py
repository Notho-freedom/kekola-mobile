# services/metric_service.py - Logique pour créer/lire metrics.

# Importe session.
from sqlalchemy.orm import Session
# Importe modèles et schémas.
from models.metric_model import DailyMetric
from schemas.metric_schemas import MetricCreate
# Importe datetime pour calculs de dates.
from datetime import datetime, timedelta

# Crée metric - stocke en DB.
def create_metric(db: Session, metric: MetricCreate, user_id: int):
    try:
        # Crée objet DailyMetric depuis schéma.
        db_metric = DailyMetric(**metric.dict(), user_id=user_id)
        # Ajoute à DB.
        db.add(db_metric)
        db.commit()
        db.refresh(db_metric)
        return db_metric
    except Exception as e:
        # En cas d'erreur (ex: contrainte d'unicité), rollback
        db.rollback()
        raise e

# Get metrics - pour un user et range (e.g., 10d).
def get_metrics(db: Session, user_id: int, range_days: int = None, start_date: str = None, end_date: str = None):
    query = db.query(DailyMetric).filter(DailyMetric.user_id == user_id)
    
    # Si range_days est fourni, utiliser cette logique
    if range_days is not None:
        start = datetime.now() - timedelta(days=range_days)
        query = query.filter(DailyMetric.date >= start.strftime("%Y-%m-%d"))
    
    # Si start_date est fourni
    if start_date:
        query = query.filter(DailyMetric.date >= start_date)
    
    # Si end_date est fourni
    if end_date:
        query = query.filter(DailyMetric.date <= end_date)
    
    # Trier par date décroissante
    return query.order_by(DailyMetric.date.desc()).all()


# Get insights - calcule % vs J-1.
def get_insights(db: Session, user_id: int, date: str):
    # Get metric pour date donnée.
    metric = db.query(DailyMetric).filter(
        DailyMetric.user_id == user_id,
        DailyMetric.date == date
    ).first()

    print("metric : ", metric)
    # Get metric J-1.
    prev_date = (datetime.strptime(date, "%Y-%m-%d") - timedelta(days=1)).strftime("%Y-%m-%d")
    print("date précédente : ", prev_date)
    print("date d'aujourd'hui : ", date)

    prev = db.query(DailyMetric).filter(
        DailyMetric.user_id == user_id,
        DailyMetric.date == prev_date
    ).first()

    print("metric d'hier : ", prev)
    # Retourne 0 si pas de prev.
    if not metric or not prev:
        return {"pctSales": 0.0, "pctCash": 0.0}
    # Calcule % variations.
    pct_sales = ((metric.sales - prev.sales) / prev.sales * 100) if prev.sales else 0.0
    pct_cash = ((metric.cash - prev.cash) / prev.cash * 100) if prev.cash else 0.0
    return {"pctSales": pct_sales, "pctCash": pct_cash}