use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct GeoLocation {
    pub place_id: i64,
    pub licence: String,
    pub osm_type: String,
    pub osm_id: i64,
    pub lat: String,
    pub lon: String,
    pub class: String,
    pub poi_type: String,
    pub place_rank: i64,
    pub importance: f64,
    pub addresstype: String,
    pub name: String,
    pub display_name: String,
    pub boundingbox: Vec<String>,
}
