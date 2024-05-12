//
//  CurrencyService.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 12/05/2024.
//

import Foundation

    class CurrencyConversionService {
        private let apiKey = "7d28069a0e2be3744db223ee0dcdcd14"
        private let baseUrl = "http://data.fixer.io/api/latest"
        private let userDefaults = UserDefaults.standard
        private let exchangeRatesKey = "exchangeRates"
        private let lastUpdateKey = "lastUpdate"

        let currencies: [Currency] = [
            Currency(code: "USD", country: "United States", flag: "us"),
            Currency(code: "EUR", country: "European Union", flag: "eu"),
            Currency(code: "GBP", country: "United Kingdom", flag: "gb"),
            Currency(code: "JPY", country: "Japan", flag: "jp"),
            Currency(code: "CAD", country: "Canada", flag: "ca"),
            // Ajoutez plus de devises selon vos besoins
        ]

        func fetchExchangeRates(for currencyCodes: [String], completion: @escaping ([String: Double]?) -> Void) {
            if let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date,
               let storedRates = userDefaults.object(forKey: exchangeRatesKey) as? [String: Double],
               Calendar.current.isDateInToday(lastUpdate),
               currencyCodes.allSatisfy({ storedRates.keys.contains($0) }) {
                print("Using cached exchange rates for required currencies.")
                completion(storedRates)
                return
            }

            // Si les devises requises ne sont pas toutes présentes ou les données ne sont pas récentes, faire un nouvel appel réseau
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

            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
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
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let rates = json["rates"] as? [String: Double] {
                        self?.userDefaults.set(rates, forKey: self?.exchangeRatesKey ?? "")
                        self?.userDefaults.set(Date(), forKey: self?.lastUpdateKey ?? "")
                        print("New exchange rates stored.")
                        completion(rates)
                    } else {
                        print("Failed to parse JSON for new exchange rates.")
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
