//
//  GameLogicTests.swift
//  chiptallyTests
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import Testing
@testable import chiptally

struct GameLogicTests {
    
    @Test func testCreditsPerPlayerCalculation() async throws {
        let gameManager = GameManager()
        gameManager.totalPotCredits = 1000.0
        gameManager.numberOfPlayers = 5
        
        #expect(gameManager.creditsPerPlayer == 200.0)
        
        gameManager.numberOfPlayers = 4
        #expect(gameManager.creditsPerPlayer == 250.0)
        
        gameManager.numberOfPlayers = 0
        #expect(gameManager.creditsPerPlayer == 0.0)
    }
    
    @Test func testGameSetupValidation() async throws {
        let gameManager = GameManager()
        
        // Test minimum players
        gameManager.numberOfPlayers = 1
        #expect(gameManager.numberOfPlayers >= 1)
        
        // Test maximum players
        gameManager.numberOfPlayers = 12
        #expect(gameManager.numberOfPlayers <= 12)
        
        // Test credits per buy-in
        gameManager.creditsPerBuyIn = 100.0
        #expect(gameManager.creditsPerBuyIn > 0)
    }
    
    @Test func testMultipleBuyInsCalculation() async throws {
        let gameManager = GameManager()
        gameManager.creditsPerBuyIn = 200.0
        gameManager.addPlayer(name: "Test Player")
        let playerId = gameManager.players[0].id
        
        // Test 1 buy-in
        gameManager.updatePlayerBuyIns(playerId: playerId, newBuyIns: 1)
        #expect(gameManager.players[0].totalCredits == 200.0)
        
        // Test 3 buy-ins
        gameManager.updatePlayerBuyIns(playerId: playerId, newBuyIns: 3)
        #expect(gameManager.players[0].totalCredits == 600.0)
        
        // Test 5 buy-ins
        gameManager.updatePlayerBuyIns(playerId: playerId, newBuyIns: 5)
        #expect(gameManager.players[0].totalCredits == 1000.0)
    }
    
    @Test func testGameEndValidation() async throws {
        let gameManager = GameManager()
        gameManager.totalPotCredits = 1000.0
        
        // Add players
        gameManager.addPlayer(name: "Player 1")
        gameManager.addPlayer(name: "Player 2")
        gameManager.addPlayer(name: "Player 3")
        
        // Set final credits that match total pot
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 400.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[1].id, newCredits: 350.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[2].id, newCredits: 250.0)
        
        let totalCredits = gameManager.getTotalPotInCredits()
        #expect(totalCredits == 1000.0)
        #expect(abs(totalCredits - gameManager.totalPotCredits) < 0.01)
    }
    
    @Test func testGameEndValidationMismatch() async throws {
        let gameManager = GameManager()
        gameManager.totalPotCredits = 1000.0
        
        // Add players
        gameManager.addPlayer(name: "Player 1")
        gameManager.addPlayer(name: "Player 2")
        
        // Set final credits that don't match total pot
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 400.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[1].id, newCredits: 500.0)
        
        let totalCredits = gameManager.getTotalPotInCredits()
        #expect(totalCredits == 900.0)
        #expect(abs(totalCredits - gameManager.totalPotCredits) > 0.01)
    }
    
    @Test func testPlayerRanking() async throws {
        let gameManager = GameManager()
        
        // Add players with different credit amounts
        gameManager.addPlayer(name: "Player 1")
        gameManager.addPlayer(name: "Player 2")
        gameManager.addPlayer(name: "Player 3")
        
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 300.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[1].id, newCredits: 500.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[2].id, newCredits: 200.0)
        
        let sortedPlayers = gameManager.players.sorted { $0.totalCredits > $1.totalCredits }
        
        #expect(sortedPlayers[0].name == "Player 2") // Highest credits
        #expect(sortedPlayers[1].name == "Player 1") // Middle credits
        #expect(sortedPlayers[2].name == "Player 3") // Lowest credits
        
        #expect(sortedPlayers[0].totalCredits == 500.0)
        #expect(sortedPlayers[1].totalCredits == 300.0)
        #expect(sortedPlayers[2].totalCredits == 200.0)
    }
    
    @Test func testProfitLossCalculation() async throws {
        let gameManager = GameManager()
        gameManager.creditsPerBuyIn = 200.0
        
        gameManager.addPlayer(name: "Winner")
        gameManager.addPlayer(name: "Loser")
        
        // Winner: bought in for 200, ended with 350 = +150 profit
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 350.0)
        let winnerProfit = gameManager.players[0].totalCredits - (gameManager.creditsPerBuyIn * Double(gameManager.players[0].buyIns))
        #expect(winnerProfit == 150.0)
        
        // Loser: bought in for 200, ended with 50 = -150 loss
        gameManager.updatePlayerCredits(playerId: gameManager.players[1].id, newCredits: 50.0)
        let loserProfit = gameManager.players[1].totalCredits - (gameManager.creditsPerBuyIn * Double(gameManager.players[1].buyIns))
        #expect(loserProfit == -150.0)
    }
    
    @Test func testEdgeCases() async throws {
        let gameManager = GameManager()
        
        // Test with zero credits
        gameManager.creditsPerBuyIn = 0.0
        gameManager.addPlayer(name: "Zero Player")
        #expect(gameManager.players[0].totalCredits == 0.0)
        
        // Test with very large numbers
        gameManager.creditsPerBuyIn = 999999.0
        gameManager.addPlayer(name: "Rich Player")
        #expect(gameManager.players[1].totalCredits == 999999.0)
        
        // Test removing all players
        gameManager.removePlayer(at: 1)
        gameManager.removePlayer(at: 0)
        #expect(gameManager.players.isEmpty)
        #expect(gameManager.getTotalPotInCredits() == 0.0)
    }
}
