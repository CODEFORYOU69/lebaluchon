//
//  translate.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 14/05/2024.
//

import Foundation
struct TranslationResponse: Codable {
    struct Data: Codable {
        var translations: [Translation]
    }
    struct Translation: Codable {
        var translatedText: String
    }
    var data: Data
}
