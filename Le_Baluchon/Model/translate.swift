//
//  translate.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 14/05/2024.
//

import Foundation

struct TranslationResponse: Codable {
    let data: TranslationData
}

struct TranslationData: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let translatedText: String
}

struct DetectionResponse: Codable {
    let data: DetectionData
}

struct DetectionData: Codable {
    let detections: [[Detection]]
}

struct Detection: Codable {
    let language: String
    let isReliable: Bool
    let confidence: Float
}

enum TranslationError: Error {
    case noData
    case decodingError
    case apiError(String)
}

enum DetectionError: Error {
    case noData
    case decodingError
    case apiError(String)
}
