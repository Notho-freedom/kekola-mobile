# services/notification_service.py - Gère les notifications dynamiques

from sqlalchemy.orm import Session
from models.user_model import User
from models.metric_model import DailyMetric
from models.notification_model import Notification
from datetime import datetime, timedelta
from typing import List

def create_notification(db: Session, user_id: int, title: str, message: str, type: str = "info"):
    """Crée une nouvelle notification"""
    notification = Notification(
        user_id=user_id,
        title=title,
        message=message,
        type=type,
        is_read=False
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification

def get_notifications(db: Session, user_id: int, limit: int = 50) -> List[Notification]:
    """Récupère les notifications d'un utilisateur"""
    return db.query(Notification).filter(
        Notification.user_id == user_id
    ).order_by(Notification.created_at.desc()).limit(limit).all()

def mark_notification_as_read(db: Session, notification_id: int, user_id: int) -> bool:
    """Marque une notification comme lue"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == user_id
    ).first()
    if notification:
        notification.is_read = True
        db.commit()
        return True
    return False

def mark_all_as_read(db: Session, user_id: int) -> int:
    """Marque toutes les notifications d'un utilisateur comme lues"""
    count = db.query(Notification).filter(
        Notification.user_id == user_id,
        Notification.is_read == False
    ).update({"is_read": True})
    db.commit()
    return count

def generate_dynamic_notifications(db: Session, user_id: int):
    """Génère des notifications dynamiques basées sur les métriques"""
    today = datetime.now().date()
    yesterday = (today - timedelta(days=1)).strftime("%Y-%m-%d")
    week_ago = (today - timedelta(days=7)).strftime("%Y-%m-%d")
    
    # Récupérer les métriques récentes
    recent_metrics = db.query(DailyMetric).filter(
        DailyMetric.user_id == user_id,
        DailyMetric.date >= week_ago
    ).order_by(DailyMetric.date.desc()).all()
    
    if not recent_metrics:
        return
    
    # Vérifier si une notification existe déjà pour aujourd'hui
    today_str = today.strftime("%Y-%m-%d")
    existing_notification = db.query(Notification).filter(
        Notification.user_id == user_id,
        Notification.message.like(f"%{today_str}%")
    ).first()
    
    if existing_notification:
        return
    
    # Calculer les moyennes
    if len(recent_metrics) > 1:
        avg_sales = sum(m.sales for m in recent_metrics) / len(recent_metrics)
        avg_cash = sum(m.cash for m in recent_metrics) / len(recent_metrics)
        
        # Vérifier la métrique d'hier
        yesterday_metric = next((m for m in recent_metrics if m.date == yesterday), None)
        
        if yesterday_metric:
            # Notification pour ventes élevées
            if yesterday_metric.sales > avg_sales * 1.2:
                create_notification(
                    db, user_id,
                    "Ventes élevées",
                    f"Vos ventes du {yesterday} ont atteint €{yesterday_metric.sales:.2f}, un record !",
                    "success"
                )
            
            # Notification pour cash bas
            if yesterday_metric.cash < avg_cash * 0.8:
                create_notification(
                    db, user_id,
                    "Cash bas",
                    f"Le cash du {yesterday} est inférieur à la moyenne.",
                    "warning"
                )
    
    # Notification pour nouvelle saisie (si métrique d'aujourd'hui existe)
    today_metric = next((m for m in recent_metrics if m.date == today_str), None)
    if today_metric:
        # Vérifier si une notification de saisie existe déjà
        existing_saisie = db.query(Notification).filter(
            Notification.user_id == user_id,
            Notification.title == "Saisie enregistrée",
            Notification.message.like(f"%{today_str}%")
        ).first()
        
        if not existing_saisie:
            create_notification(
                db, user_id,
                "Saisie enregistrée",
                f"Nouvelle saisie confirmée pour le {today_str}.",
                "info"
            )

def send_daily_reminder():
    """Envoie un rappel quotidien (pour Firebase push - à implémenter plus tard)"""
    # Cette fonction reste pour la compatibilité avec l'ancien code
    pass