//
//  ContentView.swift
//  chiptally
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @State private var showingGame = false
    @State private var showingAddGroup = false
    @State private var editingGroupIndex: Int? = nil

    private var showingEditGroup: Binding<Bool> {
        Binding(
            get: { editingGroupIndex != nil },
            set: { newValue in
                if !newValue {
                    editingGroupIndex = nil
                }
            }
        )
    }
    @State private var selectedGroupIndex: Int?
    @State private var selectedGameSession: GameSession?
    @State private var gameResultsSession: GameSession?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingSettings = false
    @State private var showingResetSessionsAlert = false
    @State private var isSelectMode = false
    @State private var selectedSessionIds: Set<UUID> = []
    @State private var showingDeleteSelectedAlert = false
    @State private var showingDeleteAllAlert = false
    @State private var lastFailedGroupName: String? = nil // Track failed group selection
    @State private var showActiveGamesOnly = false



    private var filteredGameSessions: [GameSession] {
        if showActiveGamesOnly {
            return gameManager.gameSessions.filter { !$0.isCompleted }
        } else {
            return gameManager.gameSessions
        }
    }

    // Check if current players have conflicts with active games or session limits
    private var hasPlayerConflicts: Bool {
        // Check session limit first
        if !gameManager.canCreateNewSession {
            return true
        }

        // Check if a group selection failed due to conflicts (only if a group is selected)
        if lastFailedGroupName != nil && selectedGroupIndex != nil {
            return true
        }

        // If no group is selected, no conflicts (placeholder players can always be generated)
        if selectedGroupIndex == nil {
            return false
        }

        // If a group is selected and players are loaded, check for conflicts
        // Note: If players loaded successfully and there's an exact match, it's a resume scenario (not a conflict)
        if selectedGroupIndex != nil && !gameManager.players.isEmpty {
            let currentPlayerNames = gameManager.players.map { $0.name }
            // If there's an exact match, it's a resume scenario, not a conflict
            if gameManager.hasActiveSessionWithPlayers(currentPlayerNames) {
                return false // Resume scenario - no conflict
            }
            // Check for partial conflicts (some players in other sessions)
            return currentPlayerNames.contains { playerName in
                gameManager.isPlayerNameInActiveSession(playerName)
            }
        }

        return false
    }

    // Get conflict message for display
    private var conflictMessage: String {
        // Check session limit first
        if !gameManager.canCreateNewSession {
            return "You have reached the maximum limit of 10 game sessions. Please delete an existing session before creating a new one."
        }

        // Check if a group selection failed due to conflicts (only if a group is selected)
        if let failedGroupName = lastFailedGroupName, selectedGroupIndex != nil {
            return getDetailedConflictMessage(for: failedGroupName)
        }

        if !hasPlayerConflicts {
            return ""
        }

        let currentPlayerNames = gameManager.players.map { $0.name }
        if let activeSession = gameManager.getActiveSessionWithPlayers(currentPlayerNames) {
            return "These players are already in active game '\(activeSession.name)'. Click Start Game to resume that game."
        } else {
            return "One or more players are already in active games."
        }
    }

    // Get appropriate text for Start Game button
    private func getStartButtonText() -> String {
        // Check session limit first
        if !gameManager.canCreateNewSession {
            return "Session Limit Reached"
        }

        // Check if a group selection failed due to conflicts (only if a group is selected)
        if lastFailedGroupName != nil && selectedGroupIndex != nil {
            return "Cannot Start Game"
        }

        if gameManager.players.isEmpty {
            return "Start Game" // Will use placeholder players
        }

        // Only allow resume for favorite groups, not placeholder players
        if selectedGroupIndex != nil {
            let currentPlayerNames = gameManager.players.map { $0.name }
            if gameManager.hasActiveSessionWithPlayers(currentPlayerNames) {
                return "Resume Game"
            }
        }

        return "Start Game"
    }

    // Get detailed conflict message showing which players are in which games
    private func getDetailedConflictMessage(for groupName: String) -> String {
        // Find the group to get its player names
        guard let group = gameManager.favoriteGroups.first(where: { $0.name == groupName }) else {
            return "Cannot select '\(groupName)' because one or more players are already in active games."
        }

        // Group conflicting players by their active game sessions
        var gameGroups: [String: [String]] = [:]

        for playerName in group.playerNames {
            if gameManager.isPlayerNameInActiveSession(playerName) {
                if let sessionName = gameManager.getActiveSessionNameForPlayer(playerName) {
                    if gameGroups[sessionName] == nil {
                        gameGroups[sessionName] = []
                    }
                    gameGroups[sessionName]?.append(playerName)
                }
            }
        }

        if gameGroups.isEmpty {
            return "Cannot select '\(groupName)' because one or more players are already in active games."
        }

        // Sort games by start time (newest first)
        let sortedGames = gameGroups.keys.sorted { game1, game2 in
            let session1 = gameManager.gameSessions.first { $0.name == game1 }
            let session2 = gameManager.gameSessions.first { $0.name == game2 }

            guard let date1 = session1?.dateCreated, let date2 = session2?.dateCreated else {
                return game1 < game2 // Fallback to alphabetical if dates unavailable
            }

            return date1 > date2 // Newest first (reverse chronological)
        }

        // Build detailed conflict message
        let conflictDetails = sortedGames.map { game in
            let players = gameGroups[game] ?? []
            let playerList = players.joined(separator: ", ")

            // Add start time for context
            if let session = gameManager.gameSessions.first(where: { $0.name == game }) {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                let timeString = formatter.string(from: session.dateCreated)
                return "• \(game) (started \(timeString)): \(playerList)"
            } else {
                return "• \(game): \(playerList)"
            }
        }.joined(separator: "\n")

        return "Cannot select '\(groupName)' because the following players are already in active games:\n\n\(conflictDetails)"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Settings Button
                    HStack {
                        Spacer()
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Settings")
                        .accessibilityHint("Open app settings")
                    }
                    .padding(.horizontal)

                    // Header
                VStack(spacing: 12) {
                    Image("chiptally_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }
                .padding(.top)

                // Game Sessions Section (Moved to top)
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        // First row: Game Sessions title
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.green)
                                .font(.title2)

                            Text("Game Sessions")
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()
                        }

                        // Second row: Controls (only show if there are sessions)
                        if !gameManager.gameSessions.isEmpty {
                            HStack {
                                // Add some leading space to move Active filter to the right
                                Spacer()
                                    .frame(width: 20)

                                // Active Games Filter Toggle
                                Button(action: {
                                    showActiveGamesOnly.toggle()
                                }) {
                                    let activeCount = gameManager.gameSessions.filter { !$0.isCompleted }.count
                                    let totalCount = gameManager.gameSessions.count
                                    let displayCount = showActiveGamesOnly ? activeCount : totalCount
                                    let displayText = showActiveGamesOnly ? "Active" : "All"

                                    Text("\(displayText) (\(displayCount))")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(showActiveGamesOnly ? .blue : .secondary)
                                }

                                Spacer()

                                HStack(alignment: .center, spacing: 16) {
                                    // Multi-select and delete controls
                                    if isSelectMode {
                                        // Delete Selected Button
                                        Button(action: {
                                            showingDeleteSelectedAlert = true
                                        }) {
                                            Text("Delete (\(selectedSessionIds.count))")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(selectedSessionIds.isEmpty ? .gray : .red)
                                        }
                                        .disabled(selectedSessionIds.isEmpty)

                                        // Cancel Selection Button
                                        Button(action: {
                                            isSelectMode = false
                                            selectedSessionIds.removeAll()
                                        }) {
                                            Text("Cancel")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.blue)
                                        }
                                    } else {
                                        // Select Button
                                        Button(action: {
                                            isSelectMode = true
                                            selectedSessionIds.removeAll()
                                        }) {
                                            Text("Select")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.blue)
                                        }

                                        // Delete All Button
                                        Button(action: {
                                            showingDeleteAllAlert = true
                                        }) {
                                            Text("Delete All")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }

                    if filteredGameSessions.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: showActiveGamesOnly ? "clock" : "gamecontroller")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)

                            Text(showActiveGamesOnly ? "No active games" : "No game sessions yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(showActiveGamesOnly ? "All games have been completed" : "Click 'Start Game' to create your first session")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        // Enhanced unified scroll view with better UX
                        let recentSessions = Array(filteredGameSessions.reversed())
                        let totalSessions = recentSessions.count

                        VStack(spacing: 8) {
                            // Session count indicator
                            if totalSessions > 3 {
                                HStack {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)

                                    Text("Scroll to see all \(totalSessions) sessions")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Text("Newest first")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 4)
                                .padding(.bottom, 4)
                            }

                            // Unified scroll view for all sessions
                            ScrollViewReader { proxy in
                                VStack(spacing: 8) {
                                    ScrollView {
                                        LazyVStack(spacing: 12) {
                                            ForEach(Array(recentSessions.enumerated()), id: \.element.id) { index, session in
                                                let originalIndex = gameManager.gameSessions.firstIndex(where: { $0.id == session.id }) ?? 0

                                                GameSessionCard(
                                                    session: session,
                                                    onTap: {
                                                        if !isSelectMode {
                                                            if session.isCompleted {
                                                                gameResultsSession = session
                                                            } else {
                                                                selectedGameSession = session
                                                                gameManager.loadPlayersFromSession(session)
                                                                showingGame = true
                                                            }
                                                        }
                                                    },
                                                    onDelete: {
                                                        gameManager.deleteGameSession(at: originalIndex)
                                                    },
                                                    isSelectMode: isSelectMode,
                                                    isSelected: selectedSessionIds.contains(session.id),
                                                    onSelectionToggle: {
                                                        if selectedSessionIds.contains(session.id) {
                                                            selectedSessionIds.remove(session.id)
                                                        } else {
                                                            selectedSessionIds.insert(session.id)
                                                        }
                                                    }
                                                )
                                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                    Button("Delete", role: .destructive) {
                                                        gameManager.deleteGameSession(at: originalIndex)
                                                    }
                                                }
                                                .id("session-\(session.id)")
                                                // Visual indicator for newest session
                                                .overlay(
                                                    index == 0 ?
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                                    : nil
                                                )
                                            }

                                            // Bottom indicator when scrolled
                                            if totalSessions > 3 {
                                                HStack {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.caption2)
                                                        .foregroundColor(.green)

                                                    Text("All \(totalSessions) sessions shown")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.top, 8)
                                                .id("bottom-indicator")
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .frame(maxHeight: min(CGFloat(totalSessions) * 80, 320)) // Dynamic height with max limit (compact cards)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    )
                                    .onAppear {
                                        // Auto-scroll to newest session when view appears
                                        if let newestSession = recentSessions.first {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                proxy.scrollTo("session-\(newestSession.id)", anchor: .top)
                                            }
                                        }
                                    }
                                    .onChange(of: gameManager.gameSessions.count) { _ in
                                        // Auto-scroll to newest session when new session is added
                                        if let newestSession = recentSessions.first {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                proxy.scrollTo("session-\(newestSession.id)", anchor: .top)
                                            }
                                        }
                                    }

                                    // Quick action buttons for better UX
                                    if totalSessions > 3 {
                                        HStack(spacing: 16) {
                                            Button(action: {
                                                // Scroll to newest session
                                                if let newestSession = recentSessions.first {
                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                        proxy.scrollTo("session-\(newestSession.id)", anchor: .top)
                                                    }
                                                }
                                            }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrow.up.to.line")
                                                        .font(.caption2)
                                                    Text("Newest")
                                                        .font(.caption2)
                                                }
                                                .foregroundColor(.blue)
                                            }

                                            Spacer()

                                            Button(action: {
                                                // Scroll to oldest session
                                                if let oldestSession = recentSessions.last {
                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                        proxy.scrollTo("session-\(oldestSession.id)", anchor: .bottom)
                                                    }
                                                }
                                            }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrow.down.to.line")
                                                        .font(.caption2)
                                                    Text("Oldest")
                                                        .font(.caption2)
                                                }
                                                .foregroundColor(.blue)
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.top, 4)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)





                // Game Setup Section - Compact & Slick
                VStack(spacing: 12) {
                    // Compact header
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                            .font(.title2)

                        Text("Game Setup")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()
                    }

                    // Compact configuration grid
                    VStack(spacing: 8) {
                        // Buy-in and Players in one row
                        HStack(spacing: 16) {
                            // Buy-in section (compact)
                            VStack(alignment: .center, spacing: 4) {
                                Text("Buy-in")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 8) {
                                    Button(action: {
                                        let newValue = max(50, gameManager.creditsPerBuyIn - 50)
                                        gameManager.creditsPerBuyIn = newValue
                                        gameManager.updateTotalPotCredits()
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.callout)
                                            .foregroundColor(gameManager.creditsPerBuyIn > 50 ? .red : .gray)
                                    }
                                    .disabled(gameManager.creditsPerBuyIn <= 50)

                                    Text("\(Int(gameManager.creditsPerBuyIn))")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .frame(width: 50)
                                        .multilineTextAlignment(.center)

                                    Button(action: {
                                        let newValue = min(2000, gameManager.creditsPerBuyIn + 50)
                                        gameManager.creditsPerBuyIn = newValue
                                        gameManager.updateTotalPotCredits()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.callout)
                                            .foregroundColor(gameManager.creditsPerBuyIn < 2000 ? .green : .gray)
                                    }
                                    .disabled(gameManager.creditsPerBuyIn >= 2000)
                                }
                            }

                            Spacer()

                            // Players section (compact)
                            VStack(alignment: .center, spacing: 4) {
                                Text("Players")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 8) {
                                    Button(action: {
                                        if gameManager.numberOfPlayers > 1 {
                                            gameManager.numberOfPlayers -= 1
                                            gameManager.updateTotalPotCredits()
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.callout)
                                            .foregroundColor(.red)
                                    }

                                    Text("\(gameManager.numberOfPlayers)")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                        .multilineTextAlignment(.center)

                                    Button(action: {
                                        if gameManager.numberOfPlayers < 12 {
                                            gameManager.numberOfPlayers += 1
                                            gameManager.updateTotalPotCredits()
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.callout)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)

                        // Total pot and selected group in one compact row
                        HStack {
                            // Total pot (compact)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total Pot")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Text("\(Int(gameManager.totalPotCredits))")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }

                            Spacer()

                            // Selected group indicator (compact)
                            if let selectedIndex = selectedGroupIndex, selectedIndex < gameManager.favoriteGroups.count {
                                let selectedGroup = gameManager.favoriteGroups[selectedIndex]
                                HStack(spacing: 4) {
                                    Image(systemName: "person.3.fill")
                                        .font(.caption2)
                                        .foregroundColor(.blue)

                                    Text(selectedGroup.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                        .lineLimit(1)

                                    Text("(\(selectedGroup.playerNames.count))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.crop.circle.dashed")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)

                                    Text("Placeholder")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)

                                    Text("(\(gameManager.numberOfPlayers))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                // Favorite Groups Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.purple)
                            .font(.title2)

                        Text("Favorite Groups")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: {
                            showingAddGroup = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }

                    VStack(spacing: 8) {
                        ForEach(Array(gameManager.favoriteGroups.enumerated()), id: \.element.id) { index, group in
                            FavoriteGroupListItem(
                                group: group,
                                gameManager: gameManager,
                                isSelected: selectedGroupIndex == index,
                                onSelect: {
                                    if selectedGroupIndex == index {
                                        // Unselect if tapping the same group
                                        selectedGroupIndex = nil
                                        lastFailedGroupName = nil // Clear failed group tracking
                                        gameManager.resetGame() // Clear players when unselecting
                                    } else {
                                        // Always select the group visually, regardless of conflicts
                                        selectedGroupIndex = index

                                        // Try to load players from the group
                                        let result = gameManager.loadPlayersFromGroup(group)
                                        if result.success {
                                            lastFailedGroupName = nil // Clear any previous failed group
                                        } else {
                                            // Conflicts detected - keep group selected but track the failure
                                            lastFailedGroupName = group.name // Track failed group for UI display
                                            print("Cannot load players from group '\(group.name)' - players already in active games: \(result.conflictingPlayers)")
                                        }
                                    }
                                },
                                onEdit: {
                                    editingGroupIndex = index
                                },
                                onDelete: {
                                    // Clear selection if deleting selected group
                                    if selectedGroupIndex == index {
                                        selectedGroupIndex = nil
                                    } else if let selected = selectedGroupIndex, selected > index {
                                        selectedGroupIndex = selected - 1
                                    }

                                    // Clear editing index if deleting the group being edited
                                    if editingGroupIndex == index {
                                        editingGroupIndex = nil
                                    } else if let editIndex = editingGroupIndex, editIndex > index {
                                        editingGroupIndex = editIndex - 1
                                    }

                                    gameManager.removeFavoriteGroup(at: index)
                                }
                            )
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)



                Spacer()

                // Player Conflict Warning
                if hasPlayerConflicts {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.title3)

                            Text("Player Conflict")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)

                            Spacer()
                        }

                        HStack {
                            Text(conflictMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)

                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }

                // Start Game Button
                Button(action: {
                    // If no group is selected, always generate new placeholder players
                    if selectedGroupIndex == nil {
                        print("No group selected, generating new placeholder players...")
                        gameManager.generateDefaultPlayers()
                        print("Generated \(gameManager.players.count) default players: \(gameManager.players.map { $0.name })")
                    }

                    // Check if we can create a new session (max 10 limit)
                    if !gameManager.canCreateNewSession {
                        // Session limit reached - this is already handled by button being disabled
                        return
                    }

                    // Check if there's already an active session with these players (only for favorite groups)
                    let currentPlayerNames = gameManager.players.map { $0.name }
                    if selectedGroupIndex != nil && gameManager.hasActiveSessionWithPlayers(currentPlayerNames) {
                        // Resume existing game for favorite groups only
                        if let activeSession = gameManager.getActiveSessionWithPlayers(currentPlayerNames) {
                            selectedGameSession = activeSession
                            gameManager.loadPlayersFromSession(activeSession)
                            selectedGroupIndex = nil // Clear group selection
                            lastFailedGroupName = nil // Clear failed group tracking
                            showingGame = true
                        }
                    } else {
                        // Create a new game session (always for placeholder players, or new favorite group games)
                        gameManager.startGame() // Track buy-in amount
                        if let newSession = gameManager.createGameSession() {
                            selectedGameSession = newSession
                            selectedGroupIndex = nil // Clear group selection after successful game start
                            lastFailedGroupName = nil // Clear failed group tracking
                            showingGame = true // Actually show the game!
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: hasPlayerConflicts ? "exclamationmark.circle.fill" : "play.circle.fill")
                            .font(.title2)

                        Text(getStartButtonText())
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(hasPlayerConflicts ? Color.gray : Color.blue)
                    .cornerRadius(25)
                    .shadow(color: hasPlayerConflicts ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    .accessibilityLabel(hasPlayerConflicts ? "Cannot Start Game" : "Start Game")
                    .accessibilityHint(hasPlayerConflicts ? "Players are already in active games" : "Start a new poker game with current players")
                }
                .disabled(hasPlayerConflicts)
                .padding(.horizontal)
                .padding(.bottom)
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingGame) {
            GamePlayView(gameManager: gameManager, gameSession: selectedGameSession)
        }
        .sheet(item: $gameResultsSession) { session in
            GameResultsView(session: session)
        }
        .sheet(isPresented: $showingAddGroup) {
            AddFavoriteGroupView(gameManager: gameManager, isPresented: $showingAddGroup)
        }
        .sheet(isPresented: showingEditGroup) {
            if let editIndex = editingGroupIndex, editIndex < gameManager.favoriteGroups.count {
                EditFavoriteGroupView(
                    gameManager: gameManager,
                    groupIndex: editIndex,
                    isPresented: showingEditGroup
                )
            } else {
                VStack {
                    Text("Error loading group for editing")
                    Button("Close") {
                        editingGroupIndex = nil
                    }
                }
                .padding()
            }
        }

        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Delete Selected Sessions", isPresented: $showingDeleteSelectedAlert) {
            Button("Delete \(selectedSessionIds.count) Sessions", role: .destructive) {
                gameManager.deleteGameSessions(withIds: selectedSessionIds)
                selectedSessionIds.removeAll()
                isSelectMode = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete \(selectedSessionIds.count) selected game sessions. This action cannot be undone.")
        }
        .alert("Delete All Sessions", isPresented: $showingDeleteAllAlert) {
            Button("Delete All", role: .destructive) {
                gameManager.clearAllGameSessions()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all \(gameManager.gameSessions.count) game sessions. This action cannot be undone.")
        }

        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }

    }
}

struct FavoriteGroupListItem: View {
    let group: PlayerGroup
    @ObservedObject var gameManager: GameManager
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Group icon and player count
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.purple)
                    .frame(width: 40, height: 40)

                VStack(spacing: 2) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)

                    Text("\(group.playerNames.count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            // Group details
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                HStack {
                    let displayNames = Array(group.playerNames.prefix(3))
                    let remainingCount = max(0, group.playerNames.count - 3)

                    Text(displayNames.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if remainingCount > 0 {
                        Text("+\(remainingCount) more")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }

            Spacer()

            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button(action: onSelect) {
                Label("Select Group", systemImage: "person.3.fill")
            }

            Button(action: onEdit) {
                Label("Edit Group", systemImage: "pencil")
            }

            Button(action: onDelete) {
                Label("Delete Group", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
    }
}

struct FavoriteGroupCard: View {
    let group: PlayerGroup
    @ObservedObject var gameManager: GameManager
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.3.fill")
                        .font(.title3)
                        .foregroundColor(.blue)

                    Spacer()

                    Text("\(group.playerNames.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                Text(group.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: 2) {
                    ForEach(group.playerNames.prefix(3), id: \.self) { playerName in
                        Text("• \(playerName)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    if group.playerNames.count > 3 {
                        Text("• +\(group.playerNames.count - 3) more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.blue.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: onSelect) {
                Label("Select Group", systemImage: "person.3.fill")
            }

            Button(action: onEdit) {
                Label("Edit Group", systemImage: "pencil")
            }

            Button(action: onDelete) {
                Label("Delete Group", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
    }
}

struct AddFavoriteGroupView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var groupName = ""
    @State private var playerNames: [String] = ["", "", "", "", ""]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)

                        Text("Create Favorite Group")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Save a group of players for quick setup")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Group Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Group Name")
                            .font(.headline)
                            .fontWeight(.semibold)

                        TextField("Enter group name", text: $groupName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(groupNameError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )

                        if let error = groupNameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)

                    // Player Names
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Player Names")
                            .font(.headline)
                            .fontWeight(.semibold)

                        ForEach(0..<playerNames.count, id: \.self) { index in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)

                                TextField("Player \(index + 1)", text: $playerNames[index])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                if index >= 3 {
                                    Button(action: {
                                        if playerNames.count > 3 {
                                            playerNames.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }

                        if playerNames.count < 12 {
                            Button(action: {
                                playerNames.append("")
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Player")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)

                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGroup()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty &&
               !gameManager.isGroupNameTaken(trimmedName) &&
               playerNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 3
    }

    private var groupNameError: String? {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return nil
        } else if gameManager.isGroupNameTaken(trimmedName) {
            return "A group with this name already exists"
        }
        return nil
    }

    private func saveGroup() {
        let validPlayerNames = playerNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let newGroup = PlayerGroup(name: groupName.trimmingCharacters(in: .whitespacesAndNewlines),
                                 playerNames: validPlayerNames)
        gameManager.addFavoriteGroup(newGroup)
        dismiss()
    }
}

struct EditFavoriteGroupView: View {
    @ObservedObject var gameManager: GameManager
    let groupIndex: Int
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var groupName = ""
    @State private var playerNames: [String] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)

                        Text("Edit Favorite Group")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Modify group name and players")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Group Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Group Name")
                            .font(.headline)
                            .fontWeight(.semibold)

                        TextField("Enter group name", text: $groupName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(groupNameError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )

                        if let error = groupNameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)

                    // Player Names
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Player Names")
                            .font(.headline)
                            .fontWeight(.semibold)

                        ForEach(0..<playerNames.count, id: \.self) { index in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)

                                TextField("Player \(index + 1)", text: $playerNames[index])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                if index >= 3 {
                                    Button(action: {
                                        if playerNames.count > 3 {
                                            playerNames.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }

                        if playerNames.count < 12 {
                            Button(action: {
                                playerNames.append("")
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Player")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)

                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            loadGroupData()
        }
    }

    private var canSave: Bool {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty &&
               !gameManager.isGroupNameTaken(trimmedName, excludingIndex: groupIndex) &&
               playerNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 3
    }

    private var groupNameError: String? {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return nil
        } else if gameManager.isGroupNameTaken(trimmedName, excludingIndex: groupIndex) {
            return "A group with this name already exists"
        }
        return nil
    }

    private func loadGroupData() {
        if groupIndex < gameManager.favoriteGroups.count {
            let group = gameManager.favoriteGroups[groupIndex]
            groupName = group.name
            playerNames = group.playerNames

            // Ensure minimum 5 fields for editing
            while playerNames.count < 5 {
                playerNames.append("")
            }
        }
    }

    private func saveChanges() {
        let validPlayerNames = playerNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let trimmedGroupName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedGroup = PlayerGroup(name: trimmedGroupName, playerNames: validPlayerNames)
        let success = gameManager.updateFavoriteGroup(at: groupIndex, with: updatedGroup)

        if success {
            dismiss()
        } else {
            // Could add an alert here to show the error to the user
            print("Failed to save group changes")
        }
    }
}

struct GameSessionCard: View {
    let session: GameSession
    let onTap: () -> Void
    let onDelete: () -> Void
    let isSelectMode: Bool
    let isSelected: Bool
    let onSelectionToggle: () -> Void

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.dateCreated)
    }

    private var formattedCompletedDate: String? {
        guard session.isCompleted, let completedDate = session.completedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: completedDate)
    }

    private var statusColor: Color {
        session.isCompleted ? .green : .orange
    }

    private var statusText: String {
        session.isCompleted ? "Completed" : "In Progress"
    }

    private var statusIcon: String {
        session.isCompleted ? "checkmark.circle.fill" : "play.circle.fill"
    }

    var body: some View {
        Button(action: isSelectMode ? onSelectionToggle : onTap) {
            HStack(spacing: 10) {
                // Selection indicator
                if isSelectMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title3)
                }

                // Main content in horizontal layout for compactness
                HStack(spacing: 12) {
                    // Left side: Game info
                    VStack(alignment: .leading, spacing: 3) {
                        // Game name and status in one line
                        HStack(spacing: 6) {
                            Text(session.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            // Compact status dot
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)
                        }

                        // Date, player count, and group info in one compact line
                        HStack(spacing: 6) {
                            // Date (time only for compactness)
                            Text(formattedDate.components(separatedBy: " ").last ?? formattedDate)
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            // Player count with icon
                            HStack(spacing: 2) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                Text("\(session.players.count)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }

                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            // Group or placeholder indicator
                            if let groupName = session.originalGroupName {
                                HStack(spacing: 2) {
                                    Image(systemName: "person.3.fill")
                                        .font(.caption2)
                                        .foregroundColor(.purple)
                                    Text(groupName)
                                        .font(.caption2)
                                        .foregroundColor(.purple)
                                        .fontWeight(.medium)
                                        .lineLimit(1)

                                    // Show + indicator if there are additional players
                                    if let originalPlayerNames = session.originalGroupPlayerNames,
                                       session.players.count > originalPlayerNames.count {
                                        Text("+\(session.players.count - originalPlayerNames.count)")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                            .fontWeight(.bold)
                                    }
                                }
                            } else {
                                HStack(spacing: 2) {
                                    Image(systemName: "person.crop.circle.dashed")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("Placeholder")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    Spacer()

                    // Right side: Game details (very compact)
                    VStack(alignment: .trailing, spacing: 2) {
                        // Buy-in and pot in compact format
                        Text("\(Int(session.creditsPerBuyIn))/\(Int(session.totalPotCredits))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Text("buy-in/pot")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        // Status or completion time
                        if let completedDateString = formattedCompletedDate {
                            Text("✓ \(completedDateString.components(separatedBy: " ").last ?? "")")
                                .font(.caption2)
                                .foregroundColor(.green)
                                .lineLimit(1)
                        } else {
                            Text(statusText)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(statusColor)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(statusColor.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: onTap) {
                Label("Open Game", systemImage: "gamecontroller.fill")
            }

            Button(action: onDelete) {
                Label("Delete Session", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
    }
}

struct GameResultsView: View {
    let session: GameSession
    @Environment(\.dismiss) private var dismiss

    private var sortedPlayers: [Player] {
        session.players.sorted { $0.totalCredits > $1.totalCredits }
    }

    private var winner: Player? {
        sortedPlayers.first
    }

    private var totalCreditsInPlay: Double {
        session.players.reduce(0) { $0 + $1.totalCredits }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: session.dateCreated)
    }

    private var formattedCompletedDate: String {
        guard let completedDate = session.completedDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: completedDate)
    }

    private var gameDuration: String {
        guard let completedDate = session.completedDate else { return "Unknown" }
        let duration = completedDate.timeIntervalSince(session.dateCreated)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)

                        Text(session.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Game Results")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Winner Section
                    if let winner = winner {
                        VStack(spacing: 8) {
                            Text("🏆 Biggest Winner")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)

                            Text(winner.name)
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("\(Int(winner.totalCredits)) credits")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                                .fontWeight(.semibold)
                        }
                        .padding(12)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Final Standings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Final Credit Standings")
                            .font(.title2)
                            .fontWeight(.bold)

                        VStack(spacing: 12) {
                            ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                                PlayerResultCard(player: player, position: index + 1, session: session)
                            }
                        }
                    }

                    // Game Statistics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Game Statistics")
                            .font(.title2)
                            .fontWeight(.bold)

                        VStack(spacing: 12) {
                            StatRow(label: "Started", value: formattedDate)
                            StatRow(label: "Completed", value: formattedCompletedDate)
                            StatRow(label: "Duration", value: gameDuration)

                            Divider()

                            StatRow(label: "Players", value: "\(session.players.count)")
                            StatRow(label: "Buy-in Amount", value: "\(Int(session.creditsPerBuyIn)) credits")
                            StatRow(label: "Initial Pot", value: "\(Int(session.creditsPerBuyIn * Double(session.players.count))) credits")
                            StatRow(label: "Final Pot", value: "\(Int(totalCreditsInPlay)) credits")

                            let potDifference = totalCreditsInPlay - (session.creditsPerBuyIn * Double(session.players.count))
                            if abs(potDifference) > 0.01 {
                                StatRow(label: "Pot Change", value: potDifference >= 0 ? "+\(Int(potDifference))" : "\(Int(potDifference))")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlayerResultCard: View {
    let player: Player
    let position: Int
    let session: GameSession

    private var positionColor: Color {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }

    private var positionIcon: String {
        switch position {
        case 1: return "1.circle.fill"
        case 2: return "2.circle.fill"
        case 3: return "3.circle.fill"
        default: return "\(position).circle"
        }
    }

    private var profitLoss: Double {
        let invested = Double(player.buyIns) * session.creditsPerBuyIn
        return player.totalCredits - invested
    }

    private var profitLossColor: Color {
        profitLoss >= 0 ? .green : .red
    }

    private var profitLossText: String {
        if profitLoss >= 0 {
            return "+\(Int(profitLoss))"
        } else {
            return "-\(Int(abs(profitLoss)))"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Position
            Image(systemName: positionIcon)
                .font(.title2)
                .foregroundColor(positionColor)
                .frame(width: 30)

            // Player Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )

            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("\(player.buyIns) buy-in\(player.buyIns == 1 ? "" : "s") • Invested: \(Int(Double(player.buyIns) * session.creditsPerBuyIn)) credits")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Final: \(Int(player.totalCredits)) credits")
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            Spacer()

            // Credits and Profit/Loss
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(player.totalCredits))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(profitLossText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(profitLossColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingPrivacyPolicy = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Info Section
                VStack(spacing: 16) {
                    Image("chiptally_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)

                    Text("ChipTally")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Professional Poker Session Management")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Features Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Features")
                        .font(.headline)
                        .fontWeight(.semibold)

                    FeatureRow(icon: "person.3.fill", title: "Player Groups", description: "Save and manage favorite player groups")
                    FeatureRow(icon: "gamecontroller.fill", title: "Session Tracking", description: "Track up to 10 game sessions")
                    FeatureRow(icon: "dollarsign.circle.fill", title: "Credit Management", description: "Accurate buy-in and credit tracking")
                    FeatureRow(icon: "chart.bar.fill", title: "Game Results", description: "Complete session history and statistics")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Spacer()

                // Footer
                VStack(spacing: 8) {
                    Text("Made with ❤️ for poker players")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("© 2025 ChipTally")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
