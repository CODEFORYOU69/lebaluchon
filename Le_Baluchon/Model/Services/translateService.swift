//
//  translateService.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 14/05/2024.
//

import Foundation



class TranslationService {
    static let apiKey = "AIzaSyD_xlYOPWa53MDDMPtH6V7ruwCktK8GLaw"
    
    static func translate(text: String, from sourceLanguage: String, to targetLanguage: String, session: URLSessionProtocol = URLSession.shared, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://translation.googleapis.com/language/translate/v2"
        let parameters = [
            "q": text,
            "source": sourceLanguage,
            "target": targetLanguage,
            "format": "text",
            "key": apiKey
        ]
        
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
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
    
    static func detectLanguage(for text: String, session: URLSessionProtocol = URLSession.shared, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://translation.googleapis.com/language/translate/v2/detect"
        let parameters = [
            "q": text,
            "key": apiKey
        ]
        
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
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
}
