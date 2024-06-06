import XCTest
@testable import Le_Baluchon

class TranslationServiceTests: XCTestCase {
    
    var testURLSession: TestURLSession!
    var translationService: TranslationService!

    override func setUp() {
        super.setUp()
        testURLSession = TestURLSession()
        translationService = TranslationService(session: testURLSession)
    }

    override func tearDown() {
        testURLSession = nil
        translationService = nil
        super.tearDown()
    }

    func testTranslateSuccess() {
        let expectation = self.expectation(description: "TranslationSuccess")
        let mockResponse = TranslationResponse(data: TranslationData(translations: [Translation(translatedText: "Bonjour")]))
        testURLSession.data = try? JSONEncoder().encode(mockResponse)

        translationService.translate(text: "Hello", from: "en", to: "fr") { result in
            switch result {
            case .success(let translatedText):
                XCTAssertEqual(translatedText, "Bonjour")
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testTranslateFailure() {
        let expectation = self.expectation(description: "TranslationFailure")
        testURLSession.error = NSError(domain: "TestError", code: 0, userInfo: nil)

        translationService.translate(text: "Hello", from: "en", to: "fr") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testDetectLanguageSuccess() {
        let expectation = self.expectation(description: "DetectionSuccess")
        let mockResponse = DetectionResponse(data: DetectionData(detections: [[Detection(language: "en", isReliable: true, confidence: 0.99)]]))
        testURLSession.data = try? JSONEncoder().encode(mockResponse)

        translationService.detectLanguage(for: "Hello") { result in
            switch result {
            case .success(let detectedLanguage):
                XCTAssertEqual(detectedLanguage, "en")
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testDetectLanguageFailure() {
        let expectation = self.expectation(description: "DetectionFailure")
        testURLSession.error = NSError(domain: "TestError", code: 0, userInfo: nil)

        translationService.detectLanguage(for: "Hello") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchSupportedLanguagesSuccess() {
        let expectation = self.expectation(description: "FetchLanguagesSuccess")
        let mockResponse = LanguagesResponse(data: LanguagesData(languages: [Language(language: "en", name: "English"), Language(language: "fr", name: "French")]))
        testURLSession.data = try? JSONEncoder().encode(mockResponse)

        translationService.fetchSupportedLanguages { result in
            switch result {
            case .success(let languages):
                XCTAssertEqual(languages["en"], "English")
                XCTAssertEqual(languages["fr"], "French")
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchSupportedLanguagesFailure() {
        let expectation = self.expectation(description: "FetchLanguagesFailure")
        testURLSession.error = NSError(domain: "TestError", code: 0, userInfo: nil)

        translationService.fetchSupportedLanguages { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
