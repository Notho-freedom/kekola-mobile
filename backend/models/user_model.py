# models/user_model.py - Définit la table users pour SQLAlchemy.
# Pour un débutant : Ce fichier décrit la structure de la table users (colonnes, types).

# Importe les types de colonnes SQLAlchemy.
from sqlalchemy import Column, Integer, String
# Importe relationship pour lier tables.
from sqlalchemy.orm import relationship
# Importe Base depuis database.py.
from .database import Base

# Classe User - représente la table users.
class User(Base):
    # Nom de la table dans la DB.
    __tablename__ = "users"
    
    # Colonne id - clé primaire, auto-incrémentée.
    id = Column(Integer, primary_key=True, index=True)
    # Colonne email - unique pour identifier l'utilisateur.
    email = Column(String, unique=True, index=True)
    # Colonne name - nom affiché (e.g., "Ana").
    name = Column(String)
    # Colonne hashed_password - mot de passe sécurisé (hashé avec bcrypt).
    hashed_password = Column(String)
    # Colonne locale - langue par défaut FR (section 3 specs).
    locale = Column(String, default="FR")
    # Colonne fcm_token - pour notifications push Firebase .
    fcm_token = Column(String)
    
    # Relation avec DailyMetric - un user a plusieurs metrics.
    metrics = relationship("DailyMetric", back_populates="user")