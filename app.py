"""Flask backend for the Jenkins CI/CD assignment."""
import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")


def _now():
    return datetime.now(timezone.utc).isoformat()


@app.get("/")
def index():
    return jsonify(
        service="flask-backend",
        status="ok",
        message="Flask backend is running",
        endpoints=["/api/health", "/api/message", "/api/info", "/api/config-status"],
    )


@app.get("/api/health")
def health():
    return jsonify(status="healthy", service="flask-backend", time=_now())


@app.get("/api/message")
def message():
    return jsonify(
        message="Hello from the Flask backend, deployed by Jenkins!",
        version=APP_VERSION,
        host=socket.gethostname(),
        time=_now(),
    )


@app.get("/api/info")
def info():
    return jsonify(
        service="flask-backend",
        version=APP_VERSION,
        host=socket.gethostname(),
        port=int(os.getenv("PORT", "5000")),
        time=_now(),
    )


@app.get("/api/config-status")
def config_status():
    """Shows whether the secret injected by Jenkins is present (never returns the value)."""
    return jsonify(api_key_configured=bool(os.getenv("API_KEY")))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")))
