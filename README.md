# Campus Event Tracker

A CSC443 Software Engineering team project at Augsburg University. Students can browse campus events; the team is developing creation and other organizer workflows.

**Team:** Iymen Mohamed, Samson Gyasi, Abshir Edow.

## Current functionality (verified baseline: November 16, 2026)

| Feature | Status |
| --- | --- |
| Browse events from MySQL | **Working** through the Spring Boot GET API and browser. On November 16, Docker returned 22 seeded events. |
| Search/filter events | **Implemented** in the browser: title, category, location, calendar date, and today/this-week filters. |
| Create an event | **Backend implemented**: `POST /api/events`, request validation, and mocked controller tests. **Not** yet verified with a real database INSERT; there is no creation form in the merged frontend. |
| Login | **UI prototype only** at `/css/login.html`. No user authentication, password verification, or access control. |
| Delete an event | Not implemented. |
| Setup on Windows via Docker | **Verified November 16, 2026**: MySQL healthy, Spring Boot running, `/` HTTP 200, `/api/events` HTTP 200, 22 events retrieved. |
| Setup on macOS via Docker | Same intended Compose configuration, **not yet tested on a teammate's Mac**. |

The event-search and event-creation backend PRs were merged into `main` on November 5, 2026. Docker setup is currently on `feature/cet-integration`; a new GitHub clone of `main` will **not** contain it until that branch is merged.

**Scope boundary:** A working event-listing site does not prove that users can create events from the website, log in, or delete events.

## Recommended setup — Docker Compose (Windows and macOS)

Docker Compose starts two containers together:

- `app`: the Java 21 / Spring Boot application, including the HTML, CSS, and JavaScript.
- `db`: a private MySQL 8.4 server, initially seeded from `docker/db/seed.sql`.

**Prerequisites:** Git, Docker Desktop (with the Docker engine running), terminal/PowerShell, and a browser. No separate Java, Maven, MySQL Server, or MySQL Workbench installation is required for **this** setup method.

### 1. Obtain the source

After `feature/cet-integration` is merged, a teammate can run:

```bash
git clone https://github.com/iymen-stack/campus-event-tracker.git
cd campus-event-tracker
```

For an existing clone, first make sure you are on a branch containing `Dockerfile`, `compose.yaml`, `.env.example`, and `docker/db/seed.sql`. Do not run these instructions from an older checkout.

### 2. Make your own local configuration

In **Windows PowerShell**:

```powershell
Copy-Item .env.example .env
notepad .env
```

In **macOS Terminal**:

```bash
cp .env.example .env
nano .env
```

Replace **both** example passwords (`DB_PASSWORD` and `DB_ROOT_PASSWORD`) with different development-only passwords. Save the file. `.env` is ignored by Git; **never commit it or send it to teammates**. Each developer chooses their own credentials. The default web port is `APP_PORT=8080`; change it to `8081` if port 8080 is occupied.

On an existing Docker database volume, editing these password settings does **not** automatically change already-created MySQL accounts. Keep the settings consistent or plan a controlled credential change.

### 3. Start the website and database

Open Docker Desktop and make sure its engine is running. From the repository root run:

```bash
docker info
docker compose config --quiet
docker compose up --build -d
docker compose ps
```

What the commands mean:

| Command | Purpose |
| --- | --- |
| `docker info` | Verify the Docker engine is reachable. Installing the CLI alone is not enough. |
| `docker compose config --quiet` | Validate the Compose configuration without printing the resolved environment values. |
| `docker compose up --build -d` | Build the app image, start MySQL, wait for its health check, and start Spring Boot in the background. |
| `docker compose ps` | Check that `db` is healthy and `app` is running. |

The first run needs network access to download Docker images and Maven dependencies. On a new **empty Docker data volume**, MySQL automatically imports `docker/db/seed.sql` **once**. Subsequent starts reuse the stored database; changing the seed file does **not** update an existing volume.

The Docker MySQL server is internal to the Compose network and does not publish port 3306 to Windows/macOS. Thus an existing host MySQL installation need not be stopped. The Spring application connects to the service name `db` inside Docker.

### 4. Verify the result

Open these URLs on the **same computer**:

- [Website](http://localhost:8080/) — should show the campus event cards and search/filter controls.
- [GET events API](http://localhost:8080/api/events) — should return a JSON array.

If `APP_PORT` is different, use that port in both URLs. The default app is bound to `127.0.0.1`, so this is for local development: it is not a publicly hosted site and will not automatically let teammates visit **your** instance.

On November 16, 2026, Windows Docker verification returned HTTP 200 on both URLs and 22 events from the seeded MySQL container. **A fresh macOS installation and real POST persistence are separate pending tests.**

### 5. Stop, restart, rebuild, and inspect logs

```bash
docker compose down
docker compose up -d
docker compose up --build -d
docker compose logs --tail=100 app
docker compose logs --tail=100 db
```

- `down` stops/removes containers and their network, but **keeps** the named database volume.
- `up -d` starts containers from the existing image/configuration.
- `up --build -d` rebuilds after application or packaged frontend changes.
- `logs` provides errors for the respective service.

**Do not casually run `docker compose down -v`.** The `-v` removes the MySQL data volume and deletes locally stored events. The initialization SQL also drops/recreates tables and must **not** be used against a populated database as a migration.

For the technical explanation of the Dockerfile, network, data volume, and known limitations, see [Docker local development notes](docs/docker-local-development.md).

## Alternative: run without Docker

Use this only when you deliberately want a native Java/MySQL environment. **Do not run native Spring Boot and Docker Spring Boot on the same HTTP port.**

**Common requirements:** Java 21+, a local MySQL server containing the `augsburg_events` schema, and a database account with the required privileges. The repository's `backend/` contains the Maven wrapper; installing Maven globally is unnecessary.

The included SQL exports are **not safe migrations**. `augsburg_database.sql`, `augsburg_events2.sql`, and `augsburg_database_updated` contain table-dropping statements, and their data/schemas differ. Only initialize a new disposable database using a reviewed schema. Back up an existing database and plan migrations separately. The application account needs SELECT access to browse events and INSERT rights to create them.

### Windows PowerShell

From the repository root:

```powershell
Get-Service MySQL84
# If MySQL84 is installed but stopped, start it in an administrator PowerShell:
# Start-Service MySQL84
.\scripts\start-dev.ps1
```

The script prompts for a MySQL password, launches the backend with the `frontend/` folder as static resources, and defaults to user `campus_reader`, database `augsburg_events`, and port 8080. To choose another HTTP port or account:

```powershell
.\scripts\start-dev.ps1 -Port 8081 -DbUser your_local_user
```

If the system blocks trusted local scripts, `Set-ExecutionPolicy -Scope Process Bypass` applies only to that terminal session. Stop the native server with **Ctrl+C**.

### macOS Terminal

Install Java 21+, local MySQL Server, and Git using the platform's supported installation method. Start the MySQL server with its relevant service manager; `brew services start mysql` applies only if MySQL was installed via Homebrew. From the repository root:

```bash
bash scripts/start-dev-mac.sh
# Optional alternate HTTP port:
bash scripts/start-dev-mac.sh 8081
# Optional alternate database user:
DB_USER=my_local_mysql_user bash scripts/start-dev-mac.sh
```

The Mac helper asks for the database password and runs Spring Boot with the frontend. **This native helper has not been runtime-tested on a Mac.** It does not create or migrate tables. Stop with **Ctrl+C**.

### Browser note

Chrome is a browser, not a Java/MySQL hosting platform. `localhost` refers to the machine running the browser. Do not open `frontend/index.html` directly as a `file://` page to test API integration; it calls the relative endpoint `/api/events` on the serving origin.

## Repository structure

```text
campus-event-tracker/
  backend/                         Java 21 / Spring Boot / Maven wrapper / tests
  frontend/index.html              Event listing, search and filters
  frontend/css/style.css           Website styles
  frontend/css/login.html          Login UI prototype (not authentication)
  Dockerfile                       Two-stage Java image build
  compose.yaml                     app + db local development services
  .env.example                     Nonsecret configuration template
  docker/db/seed.sql               Initial Docker database data (first use only)
  docs/docker-local-development.md Detailed Docker notes
  scripts/start-dev.ps1            Optional native Windows startup
  scripts/start-dev-mac.sh         Optional native macOS startup
  augsburg_database.sql            Legacy SQL export — not a migration
  augsburg_events2.sql             Legacy SQL export — not a migration
  augsburg_database_updated        November 4 SQL export — not a migration
```

The Dockerfile follows the CSC443 two-stage Java build exercise: a JDK builds the Spring Boot JAR, then a JRE image runs it. The HTML/CSS/JS frontend is bundled into Spring Boot's static resources during that build.

## API contract

### GET `/api/events`

Reads events joined to locations from MySQL. Response objects include `event_id`, `title`, `category`, `location_name`, `start_time`, and `end_time`. Example **shape**, not a live response:

```json
{
  "event_id": 1,
  "title": "Example event",
  "category": "Sports",
  "location_name": "Hagfors Center",
  "start_time": "2026-11-05T15:00:00",
  "end_time": "2026-11-05T17:00:00"
}
```

### POST `/api/events`

The merged backend controller accepts JSON in this form:

```json
{
  "title": "Coding Night",
  "category": "Student Activities",
  "locationId": 8,
  "startTime": "2026-11-18T17:00:00",
  "endTime": "2026-11-18T19:00:00"
}
```

**Validation in code:** title required/nonblank and at most 150 characters; category optional and at most 50 characters; `locationId` required and positive; both times required; end time strictly after start time. Valid controller requests call a JDBC INSERT and return HTTP 201. Invalid input is covered by controller tests that use a mocked `JdbcTemplate`.

**Not yet verified against real MySQL:** successful INSERT, resulting GET, expected application response when `locationId` is positive but nonexistent, or a full create-event browser workflow. An existing location ID is a **database constraint**, not something the current Java bean validation independently checks. The GET response uses snake_case field names while the POST request uses camelCase; a frontend form must use the POST contract.

POST currently accepts no description or organizer field. There is no authenticated organizer/authorization check.

## Tests and troubleshooting

Five `EventControllerTest` tests cover valid creation and invalid-request cases using a **mocked** JDBC layer. There is also a Spring application context-load test (six tests previously passed in total). These tests do not demonstrate a real database INSERT or browser form.

For a native build from `backend/` on Windows:

```powershell
.\mvnw.cmd test
```

On macOS/Linux: `./mvnw test`. A local backend test may need suitable datasource configuration. The Docker build intentionally packages with `-DskipTests`; a successful Docker image build is **not** a substitute for tests.

| Symptom | Check |
| --- | --- |
| Docker cannot connect to engine | Start Docker Desktop; verify `docker info` works |
| App container is not running | `docker compose ps` then `docker compose logs --tail=100 app` |
| Database unhealthy | `docker compose logs --tail=100 db`; inspect first-start seed errors |
| HTTP port 8080 busy | Change `APP_PORT` in `.env`, then restart Compose |
| Website loads but events API fails | Inspect app/database logs and `/api/events` response |
| MySQL access denied | Confirm app settings match **the initialized volume's** user/password |
| App can't resolve database hostname | Compose app uses `db` internally; native scripts use `localhost` |
| Invalid event location ID | The ID must exist in the `locations` table |
| Schema/seed changed but old data remains | Existing volume isn't re-seeded; use reviewed migrations, not `down -v` |

## Next integration milestones

1. Verify a valid `POST /api/events` produces one new row in the **Docker** database and appears in a subsequent GET. Verify invalid requests do not insert rows.
2. Agree on the actual location IDs/schema with the team and reconcile Samson's newer proposed 100+ event dataset. The current seed derives from the November 4 export and is not evidence of subsequent changes.
3. Integrate a frontend event-creation form against the verified POST contract.
4. Have a teammate run this setup from a **fresh clone on macOS**, following the instructions without hidden manual steps.
5. Decide the course-required scope for login/authentication and deletion; neither is complete.
6. Merge the validated integration branch, then update Jira/sprint evidence to reflect what is **actually verified**.

These instructions are for local development, not production deployment.
