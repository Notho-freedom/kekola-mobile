# schemas/dashboard_schemas.py - Schémas pour dashboard

from pydantic import BaseModel
from typing import Optional, List

# Schéma DashboardStats - pour GET /v1/dashboard
class DashboardStats(BaseModel):
    userName: str
    yesterdaySales: float
    yesterdayCash: float
    salesData: List[float]  # 7 derniers jours
    cashData: List[float]  # 7 derniers jours

# Schéma GraphData - pour GET /v1/graphs
class GraphData(BaseModel):
    weeklySales: List[float]  # 3 dernières semaines
    weeklyCash: List[float]  # 3 dernières semaines
    totalSales: float
    totalCash: float

