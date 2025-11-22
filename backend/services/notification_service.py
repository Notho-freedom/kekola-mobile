# services/notification_service.py - Gère envoi push via Firebase.
# Pour un débutant : Envoie rappels à 20h si pas de saisie.

import firebase_admin
from firebase_admin import credentials, messaging
# import os  # Commenté car Firebase désactivé pour test.
from sqlalchemy.orm import Session
from models.user_model import User
from models.metric_model import DailyMetric
from datetime import datetime
from models.database import SessionLocal

# Firebase désactivé pour test - décommente en prod avec fichier JSON.
# cred = credentials.Certificate("/home/lagrange/Bureau/formationFastApi/compta-backend/firebase/firebase-adminsdk.json")
# firebase_admin.initialize_app(cred)

def send_daily_reminder():
    db = SessionLocal()
    try:
        today = datetime.now().strftime("%Y-%m-%d")
        users = db.query(User).all()
        for user in users:
            has_metric = db.query(DailyMetric).filter(
                DailyMetric.user_id == user.id,
                DailyMetric.date == today
            ).first()
            if not has_metric and user.fcm_token:
                # Mock push pour test sans Firebase.
                print(f"Mock push to {user.email}: Pense à saisir tes chiffres du jour 👍")
                # Décommente en prod :
                # message = messaging.Message(
                #     notification=messaging.Notification(
                #         title="Rappel",
                #         body="Pense à saisir tes chiffres du jour 👍"
                #     ),
                #     token=user.fcm_token
                # )
                # messaging.send(message)
    finally:
        db.close()