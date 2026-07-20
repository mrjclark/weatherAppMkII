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
