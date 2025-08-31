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

struct PlayerGroup: Identifiable, Codable {
    let id = UUID()
    var name: String
    var playerNames: [String]
    var dateCreated: Date

    init(name: String, playerNames: [String]) {
        self.name = name
        self.playerNames = playerNames
        self.dateCreated = Date()
    }
}

struct GameSession: Identifiable, Codable {
    let id = UUID()
    var name: String
    var dateCreated: Date
    var players: [Player]
    var totalPotCredits: Double
    var creditsPerBuyIn: Double
    var isCompleted: Bool = false
    var completedDate: Date?

    init(name: String, players: [Player], totalPotCredits: Double, creditsPerBuyIn: Double) {
        self.name = name
        self.dateCreated = Date()
        self.players = players
        self.totalPotCredits = totalPotCredits
        self.creditsPerBuyIn = creditsPerBuyIn
    }
}

class GameManager: ObservableObject {
    @Published var players: [Player] = []
    @Published var totalPotCredits: Double = 1000.0
    @Published var numberOfPlayers: Int = 5
    @Published var creditsPerBuyIn: Double = 200.0
    @Published var favoriteGroups: [PlayerGroup] = []
    @Published var gameSessions: [GameSession] = []

    private var lastLoadedGroupName: String?

    var creditsPerPlayer: Double {
        return numberOfPlayers > 0 ? totalPotCredits / Double(numberOfPlayers) : 0.0
    }

    init() {
        updateTotalPotCredits()
        loadDefaultFavoriteGroups()
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
        lastLoadedGroupName = nil
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

    // MARK: - Favorite Groups Management

    func loadDefaultFavoriteGroups() {
        if favoriteGroups.isEmpty {
            favoriteGroups = [
                PlayerGroup(name: "Weekend Warriors", playerNames: ["Morgan", "Riley", "Avery", "Quinn"]),
                PlayerGroup(name: "Poker Pros", playerNames: ["Blake", "Cameron", "Drew", "Emery", "Finley", "Harper"])
            ]
        }
    }

    func addFavoriteGroup(_ group: PlayerGroup) {
        favoriteGroups.append(group)
    }

    func removeFavoriteGroup(at index: Int) {
        if index < favoriteGroups.count {
            favoriteGroups.remove(at: index)
        }
    }

    func updateFavoriteGroup(at index: Int, with updatedGroup: PlayerGroup) {
        if index < favoriteGroups.count {
            favoriteGroups[index] = updatedGroup
        }
    }

    func loadPlayersFromGroup(_ group: PlayerGroup) {
        // Prevent loading the same group multiple times
        if lastLoadedGroupName == group.name && !players.isEmpty {
            return
        }

        players.removeAll()
        numberOfPlayers = group.playerNames.count
        lastLoadedGroupName = group.name

        for playerName in group.playerNames {
            let player = Player(name: playerName, buyIns: 1, totalCredits: creditsPerBuyIn, score: 0)
            players.append(player)
        }

        updateTotalPotCredits()
    }

    func saveCurrentPlayersAsGroup(name: String) {
        let playerNames = players.map { $0.name }
        let newGroup = PlayerGroup(name: name, playerNames: playerNames)
        addFavoriteGroup(newGroup)
    }

    // MARK: - Game Session Management

    func createGameSession() -> GameSession {
        let sessionNumber = gameSessions.count + 1
        let sessionName = "Game \(sessionNumber)"

        // Create a copy of current players for the session
        let sessionPlayers = players.map { player in
            Player(name: player.name, buyIns: player.buyIns, totalCredits: player.totalCredits, score: player.score)
        }

        let session = GameSession(
            name: sessionName,
            players: sessionPlayers,
            totalPotCredits: totalPotCredits,
            creditsPerBuyIn: creditsPerBuyIn
        )

        gameSessions.append(session)
        return session
    }

    func updateGameSession(_ session: GameSession) {
        if let index = gameSessions.firstIndex(where: { $0.id == session.id }) {
            gameSessions[index] = session
        }
    }

    func completeGameSession(_ sessionId: UUID) {
        if let index = gameSessions.firstIndex(where: { $0.id == sessionId }) {
            gameSessions[index].isCompleted = true
            gameSessions[index].completedDate = Date()
        }
    }

    func deleteGameSession(at index: Int) {
        if index < gameSessions.count {
            gameSessions.remove(at: index)
        }
    }

    func loadPlayersFromSession(_ session: GameSession) {
        players = session.players.map { player in
            Player(name: player.name, buyIns: player.buyIns, totalCredits: player.totalCredits, score: player.score)
        }
        numberOfPlayers = players.count
        totalPotCredits = session.totalPotCredits
        creditsPerBuyIn = session.creditsPerBuyIn
        updateTotalPotCredits()
    }

    func hasActiveSessionWithPlayers(_ playerNames: [String]) -> Bool {
        return gameSessions.contains { session in
            !session.isCompleted && Set(session.players.map { $0.name }) == Set(playerNames)
        }
    }

    func getActiveSessionWithPlayers(_ playerNames: [String]) -> GameSession? {
        return gameSessions.first { session in
            !session.isCompleted && Set(session.players.map { $0.name }) == Set(playerNames)
        }
    }
}

