@echo off
REM Script pour activer l'environnement virtuel et lancer le serveur
cd /d %~dp0
call venv\Scripts\activate.bat
echo.
echo ========================================
echo   SERVEUR BACKEND - ENVIRONNEMENT VIRTUEL
echo ========================================
echo.
echo Environnement virtuel active!
echo Lancement du serveur sur http://0.0.0.0:8000
echo.
echo Documentation:
echo   - Swagger UI: http://localhost:8000/docs
echo   - ReDoc: http://localhost:8000/redoc
echo.
echo Appuyez sur CTRL+C pour arreter le serveur
echo.
uvicorn run:app --host 0.0.0.0 --port 8000 --reload

