# Script pour activer l'environnement virtuel sur Windows (PowerShell)
Set-Location $PSScriptRoot
.\venv\Scripts\Activate.ps1
Write-Host "Environnement virtuel activé!" -ForegroundColor Green
Write-Host ""
Write-Host "Pour lancer le serveur:" -ForegroundColor Yellow
Write-Host "  uvicorn run:app --host 0.0.0.0 --port 8000 --reload" -ForegroundColor Cyan
Write-Host ""

