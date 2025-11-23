# tests/test_metrics.py - Tests pour les endpoints de métriques
import pytest
from datetime import datetime, timedelta
from fastapi import status


@pytest.fixture
def auth_token(client, test_user_data):
    """Fixture pour obtenir un token d'authentification"""
    client.post("/register", json=test_user_data)
    response = client.post("/login", json={
        "email": test_user_data["email"],
        "password": test_user_data["password"]
    })
    return response.json()["access_token"]


def test_create_metric_success(client, auth_token):
    """Test de création d'une métrique réussie"""
    today = datetime.now().strftime("%Y-%m-%d")
    
    response = client.post(
        "/v1/metrics",
        json={
            "date": today,
            "sales": 1500.50,
            "cash": 1200.75,
            "source": "APP"
        },
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "id" in data
    assert data["sales"] == 1500.50
    assert data["cash"] == 1200.75
    assert data["date"] == today
    assert "deltas" in data


def test_create_metric_unauthorized(client):
    """Test de création de métrique sans authentification"""
    today = datetime.now().strftime("%Y-%m-%d")
    
    response = client.post(
        "/v1/metrics",
        json={
            "date": today,
            "sales": 1500.50,
            "cash": 1200.75
        }
    )
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


def test_create_metric_invalid_token(client):
    """Test de création de métrique avec un token invalide"""
    today = datetime.now().strftime("%Y-%m-%d")
    
    response = client.post(
        "/v1/metrics",
        json={
            "date": today,
            "sales": 1500.50,
            "cash": 1200.75
        },
        headers={"Authorization": "Bearer invalid_token"}
    )
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


def test_get_metrics_success(client, auth_token):
    """Test de récupération des métriques"""
    # Créer quelques métriques
    today = datetime.now()
    for i in range(3):
        date = (today - timedelta(days=i)).strftime("%Y-%m-%d")
        client.post(
            "/v1/metrics",
            json={
                "date": date,
                "sales": 1000.0 + (i * 100),
                "cash": 800.0 + (i * 50)
            },
            headers={"Authorization": f"Bearer {auth_token}"}
        )
    
    # Récupérer les métriques
    response = client.get(
        "/v1/metrics?range=10d",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "metrics" in data
    assert len(data["metrics"]) == 3


def test_get_metrics_with_deltas(client, auth_token):
    """Test que les deltas sont calculés correctement"""
    today = datetime.now()
    yesterday = (today - timedelta(days=1)).strftime("%Y-%m-%d")
    today_str = today.strftime("%Y-%m-%d")
    
    # Créer une métrique pour hier
    client.post(
        "/v1/metrics",
        json={
            "date": yesterday,
            "sales": 1000.0,
            "cash": 800.0
        },
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    # Créer une métrique pour aujourd'hui (augmentation de 20%)
    response = client.post(
        "/v1/metrics",
        json={
            "date": today_str,
            "sales": 1200.0,
            "cash": 960.0
        },
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "deltas" in data
    # Vérifier que les deltas sont calculés (environ 20% d'augmentation)
    assert abs(data["deltas"]["sales"] - 20.0) < 1.0  # Tolérance de 1%


def test_get_insights(client, auth_token):
    """Test de récupération des insights"""
    today = datetime.now().strftime("%Y-%m-%d")
    
    # Créer quelques métriques pour avoir des données
    for i in range(7):
        date = (datetime.now() - timedelta(days=i)).strftime("%Y-%m-%d")
        client.post(
            "/v1/metrics",
            json={
                "date": date,
                "sales": 1000.0,
                "cash": 800.0
            },
            headers={"Authorization": f"Bearer {auth_token}"}
        )
    
    # Récupérer les insights
    response = client.get(
        f"/v1/insights?date={today}",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "pctSales" in data
    assert "pctCash" in data

