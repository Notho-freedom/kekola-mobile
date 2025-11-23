# services/dashboard_service.py - Logique pour dashboard

from sqlalchemy.orm import Session
from models.metric_model import DailyMetric
from datetime import datetime, timedelta, date
from typing import List, Tuple

# Get dashboard stats
def get_dashboard_stats(db: Session, user_id: int) -> dict:
    # Récupérer les 7 derniers jours (incluant aujourd'hui)
    today = datetime.now().date()
    start_date = today - timedelta(days=6)  # 7 jours au total (0 à 6 jours avant)
    
    start_date_str = start_date.strftime("%Y-%m-%d")
    today_str = today.strftime("%Y-%m-%d")
    
    # Récupérer toutes les métriques des 7 derniers jours
    metrics = db.query(DailyMetric).filter(
        DailyMetric.user_id == user_id,
        DailyMetric.date >= start_date_str,
        DailyMetric.date <= today_str
    ).order_by(DailyMetric.date.asc()).all()
    
    # Debug: afficher les métriques trouvées
    print(f"[DASHBOARD] User {user_id}: Found {len(metrics)} metrics between {start_date_str} and {today_str}")
    for m in metrics:
        print(f"  - Date: {m.date}, Sales: {m.sales}, Cash: {m.cash}")
    
    # Récupérer les données d'hier
    yesterday = (today - timedelta(days=1)).strftime("%Y-%m-%d")
    yesterday_metric = db.query(DailyMetric).filter(
        DailyMetric.user_id == user_id,
        DailyMetric.date == yesterday
    ).first()
    
    yesterday_sales = float(yesterday_metric.sales) if yesterday_metric else 0.0
    yesterday_cash = float(yesterday_metric.cash) if yesterday_metric else 0.0
    
    print(f"[DASHBOARD] Yesterday ({yesterday}): Sales={yesterday_sales}, Cash={yesterday_cash}")
    
    # Créer des listes pour les 7 derniers jours (remplir avec 0 si pas de données)
    sales_data = [0.0] * 7
    cash_data = [0.0] * 7
    
    # Organiser les données par jour (du plus ancien au plus récent)
    for i in range(7):
        target_date = (start_date + timedelta(days=i)).strftime("%Y-%m-%d")
        metric = next((m for m in metrics if m.date == target_date), None)
        if metric:
            sales_data[i] = float(metric.sales)
            cash_data[i] = float(metric.cash)
    
    print(f"[DASHBOARD] Sales data: {sales_data}")
    print(f"[DASHBOARD] Cash data: {cash_data}")
    
    return {
        "yesterdaySales": yesterday_sales,
        "yesterdayCash": yesterday_cash,
        "salesData": sales_data,
        "cashData": cash_data
    }

# Get graph data (3 dernières semaines)
def get_graph_data(db: Session, user_id: int) -> dict:
    today = datetime.now().date()
    
    # Calculer les 3 dernières semaines (semaine complète de lundi à dimanche)
    weekly_sales = []
    weekly_cash = []
    
    # Pour chaque semaine (de la plus ancienne à la plus récente)
    for week_offset in range(2, -1, -1):  # 2, 1, 0 (semaines précédentes)
        # Calculer le début et la fin de la semaine
        # Semaine actuelle commence il y a (week_offset * 7) jours
        week_end = today - timedelta(days=week_offset * 7)
        week_start = week_end - timedelta(days=6)  # 7 jours au total
        
        week_start_str = week_start.strftime("%Y-%m-%d")
        week_end_str = week_end.strftime("%Y-%m-%d")
        
        # Récupérer les métriques de cette semaine
        metrics = db.query(DailyMetric).filter(
            DailyMetric.user_id == user_id,
            DailyMetric.date >= week_start_str,
            DailyMetric.date <= week_end_str
        ).all()
        
        # Calculer les totaux de la semaine
        week_sales = sum(float(m.sales) for m in metrics)
        week_cash = sum(float(m.cash) for m in metrics)
        
        print(f"[GRAPHS] Week {week_offset} ({week_start_str} to {week_end_str}): {len(metrics)} metrics, Sales={week_sales}, Cash={week_cash}")
        
        weekly_sales.append(week_sales)
        weekly_cash.append(week_cash)
    
    total_sales = sum(weekly_sales)
    total_cash = sum(weekly_cash)
    
    print(f"[GRAPHS] Total: Sales={total_sales}, Cash={total_cash}")
    
    return {
        "weeklySales": weekly_sales,
        "weeklyCash": weekly_cash,
        "totalSales": total_sales,
        "totalCash": total_cash
    }

