# Campus Event Tracker — Docker local development

This path adapts CSC443's Java Dockerfile exercises to the project, using Docker Compose to start **two Linux containers** on Windows or macOS: Spring Boot (`app`) and MySQL (`db`). **Verified on Windows November 16, 2026:** both containers ran, MySQL was healthy, the homepage and events API returned HTTP 200, and the API retrieved 22 seeded events. The refreshed checked-in seed now contains 100 events and 20 locations; a fresh-database runtime check of that seed is still needed. **Also unverified:** a fresh teammate setup on macOS and real POST-to-database event creation. The root [README](../README.md) is the main onboarding guide; this file provides technical details.

## What you need

- Git
- Docker Desktop with its Linux container engine running (or a compatible Docker Engine and Compose installation)
- A terminal (PowerShell on Windows, Terminal on macOS)
- A browser such as Chrome

You do **not** separately need a local Java or MySQL installation for this Compose workflow. The existing native MySQL service on Windows can stay running: this Compose configuration does not publish the container database's port 3306 onto the host.

### 1. Clone, or open a clone of the repo

```bash
git clone https://github.com/iymen-stack/campus-event-tracker.git
cd campus-event-tracker
```

The `compose.yaml`, `Dockerfile`, `.dockerignore`, `.env.example`, and refreshed `docker/db/seed.sql` are on branch `feature/event-search-filters`. Teammates cloning `main` won't receive the latest seed until that branch is merged. For an existing clone, switch to `feature/event-search-filters` before following the steps.

### 2. Create local-only configuration

Windows PowerShell:

```powershell
Copy-Item .env.example .env
notepad .env
```

macOS Terminal:

```bash
cp .env.example .env
nano .env
```

Change **both** example passwords to your own development-only values and save. The file `.env` is excluded by `.gitignore`: **never commit it** or use these credentials for an internet-facing production deployment.

The default browser port is `APP_PORT=8080`. Change it to 8081 if 8080 is occupied.

### 3. Inspect configuration, then start

After opening Docker Desktop and confirming the engine is running:

```bash
docker info
docker compose config --quiet
docker compose up --build -d
docker compose ps
```

- `docker info`: checks that the Docker engine is actually reachable; `docker --version` alone does not.
- `docker compose config --quiet`: validates the Compose file and `.env` references, without printing resolved passwords to the terminal.
- `docker compose up --build -d`: builds the Java image using the Dockerfile, creates the private MySQL container and its named data volume, initializes a **brand-new empty Docker database** from the seed, waits for a healthy database, and starts the application in the background.
- `docker compose ps`: displays container status and published ports.

The first build needs internet access to download the JDK/JRE and MySQL images and the Maven dependencies.

### 4. See the website

Visit `http://localhost:8080/` in Chrome on that same computer (or replace 8080 with the chosen `APP_PORT`). Check `http://localhost:8080/api/events` for JSON.

If the site doesn't load, inspect logs:

```bash
docker compose logs --tail=100 app
docker compose logs --tail=100 db
```

The `app` container uses the host `db` **inside the Compose network**, not `localhost` for the database. The browser uses localhost because it reaches the published application HTTP port on the host.

### 5. Stop and restart

```bash
docker compose down
docker compose up -d
```

`down` removes the containers/network, but the **named MySQL data volume remains**. A later `up` reuses the existing database. **Never run `docker compose down -v` casually:** the `-v` option deletes the named volume and its database contents.

## How the implementation relates to CSC443 Docker exercises

- `Dockerfile`: `FROM eclipse-temurin:21-jdk AS build` uses a Java JDK to build; the second `FROM eclipse-temurin:21-jre` creates the runtime image. This follows the two-stage classroom example.
- The Maven wrapper builds Spring Boot; the frontend is copied to `src/main/resources/static/` before packaging, so it can be served by the same application.
- `compose.yaml` describes two services, their private network, container startup dependency, and the persistent MySQL volume.
- `docker/db/seed.sql` is the refreshed 100-event local-development seed. It is imported only into a brand-new Docker database and is **not** a safe upgrade script for populated databases.
- `.env` holds each developer's own local settings. It is not committed.

## Verification status and remaining gaps

- **Verified on Windows November 16:** the application container ran, the database container was healthy, homepage/API returned HTTP 200, and the API returned 22 events from the then-current seed. The refreshed seed contains 100 events and 20 locations, but that updated count has not yet been runtime-verified. This is not proof of a Mac runtime.
- Real event insertion (POST 201 followed by a GET), and Mac/Apple Silicon runtime compatibility, still require verification.
- A new schema dump **does not reinitialize an existing named volume**. Changes to previously initialized databases require reviewed migrations, not dropping/recreating data.

This Compose workflow is for **local course development**, not production hosting or authentication. ChromeOS/Chromebook devices without a supported Docker Linux environment would need a hosted application or compatible development environment.
