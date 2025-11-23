# routes/user_routes.py - Endpoints pour gestion utilisateur

from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from schemas.user_schemas import User, UserUpdate
from services.user_service import get_user, update_user
from services.auth_service import get_current_user
from models.database import get_db

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# GET /user/me - récupère le profil utilisateur
@router.get("/user/me", response_model=User)
async def get_current_user_profile(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user

# PUT /user/me - met à jour le profil utilisateur
@router.put("/user/me", response_model=User)
async def update_current_user_profile(
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
):
    user = get_current_user(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    try:
        updated_user = update_user(db, user.id, user_update)
        if not updated_user:
            raise HTTPException(status_code=404, detail="User not found")
        return updated_user
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

