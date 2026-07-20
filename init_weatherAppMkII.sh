#!/usr/bin/env bash

set -e

PROJECT="weatherAppMkII"

echo "Creating project: $PROJECT"
mkdir -p "$PROJECT"
cd "$PROJECT"

########################################
# Cargo project + metafiles
########################################

echo "Initializing cargo project..."
cargo init --bin

# Overwrite Cargo.toml with full dependencies
cat >Cargo.toml <<'EOF'
[package]
name = "weatherAppMkII"
version = "0.1.0"
edition = "2021"

[dependencies]
reqwest = { version = "0.12", features = ["json", "blocking"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1.37", features = ["full"] }
chrono = "0.4"
rusqlite = { version = "0.31", features = ["bundled"] }
thiserror = "1.0"
anyhow = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
dotenvy = "0.15"
ipgeolocate = "0.3"
geocoding = "0.4"
EOF

########################################
# Directory structure
########################################

echo "Creating directory structure..."

mkdir -p src/models
mkdir -p src/repositories
mkdir -p src/dao
mkdir -p src/viewmodel
mkdir -p src/view
mkdir -p src/utils
mkdir -p data

########################################
# Main + lib
########################################

cat >src/main.rs <<'EOF'
mod models;
mod repositories;
mod dao;
mod viewmodel;
mod view;
mod utils;
mod config;

use view::cli_view::run_cli;

#[tokio::main]
async fn main() {
    utils::logging::init_logging();
    run_cli().await;
}
EOF

cat >src/lib.rs <<'EOF'
pub mod models;
pub mod repositories;
pub mod dao;
pub mod viewmodel;
pub mod view;
pub mod utils;
pub mod config;
EOF

########################################
# Models
########################################

cat >src/models/current_weather.rs <<'EOF'
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CurrentWeather {
    pub temperature: f64,
    pub humidity: u8,
    pub wind_speed: f64,
    pub description: String,
}
EOF

cat >src/models/historical_weather.rs <<'EOF'
use serde::Deserialize;
use chrono::NaiveDate;

#[derive(Debug, Deserialize)]
pub struct HistoricalWeather {
    pub date: NaiveDate,
    pub temperature_high: f64,
    pub temperature_low: f64,
    pub precipitation_mm: f64,
}
EOF

cat >src/models/geo_location.rs <<'EOF'
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct GeoLocation {
    pub latitude: f64,
    pub longitude: f64,
    pub city: String,
    pub region: String,
    pub country: String,
}
EOF

########################################
# Repositories
########################################

cat >src/repositories/api_repository.rs <<'EOF'
use anyhow::Result;
use reqwest::Client;

pub struct ApiRepository {
    client: Client,
}

impl ApiRepository {
    pub fn new() -> Self {
        Self { client: Client::new() }
    }

    pub async fn get_json<T: serde::de::DeserializeOwned>(&self, url: &str) -> Result<T> {
        let res = self.client.get(url).send().await?.json::<T>().await?;
        Ok(res)
    }
}
EOF

cat >src/repositories/db_repository.rs <<'EOF'
use anyhow::Result;
use rusqlite::{Connection, params};

pub struct DbRepository {
    pub conn: Connection,
}

impl DbRepository {
    pub fn new(path: &str) -> Result<Self> {
        Ok(Self { conn: Connection::open(path)? })
    }

    pub fn execute(&self, query: &str) -> Result<()> {
        self.conn.execute(query, params![])?;
        Ok(())
    }
}
EOF

cat >src/repositories/json_repository.rs <<'EOF'
use anyhow::Result;
use serde::de::DeserializeOwned;
use serde_json;

pub struct JsonRepository;

impl JsonRepository {
    pub fn read<T: DeserializeOwned>(path: &str) -> Result<T> {
        let data = std::fs::read_to_string(path)?;
        Ok(serde_json::from_str(&data)?)
    }

    pub fn write<T: serde::Serialize>(path: &str, value: &T) -> Result<()> {
        let data = serde_json::to_string_pretty(value)?;
        std::fs::write(path, data)?;
        Ok(())
    }
}
EOF

########################################
# DAOs
########################################

cat >src/dao/weather_dao.rs <<'EOF'
use anyhow::Result;
use rusqlite::{Connection, params};
use crate::models::current_weather::CurrentWeather;

pub struct WeatherDao<'a> {
    conn: &'a Connection,
}

impl<'a> WeatherDao<'a> {
    pub fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    pub fn insert_current(&self, weather: &CurrentWeather) -> Result<()> {
        self.conn.execute(
            "INSERT INTO current_weather (temperature, humidity, wind_speed, description)
             VALUES (?1, ?2, ?3, ?4)",
            params![weather.temperature, weather.humidity, weather.wind_speed, weather.description],
        )?;
        Ok(())
    }
}
EOF

cat >src/dao/location_dao.rs <<'EOF'
use anyhow::Result;
use rusqlite::{Connection, params};
use crate::models::geo_location::GeoLocation;

pub struct LocationDao<'a> {
    conn: &'a Connection,
}

impl<'a> LocationDao<'a> {
    pub fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    pub fn insert_location(&self, loc: &GeoLocation) -> Result<()> {
        self.conn.execute(
            "INSERT INTO locations (latitude, longitude, city, region, country)
             VALUES (?1, ?2, ?3, ?4, ?5)",
            params![loc.latitude, loc.longitude, loc.city, loc.region, loc.country],
        )?;
        Ok(())
    }
}
EOF

########################################
# ViewModel
########################################

cat >src/viewmodel/weather_viewmodel.rs <<'EOF'
use anyhow::Result;
use crate::repositories::{api_repository::ApiRepository, db_repository::DbRepository};
use crate::models::{current_weather::CurrentWeather, geo_location::GeoLocation};

pub struct WeatherViewModel {
    api: ApiRepository,
    db: DbRepository,
}

impl WeatherViewModel {
    pub fn new() -> Result<Self> {
        Ok(Self {
            api: ApiRepository::new(),
            db: DbRepository::new("data/weather.db")?,
        })
    }

    pub async fn fetch_and_store(&self) -> Result<()> {
        let location: GeoLocation = self.api.get_json("https://ipapi.co/json").await?;
        let weather: CurrentWeather = self.api.get_json("https://api.weatherapi.com/...").await?;

        println!("Fetched weather for {}", location.city);

        Ok(())
    }
}
EOF

########################################
# View
########################################

cat >src/view/cli_view.rs <<'EOF'
use crate::viewmodel::weather_viewmodel::WeatherViewModel;

pub async fn run_cli() {
    let vm = WeatherViewModel::new().unwrap();
    vm.fetch_and_store().await.unwrap();
}
EOF

########################################
# Utils
########################################

cat >src/utils/file_utils.rs <<'EOF'
use anyhow::Result;
use std::fs;

pub fn read(path: &str) -> Result<String> {
    Ok(fs::read_to_string(path)?)
}

pub fn write(path: &str, data: &str) -> Result<()> {
    fs::write(path, data)?;
    Ok(())
}
EOF

cat >src/utils/error.rs <<'EOF'
use thiserror::Error;

#[derive(Error, Debug)]
pub enum WeatherError {
    #[error("Network error: {0}")]
    Network(String),

    #[error("Database error: {0}")]
    Database(String),

    #[error("Unknown error")]
    Unknown,
}
EOF

cat >src/utils/logging.rs <<'EOF'
use tracing_subscriber;

pub fn init_logging() {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .init();
}
EOF

########################################
# Config
########################################

cat >src/config.rs <<'EOF'
use dotenvy::dotenv;
use std::env;

pub fn load_api_key() -> String {
    dotenv().ok();
    env::var("WEATHER_API_KEY").expect("Missing WEATHER_API_KEY")
}
EOF

########################################
# README.md
########################################

cat >README.md <<'EOF'
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

EOF

########################################
# Final message
########################################

echo "Project scaffold created successfully."
