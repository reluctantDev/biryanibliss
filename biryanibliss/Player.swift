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
    private var initialGameBuyIn: Double? // Track the buy-in amount when game starts
    private var favoriteGroupsLoaded = false // Track if favorite groups have been loaded

    var creditsPerPlayer: Double {
        return numberOfPlayers > 0 ? totalPotCredits / Double(numberOfPlayers) : 0.0
    }

    var actualCreditsInPlay: Double {
        return players.reduce(0) { $0 + $1.totalCredits }
    }

    init() {
        updateTotalPotCredits()
        loadDefaultFavoriteGroups()
        removeDuplicateGroups() // Clean up any existing duplicates
        debugFavoriteGroups() // Debug output
        loadGameSessions()
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
        // Use initial game buy-in if game has started, otherwise use current buy-in
        let buyInAmount = initialGameBuyIn ?? creditsPerBuyIn
        let newPlayer = Player(name: name, buyIns: 1, totalCredits: buyInAmount, score: 0)
        players.append(newPlayer)
        numberOfPlayers = players.count
        updateTotalPotCredits()
    }

    func startGame() {
        // Capture the initial buy-in amount when game starts
        initialGameBuyIn = creditsPerBuyIn
    }

    func resetGame() {
        // Reset the initial buy-in tracking when game is reset
        initialGameBuyIn = nil
        players.removeAll()
        numberOfPlayers = 5
        creditsPerBuyIn = 200.0
        lastLoadedGroupName = nil
        updateTotalPotCredits()
    }

    func getInitialBuyInAmount() -> Double {
        // Return the initial buy-in if game has started, otherwise current buy-in
        return initialGameBuyIn ?? creditsPerBuyIn
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
        // Only load favorite groups once
        guard !favoriteGroupsLoaded else { return }

        // First, try to load saved groups
        loadSavedFavoriteGroups()

        // If no saved groups exist, create defaults and save them
        if favoriteGroups.isEmpty {
            favoriteGroups = [
                PlayerGroup(name: "Weekend Warriors", playerNames: ["Morgan", "Riley", "Avery", "Quinn"]),
                PlayerGroup(name: "Poker Pros", playerNames: ["Blake", "Cameron", "Drew", "Emery", "Finley", "Harper"])
            ]
            // Save the default groups so they persist
            saveFavoriteGroups()
        }

        favoriteGroupsLoaded = true
    }

    // Debug method to clear all saved data (for testing)
    func clearAllSavedData() {
        UserDefaults.standard.removeObject(forKey: "SavedFavoriteGroups")
        UserDefaults.standard.removeObject(forKey: "SavedGameSessions")
        favoriteGroups.removeAll()
        gameSessions.removeAll()
        favoriteGroupsLoaded = false
    }

    // Method to remove duplicate groups by name
    func removeDuplicateGroups() {
        var uniqueGroups: [PlayerGroup] = []
        var seenNames: Set<String> = []

        for group in favoriteGroups {
            let normalizedName = group.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if !seenNames.contains(normalizedName) {
                uniqueGroups.append(group)
                seenNames.insert(normalizedName)
            } else {
                print("Removing duplicate group: \(group.name)")
            }
        }

        if uniqueGroups.count != favoriteGroups.count {
            let removedCount = favoriteGroups.count - uniqueGroups.count
            favoriteGroups = uniqueGroups
            saveFavoriteGroups()
            print("Removed \(removedCount) duplicate groups. Current groups: \(favoriteGroups.map { $0.name })")
        }
    }

    // Debug method to print current favorite groups
    func debugFavoriteGroups() {
        print("=== Favorite Groups Debug ===")
        print("Total groups: \(favoriteGroups.count)")
        for (index, group) in favoriteGroups.enumerated() {
            print("\(index + 1). \(group.name) (\(group.playerNames.count) players)")
        }
        print("Groups loaded flag: \(favoriteGroupsLoaded)")
        print("=============================")
    }

    func addFavoriteGroup(_ group: PlayerGroup) {
        // Check for duplicate names (case-insensitive)
        let groupNameLower = group.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let isDuplicate = favoriteGroups.contains { existingGroup in
            existingGroup.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == groupNameLower
        }

        // Only add if not duplicate
        if !isDuplicate {
            favoriteGroups.append(group)
            saveFavoriteGroups()
        }
    }

    func removeFavoriteGroup(at index: Int) {
        if index < favoriteGroups.count {
            favoriteGroups.remove(at: index)
            saveFavoriteGroups()
        }
    }

    func updateFavoriteGroup(at index: Int, with updatedGroup: PlayerGroup) {
        guard index < favoriteGroups.count else { return }

        // Check for duplicate names (case-insensitive), excluding the current group being updated
        let groupNameLower = updatedGroup.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let isDuplicate = favoriteGroups.enumerated().contains { (i, existingGroup) in
            i != index && existingGroup.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == groupNameLower
        }

        // Only update if not duplicate
        if !isDuplicate {
            favoriteGroups[index] = updatedGroup
            saveFavoriteGroups()
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

    // Check if a group name already exists (case-insensitive)
    func isGroupNameTaken(_ name: String) -> Bool {
        let nameLower = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return favoriteGroups.contains { existingGroup in
            existingGroup.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == nameLower
        }
    }

    // Check if a group name is taken when updating (excludes the group being updated)
    func isGroupNameTaken(_ name: String, excludingIndex: Int) -> Bool {
        let nameLower = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return favoriteGroups.enumerated().contains { (i, existingGroup) in
            i != excludingIndex && existingGroup.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == nameLower
        }
    }

    // MARK: - Game Session Management

    func createGameSession() -> GameSession? {
        // Check if we've reached the maximum limit of 10 games
        if gameSessions.count >= 10 {
            return nil // Cannot create more games
        }

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
        saveGameSessions()
        return session
    }

    var canCreateNewSession: Bool {
        return gameSessions.count < 10
    }

    func updateGameSession(_ session: GameSession) {
        if let index = gameSessions.firstIndex(where: { $0.id == session.id }) {
            gameSessions[index] = session
            saveGameSessions()
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
            saveGameSessions()
        }
    }

    func clearAllGameSessions() {
        gameSessions.removeAll()
        saveGameSessions()
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

    func addPlayerToGame(name: String) {
        // Use initial game buy-in if game has started, otherwise use current buy-in
        let buyInAmount = initialGameBuyIn ?? creditsPerBuyIn
        let newPlayer = Player(
            name: name,
            buyIns: 1,
            totalCredits: buyInAmount,
            score: 0
        )

        players.append(newPlayer)
        numberOfPlayers = players.count
        updateTotalPotCredits()
    }

    // MARK: - Data Persistence

    private func saveGameSessions() {
        do {
            let data = try JSONEncoder().encode(gameSessions)
            UserDefaults.standard.set(data, forKey: "SavedGameSessions")
        } catch {
            print("Failed to save game sessions: \(error)")
        }
    }

    private func loadGameSessions() {
        guard let data = UserDefaults.standard.data(forKey: "SavedGameSessions") else { return }

        do {
            gameSessions = try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            print("Failed to load game sessions: \(error)")
            gameSessions = []
        }
    }

    private func saveFavoriteGroups() {
        do {
            let data = try JSONEncoder().encode(favoriteGroups)
            UserDefaults.standard.set(data, forKey: "SavedFavoriteGroups")
        } catch {
            print("Failed to save favorite groups: \(error)")
        }
    }

    private func loadSavedFavoriteGroups() {
        guard let data = UserDefaults.standard.data(forKey: "SavedFavoriteGroups") else { return }

        do {
            let savedGroups = try JSONDecoder().decode([PlayerGroup].self, from: data)
            favoriteGroups = savedGroups // Replace instead of append to avoid duplicates
        } catch {
            print("Failed to load favorite groups: \(error)")
        }
    }
}

