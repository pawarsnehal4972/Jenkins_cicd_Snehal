# Flask Backend

Small Flask API (port 5000) deployed to EC2 with a Jenkins CI/CD pipeline.

| Endpoint | Description |
|----------|-------------|
| `/api/health` | health check |
| `/api/message` | sample message |
| `/api/info` | service info |
| `/api/config-status` | tells whether `API_KEY` (from Jenkins credentials) is set |

Run locally: `pip install -r requirements.txt && python app.py`
Tests: `pip install -r requirements-dev.txt && pytest`
Pipeline: see `Jenkinsfile` (Checkout > Install > Test > Deploy with pm2 > Health Check).
