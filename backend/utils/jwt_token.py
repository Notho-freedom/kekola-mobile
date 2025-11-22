# utils/jwt_token.py - Gère création/décodage JWT.
# Pour un débutant : Sépare la logique JWT pour réutilisation.

# Importe JWT.
import jwt
# Importe datetime.
from datetime import datetime, timedelta
# Importe os.
import os

# Clé secrète et algo.
SECRET_KEY = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"  # Identique à auth_service.py.
ALGORITHM = "HS256"

# Crée access token.
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(hours=24)  # Expire 24h.
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Crée refresh token.
def create_refresh_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=30)  # 30j.
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Décode token.
def decode_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload.get("sub")  # Retourne email.
    except:
        return None