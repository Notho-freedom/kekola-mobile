# Migration vers SQLite Locale

## ✅ Migration Effectuée

Le projet utilise maintenant **SQLite3 locale** au lieu de PostgreSQL distant.

## 📝 Changements Effectués

### 1. Configuration de la Base de Données
- **Fichier** : `backend/models/database.py`
- **Changement** : URL de connexion modifiée pour utiliser SQLite
- **Fichier de base** : `backend/compta.db` (créé automatiquement)

### 2. Dépendances
- **Retiré** : `psycopg2-binary` (driver PostgreSQL)
- **Utilisé** : SQLite3 (inclus dans Python, pas de dépendance supplémentaire)

### 3. Fichiers Ignorés
- Ajout de `*.db`, `*.sqlite`, `*.sqlite3` au `.gitignore`
- Les fichiers de base de données ne seront pas versionnés

## 🗄️ Structure de la Base de Données

La base SQLite locale contient les mêmes tables que PostgreSQL :
- `users` - Utilisateurs
- `daily_metrics` - Métriques journalières

## 🚀 Utilisation

### Créer la Base de Données
La base est créée automatiquement au premier démarrage de l'API :
```bash
cd backend
python run.py
# ou
uvicorn run:app --reload
```

Le fichier `compta.db` sera créé dans le dossier `backend/`.

### Localisation du Fichier
- **Par défaut** : `backend/compta.db`
- **Personnalisable** : Variable d'environnement `DB_FILE`
  ```bash
  export DB_FILE=ma_base.db
  ```

### Sauvegarde
Pour sauvegarder la base de données, copiez simplement le fichier `.db` :
```bash
cp backend/compta.db backup/compta_backup_$(date +%Y%m%d).db
```

## 🔄 Synchronisation Future

Un module de synchronisation en ligne sera développé plus tard pour :
- Synchroniser les données locales avec un serveur distant
- Gérer les conflits de données
- Permettre le travail hors ligne

## ⚠️ Notes Importantes

1. **Performance** : SQLite est parfait pour un usage local et développement
2. **Concurrence** : SQLite gère bien la concurrence en lecture, limitée en écriture simultanée
3. **Taille** : Recommandé pour des bases < 100 Go
4. **Portabilité** : Le fichier `.db` peut être copié/mové facilement

## 🧪 Tests

Les tests utilisent déjà SQLite en mémoire (`sqlite:///:memory:`) et fonctionnent parfaitement :
```bash
pytest tests/ -v
```

## 📊 Migration des Données (si nécessaire)

Si vous aviez des données dans PostgreSQL, vous pouvez les exporter et les importer :
1. Exporter depuis PostgreSQL : `pg_dump`
2. Convertir au format SQLite (outils disponibles)
3. Importer dans SQLite

Pour l'instant, la base est vide et prête à être utilisée.

