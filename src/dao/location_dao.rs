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
