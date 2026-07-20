mod models;
mod repositories;
mod dao;
mod viewmodel;
mod view;
mod utils;
mod config;

use view::cli_view::run_cli;

#[tokio::main]
async fn main() {
    utils::logging::init_logging();
    run_cli().await;
}
