import Foundation

struct Player: Identifiable, Codable {
    let id = UUID()
    var name: String
    var buyIns: Int
    var totalCredits: Double
    var score: Int

    init(name: String, buyIns: Int = 1, totalCredits: Double = 0, score: Int = 0) {
        self.name = name
        self.buyIns = buyIns
        self.totalCredits = totalCredits
        self.score = score
    }
}



class GameManager: ObservableObject {
    @Published var players: [Player] = []
    @Published var totalPotCredits: Double = 1000.0
    @Published var numberOfPlayers: Int = 5
    @Published var creditsPerBuyIn: Double = 200.0

    var creditsPerPlayer: Double {
        return numberOfPlayers > 0 ? totalPotCredits / Double(numberOfPlayers) : 0.0
    }

    init() {
        updateTotalPotCredits()
    }

    func updateCreditsPerBuyIn() {
        creditsPerBuyIn = numberOfPlayers > 0 ? totalPotCredits / Double(numberOfPlayers) : 0.0
    }

    func updateTotalPotCredits() {
        totalPotCredits = creditsPerBuyIn * Double(numberOfPlayers)
    }
    
    func generateDefaultPlayers() {
        players.removeAll()

        let defaultNames = ["Player 1", "Player 2", "Player 3", "Player 4", "Player 5", "Player 6",
                           "Player 7", "Player 8", "Player 9", "Player 10", "Player 11", "Player 12"]

        for i in 0..<numberOfPlayers {
            let playerName = defaultNames[i]
            let newPlayer = Player(name: playerName, buyIns: 1, totalCredits: creditsPerBuyIn, score: 0)
            players.append(newPlayer)
        }
    }
    
    func addPlayer(name: String) {
        let newPlayer = Player(name: name, buyIns: 1, totalCredits: creditsPerBuyIn, score: 0)
        players.append(newPlayer)
    }
    
    func removePlayer(at index: Int) {
        if index < players.count {
            players.remove(at: index)
        }
    }
    
    func updatePlayerName(playerId: UUID, newName: String) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].name = newName
        }
    }
    
    func updatePlayerBuyIns(playerId: UUID, newBuyIns: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].buyIns = newBuyIns
            players[index].totalCredits = Double(newBuyIns) * creditsPerBuyIn
        }
    }
    
    func updatePlayerCredits(playerId: UUID, newCredits: Double) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].totalCredits = newCredits
        }
    }

    func updatePlayerScore(playerId: UUID, newScore: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].score = newScore
        }
    }
    
    func getTotalPotInCredits() -> Double {
        return players.reduce(0) { $0 + $1.totalCredits }
    }
    
    func resetGame() {
        players.removeAll()
        numberOfPlayers = 5
        creditsPerBuyIn = 200.0
        updateTotalPotCredits()
    }

    func startNewGameWithSameSettings() {
        // Keep the same settings but reset players to initial state
        let currentBuyIn = creditsPerBuyIn
        let currentPlayerCount = numberOfPlayers

        // Reset players to initial credits
        for i in players.indices {
            players[i].totalCredits = currentBuyIn * Double(players[i].buyIns)
            players[i].score = 0
        }

        // Maintain current settings
        creditsPerBuyIn = currentBuyIn
        numberOfPlayers = currentPlayerCount
        updateTotalPotCredits()
    }
}

