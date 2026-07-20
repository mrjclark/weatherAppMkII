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
