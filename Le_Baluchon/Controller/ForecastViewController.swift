//
//  ForecastViewController.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 09/05/2024.
//

import UIKit
import Lottie

class ForecastViewController: UIViewController {

    @IBOutlet weak var newYorkTemperatureLabel: UILabel!
    @IBOutlet weak var newYorkConditionLabel: UILabel!
    @IBOutlet weak var localTemperatureLabel: UILabel!
    @IBOutlet weak var localConditionLabel: UILabel!
    @IBOutlet weak var newYorkAnimationView: LottieAnimationView!
    @IBOutlet weak var localAnimationView: LottieAnimationView!

    let localCity = "Lyon" // Remplacez par votre ville

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchWeather(for: "New York", temperatureLabel: newYorkTemperatureLabel, conditionLabel: newYorkConditionLabel, animationView: newYorkAnimationView)
        fetchWeather(for: localCity, temperatureLabel: localTemperatureLabel, conditionLabel: localConditionLabel, animationView: localAnimationView)
    }

    func fetchWeather(for city: String, temperatureLabel: UILabel, conditionLabel: UILabel, animationView: LottieAnimationView) {
        WeatherService.fetchWeather(for: city) { response, error in
            DispatchQueue.main.async {
                if let response = response {
                    temperatureLabel.text = "\(response.main.temp)°C"
                    conditionLabel.text = response.weather.first?.description.capitalized
                    self.setAnimation(for: response.weather.first?.description ?? "", in: animationView)
                } else if let error = error {
                    print("Failed to fetch weather data: \(error.localizedDescription)")
                }
            }
        }
    }

    func setAnimation(for condition: String, in animationView: LottieAnimationView) {
        var animationName = ""

        switch condition.lowercased() {
        case "clear sky":
            animationName = "sunny"
        case "few clouds", "scattered clouds", "broken clouds", "overcast clouds":
            animationName = "cloudy"
        case "shower rain", "rain":
            animationName = "rainy"
        case "thunderstorm":
            animationName = "stormy"
        case "snow":
            animationName = "snowy"
        case "mist", "light intensity drizzle":
            animationName = "misty"
        default:
            animationName = "default"
        }

        let animation = LottieAnimation.named(animationName)
        animationView.animation = animation
        animationView.play()
        animationView.loopMode = .loop
    }
}
