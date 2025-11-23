# 🐍 Environnement Virtuel Python - Backend

## 📋 Création et Activation

### Windows (PowerShell)
```powershell
cd backend

# Créer l'environnement virtuel
python -m venv venv

# Activer l'environnement
.\venv\Scripts\Activate.ps1

# Si erreur d'exécution de script, exécuter d'abord :
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Windows (CMD)
```cmd
cd backend

# Créer l'environnement virtuel
python -m venv venv

# Activer l'environnement
venv\Scripts\activate.bat
```

### Linux/Mac
```bash
cd backend

# Créer l'environnement virtuel
python3 -m venv venv

# Activer l'environnement
source venv/bin/activate
```

## 📦 Installation des Dépendances

Une fois l'environnement virtuel activé :

```bash
# Mettre à jour pip
python -m pip install --upgrade pip

# Installer les dépendances
pip install -r requirements.txt
```

**Note** : `uvloop` ne s'installera pas sur Windows (normal, pas nécessaire).

## 🚀 Lancer le Serveur

Avec l'environnement virtuel activé :

```bash
uvicorn run:app --host 0.0.0.0 --port 8000 --reload
```

## ✅ Vérification

Vérifier que l'environnement virtuel est actif :
- Le prompt devrait afficher `(venv)` au début
- `which python` (Linux/Mac) ou `where python` (Windows) devrait pointer vers `venv`

## 🗑️ Désactiver l'Environnement

```bash
deactivate
```

## 📝 Structure

```
backend/
├── venv/              # Environnement virtuel (à ignorer dans git)
├── requirements.txt   # Dépendances du projet
├── run.py            # Point d'entrée
└── ...
```

## 🔒 Fichiers à Ignorer

L'environnement virtuel est déjà dans `.gitignore` :
```
venv/
*.pyc
__pycache__/
```

## ⚠️ Notes Importantes

1. **Toujours activer l'environnement virtuel** avant de travailler sur le projet
2. **Ne pas commiter** le dossier `venv/` dans git
3. **Mettre à jour requirements.txt** si vous installez de nouveaux packages :
   ```bash
   pip freeze > requirements.txt
   ```

## 🆘 Dépannage

### Erreur "Activate.ps1 cannot be loaded"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erreur "No module named 'venv'"
Installer Python avec les outils de développement ou utiliser `virtualenv` :
```bash
pip install virtualenv
virtualenv venv
```

