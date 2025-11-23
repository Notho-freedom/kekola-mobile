# tests/test_root.py - Tests pour la route racine
from fastapi import status


def test_root_endpoint(client):
    """Test de la route racine"""
    response = client.get("/")
    assert response.status_code == status.HTTP_200_OK
    assert "message" in response.json()
    assert "running" in response.json()["message"].lower()

