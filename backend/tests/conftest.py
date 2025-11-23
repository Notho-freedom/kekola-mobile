# conftest.py - Configuration des fixtures pour pytest
import pytest
import os
from fastapi.testclient import TestClient
from fastapi import FastAPI
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from models.database import Base, get_db
from routes.metrics_routes import router as metrics_router
from routes.auth import router as auth_router

# Base de données de test en mémoire SQLite
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db():
    """Crée une nouvelle base de données pour chaque test"""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def app(db):
    """Crée une instance FastAPI pour les tests"""
    test_app = FastAPI(title="Test API")
    test_app.include_router(metrics_router)
    test_app.include_router(auth_router)
    
    @test_app.get("/")
    def read_root():
        return {"message": "Test API is running"}
    
    return test_app


@pytest.fixture(scope="function")
def client(app, db):
    """Client de test FastAPI avec base de données de test"""
    def override_get_db():
        try:
            db_session = TestingSessionLocal()
            yield db_session
        finally:
            db_session.close()
    
    app.dependency_overrides[get_db] = override_get_db
    test_client = TestClient(app)
    yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def test_user_data():
    """Données de test pour un utilisateur"""
    return {
        "email": "test@example.com",
        "password": "testpassword123",
        "name": "Test User"
    }

