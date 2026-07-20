use serde::Deserialize;
use chrono::NaiveDate;

#[derive(Debug, Deserialize)]
pub struct HistoricalWeather {
    pub date: NaiveDate,
    pub temperature_high: f64,
    pub temperature_low: f64,
    pub precipitation_mm: f64,
}
