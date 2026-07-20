use dotenvy::dotenv;
use std::env;

pub fn load_api_key() -> String {
    dotenv().ok();
    env::var("WEATHER_API_KEY").expect("Missing WEATHER_API_KEY")
}
