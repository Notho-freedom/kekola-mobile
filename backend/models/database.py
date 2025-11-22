# models/database.py - Configure la connexion DB avec SQLAlchemy.
# Pour un débutant : Crée le moteur et sessions pour interagir avec la base.
import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# URL de la DB codée en dur - utilise SQLite dans le dossier projet.
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:lagrange@localhost:5432/compta_db")
#DATABASE_URL="postgresql://compta_db_d76h_user:nrxOfBEBar74usWLnYivVxViTLUCz5u8@dpg-d3ba0mndiees73aheih0-a.oregon-postgres.render.com/compta_db_d76h"
# Crée moteur DB - connecte à la base.
engine = create_engine(DATABASE_URL)

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