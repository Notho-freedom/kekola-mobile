@echo off
REM Script pour activer l'environnement virtuel sur Windows (CMD)
cd /d %~dp0
call venv\Scripts\activate.bat
echo Environnement virtuel active!
echo.
echo Pour lancer le serveur:
echo   uvicorn run:app --host 0.0.0.0 --port 8000 --reload
echo.
cmd /k

