use anyhow::Result;
use std::fs;

pub fn read(path: &str) -> Result<String> {
    Ok(fs::read_to_string(path)?)
}

pub fn write(path: &str, data: &str) -> Result<()> {
    fs::write(path, data)?;
    Ok(())
}
