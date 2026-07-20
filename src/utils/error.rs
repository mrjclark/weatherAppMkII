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
