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

    @Test func testNewGameResetFlow() async throws {
        let gameManager = GameManager()

        // Simulate a complete game flow
        gameManager.numberOfPlayers = 3
        gameManager.creditsPerBuyIn = 300.0
        gameManager.updateTotalPotCredits()
        gameManager.generateDefaultPlayers()

        // Modify game state (simulate gameplay)
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 500.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[1].id, newCredits: 400.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[2].id, newCredits: 500.0)
        gameManager.updatePlayerScore(playerId: gameManager.players[0].id, newScore: 5)

        // Verify modified state
        #expect(gameManager.players.count == 3)
        #expect(gameManager.numberOfPlayers == 3)
        #expect(gameManager.creditsPerBuyIn == 300.0)
        #expect(gameManager.totalPotCredits == 900.0)
        #expect(gameManager.players[0].totalCredits == 500.0)
        #expect(gameManager.players[0].score == 5)

        // Simulate "New Game" button click
        gameManager.resetGame()

        // Verify complete reset to defaults
        #expect(gameManager.players.isEmpty)
        #expect(gameManager.numberOfPlayers == 5)
        #expect(gameManager.creditsPerBuyIn == 200.0)
        #expect(gameManager.totalPotCredits == 1000.0)
        #expect(gameManager.getTotalPotInCredits() == 0.0)
    }

    @Test func testFavoriteGroupsInitialization() async throws {
        let gameManager = GameManager()

        // Verify default favorite groups are loaded
        #expect(gameManager.favoriteGroups.count == 2)
        #expect(gameManager.favoriteGroups[0].name == "Weekend Warriors")
        #expect(gameManager.favoriteGroups[0].playerNames.count == 4)
        #expect(gameManager.favoriteGroups[1].name == "Poker Pros")
        #expect(gameManager.favoriteGroups[1].playerNames.count == 6)
    }

    @Test func testLoadPlayersFromGroup() async throws {
        let gameManager = GameManager()
        let testGroup = PlayerGroup(name: "Test Group", playerNames: ["Alice", "Bob", "Charlie"])

        // Load players from group
        gameManager.loadPlayersFromGroup(testGroup)

        // Verify players are loaded correctly
        #expect(gameManager.players.count == 3)
        #expect(gameManager.numberOfPlayers == 3)
        #expect(gameManager.players[0].name == "Alice")
        #expect(gameManager.players[1].name == "Bob")
        #expect(gameManager.players[2].name == "Charlie")

        // Verify each player has correct initial credits
        for player in gameManager.players {
            #expect(player.buyIns == 1)
            #expect(player.totalCredits == gameManager.creditsPerBuyIn)
            #expect(player.score == 0)
        }
    }

    @Test func testAddAndRemoveFavoriteGroups() async throws {
        let gameManager = GameManager()
        let initialCount = gameManager.favoriteGroups.count

        // Add new group
        let newGroup = PlayerGroup(name: "New Group", playerNames: ["Player1", "Player2"])
        gameManager.addFavoriteGroup(newGroup)

        #expect(gameManager.favoriteGroups.count == initialCount + 1)
        #expect(gameManager.favoriteGroups.last?.name == "New Group")

        // Remove group
        gameManager.removeFavoriteGroup(at: gameManager.favoriteGroups.count - 1)
        #expect(gameManager.favoriteGroups.count == initialCount)
    }

    @Test func testSaveCurrentPlayersAsGroup() async throws {
        let gameManager = GameManager()

        // Add some players
        gameManager.addPlayer(name: "Test Player 1")
        gameManager.addPlayer(name: "Test Player 2")
        gameManager.addPlayer(name: "Test Player 3")

        let initialGroupCount = gameManager.favoriteGroups.count

        // Save current players as group
        gameManager.saveCurrentPlayersAsGroup(name: "Current Game Group")

        // Verify group was saved
        #expect(gameManager.favoriteGroups.count == initialGroupCount + 1)
        let savedGroup = gameManager.favoriteGroups.last!
        #expect(savedGroup.name == "Current Game Group")
        #expect(savedGroup.playerNames.count == 3)
        #expect(savedGroup.playerNames.contains("Test Player 1"))
        #expect(savedGroup.playerNames.contains("Test Player 2"))
        #expect(savedGroup.playerNames.contains("Test Player 3"))
    }

    @Test func testUpdateFavoriteGroup() async throws {
        let gameManager = GameManager()
        let originalGroup = gameManager.favoriteGroups[0] // Weekend Warriors

        // Create updated group
        let updatedGroup = PlayerGroup(name: "Updated Weekend Crew", playerNames: ["NewPlayer1", "NewPlayer2", "NewPlayer3", "NewPlayer4"])

        // Update the group
        gameManager.updateFavoriteGroup(at: 0, with: updatedGroup)

        // Verify the group was updated
        #expect(gameManager.favoriteGroups[0].name == "Updated Weekend Crew")
        #expect(gameManager.favoriteGroups[0].playerNames.count == 4)
        #expect(gameManager.favoriteGroups[0].playerNames.contains("NewPlayer1"))
        #expect(gameManager.favoriteGroups[0].playerNames.contains("NewPlayer4"))

        // Verify other groups weren't affected
        #expect(gameManager.favoriteGroups[1].name == "Poker Pros")
    }

    @Test func testDeleteDefaultFavoriteGroups() async throws {
        let gameManager = GameManager()
        let initialCount = gameManager.favoriteGroups.count

        // Delete first default group (Weekend Warriors)
        gameManager.removeFavoriteGroup(at: 0)

        // Verify group was removed
        #expect(gameManager.favoriteGroups.count == initialCount - 1)
        #expect(gameManager.favoriteGroups[0].name == "Poker Pros") // Should be first now

        // Delete another group
        gameManager.removeFavoriteGroup(at: 0)

        // Verify second group was removed
        #expect(gameManager.favoriteGroups.count == initialCount - 2)
        #expect(gameManager.favoriteGroups.isEmpty) // Should be empty now
    }

    @Test func testGroupSelectionAndGameStart() async throws {
        let gameManager = GameManager()

        // Initially no players should be loaded
        #expect(gameManager.players.isEmpty)

        // Select and load the first group (Weekend Warriors)
        let selectedGroup = gameManager.favoriteGroups[0]
        gameManager.loadPlayersFromGroup(selectedGroup)

        // Verify players are loaded from the selected group
        #expect(gameManager.players.count == 4)
        #expect(gameManager.numberOfPlayers == 4)
        #expect(gameManager.players[0].name == "Morgan")
        #expect(gameManager.players[1].name == "Riley")
        #expect(gameManager.players[2].name == "Avery")
        #expect(gameManager.players[3].name == "Quinn")

        // Verify each player has correct initial setup
        for player in gameManager.players {
            #expect(player.buyIns == 1)
            #expect(player.totalCredits == gameManager.creditsPerBuyIn)
            #expect(player.score == 0)
        }

        // Test selecting a different group
        let secondGroup = gameManager.favoriteGroups[1] // Poker Pros
        gameManager.loadPlayersFromGroup(secondGroup)

        // Verify new group is loaded
        #expect(gameManager.players.count == 6)
        #expect(gameManager.numberOfPlayers == 6)
        #expect(gameManager.players[0].name == "Blake")
        #expect(gameManager.players[1].name == "Cameron")
        #expect(gameManager.players[2].name == "Drew")
        #expect(gameManager.players[3].name == "Emery")
        #expect(gameManager.players[4].name == "Finley")
        #expect(gameManager.players[5].name == "Harper")
    }
}
