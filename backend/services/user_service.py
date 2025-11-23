# services/user_service.py - Logique pour gestion utilisateur

from sqlalchemy.orm import Session
from models.user_model import User
from schemas.user_schemas import UserUpdate
from services.auth_service import pwd_context

# Get user par ID
def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

# Update user
def update_user(db: Session, user_id: int, user_update: UserUpdate):
    user = get_user(db, user_id)
    if not user:
        return None
    
    if user_update.name is not None:
        user.name = user_update.name
    if user_update.email is not None:
        # Vérifier que l'email n'est pas déjà utilisé
        existing = db.query(User).filter(User.email == user_update.email, User.id != user_id).first()
        if existing:
            raise ValueError("Email already in use")
        user.email = user_update.email
    if user_update.password is not None:
        user.hashed_password = pwd_context.hash(user_update.password)
    
    db.commit()
    db.refresh(user)
    return user

