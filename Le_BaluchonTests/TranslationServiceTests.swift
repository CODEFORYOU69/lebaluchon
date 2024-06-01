import XCTest
@testable import Le_Baluchon

class TranslationServiceTests: XCTestCase {
    
    var testURLSession: TestURLSession!
    var translationService: TranslationService.Type!

    override func setUp() {
        super.setUp()
        testURLSession = TestURLSession()
        translationService = TranslationService.self
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

        translationService.translate(text: "Hello", from: "en", to: "fr", session: testURLSession) { result in
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

        translationService.translate(text: "Hello", from: "en", to: "fr", session: testURLSession) { result in
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

        translationService.detectLanguage(for: "Hello", session: testURLSession) { result in
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

        translationService.detectLanguage(for: "Hello", session: testURLSession) { result in
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
