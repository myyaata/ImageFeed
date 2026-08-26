//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by арина сильченко on 30.05.26.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["UITestingResetAuth"]
        app.launch()
    }
    
    private func authenticate() {
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5))
        authenticateButton.tap()
        let topRight = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.25))
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("email")
        topRight.tap()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        typeSlowly("password", into: passwordTextField)
        topRight.tap()
        
        sleep(1) // вынужденный костыль чтобы не нажималась кнопка пока не скроется клавиатура
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        XCTAssertTrue(loginButton.isHittable)
        loginButton.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
    }

    private func typeSlowly(_ text: String, into element: XCUIElement) {
        for character in text {
            element.typeText(String(character))
            usleep(50000) // 50ms задержка между символами
        }
    }
    
    @MainActor
    func testAuth() throws {
        authenticate()
    }
    
    @MainActor
    func testFeed() throws {
        authenticate()
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        let startCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
        let endCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4))
        startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        
        let likeOffButton = cellToLike.buttons["like button off"]
        XCTAssertTrue(likeOffButton.waitForExistence(timeout: 5))
        likeOffButton.tap()

        sleep(2)
        
        let likeOnButton = cellToLike.buttons["like button on"]
        XCTAssertTrue(likeOnButton.waitForExistence(timeout: 5))
        likeOnButton.tap()
        sleep(1)
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["back button from single image view"]
        backButton.tap()
    }
    
    @MainActor
    func testProfile() throws {
        authenticate()
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssert(app.staticTexts["name lastname"].exists)
        XCTAssert(app.staticTexts["@username"].exists)

        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
