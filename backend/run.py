# run.py - Fichier principal pour lancer l'API FastAPI.
# Pour un débutant : Ce fichier est exécuté avec `uvicorn run:app --reload`.

# Importe FastAPI pour créer l'API.
from fastapi import FastAPI
# Importe CORS middleware pour permettre les requêtes depuis le frontend.
from fastapi.middleware.cors import CORSMiddleware
# Importe load_dotenv pour lire le fichier .env.
from dotenv import load_dotenv
# Importe os pour accéder aux variables d'environnement.
import os
# Importe les routers (routes) pour metrics et auth.
from routes.metrics_routes import router as metrics_router
from routes.auth import router as auth_router
from routes.user_routes import router as user_router
from routes.dashboard_routes import router as dashboard_router
from routes.notification_routes import router as notification_router
# Importe la DB engine et Base pour créer les tables.
from models.database import engine, Base
# Importe tous les modèles pour que SQLAlchemy les détecte et crée les tables
from models.user_model import User
from models.metric_model import DailyMetric
from models.notification_model import Notification
# Importe le scheduler pour tâches planifiées (rappels push).
from apscheduler.schedulers.background import BackgroundScheduler
# Importe la fonction pour envoyer rappels push.
from services.notification_service import send_daily_reminder
# Importe les gestionnaires d'exceptions
from fastapi.exceptions import RequestValidationError
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from middleware.exception_handler import exception_handler, validation_exception_handler, integrity_error_handler

# Charge les variables d'environnement (e.g., DATABASE_URL, SECRET_KEY).
load_dotenv()

# Crée l'instance FastAPI avec un titre et une version (visible dans /docs).
app = FastAPI(title="Compta Backend", version="1.0")

# Configure CORS pour permettre les requêtes depuis le frontend Flutter.
# IMPORTANT: Le middleware CORS doit être ajouté AVANT les routers
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En développement, autorise toutes les origines. En production, spécifier les domaines autorisés.
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH", "HEAD"],  # Méthodes HTTP explicites incluant OPTIONS
    allow_headers=["*"],  # Autorise tous les headers (Content-Type, Authorization, etc.)
    expose_headers=["*"],  # Expose tous les headers dans la réponse
    max_age=3600,  # Cache les résultats preflight pendant 1 heure
)

# Ajoute les gestionnaires d'exceptions globaux
app.add_exception_handler(Exception, exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(IntegrityError, integrity_error_handler)

# Crée les tables dans la DB au démarrage (SQLAlchemy génère les CREATE TABLE).
Base.metadata.create_all(bind=engine)

# Ajoute les routers à l'app avec préfixe /v1 pour metrics (versioning API).
app.include_router(metrics_router)
# Ajoute le router auth sans préfixe (e.g., /login).
app.include_router(auth_router)
# Ajoute le router user pour profil.
app.include_router(user_router)
# Ajoute le router dashboard pour stats et graphiques.
app.include_router(dashboard_router)
# Ajoute le router notifications pour les notifications dynamiques.
app.include_router(notification_router)

# Configure le scheduler pour envoyer rappels push à 20h (section 11 specs).
scheduler = BackgroundScheduler()
# Ajoute job pour appeler send_daily_reminder tous les jours à 20:00.
scheduler.add_job(send_daily_reminder, 'cron', hour=20, minute=0)
# Démarre le scheduler en background (non bloquant).
scheduler.start()

# Route racine pour tester si l'API fonctionne (GET /).
@app.get("/")
def read_root():
    # Retourne un JSON simple pour confirmer que l'API est up.
    return {"message": "Compta Backend API is running"}