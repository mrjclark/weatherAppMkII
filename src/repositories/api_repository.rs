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
