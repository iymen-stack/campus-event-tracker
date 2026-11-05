# Campus Event Tracker

A CSC 443 Software Engineering team project at Augsburg University. The goal is to help students discover campus events and, in a later integrated flow, create events.

**Team:** Iymen Mohamed, Samson Gyasi, and Abshir Edow.

## Current state (November 2026)

| Feature | Status |
| --- | --- |
| Browse events | Implemented: Spring GET endpoint and a basic event-listing page |
| MySQL-backed event data | Implemented for reads; local database configuration is required |
| Login page | UI prototype only; authentication is not implemented |
| Search and filter | Work in a separate pull request, not yet in `main` |
| Create an event | Backend POST/validation work in progress on a separate local branch; not yet on `main` |
| Delete events | Planned, not implemented |

Do not confuse code that compiles with a tested end-to-end workflow. Creating an event through the website has **not** been verified.

## Tech stack and repository layout

- **Frontend:** HTML, CSS, and plain JavaScript in `frontend/`.
- **Backend:** Java 21, Spring Boot 4.1.1, Spring MVC, Spring JDBC, Maven wrapper in `backend/`.
- **Database:** MySQL; `events.location_id` references `locations.location_id`.
- **Tests:** JUnit/Spring test dependencies are present. The checked-in application test is a basic context-load test; creation/validation tests are still needed.

```text
campus-event-tracker/
  backend/                     Spring Boot project and Maven wrapper
    src/main/java/             REST controller and application entry point
    src/main/resources/        Application configuration
    src/test/                  Java tests
  frontend/
    index.html                 Event listing page
    css/style.css              Styles
  augsburg_database.sql        Original database dump
  augsburg_events2.sql         Earlier exported database dump
  augsburg_database_updated    Newer dump with AUTO_INCREMENT (see warnings below)
  scripts/start-dev.ps1        Windows development startup helper
```

## Run locally on Windows

### 1. Prerequisites

- JDK 21 or newer installed and accessible to PowerShell (`java -version`).
- A local MySQL server (e.g. Windows service `MySQL84`) and a MySQL client/Workbench.
- A local MySQL user with access to the `augsburg_events` schema.
- PowerShell. You do **not** need to install Maven globally; the repo includes `backend/mvnw.cmd`.

Check your MySQL service:

```powershell
Get-Service MySQL84
# If it is stopped, run this from an administrator PowerShell:
Start-Service MySQL84
```

The MySQL service listening on port 3306 and Spring Boot serving HTTP on port 8080 are **different processes**.

### 2. Set up the database

Use the schema named `augsburg_events`. For a **new, disposable local database only**, `augsburg_database_updated` contains the current sample tables and seed rows. Open it as a SQL script using MySQL Workbench after creating/selecting the `augsburg_events` schema.

**Warning: the dump executes `DROP TABLE IF EXISTS` for `events` and `locations`. Running it against a database you already use will replace those tables and their data. Do not import it as a migration or over an existing database. Back up your data first.**

The updated dump defines `events.event_id` and `locations.location_id` as `AUTO_INCREMENT`. Existing local databases are **not** updated automatically by pulling Git commits. Check their live schema before making changes:

```sql
SHOW CREATE TABLE events;
SHOW CREATE TABLE locations;
```

Have a database owner review any necessary migration; do not rerun the full dump to change a primary key.

The application has previously used a local MySQL account named `campus_reader`. Despite its name, saving new events also requires **INSERT** permission on `augsburg_events.events`. Verify that the account exists and has the required privileges; do not add passwords to Git or this README.

### 3. Start the application (recommended)

From the repository root in PowerShell:

```powershell
.\scripts\start-dev.ps1
```

The script checks whether the chosen HTTP port is occupied, prompts for your local MySQL password, sets the Spring datasource environment variables, and launches Spring Boot from `backend/`. It also configures Spring's local static-resource path to use the existing `frontend/` directory, so the page and `/api/events` can use the same origin.

Defaults: database `augsburg_events`, user `campus_reader`, MySQL port `3306`, HTTP port `8080`.

To use another HTTP port or MySQL username:

```powershell
.\scripts\start-dev.ps1 -Port 8081 -DbUser your_local_user
```

If PowerShell blocks local scripts under your execution policy, use a trusted checkout and, **in that terminal only**, run `Set-ExecutionPolicy -Scope Process Bypass` before launching the script. This does not change the machine-wide execution policy.

The script does not start/stop other applications, modify tables, create database accounts, or store your password in a file. Password access is temporary for the launched process; the script clears its environment-variable copy when the application exits.

### 4. Check the application

After Spring logs that it started, try:

- `http://localhost:8080/` — frontend page when launched with `start-dev.ps1`.
- `http://localhost:8080/api/events` — JSON from the current GET endpoint.
- `http://localhost:8080/login.html` — **not guaranteed on `main`**: the login page currently sits in `frontend/css/login.html`; a separate branch moves it. Login is only a UI prototype.

A quick GET check from another PowerShell window:

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/events" -Method GET
```

The JavaScript in `frontend/index.html` calls `fetch("/api/events")`, so the frontend must be served from the same origin as Spring (or use an explicitly configured development proxy). Double-clicking `index.html` as a `file://` page or using an unrelated static server will not necessarily reach the API.

Stop the running app with **Ctrl+C** in its terminal.

## API contract

### GET /api/events — currently on main

Returns an array of events selected from MySQL, with fields including:

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

The object above is an illustrative shape, **not** a live response or a promise of exact JSON datetime formatting.

### POST /api/events — work in progress, not on main

Current backend feature work proposes this JSON request:

```json
{
  "title": "Coding Night",
  "category": "Student Activities",
  "locationId": 8,
  "startTime": "2026-11-05T17:00:00",
  "endTime": "2026-11-05T19:00:00"
}
```

Intended constraints: title required and at most 150 characters; category optional and at most 50; `locationId` must be a positive existing location ID; both times required; end time strictly after start time. A successful insert is intended to return HTTP 201. Error cases and persistence have not been fully tested.

The GET response uses database-style names such as `start_time` and `location_name`; the POST request uses Java record-style names such as `startTime` and `locationId`. Frontend work must follow the actual POST contract rather than assuming the GET object can be posted unchanged. The current POST request does **not** include a description or organizer field, even though the database table contains those columns.

## Build, test, and troubleshoot

From the `backend/` directory:

```powershell
.\mvnw.cmd -DskipTests compile
.\mvnw.cmd test
```

`compile` checks Java compilation; it does not start a server or prove the API works. The checked-in context-load test may require working datasource configuration. A full test suite for event creation is not yet in `main`.

If `spring-boot:run` ends with **BUILD FAILURE**, scroll **up** to `APPLICATION FAILED TO START`, the `Description`, or `Caused by:` lines. The final Maven message is a summary, not the root cause.

| Symptom | Next check |
| --- | --- |
| `url attribute is not specified` | Spring received no datasource URL; use the script or check variables in the **same terminal** as Maven |
| MySQL connection refused | `Get-Service MySQL84` and `Test-NetConnection localhost -Port 3306` |
| MySQL access denied | Credentials and account permissions |
| HTTP port 8080 already in use | Inspect the process below or launch the script with `-Port 8081` |
| `/api/events` returns 404 | Check that Campus Event Tracker (not another app) is serving that HTTP port |
| Failed foreign key for `location_id` | The selected ID must exist in `locations` |
| Missing generated event ID | Inspect `SHOW CREATE TABLE events`; updated dump alone does not migrate an existing schema |

To inspect which process is using port 8080 without stopping it:

```powershell
Get-NetTCPConnection -LocalPort 8080 -State Listen |
  Select-Object LocalPort, State, OwningProcess
Get-Process -Id <OwningProcess-from-output>
```

Replace the angle-bracket placeholder with the numeric PID. Stop your own running development server with Ctrl+C; never terminate an unfamiliar process solely because it owns a port.

## Integration checkpoints

Before claiming event creation is complete, the team needs to verify:

1. Frontend and backend can be opened together and GET events works.
2. Frontend creation fields match the POST request record (including a real location ID).
3. Invalid title and invalid time range return 400 without inserting anything.
4. The active MySQL table generates event IDs and the application database user has INSERT permission.
5. A valid POST creates exactly one event; a subsequent GET displays it.
6. Search/filter changes and login-page relocation are reviewed and integrated separately.
7. Setup instructions are tested on a teammate's machine before treating them as reproducible.

This README describes the project as it exists and identifies incomplete work; it is not evidence that every integration checkpoint has passed.
