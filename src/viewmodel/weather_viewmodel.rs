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
