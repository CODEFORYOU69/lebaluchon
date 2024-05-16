//
//  ForecastViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 09/05/2024.
//

import UIKit

class ForecastViewController: UIViewController {
    
    @IBOutlet weak var newYorkTemperatureLabel: UILabel!
    @IBOutlet weak var newYorkConditionLabel: UILabel!
    @IBOutlet weak var localTemperatureLabel: UILabel!
    @IBOutlet weak var localConditionLabel: UILabel!
    
    let localCity = "Lyon" // Remplacez par votre ville
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchWeather(for: "New York", temperatureLabel: newYorkTemperatureLabel, conditionLabel: newYorkConditionLabel)
        fetchWeather(for: localCity, temperatureLabel: localTemperatureLabel, conditionLabel: localConditionLabel)
    }
    
    func fetchWeather(for city: String, temperatureLabel: UILabel, conditionLabel: UILabel) {
            WeatherService.fetchWeather(for: city) { response, error in
                DispatchQueue.main.async {
                    if let response = response {
                        temperatureLabel.text = "\(response.main.temp)°C"
                        conditionLabel.text = response.weather.first?.description.capitalized
                    } else if let error = error {
                        print("Failed to fetch weather data: \(error.localizedDescription)")
                    }
            }
        }
    }
}

