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
