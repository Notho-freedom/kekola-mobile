# Guide des Tests Backend

## Installation des dépendances de test

```bash
cd backend
pip install -r test_requirements.txt
```

## Exécution des tests

### Tous les tests
```bash
pytest
```

### Tests avec couverture
```bash
pytest --cov=. --cov-report=html
```

### Tests spécifiques
```bash
# Tests d'authentification uniquement
pytest tests/test_auth.py

# Tests de métriques uniquement
pytest tests/test_metrics.py

# Un test spécifique
pytest tests/test_auth.py::test_login_success
```

### Mode verbeux
```bash
pytest -v
```

## Structure des tests

- `tests/conftest.py` - Configuration et fixtures partagées
- `tests/test_auth.py` - Tests d'authentification (login, register, refresh)
- `tests/test_metrics.py` - Tests de métriques (création, récupération, insights)
- `tests/test_root.py` - Tests de la route racine

## Fixtures disponibles

- `client` - Client de test FastAPI avec base de données de test
- `db` - Base de données SQLite en mémoire (créée/nettoyée pour chaque test)
- `test_user_data` - Données de test pour un utilisateur
- `auth_token` - Token d'authentification valide (dans test_metrics.py)

## Notes

- Les tests utilisent une base de données SQLite en mémoire pour l'isolation
- Chaque test a sa propre base de données propre
- Les tokens JWT sont générés avec les mêmes secrets que l'application

