//
//  PlayerTests.swift
//  chiptallyTests
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import Testing
@testable import chiptally

struct PlayerTests {
    
    @Test func testPlayerInitialization() async throws {
        let player = Player(name: "Test Player")
        
        #expect(player.name == "Test Player")
        #expect(player.buyIns == 1)
        #expect(player.totalCredits == 0)
        #expect(player.score == 0)
        #expect(player.id != UUID()) // Should have a unique ID
    }
    
    @Test func testPlayerInitializationWithCustomValues() async throws {
        let player = Player(name: "Custom Player", buyIns: 3, totalCredits: 600.0, score: 5)
        
        #expect(player.name == "Custom Player")
        #expect(player.buyIns == 3)
        #expect(player.totalCredits == 600.0)
        #expect(player.score == 5)
    }
    
    @Test func testPlayerIdentifiable() async throws {
        let player1 = Player(name: "Player 1")
        let player2 = Player(name: "Player 2")
        
        #expect(player1.id != player2.id)
    }
    
    @Test func testPlayerCodable() async throws {
        let originalPlayer = Player(name: "Codable Player", buyIns: 2, totalCredits: 400.0, score: 3)
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalPlayer)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedPlayer = try decoder.decode(Player.self, from: data)
        
        #expect(decodedPlayer.name == originalPlayer.name)
        #expect(decodedPlayer.buyIns == originalPlayer.buyIns)
        #expect(decodedPlayer.totalCredits == originalPlayer.totalCredits)
        #expect(decodedPlayer.score == originalPlayer.score)
        // Note: UUID won't be the same after encoding/decoding
    }
}
