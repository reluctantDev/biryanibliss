//
//  ValidationTests.swift
//  chiptallyTests
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import Testing
@testable import chiptally

struct ValidationTests {
    
    @Test func testGameEndValidation() async throws {
        let gameManager = GameManager()
        gameManager.totalPotCredits = 1000.0
        
        // Add 3 players
        gameManager.addPlayer(name: "Player 1")
        gameManager.addPlayer(name: "Player 2")
        gameManager.addPlayer(name: "Player 3")
        
        // Test case 1: Credits match exactly
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 400.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[1].id, newCredits: 350.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[2].id, newCredits: 250.0)
        
        let totalCredits = gameManager.getTotalPotInCredits()
        #expect(totalCredits == 1000.0)
        #expect(abs(totalCredits - gameManager.totalPotCredits) < 0.01)
        
        // Test case 2: Credits don't match
        gameManager.updatePlayerCredits(playerId: gameManager.players[2].id, newCredits: 300.0)
        let newTotalCredits = gameManager.getTotalPotInCredits()
        #expect(newTotalCredits == 1050.0)
        #expect(abs(newTotalCredits - gameManager.totalPotCredits) > 0.01)
    }
    
    @Test func testPlayerCountValidation() async throws {
        let gameManager = GameManager()
        
        // Test minimum players
        gameManager.numberOfPlayers = 1
        #expect(gameManager.numberOfPlayers >= 1)
        
        // Test maximum players
        gameManager.numberOfPlayers = 12
        #expect(gameManager.numberOfPlayers <= 12)
        
        // Test that creditsPerPlayer calculation handles edge cases
        gameManager.numberOfPlayers = 0
        #expect(gameManager.creditsPerPlayer == 0.0)
        
        gameManager.numberOfPlayers = 1
        gameManager.totalPotCredits = 1000.0
        #expect(gameManager.creditsPerPlayer == 1000.0)
    }
    
    @Test func testCreditValidation() async throws {
        let gameManager = GameManager()
        
        // Test zero credits
        gameManager.creditsPerBuyIn = 0.0
        gameManager.addPlayer(name: "Zero Player")
        #expect(gameManager.players[0].totalCredits == 0.0)
        
        // Test negative credits (should be handled gracefully)
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: -100.0)
        #expect(gameManager.players[0].totalCredits == -100.0) // App should handle this
        
        // Test very large credits
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 999999.0)
        #expect(gameManager.players[0].totalCredits == 999999.0)
    }
    
    @Test func testBuyInValidation() async throws {
        let gameManager = GameManager()
        gameManager.creditsPerBuyIn = 200.0
        gameManager.addPlayer(name: "Test Player")
        let playerId = gameManager.players[0].id
        
        // Test minimum buy-ins
        gameManager.updatePlayerBuyIns(playerId: playerId, newBuyIns: 1)
        #expect(gameManager.players[0].buyIns == 1)
        #expect(gameManager.players[0].totalCredits == 200.0)
        
        // Test multiple buy-ins
        gameManager.updatePlayerBuyIns(playerId: playerId, newBuyIns: 5)
        #expect(gameManager.players[0].buyIns == 5)
        #expect(gameManager.players[0].totalCredits == 1000.0)
        
        // Test zero buy-ins (edge case)
        gameManager.updatePlayerBuyIns(playerId: playerId, newBuyIns: 0)
        #expect(gameManager.players[0].buyIns == 0)
        #expect(gameManager.players[0].totalCredits == 0.0)
    }
    
    @Test func testNameValidation() async throws {
        let gameManager = GameManager()

        // Test normal names
        let (success1, _) = gameManager.addPlayer(name: "Normal Player")
        #expect(success1 == true)
        #expect(gameManager.players[0].name == "Normal Player")

        // Test empty name
        let (success2, reason2) = gameManager.addPlayer(name: "")
        #expect(success2 == false)
        #expect(reason2?.contains("Please enter a player name") == true)

        // Test short name
        let (success3, reason3) = gameManager.addPlayer(name: "A")
        #expect(success3 == false)
        #expect(reason3?.contains("must be at least 2 characters") == true)

        // Test very long name
        let longName = String(repeating: "A", count: 100)
        let (success4, _) = gameManager.addPlayer(name: longName)
        #expect(success4 == true)
        #expect(gameManager.players[1].name == longName)

        // Test special characters
        let (success5, _) = gameManager.addPlayer(name: "Player@#$%")
        #expect(success5 == true)
        #expect(gameManager.players[2].name == "Player@#$%")

        // Test unicode characters
        let (success6, _) = gameManager.addPlayer(name: "玩家1")
        #expect(success6 == true)
        #expect(gameManager.players[3].name == "玩家1")

        // Test duplicate in same game
        let (success7, reason7) = gameManager.addPlayer(name: "Normal Player")
        #expect(success7 == false)
        #expect(reason7?.contains("already exists in the current game") == true)
    }

    @Test func testCrossSessionPlayerUniqueness() async throws {
        let gameManager = GameManager()

        // Create first game session with players
        let (success1, _) = gameManager.addPlayer(name: "Alice")
        let (success2, _) = gameManager.addPlayer(name: "Bob")
        #expect(success1 == true)
        #expect(success2 == true)

        // Start game and create session
        gameManager.startGame()
        let session1 = gameManager.createGameSession()
        #expect(session1 != nil)

        // Reset for new game
        gameManager.resetGame()

        // Try to add Alice to new game - should fail
        let (success3, reason3) = gameManager.addPlayer(name: "Alice")
        #expect(success3 == false)
        #expect(reason3?.contains("already playing") == true)

        // Try to add Bob to new game - should fail
        let (success4, reason4) = gameManager.addPlayer(name: "Bob")
        #expect(success4 == false)
        #expect(reason4?.contains("already playing") == true)

        // Add different player - should succeed
        let (success5, _) = gameManager.addPlayer(name: "Charlie")
        #expect(success5 == true)

        // Complete the first session
        if let sessionId = session1?.id {
            gameManager.completeGameSession(sessionId)
        }

        // Now Alice should be available again
        gameManager.resetGame()
        let (success6, _) = gameManager.addPlayer(name: "Alice")
        #expect(success6 == true)
    }

    @Test func testGroupLoadingWithConflicts() async throws {
        let gameManager = GameManager()

        // Create a group with players
        let group = PlayerGroup(name: "Test Group", playerNames: ["Alice", "Bob", "Charlie"])
        gameManager.addFavoriteGroup(group)

        // Load the group initially - should succeed
        let (success1, conflictingPlayers1) = gameManager.loadPlayersFromGroup(group)
        #expect(success1 == true)
        #expect(conflictingPlayers1.isEmpty == true)
        #expect(gameManager.players.count == 3)

        // Start game and create session
        gameManager.startGame()
        let session = gameManager.createGameSession()
        #expect(session != nil)

        // Reset for new game
        gameManager.resetGame()

        // Try to load same group again - should fail due to conflicts
        let (success2, conflictingPlayers2) = gameManager.loadPlayersFromGroup(group)
        #expect(success2 == false)
        #expect(conflictingPlayers2.count == 3)
        #expect(conflictingPlayers2.contains("Alice") == true)
        #expect(conflictingPlayers2.contains("Bob") == true)
        #expect(conflictingPlayers2.contains("Charlie") == true)

        // Players should not be loaded
        #expect(gameManager.players.isEmpty == true)
    }

    @Test func testCaseInsensitivePlayerNameConflicts() async throws {
        let gameManager = GameManager()

        // Add player with specific case
        let (success1, _) = gameManager.addPlayer(name: "Alice")
        #expect(success1 == true)

        // Create session
        gameManager.startGame()
        let session = gameManager.createGameSession()
        #expect(session != nil)

        // Reset for new game
        gameManager.resetGame()

        // Try to add same player with different case - should fail
        let (success2, reason2) = gameManager.addPlayer(name: "ALICE")
        #expect(success2 == false)
        #expect(reason2?.contains("already playing") == true)

        let (success3, reason3) = gameManager.addPlayer(name: "alice")
        #expect(success3 == false)
        #expect(reason3?.contains("already playing") == true)

        let (success4, reason4) = gameManager.addPlayer(name: "AlIcE")
        #expect(success4 == false)
        #expect(reason4?.contains("already playing") == true)
    }
    
    @Test func testScoreValidation() async throws {
        let gameManager = GameManager()
        gameManager.addPlayer(name: "Test Player")
        let playerId = gameManager.players[0].id
        
        // Test positive scores
        gameManager.updatePlayerScore(playerId: playerId, newScore: 10)
        #expect(gameManager.players[0].score == 10)
        
        // Test zero score
        gameManager.updatePlayerScore(playerId: playerId, newScore: 0)
        #expect(gameManager.players[0].score == 0)
        
        // Test negative scores
        gameManager.updatePlayerScore(playerId: playerId, newScore: -5)
        #expect(gameManager.players[0].score == -5)
        
        // Test very large scores
        gameManager.updatePlayerScore(playerId: playerId, newScore: 999999)
        #expect(gameManager.players[0].score == 999999)
    }
    
    @Test func testDataConsistency() async throws {
        let gameManager = GameManager()
        
        // Test that total pot credits always equals numberOfPlayers * creditsPerBuyIn
        gameManager.numberOfPlayers = 5
        gameManager.creditsPerBuyIn = 200.0
        gameManager.updateTotalPotCredits()
        #expect(gameManager.totalPotCredits == 1000.0)
        
        // Change players and verify consistency
        gameManager.numberOfPlayers = 8
        gameManager.updateTotalPotCredits()
        #expect(gameManager.totalPotCredits == 1600.0)
        
        // Change credits per buy-in and verify consistency
        gameManager.creditsPerBuyIn = 150.0
        gameManager.updateTotalPotCredits()
        #expect(gameManager.totalPotCredits == 1200.0)
    }
    
    @Test func testPlayerRemovalValidation() async throws {
        let gameManager = GameManager()

        // Add players
        let (success1, _) = gameManager.addPlayer(name: "Player 1")
        let (success2, _) = gameManager.addPlayer(name: "Player 2")
        let (success3, _) = gameManager.addPlayer(name: "Player 3")

        #expect(success1 == true)
        #expect(success2 == true)
        #expect(success3 == true)
        #expect(gameManager.players.count == 3)
        
        // Remove middle player
        gameManager.removePlayer(at: 1)
        #expect(gameManager.players.count == 2)
        #expect(gameManager.players[0].name == "Player 1")
        #expect(gameManager.players[1].name == "Player 3")
        
        // Remove all players
        gameManager.removePlayer(at: 1)
        gameManager.removePlayer(at: 0)
        #expect(gameManager.players.isEmpty)
        #expect(gameManager.getTotalPotInCredits() == 0.0)
    }
    
    @Test func testFloatingPointPrecision() async throws {
        let gameManager = GameManager()
        
        // Test floating point calculations
        gameManager.creditsPerBuyIn = 333.33
        gameManager.numberOfPlayers = 3
        gameManager.updateTotalPotCredits()
        
        // Should handle floating point precision correctly
        let expectedTotal = 333.33 * 3
        #expect(abs(gameManager.totalPotCredits - expectedTotal) < 0.01)
        
        // Test with player credits
        gameManager.addPlayer(name: "Test Player")
        let playerId = gameManager.players[0].id
        gameManager.updatePlayerCredits(playerId: playerId, newCredits: 333.33)
        
        #expect(abs(gameManager.players[0].totalCredits - 333.33) < 0.01)
    }
}
