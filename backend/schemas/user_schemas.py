# schemas/user_schemas.py - Schémas pour profil utilisateur

from pydantic import BaseModel
from typing import Optional

# Schéma User - pour output (profil)
class User(BaseModel):
    id: int
    email: str
    name: str
    locale: Optional[str] = "FR"
    
    class Config:
        from_attributes = True

# Schéma UserUpdate - pour PUT /user/me (input)
class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None

