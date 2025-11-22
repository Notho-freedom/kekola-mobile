# schemas/metric_schemas.py - Définit les schémas pour input/output metrics.
# Pour un débutant : Les schémas valident automatiquement les données (types, formats).

# Importe BaseModel pour créer schémas.
from pydantic import BaseModel
# Importe Optional et List pour types flexibles.
from typing import Optional, List

# Schéma MetricCreate - pour POST /metrics (input).
class MetricCreate(BaseModel):
    # Date - string ISO (requis).
    date: str
    # Sales - float pour ventes (XOF).
    sales: float
    # Cash - float pour cash.
    cash: float
    # Source - optionnel, default "APP" (section 10 specs).
    source: Optional[str] = "APP"

# Schéma Metric - pour output (avec ID et deltas).
class Metric(BaseModel):
    id: int
    date: str
    sales: float
    cash: float
    # Deltas - variations % vs J-1 (optionnel si pas calculé).
    deltas: Optional[dict] = None
    
    # Config - permet conversion depuis modèles SQLAlchemy.
    class Config:
        from_attributes = True

# Schéma MetricList - pour GET /metrics (liste).
class MetricList(BaseModel):
    metrics: List[Metric]

# Schéma Insights - pour GET /insights.
class Insights(BaseModel):
    pctSales: float
    pctCash: float