# routes/notification_routes.py - Endpoints pour les notifications

from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from typing import List
from schemas.notification_schemas import NotificationResponse, NotificationUpdate
from services.notification_service import (
    get_notifications,
    mark_notification_as_read,
    mark_all_as_read,
    generate_dynamic_notifications
)
from services.auth_service import get_current_user
from models.database import get_db

router = APIRouter(prefix="/notifications", tags=["notifications"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# GET /notifications - récupère les notifications de l'utilisateur
@router.get("", response_model=List[NotificationResponse])
async def get_notifications_endpoint(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Générer des notifications dynamiques avant de récupérer
    generate_dynamic_notifications(db, user.id)
    
    notifications = get_notifications(db, user.id)
    return notifications

# PUT /notifications/{notification_id}/read - marque une notification comme lue
@router.put("/{notification_id}/read", response_model=NotificationResponse)
async def mark_notification_read_endpoint(
    notification_id: int,
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    success = mark_notification_as_read(db, notification_id, user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    # Récupérer la notification mise à jour
    from models.notification_model import Notification
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == user.id
    ).first()
    
    return notification

# PUT /notifications/read-all - marque toutes les notifications comme lues
@router.put("/read-all")
async def mark_all_notifications_read_endpoint(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    count = mark_all_as_read(db, user.id)
    return {"message": f"{count} notifications marquées comme lues"}

