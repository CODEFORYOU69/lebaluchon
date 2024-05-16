//
//  WeatherService.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 16/05/2024.
//

import Foundation

struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double
    }
    
    struct Weather: Codable {
        let description: String
    }
}

class WeatherService {
    static let apiKey = "829a9879a4c00c7941c92290f12eaed6" 

    static func fetchWeather(for city: String, completion: @escaping (WeatherResponse?, Error?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "WeatherServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, NSError(domain: "WeatherServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weatherResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}

