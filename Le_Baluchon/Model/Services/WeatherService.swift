//
//  WeatherService.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 16/05/2024.
//
import Foundation

enum WeatherServiceError: Error, LocalizedError, Equatable {
    case noData
    case decodingError
    case customError(String)

    var errorDescription: String? {
        switch self {
        
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .customError(let message):
            return message
        }
    }
    
    static func == (lhs: WeatherServiceError, rhs: WeatherServiceError) -> Bool {
        switch (lhs, rhs) {
        case
             (.noData, .noData),
             (.decodingError, .decodingError):
            return true
        case (.customError(let lhsMessage), .customError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}



class WeatherService {
    static let apiKey = "829a9879a4c00c7941c92290f12eaed6"
    
    static func fetchWeather(for city: String, urlSession: URLSessionProtocol = URLSession.shared, completion: @escaping (Result<WeatherResponse, WeatherServiceError>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString), !city.isEmpty else {
            completion(.failure(.decodingError))
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.customError(error.localizedDescription)))
                return
            }
            guard let data = data, !data.isEmpty else {
                completion(.failure(.noData))
                return
            }
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        task.resume()
    }
}


