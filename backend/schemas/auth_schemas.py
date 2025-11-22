# schemas/auth_schemas.py - Schémas pour login et tokens.
# Pour un débutant : Valide les données pour login et réponses tokens.

# Importe BaseModel.
from pydantic import BaseModel

# Schéma Login - input pour /login.
class Login(BaseModel):
    # Email - requis.
    email: str
    # Password - requis.
    password: str

# Schéma Token - output pour login/refresh.
class Token(BaseModel):
    # Access token - JWT pour auth (24h).
    access_token: str
    # Refresh token - pour renouveler (30j).
    refresh_token: str
    # Type - toujours "bearer".
    token_type: str = "bearer"

# Schéma Register - input pour /register.
class Register(BaseModel):
    email: str
    password: str
    name: str

# Nouveau schéma pour set-fcm-token
class FCMToken(BaseModel):
    fcm_token: str