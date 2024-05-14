//
//  translateService.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 14/05/2024.
//

import Foundation

class TranslationService {
    static func translate(text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?, Error?) -> Void) {
      
        let url = "https://translation.googleapis.com/language/translate/v2"
        let parameters = [
            "q": text,
            "source": sourceLanguage,
            "target": targetLanguage,
            "format": "text",
            "key": "AIzaSyD_xlYOPWa53MDDMPtH6V7ruwCktK8GLaw",
        ]
        
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, NSError(domain: "TranslationError", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data received"]))
                return
            }
            if let responseDict = try? JSONDecoder().decode(TranslationResponse.self, from: data),
               let translatedTexts = responseDict.data.translations.first?.translatedText {
                completion(translatedTexts, nil)
            } else {
                completion(nil, NSError(domain: "TranslationError", code: 1, userInfo: [NSLocalizedDescriptionKey : "Failed to decode response"]))
            }
        }.resume()
    }
}
