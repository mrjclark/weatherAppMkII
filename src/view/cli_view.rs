use crate::viewmodel::weather_viewmodel::WeatherViewModel;

pub async fn run_cli() {
    let vm = WeatherViewModel::new().unwrap();
    vm.fetch_and_store().await.unwrap();
}
