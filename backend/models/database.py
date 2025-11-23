# models/database.py - Configure la connexion DB avec SQLAlchemy.
# Pour un débutant : Crée le moteur et sessions pour interagir avec la base.
import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# URL de la DB - utilise SQLite locale dans le dossier backend.
# Le fichier sera créé automatiquement s'il n'existe pas.
DB_FILE = os.getenv("DB_FILE", "compta.db")
DATABASE_URL = f"sqlite:///./{DB_FILE}"

# Crée moteur DB - connecte à la base SQLite.
# check_same_thread=False permet à SQLite de fonctionner avec FastAPI (multi-thread).
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},
    echo=False  # Mettre à True pour voir les requêtes SQL dans les logs
)

# Crée factory pour sessions.
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base pour modèles (tables).
Base = declarative_base()

# Dependency pour sessions DB.
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()