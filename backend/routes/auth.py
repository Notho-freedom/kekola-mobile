# routes/auth.py - Définit les endpoints pour login/refresh.

# Importe FastAPI router et depends.
from fastapi import APIRouter, Depends, HTTPException
# Importe OAuth2 pour Bearer token.
from fastapi.security import OAuth2PasswordBearer
# Importe session.
from sqlalchemy.orm import Session
# Importe schémas et services.
from schemas.auth_schemas import Login, Token, Register, FCMToken
from services.auth_service import authenticate_user, create_access_token, create_refresh_token, create_user, get_current_user, get_user_by_email
# Importe get_db.
from models.database import get_db

# Crée router pour auth endpoints.
router = APIRouter()

# Scheme OAuth2 - pointe vers /login pour token.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# POST /login - authentifie et retourne tokens.
@router.post("/login", response_model=Token)
def login(login: Login, db: Session = Depends(get_db)):
    # Authentifie user avec email/password.
    user = authenticate_user(db, login.email, login.password)
    # Si échec, lève erreur 401.
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    # Crée access et refresh tokens.
    access_token = create_access_token({"sub": user.email})
    refresh_token = create_refresh_token({"sub": user.email})
    # Met à jour fcm_token si fourni (pour push).
    # Note : Ajoute fcm_token dans Login schema si besoin.
    return {"access_token": access_token, "refresh_token": refresh_token}

# POST /refresh - renouvelle access token.
@router.post("/refresh", response_model=Token)
def refresh(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    # Décode refresh token.
    from services.auth_service import get_current_user
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    # Crée nouveaux tokens.
    access_token = create_access_token({"sub": user.email})
    refresh_token = create_refresh_token({"sub": user.email})
    return {"access_token": access_token, "refresh_token": refresh_token}

@router.post("/register", response_model=Token)
def register(register: Register, db: Session = Depends(get_db)):
    # Vérifier si l'utilisateur existe déjà
    existing_user = get_user_by_email(db, register.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    user = create_user(db, register.email, register.password, register.name)
    # Créer et retourner les tokens pour connecter automatiquement
    access_token = create_access_token({"sub": user.email})
    refresh_token = create_refresh_token({"sub": user.email})
    return {"access_token": access_token, "refresh_token": refresh_token}

@router.post("/set-fcm-token")
async def set_fcm_token(fcm: FCMToken, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    user.fcm_token = fcm.fcm_token
    db.commit()
    return {"message": "FCM token updated"}