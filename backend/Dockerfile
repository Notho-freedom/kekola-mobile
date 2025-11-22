# Utilise une image officielle Python légère
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copier requirements.txt et installer les dépendances
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste du code source
COPY . .

# Expose le port FastAPI (8000 par défaut)
EXPOSE 8000

# Commande de lancement
CMD ["uvicorn", "run:app", "--host", "0.0.0.0", "--port", "8000"]
