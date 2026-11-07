// pm2 process definition for the Flask backend (served by gunicorn from the app's own virtualenv).
module.exports = {
  apps: [
    {
      name: "flask-backend",
      cwd: __dirname,
      script: "./venv/bin/gunicorn",
      args: "--bind 0.0.0.0:5000 --workers 2 app:app",
      interpreter: "none",
      autorestart: true,
      env: {
        PORT: "5000",
        APP_VERSION: process.env.APP_VERSION || "1.0.0",
        // Injected by Jenkins (Credentials Binding) at deploy time; empty when not configured.
        API_KEY: process.env.API_KEY || "",
      },
    },
  ],
};
