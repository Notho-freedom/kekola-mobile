# services/auth_service.py - Logique pour authentification (login, tokens).

# Importe SQLAlchemy session.
from sqlalchemy.orm import Session
# Importe modèles et schémas.
from models.user_model import User
from schemas.auth_schemas import Login
# Importe passlib pour hasher passwords.
from passlib.context import CryptContext
# Importe JWT pour tokens.
import jwt
# Importe datetime pour gérer expiration.
from datetime import datetime, timedelta
# Importe os pour SECRET_KEY.
import os

# Contexte bcrypt - pour hasher mots de passe.
pwd_context = CryptContext(schemes=["argon2", "bcrypt"], deprecated="auto")
# Clé secrète pour JWT - depuis .env.
SECRET_KEY  = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
# Algorithme JWT - standard sécurisé.
ALGORITHM = "HS256"

# Crée user - pour inscription (pas dans specs, mais utile).
def create_user(db: Session, email: str, password: str, name: str):
    # Hash le mot de passe pour sécurité.
    hashed = pwd_context.hash(password)
    # Crée objet User.
    db_user = User(email=email, hashed_password=hashed, name=name)
    # Ajoute à la session.
    db.add(db_user)
    # Commit pour sauvegarder.
    db.commit()
    # Refresh pour get ID généré.
    db.refresh(db_user)
    return db_user

# Get user par email - pour login.
def get_user_by_email(db: Session, email: str):
    # Query DB pour trouver user par email.
    return db.query(User).filter(User.email == email).first()

# Authentifie user - vérifie email/password.
def authenticate_user(db: Session, email: str, password: str):
    # Get user.
    user = get_user_by_email(db, email)
    # Vérifie si existe et password correct.
    if not user or not pwd_context.verify(password, user.hashed_password):
        return None
    return user

# Crée access token - JWT 24h (section 8).
def create_access_token(data: dict):
    # Copie data pour éviter mutation.
    to_encode = data.copy()
    # Set expiration à 24h.
    expire = datetime.utcnow() + timedelta(hours=24)
    # Ajoute exp dans payload.
    to_encode.update({"exp": expire})
    # Encode en JWT.
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Crée refresh token - 30j.
def create_refresh_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=30)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Get current user - décode JWT.
def get_current_user(db: Session, token: str):
    try:
        # Décode token avec SECRET_KEY.
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        # Extrait email depuis sub.
        email: str = payload.get("sub")
        if email is None:
            return None
        # Get user depuis DB.
        return get_user_by_email(db, email)
    except:
        return None