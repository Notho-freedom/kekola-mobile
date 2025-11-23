# schemas/notification_schemas.py - Schémas pour les notifications

from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class NotificationResponse(BaseModel):
    id: int
    title: str
    message: str
    type: str
    is_read: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class NotificationUpdate(BaseModel):
    is_read: bool

