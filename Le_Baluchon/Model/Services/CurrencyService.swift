//
//  CurrencyService.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 12/05/2024.
//

import Foundation

struct ExchangeRatesResponse: Codable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Double]
}

typealias CurrencyMap = [String: Double]

class CurrencyConversionService {
    private let apiKey: String
    private let baseUrl: String
    private let userDefaults: UserDefaults
    private let urlSession: URLSessionProtocol
    private let exchangeRatesKey = "exchangeRates"
    private let lastUpdateKey = "lastUpdate"

    let currencies: [Currency] = [
        Currency(code: "USD", country: "United States", flag: "us"),
        Currency(code: "EUR", country: "European Union", flag: "eu"),
        Currency(code: "GBP", country: "United Kingdom", flag: "gb"),
        Currency(code: "JPY", country: "Japan", flag: "jp"),
        Currency(code: "CAD", country: "Canada", flag: "ca"),
        Currency(code: "MAD", country: "Morocco", flag: "ma"),
    ]

    init(apiKey: String = "7d28069a0e2be3744db223ee0dcdcd14",
         baseUrl: String = "http://data.fixer.io/api/latest",
         userDefaults: UserDefaults = .standard,
         urlSession: URLSessionProtocol = URLSession.shared) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
        self.userDefaults = userDefaults
        self.urlSession = urlSession
    }
    
    func fetchExchangeRates(for currencyCodes: [String], completion: @escaping (Result<CurrencyMap, Error>) -> Void) {
        if let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date,
           let storedData = userDefaults.data(forKey: exchangeRatesKey),
           Calendar.current.isDateInToday(lastUpdate) {
            let result = Result {
                let storedRates = try JSONDecoder().decode(CurrencyMap.self, from: storedData)
                if currencyCodes.allSatisfy({ storedRates.keys.contains($0) }) {
                    return storedRates
                } else {
                    throw NSError(domain: "CurrencyConversionServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Required currencies not found in cached rates"])
                }
            }
            completion(result)
            return
        }

        // If currency rates are not available or data is too old, do a new API call
        print("Fetching new exchange rates because required currencies are not all available in cache or data is outdated.")
        fetchNewExchangeRates(completion: completion)
    }

    private func fetchNewExchangeRates(completion: @escaping (Result<CurrencyMap, Error>) -> Void) {
        let urlString = "\(baseUrl)?access_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "CurrencyConversionServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let request = URLRequest(url: url)

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "CurrencyConversionServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let exchangeRatesResponse = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
                if exchangeRatesResponse.success {
                    let rates = exchangeRatesResponse.rates
                    self?.userDefaults.set(try? JSONEncoder().encode(rates), forKey: self?.exchangeRatesKey ?? "")
                    self?.userDefaults.set(Date(), forKey: self?.lastUpdateKey ?? "")
                    completion(.success(rates))
                } else {
                    completion(.failure(NSError(domain: "CurrencyConversionServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch exchange rates"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func convert(amount: Double, from: String, to: String, rates: [String: Double]) -> Double? {
        guard let fromRate = rates[from], let toRate = rates[to] else {
            return nil
        }
        let baseAmount = amount / fromRate
        let convertedAmount = baseAmount * toRate
        return convertedAmount
    }
}

