# cbsvault_api

CBS Vault **Dart Frog** BFF: JSON metadata, health, and a simple `/v1/status` route. The Flutter app stores an optional base URL and calls **`GET /health`** from Settings (“Test connection”). Vault entries remain in **Firebase Firestore**; this service does not replace Firestore.

## Local development

- From this directory: `dart pub get`, then `dart_frog dev` (see [Dart Frog](https://dart-frog.dev)).
- Tests: `dart test`

## Deploy on Render

1. Push the repo (including `cbsvault_api/`) to GitHub/GitLab/Bitbucket.
2. In [Render](https://render.com), **New** → **Web Service** → connect the repo.
3. **Docker** environment; Render injects **`PORT`**.
4. Choose **one** layout (both work):
   - **A:** **Root Directory** `cbsvault_api`, **Dockerfile Path** `Dockerfile` (build context = this folder).
   - **B (recommended if Root Directory misbehaves):** **Root Directory** *empty*, **Dockerfile Path** `Dockerfile.render` (repo root; copies from `cbsvault_api/`).
5. Optional: **Health Check Path** **`/health`**.
6. After deploy, copy the service URL into the Flutter app **Settings** → BFF base URL → **Save URL** → **Test connection**.

## Routes

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/` | Service name and version JSON |
| GET | `/health` | Liveness for Render / manual checks |
| GET | `/v1/status` | Simple API status JSON |
