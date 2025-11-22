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
    # Crée objet DailyMetric depuis schéma.
    db_metric = DailyMetric(**metric.dict(), user_id=user_id)
    # Ajoute à DB.
    db.add(db_metric)
    db.commit()
    db.refresh(db_metric)
    return db_metric

# Get metrics - pour un user et range (e.g., 10d).
def get_metrics(db: Session, user_id: int, range_days: int):
    # Calcule date de début.
    start = datetime.now() - timedelta(days=range_days)
    # Query pour metrics dans range.
    return db.query(DailyMetric).filter(
        DailyMetric.user_id == user_id,
        DailyMetric.date >= start.strftime("%Y-%m-%d")
    ).all()


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