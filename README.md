# Weather App (Rust)

A modular, MVVM-style Rust application for retrieving current weather, historical weather, and geolocation data, then storing it in SQLite and JSON caches. This project is a migration from a Bash-based weather pipeline into a strongly typed, async Rust architecture.

## Features

- Fetch current weather via HTTP APIs
- Fetch historical weather data
- Resolve geolocation via IP-based services
- Store weather snapshots in SQLite
- Cache data in JSON files
- MVVM architecture (Models, ViewModel, View)
- Modular repositories and DAOs
- Logging, error handling, and utilities

---

## TODO: Implementation Plan

### Phase 1 — Core Infrastructure
- [ ] Implement SQLite schema and migrations
- [ ] Add proper API endpoints and authentication
- [ ] Build typed API clients for weather + geolocation
- [ ] Add configuration loader for API keys and settings

### Phase 2 — Data Layer
- [ ] Implement full CRUD in DAOs
- [ ] Add historical weather ingestion
- [ ] Add JSON caching strategy
- [ ] Add retry/backoff logic for API calls

### Phase 3 — ViewModel Logic
- [ ] Build orchestration pipeline (location → weather → store)
- [ ] Add error propagation and recovery
- [ ] Add logging/tracing instrumentation

### Phase 4 — CLI View
- [ ] Add command-line arguments (current, historical, dump-db, etc.)
- [ ] Add pretty terminal output
- [ ] Add interactive mode

### Phase 5 — Enhancements
- [ ] Add cron-like scheduler for periodic ingestion
- [ ] Add export tools (CSV, JSON)
- [ ] Add optional Tauri desktop UI
- [ ] Add unit tests + integration tests

