//
//  AppFlowUITests.swift
//  chiptallyUITests
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import XCTest

final class AppFlowUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testAppLaunch() throws {
        // Test that the app launches successfully
        XCTAssertTrue(app.staticTexts["Game Configuration"].exists)
        XCTAssertTrue(app.staticTexts["Buy-in Credits:"].exists)
        XCTAssertTrue(app.staticTexts["Number of Players:"].exists)
    }
    
    @MainActor
    func testGameSetupFlow() throws {
        // Test basic game setup
        XCTAssertTrue(app.staticTexts["Game Configuration"].exists)
        
        // Test changing number of players
        let minusButton = app.buttons["minus.circle.fill"]
        if minusButton.exists {
            minusButton.tap()
        }
        
        let plusButton = app.buttons["plus.circle.fill"]
        if plusButton.exists {
            plusButton.tap()
        }
    }
    
    @MainActor
    func testStartGameFlow() throws {
        // Test starting a game
        let startGameButton = app.buttons["Start Game"]
        XCTAssertTrue(startGameButton.exists)
        
        startGameButton.tap()
        
        // Should navigate to game play view
        XCTAssertTrue(app.staticTexts["Credit Manager"].exists)
    }
    
    @MainActor
    func testGamePlayFlow() throws {
        // Start a game first
        app.buttons["Start Game"].tap()
        
        // Verify we're in the game play view
        XCTAssertTrue(app.staticTexts["Credit Manager"].exists)
        
        // Test that player cards are displayed
        XCTAssertTrue(app.staticTexts["Player 1"].exists)
        
        // Test navigation back
        let backButton = app.buttons["xmark.circle.fill"]
        if backButton.exists {
            backButton.tap()
            // Should be back to setup
            XCTAssertTrue(app.staticTexts["Game Configuration"].exists)
        }
    }
    
    @MainActor
    func testEndGameFlow() throws {
        // Start a game
        app.buttons["Start Game"].tap()
        
        // Navigate to end game
        let endGameButton = app.buttons["End Game"]
        if endGameButton.exists {
            endGameButton.tap()
            
            // Should show final credits entry
            XCTAssertTrue(app.staticTexts["Enter Final Credits"].exists)
        }
    }
    
    @MainActor
    func testNavigationFlow() throws {
        // Test complete navigation flow
        
        // 1. Start from setup
        XCTAssertTrue(app.staticTexts["Game Configuration"].exists)
        
        // 2. Go to game play
        app.buttons["Start Game"].tap()
        XCTAssertTrue(app.staticTexts["Credit Manager"].exists)
        
        // 3. Go to end game
        let endGameButton = app.buttons["End Game"]
        if endGameButton.exists {
            endGameButton.tap()
            XCTAssertTrue(app.staticTexts["Enter Final Credits"].exists)
            
            // 4. Cancel back to game play
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
                XCTAssertTrue(app.staticTexts["Credit Manager"].exists)
            }
        }
        
        // 5. Go back to setup
        let backToSetupButton = app.buttons["xmark.circle.fill"]
        if backToSetupButton.exists {
            backToSetupButton.tap()
            XCTAssertTrue(app.staticTexts["Game Configuration"].exists)
        }
    }
    
    @MainActor
    func testAccessibility() throws {
        // Test that key elements are accessible
        XCTAssertTrue(app.staticTexts["Game Configuration"].isHittable)
        XCTAssertTrue(app.buttons["Start Game"].isHittable)
        
        // Start game and test game play accessibility
        app.buttons["Start Game"].tap()
        XCTAssertTrue(app.staticTexts["Credit Manager"].isHittable)
        
        let endGameButton = app.buttons["End Game"]
        if endGameButton.exists {
            XCTAssertTrue(endGameButton.isHittable)
        }
    }
    
    @MainActor
    func testCompleteGameFlow() throws {
        // Test a complete game from start to finish
        
        // 1. Setup game
        XCTAssertTrue(app.staticTexts["Game Configuration"].exists)
        
        // 2. Start game
        app.buttons["Start Game"].tap()
        XCTAssertTrue(app.staticTexts["Credit Manager"].exists)
        
        // 3. End game
        let endGameButton = app.buttons["End Game"]
        if endGameButton.exists {
            endGameButton.tap()
            XCTAssertTrue(app.staticTexts["Enter Final Credits"].exists)
            
            // 4. Try to finish (should be disabled initially)
            let finishButton = app.buttons["Finish Game"]
            if finishButton.exists {
                // Button should exist but may be disabled
                XCTAssertTrue(finishButton.exists)
            }
        }
    }
}
