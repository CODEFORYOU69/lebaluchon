//
//  weather.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 07/06/2024.
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
