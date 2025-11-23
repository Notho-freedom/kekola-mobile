# middleware/exception_handler.py - Gestion globale des exceptions

from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from fastapi import HTTPException
import traceback

async def exception_handler(request: Request, exc: Exception):
    """Gestionnaire global des exceptions non gérées"""
    # Ne pas gérer les HTTPException ici, elles sont déjà gérées
    if isinstance(exc, HTTPException):
        raise exc
    
    print(f"Exception non gérée: {type(exc).__name__}: {str(exc)}")
    print(traceback.format_exc())
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "detail": f"Erreur serveur: {str(exc)}",
            "type": type(exc).__name__
        }
    )

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Gestionnaire pour les erreurs de validation"""
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": exc.errors(), "body": exc.body}
    )

async def integrity_error_handler(request: Request, exc: IntegrityError):
    """Gestionnaire pour les erreurs d'intégrité de la base de données"""
    error_msg = str(exc.orig) if hasattr(exc, 'orig') else str(exc)
    
    # Détecter si c'est une contrainte d'unicité
    if "UNIQUE constraint" in error_msg or "unique constraint" in error_msg.lower():
        return JSONResponse(
            status_code=status.HTTP_409_CONFLICT,
            content={"detail": "Une métrique existe déjà pour cette date"}
        )
    
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content={"detail": f"Erreur de contrainte: {error_msg}"}
    )

