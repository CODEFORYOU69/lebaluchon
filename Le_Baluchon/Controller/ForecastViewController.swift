//
//  ForecastViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 09/05/2024.
//

import UIKit
import Lottie

class ForecastViewController: UIViewController {
    
    // UI Outlets
    @IBOutlet weak var forecastTitle: UILabel!
    @IBOutlet weak var newYorkTemperatureLabel: UILabel!
    @IBOutlet weak var newYorkConditionLabel: UILabel!
    @IBOutlet weak var localTemperatureLabel: UILabel!
    @IBOutlet weak var localConditionLabel: UILabel!
    @IBOutlet weak var newYorkAnimationView: LottieAnimationView!
    @IBOutlet weak var localAnimationView: LottieAnimationView!
    @IBOutlet weak var travelCityLabelTemp: UILabel!
    @IBOutlet weak var homeCityLabelTemp: UILabel!
    @IBOutlet weak var travelCityLabelCond: UILabel!
    @IBOutlet weak var homeCityLabelCond: UILabel!
    
    // Default cities
    var localCity: String = UserDefaults.standard.string(forKey: "homeLocation") ?? "Lyon"
    var travelCity: String = UserDefaults.standard.string(forKey: "travelLocation") ?? "New York"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI elements
        view.sendSubviewToBack(newYorkAnimationView)
        view.sendSubviewToBack(localAnimationView)
        view.bringSubviewToFront(newYorkTemperatureLabel)
        view.bringSubviewToFront(newYorkConditionLabel)
        view.bringSubviewToFront(localTemperatureLabel)
        view.bringSubviewToFront(localConditionLabel)
        
        // Set city labels
        homeCityLabelTemp.text = localCity
        travelCityLabelTemp.text = travelCity
        homeCityLabelTemp.font = UIFont(name: "SFPro-CompressedMedium", size: 20)
        travelCityLabelTemp.font = UIFont(name: "SFPro-CompressedMedium", size: 20)
        homeCityLabelCond.text = localCity
        travelCityLabelCond.text = travelCity
        homeCityLabelCond.font = UIFont(name: "SFPro-CompressedMedium", size: 20)
        travelCityLabelCond.font = UIFont(name: "SFPro-CompressedMedium", size: 20)
        
        // Fetch weather for the initial cities
        fetchWeather(for: travelCity, temperatureLabel: newYorkTemperatureLabel, conditionLabel: newYorkConditionLabel, animationView: newYorkAnimationView)
        fetchWeather(for: localCity, temperatureLabel: localTemperatureLabel, conditionLabel: localConditionLabel, animationView: localAnimationView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLocations()
    }
    
    // Update locations from UserDefaults
    func updateLocations() {
        localCity = UserDefaults.standard.string(forKey: "homeLocation") ?? "Lyon"
        travelCity = UserDefaults.standard.string(forKey: "travelLocation") ?? "New York"
        
        homeCityLabelTemp.text = localCity
        travelCityLabelTemp.text = travelCity
        homeCityLabelCond.text = localCity
        travelCityLabelCond.text = travelCity
        
        fetchWeather(for: travelCity, temperatureLabel: newYorkTemperatureLabel, conditionLabel: newYorkConditionLabel, animationView: newYorkAnimationView)
        fetchWeather(for: localCity, temperatureLabel: localTemperatureLabel, conditionLabel: localConditionLabel, animationView: localAnimationView)
    }
    
    // Fetch weather data for a given city
    func fetchWeather(for city: String, temperatureLabel: UILabel, conditionLabel: UILabel, animationView: LottieAnimationView) {
        WeatherService.fetchWeather(for: city) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    temperatureLabel.text = "\(response.main.temp)°C"
                    conditionLabel.text = response.weather.first?.description.capitalized
                    self.setAnimation(for: response.weather.first?.description ?? "", in: animationView)
                case .failure(let error):
                    print("Failed to fetch weather data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Set animation based on weather condition
    func setAnimation(for condition: String, in animationView: LottieAnimationView) {
        var animationName = ""
        
        switch condition.lowercased() {
        case "clear sky", "Clear sky":
            animationName = "sunny"
        case "few clouds", "scattered clouds", "broken clouds", "overcast clouds":
            animationName = "cloudy"
        case "shower rain", "rain", "light rain":
            animationName = "rainy"
        case "thunderstorm":
            animationName = "stormy"
        case "snow":
            animationName = "snowy"
        case "mist", "light intensity drizzle", "drizzle", "fog", "haze":
            animationName = "misty"
        default:
            animationName = "default"
        }
        
        // Configure and play the animation
        let animation = LottieAnimation.named(animationName)
        animationView.animation = animation
        animationView.play()
        animationView.loopMode = .loop
    }
}
