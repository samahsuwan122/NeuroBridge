"""Tests for the health-check endpoints (Phase 2)."""

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)

EXPECTED_SERVICE = "NeuroBridge API"
EXPECTED_VERSION = "v1"


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200

    data = response.json()
    assert data["success"] is True
    assert data["service"] == EXPECTED_SERVICE
    assert data["status"] == "healthy"
    assert data["version"] == EXPECTED_VERSION
    assert "environment" in data


def test_api_v1_health_endpoint():
    response = client.get("/api/v1/health")
    assert response.status_code == 200

    data = response.json()
    assert data["success"] is True
    assert data["service"] == EXPECTED_SERVICE
    assert data["status"] == "healthy"
    assert data["version"] == EXPECTED_VERSION
    assert "environment" in data


def test_health_endpoints_match():
    assert client.get("/health").json() == client.get("/api/v1/health").json()
