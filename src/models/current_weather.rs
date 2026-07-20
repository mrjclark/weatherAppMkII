use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CurrentWeather {
    pub temperature: f64,
    pub humidity: u8,
    pub wind_speed: f64,
    pub description: String,
}
