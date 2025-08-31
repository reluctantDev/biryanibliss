//
//  chiptallyTests.swift
//  chiptallyTests
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import Testing
@testable import chiptally

struct chiptallyTests {

    // MARK: - GameManager Tests

    @Test func testGameManagerInitialization() async throws {
        let gameManager = GameManager()

        #expect(gameManager.numberOfPlayers == 5)
        #expect(gameManager.creditsPerBuyIn == 200.0)
        #expect(gameManager.totalPotCredits == 1000.0)
        #expect(gameManager.players.isEmpty)
    }

    @Test func testUpdateTotalPotCredits() async throws {
        let gameManager = GameManager()
        gameManager.numberOfPlayers = 4
        gameManager.creditsPerBuyIn = 250.0
        gameManager.updateTotalPotCredits()

        #expect(gameManager.totalPotCredits == 1000.0) // 4 * 250
    }

    @Test func testUpdateCreditsPerBuyIn() async throws {
        let gameManager = GameManager()
        gameManager.totalPotCredits = 1200.0
        gameManager.numberOfPlayers = 6
        gameManager.updateCreditsPerBuyIn()

        #expect(gameManager.creditsPerBuyIn == 200.0) // 1200 / 6
    }

    @Test func testGenerateDefaultPlayers() async throws {
        let gameManager = GameManager()
        gameManager.numberOfPlayers = 3
        gameManager.creditsPerBuyIn = 300.0
        gameManager.generateDefaultPlayers()

        #expect(gameManager.players.count == 3)
        #expect(gameManager.players[0].name == "Player 1")
        #expect(gameManager.players[0].buyIns == 1)
        #expect(gameManager.players[0].totalCredits == 300.0)
        #expect(gameManager.players[0].score == 0)
    }

    @Test func testAddPlayer() async throws {
        let gameManager = GameManager()
        gameManager.creditsPerBuyIn = 200.0
        gameManager.addPlayer(name: "Test Player")

        #expect(gameManager.players.count == 1)
        #expect(gameManager.players[0].name == "Test Player")
        #expect(gameManager.players[0].totalCredits == 200.0)
    }

    @Test func testRemovePlayer() async throws {
        let gameManager = GameManager()
        gameManager.addPlayer(name: "Player 1")
        gameManager.addPlayer(name: "Player 2")

        gameManager.removePlayer(at: 0)

        #expect(gameManager.players.count == 1)
        #expect(gameManager.players[0].name == "Player 2")
    }

    @Test func testUpdatePlayerName() async throws {
        let gameManager = GameManager()
        gameManager.addPlayer(name: "Old Name")
        let playerId = gameManager.players[0].id

        gameManager.updatePlayerName(playerId: playerId, newName: "New Name")

        #expect(gameManager.players[0].name == "New Name")
    }

    @Test func testUpdatePlayerBuyIns() async throws {
        let gameManager = GameManager()
        gameManager.creditsPerBuyIn = 200.0
        gameManager.addPlayer(name: "Test Player")
        let playerId = gameManager.players[0].id

        gameManager.updatePlayerBuyIns(playerId: playerId, newBuyIns: 3)

        #expect(gameManager.players[0].buyIns == 3)
        #expect(gameManager.players[0].totalCredits == 600.0) // 3 * 200
    }

    @Test func testUpdatePlayerCredits() async throws {
        let gameManager = GameManager()
        gameManager.addPlayer(name: "Test Player")
        let playerId = gameManager.players[0].id

        gameManager.updatePlayerCredits(playerId: playerId, newCredits: 500.0)

        #expect(gameManager.players[0].totalCredits == 500.0)
    }

    @Test func testUpdatePlayerScore() async throws {
        let gameManager = GameManager()
        gameManager.addPlayer(name: "Test Player")
        let playerId = gameManager.players[0].id

        gameManager.updatePlayerScore(playerId: playerId, newScore: 10)

        #expect(gameManager.players[0].score == 10)
    }

    @Test func testGetTotalPotInCredits() async throws {
        let gameManager = GameManager()
        gameManager.addPlayer(name: "Player 1")
        gameManager.addPlayer(name: "Player 2")
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 300.0)
        gameManager.updatePlayerCredits(playerId: gameManager.players[1].id, newCredits: 700.0)

        #expect(gameManager.getTotalPotInCredits() == 1000.0)
    }

    @Test func testResetGame() async throws {
        let gameManager = GameManager()
        gameManager.addPlayer(name: "Test Player")
        gameManager.numberOfPlayers = 3
        gameManager.creditsPerBuyIn = 300.0

        gameManager.resetGame()

        #expect(gameManager.players.isEmpty)
        #expect(gameManager.numberOfPlayers == 5)
        #expect(gameManager.creditsPerBuyIn == 200.0)
        #expect(gameManager.totalPotCredits == 1000.0)
    }

    @Test func testStartNewGameWithSameSettings() async throws {
        let gameManager = GameManager()
        gameManager.creditsPerBuyIn = 250.0
        gameManager.numberOfPlayers = 4
        gameManager.addPlayer(name: "Player 1")
        gameManager.addPlayer(name: "Player 2")
        gameManager.updatePlayerCredits(playerId: gameManager.players[0].id, newCredits: 500.0)
        gameManager.updatePlayerScore(playerId: gameManager.players[0].id, newScore: 5)

        gameManager.startNewGameWithSameSettings()

        #expect(gameManager.creditsPerBuyIn == 250.0)
        #expect(gameManager.numberOfPlayers == 4)
        #expect(gameManager.players[0].totalCredits == 250.0) // Reset to initial
        #expect(gameManager.players[0].score == 0) // Reset score
    }
}
