# run.py - Fichier principal pour lancer l'API FastAPI.
# Pour un débutant : Ce fichier est exécuté avec `uvicorn run:app --reload`.

# Importe FastAPI pour créer l'API.
from fastapi import FastAPI
# Importe load_dotenv pour lire le fichier .env.
from dotenv import load_dotenv
# Importe os pour accéder aux variables d'environnement.
import os
# Importe les routers (routes) pour metrics et auth.
from routes.metrics_routes import router as metrics_router
from routes.auth import router as auth_router
# Importe la DB engine et Base pour créer les tables.
from models.database import engine, Base
# Importe le scheduler pour tâches planifiées (rappels push).
from apscheduler.schedulers.background import BackgroundScheduler
# Importe la fonction pour envoyer rappels push.
from services.notification_service import send_daily_reminder

# Charge les variables d'environnement (e.g., DATABASE_URL, SECRET_KEY).
load_dotenv()

# Crée l'instance FastAPI avec un titre et une version (visible dans /docs).
app = FastAPI(title="Compta Backend", version="1.0")

# Crée les tables dans la DB au démarrage (SQLAlchemy génère les CREATE TABLE).
Base.metadata.create_all(bind=engine)

# Ajoute les routers à l'app avec préfixe /v1 pour metrics (versioning API).
app.include_router(metrics_router)
# Ajoute le router auth sans préfixe (e.g., /login).
app.include_router(auth_router)

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