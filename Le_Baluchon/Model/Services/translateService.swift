//
//  translateService.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 14/05/2024.
//

import Foundation

// Service class to handle translation-related tasks
class TranslationService {
    private let apiKey = "AIzaSyD_xlYOPWa53MDDMPtH6V7ruwCktK8GLaw"
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    // Function to translate text from one language to another
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://translation.googleapis.com/language/translate/v2"
        let parameters = [
            "q": text,
            "source": sourceLanguage,
            "target": targetLanguage,
            "format": "text",
            "key": apiKey
        ]
        
        // Construct URL with query parameters
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        // Make a network request to translate the text
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(TranslationError.noData))
                return
            }
            do {
                let responseDict = try JSONDecoder().decode(TranslationResponse.self, from: data)
                if let translatedText = responseDict.data.translations.first?.translatedText {
                    completion(.success(translatedText))
                } else {
                    completion(.failure(TranslationError.decodingError))
                }
            } catch {
                completion(.failure(TranslationError.decodingError))
            }
        }.resume()
    }
    
    // Function to detect the language of a given text
    func detectLanguage(for text: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://translation.googleapis.com/language/translate/v2/detect"
        let parameters = [
            "q": text,
            "key": apiKey
        ]
        
        // Construct URL with query parameters
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        // Make a network request to detect the language of the text
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(DetectionError.noData))
                return
            }
            do {
                let responseDict = try JSONDecoder().decode(DetectionResponse.self, from: data)
                if let detectedLanguage = responseDict.data.detections.first?.first?.language {
                    completion(.success(detectedLanguage))
                } else {
                    completion(.failure(DetectionError.decodingError))
                }
            } catch {
                completion(.failure(DetectionError.decodingError))
            }
        }.resume()
    }
    
    // Function to fetch the list of supported languages
    func fetchSupportedLanguages(targetLanguage: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        let url = "https://translation.googleapis.com/language/translate/v2/languages"
        let parameters = [
            "key": apiKey,
            "target": targetLanguage // Language in which the language names should be returned
        ]
        
        // Construct URL with query parameters
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        // Make a network request to fetch supported languages
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(TranslationError.noData))
                return
            }
            do {
                let responseDict = try JSONDecoder().decode(LanguagesResponse.self, from: data)
                var languages: [String: String] = [:]
                for language in responseDict.data.languages {
                    languages[language.language] = language.name
                }
                completion(.success(languages))
            } catch {
                completion(.failure(TranslationError.decodingError))
            }
        }.resume()
    }
}
