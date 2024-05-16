//
//  TranslationServiceTests.swift
//  Le_BaluchonTests
//
//  Created by younes ouasmi on 17/05/2024.
//

import XCTest
@testable import Le_Baluchon

class TranslationServiceTests: XCTestCase {
    func loadMockData(fileName: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: url)
    }

    func testTranslate() {
        let jsonData = loadMockData(fileName: "MockTranslationResponse")
        let decoder = JSONDecoder()
        let response = try! decoder.decode(TranslationResponse.self, from: jsonData)
        
        XCTAssertEqual(response.data.translations.first?.translatedText, "Bonjour")
    }

    func testDetectLanguage() {
        let jsonData = loadMockData(fileName: "MockDetectionResponse")
        let decoder = JSONDecoder()
        let response = try! decoder.decode(DetectionResponse.self, from: jsonData)
        
        XCTAssertEqual(response.data.detections.first?.first?.language, "en")
    }


}
