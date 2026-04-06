# cbsvault_api

CBS Vault **Dart Frog** BFF: JSON metadata, health, and a simple `/v1/status` route. The Flutter app stores an optional base URL and calls **`GET /health`** from Settings (“Test connection”). Vault entries remain in **Firebase Firestore**; this service does not replace Firestore.

## Local development

- From this directory: `dart pub get`, then `dart_frog dev` (see [Dart Frog](https://dart-frog.dev)).
- Tests: `dart test`

## Deploy on Render

1. Push the repo (including `cbsvault_api/`) to GitHub/GitLab/Bitbucket.
2. In [Render](https://render.com), **New** → **Web Service** → connect the repo.
3. Set **Root Directory** to `cbsvault_api`.
4. **Environment:** **Docker** (build uses `Dockerfile` in this folder). Render injects **`PORT`**; the container listens on that port.
5. Optional: set **Health Check Path** to **`/health`**.
6. After deploy, copy the service URL (e.g. `https://your-service.onrender.com`) into the Flutter app **Settings** → BFF base URL → **Save URL** → **Test connection**.

## Routes

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/` | Service name and version JSON |
| GET | `/health` | Liveness for Render / manual checks |
| GET | `/v1/status` | Simple API status JSON |
