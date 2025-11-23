# Script pour activer l'environnement virtuel et lancer le serveur
Set-Location $PSScriptRoot

# Activer l'environnement virtuel
.\venv\Scripts\Activate.ps1

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SERVEUR BACKEND - ENVIRONNEMENT VIRTUEL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Environnement virtuel activé!" -ForegroundColor Green
Write-Host "Lancement du serveur sur http://0.0.0.0:8000" -ForegroundColor Yellow
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  - Swagger UI: http://localhost:8000/docs" -ForegroundColor White
Write-Host "  - ReDoc: http://localhost:8000/redoc" -ForegroundColor White
Write-Host ""
Write-Host "Appuyez sur CTRL+C pour arrêter le serveur" -ForegroundColor Yellow
Write-Host ""

# Lancer le serveur
uvicorn run:app --host 0.0.0.0 --port 8000 --reload

