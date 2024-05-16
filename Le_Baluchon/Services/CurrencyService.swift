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


class CurrencyConversionService {
    private let apiKey: String
    private let baseUrl: String
    private let userDefaults: UserDefaults
    private let urlSession: URLSession
    private let exchangeRatesKey = "exchangeRates"
    private let lastUpdateKey = "lastUpdate"

    let currencies: [Currency] = [
        Currency(code: "USD", country: "United States", flag: "us"),
        Currency(code: "EUR", country: "European Union", flag: "eu"),
        Currency(code: "GBP", country: "United Kingdom", flag: "gb"),
        Currency(code: "JPY", country: "Japan", flag: "jp"),
        Currency(code: "CAD", country: "Canada", flag: "ca"),

    ]

    init(apiKey: String = "7d28069a0e2be3744db223ee0dcdcd14",
         baseUrl: String = "http://data.fixer.io/api/latest",
         userDefaults: UserDefaults = .standard,
         urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
        self.userDefaults = userDefaults
        self.urlSession = urlSession
    }

    func fetchExchangeRates(for currencyCodes: [String], completion: @escaping ([String: Double]?) -> Void) {
        if let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date,
           let storedData = userDefaults.data(forKey: exchangeRatesKey),
           Calendar.current.isDateInToday(lastUpdate) {
            do {
                let storedRates = try JSONDecoder().decode([String: Double].self, from: storedData)
                if currencyCodes.allSatisfy({ storedRates.keys.contains($0) }) {
                    print("Using cached exchange rates for required currencies.")
                    completion(storedRates)
                    return
                }
            } catch {
                print("Failed to decode stored exchange rates: \(error.localizedDescription)")
            }
        }

        //  if currency are not availables or data too old , do a new api call 
        print("Fetching new exchange rates because required currencies are not all available in cache or data is outdated.")
        fetchNewExchangeRates(completion: completion)
    }

    private func fetchNewExchangeRates(completion: @escaping ([String: Double]?) -> Void) {
        let urlString = "\(baseUrl)?access_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        print("Starting request to fetch new exchange rates: \(urlString)")

        let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error during data task: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                let exchangeRatesResponse = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
                if exchangeRatesResponse.success {
                    let rates = exchangeRatesResponse.rates
                    self?.userDefaults.set(try? JSONEncoder().encode(rates), forKey: self?.exchangeRatesKey ?? "")
                    self?.userDefaults.set(Date(), forKey: self?.lastUpdateKey ?? "")
                    print("New exchange rates stored.")
                    completion(rates)
                } else {
                    print("Failed to fetch exchange rates: response indicates failure.")
                    completion(nil)
                }
            } catch {
                print("JSON parsing error for new exchange rates: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }

    func convert(amount: Double, from: String, to: String, rates: [String: Double]) -> Double? {
        guard let fromRate = rates[from], let toRate = rates[to] else {
            print("Conversion failed: missing rates for \(from) or \(to)")
            return nil
        }
        let baseAmount = amount / fromRate
        let convertedAmount = baseAmount * toRate
        print("Converted \(amount) \(from) to \(convertedAmount) \(to)")
        return convertedAmount
    }
}


