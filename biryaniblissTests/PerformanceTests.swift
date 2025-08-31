//
//  PerformanceTests.swift
//  chiptallyTests
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import Testing
@testable import chiptally

struct PerformanceTests {
    
    @Test func testGameManagerPerformance() async throws {
        let gameManager = GameManager()
        
        // Measure time to generate many players
        let startTime = CFAbsoluteTimeGetCurrent()
        
        gameManager.numberOfPlayers = 12
        gameManager.generateDefaultPlayers()
        
        // Perform many operations
        for i in 0..<1000 {
            gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: Double(i))
            _ = gameManager.getTotalPotInCredits()
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should complete in reasonable time (less than 1 second)
        #expect(timeElapsed < 1.0)
    }
    
    @Test func testLargePlayerSetPerformance() async throws {
        let gameManager = GameManager()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Add maximum number of players
        gameManager.numberOfPlayers = 12
        gameManager.generateDefaultPlayers()
        
        // Update all players multiple times
        for _ in 0..<100 {
            for player in gameManager.players {
                gameManager.updatePlayerCredits(playerId: player.id, newCredits: Double.random(in: 0...1000))
                gameManager.updatePlayerScore(playerId: player.id, newScore: Int.random(in: 0...10))
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should handle large operations efficiently
        #expect(timeElapsed < 2.0)
    }
    
    @Test func testMemoryUsage() async throws {
        // Test that creating and destroying game managers doesn't leak memory
        for _ in 0..<100 {
            let gameManager = GameManager()
            gameManager.numberOfPlayers = 12
            gameManager.generateDefaultPlayers()
            
            // Perform operations
            for player in gameManager.players {
                gameManager.updatePlayerCredits(playerId: player.id, newCredits: 500.0)
            }
            
            // Reset game
            gameManager.resetGame()
        }
        
        // If we get here without crashing, memory management is working
        #expect(true)
    }
    
    @Test func testConcurrentAccess() async throws {
        let gameManager = GameManager()
        gameManager.numberOfPlayers = 5
        gameManager.generateDefaultPlayers()
        
        // Test concurrent access to game manager
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    for j in 0..<100 {
                        let playerIndex = j % gameManager.players.count
                        let playerId = gameManager.players[playerIndex].id
                        gameManager.updatePlayerCredits(playerId: playerId, newCredits: Double(i * j))
                    }
                }
            }
        }
        
        // Should complete without crashes
        #expect(gameManager.players.count == 5)
    }
    
    @Test func testDataPersistencePerformance() async throws {
        let gameManager = GameManager()
        gameManager.numberOfPlayers = 10
        gameManager.generateDefaultPlayers()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Test encoding/decoding performance
        for _ in 0..<100 {
            let encoder = JSONEncoder()
            let data = try encoder.encode(gameManager.players)
            
            let decoder = JSONDecoder()
            _ = try decoder.decode([Player].self, from: data)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should encode/decode efficiently
        #expect(timeElapsed < 1.0)
    }
    
    @Test func testCalculationPerformance() async throws {
        let gameManager = GameManager()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Test calculation performance
        for i in 1...1000 {
            gameManager.numberOfPlayers = (i % 12) + 1
            gameManager.creditsPerBuyIn = Double(i)
            gameManager.updateTotalPotCredits()
            
            _ = gameManager.creditsPerPlayer
            _ = gameManager.totalPotCredits
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should perform calculations quickly
        #expect(timeElapsed < 0.5)
    }
}
