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
    @State private var showingDuplicateSessionAlert = false
    @State private var existingActiveSession: GameSession?
    @State private var showingGameResults = false
    @State private var showingSessionLimitAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingSettings = false
    @State private var showingResetSessionsAlert = false
    @State private var isSelectMode = false
    @State private var selectedSessionIds: Set<UUID> = []
    @State private var showingDeleteSelectedAlert = false
    @State private var showingDeleteAllAlert = false
    
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

                    Text("Chip Ledger")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top)

                // Game Sessions Section (Moved to top)
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.green)
                            .font(.title2)

                        Text("Game Sessions")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        // Multi-select and delete controls (only show if there are sessions)
                        if !gameManager.gameSessions.isEmpty {
                            HStack(spacing: 16) {
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
                        }
                    }

                    if gameManager.gameSessions.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "gamecontroller")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)

                            Text("No game sessions yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("Click 'Start Game' to create your first session")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        // Scrollable sessions: 2 games visible, rest scrollable (hard limit 10 total)
                        let recentSessions = Array(gameManager.gameSessions.reversed())
                        let visibleSessions = Array(recentSessions.prefix(2))
                        let hasMoreSessions = recentSessions.count > 2

                        VStack(spacing: 0) {
                            // Always visible: Last 2 sessions
                            ForEach(Array(visibleSessions.enumerated()), id: \.element.id) { index, session in
                                let originalIndex = gameManager.gameSessions.firstIndex(where: { $0.id == session.id }) ?? 0
                                GameSessionCard(
                                    session: session,
                                    onTap: {
                                        if !isSelectMode {
                                            selectedGameSession = session
                                            if session.isCompleted {
                                                showingGameResults = true
                                            } else {
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
                                .padding(.bottom, index < visibleSessions.count - 1 ? 12 : 0)
                            }

                            // Scrollable area for additional sessions (3-10)
                            if hasMoreSessions {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(Array(recentSessions.dropFirst(2).enumerated()), id: \.element.id) { index, session in
                                            let originalIndex = gameManager.gameSessions.firstIndex(where: { $0.id == session.id }) ?? 0
                                            GameSessionCard(
                                                session: session,
                                                onTap: {
                                                    if !isSelectMode {
                                                        selectedGameSession = session
                                                        if session.isCompleted {
                                                            showingGameResults = true
                                                        } else {
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
                                        }
                                    }
                                    .padding(.top, 12)
                                }
                                .frame(maxHeight: 200) // Fixed height for scrollable area
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)





                // Game Configuration Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                            .font(.title2)

                        Text("Game Configuration")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()
                    }

                    VStack(spacing: 16) {
                        // Buy-in Credits (Editable with increment/decrement)
                        HStack {
                            Text("Buy-in:")
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            HStack(spacing: 12) {
                                // Decrement button
                                Button(action: {
                                    let newValue = max(50, gameManager.creditsPerBuyIn - 50)
                                    gameManager.creditsPerBuyIn = newValue
                                    gameManager.updateTotalPotCredits()
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(gameManager.creditsPerBuyIn > 50 ? .red : .gray)
                                }
                                .disabled(gameManager.creditsPerBuyIn <= 50)

                                // Current value display
                                Text("\(Int(gameManager.creditsPerBuyIn))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(width: 60)
                                    .multilineTextAlignment(.center)

                                // Increment button
                                Button(action: {
                                    let newValue = min(2000, gameManager.creditsPerBuyIn + 50)
                                    gameManager.creditsPerBuyIn = newValue
                                    gameManager.updateTotalPotCredits()
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(gameManager.creditsPerBuyIn < 2000 ? .green : .gray)
                                }
                                .disabled(gameManager.creditsPerBuyIn >= 2000)

                                Text("Credits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 50, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)

                        // Number of Players
                        HStack {
                            Text("Number of Players:")
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            HStack(spacing: 12) {
                                Button(action: {
                                    if gameManager.numberOfPlayers > 1 {
                                        gameManager.numberOfPlayers -= 1
                                        gameManager.updateTotalPotCredits()
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                }

                                Text("\(gameManager.numberOfPlayers)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .frame(width: 60)
                                    .multilineTextAlignment(.center)

                                Button(action: {
                                    if gameManager.numberOfPlayers < 12 {
                                        gameManager.numberOfPlayers += 1
                                        gameManager.updateTotalPotCredits()
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                }

                                // Empty space to align with Credits label above
                                Text("")
                                    .frame(width: 50)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)

                        // Total Pot Credits (Display Only)
                        HStack {
                            Text("Total Credits in Play:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            HStack(spacing: 12) {
                                // Empty spaces to align with buttons above
                                Text("")
                                    .frame(width: 24)

                                Text("\(Int(gameManager.totalPotCredits))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                                    .frame(width: 60)
                                    .multilineTextAlignment(.center)

                                Text("")
                                    .frame(width: 24)

                                Text("Credits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 50, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

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
                                        gameManager.resetGame() // Clear players when unselecting
                                    } else {
                                        // Select new group
                                        selectedGroupIndex = index
                                        gameManager.loadPlayersFromGroup(group)
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

                // Selected Group Indicator (moved under Favorite Groups)
                if let selectedIndex = selectedGroupIndex, selectedIndex < gameManager.favoriteGroups.count {
                    let currentPlayerNames = gameManager.players.map { $0.name }
                    let hasActiveSession = gameManager.hasActiveSessionWithPlayers(currentPlayerNames)
                    let activeSession = gameManager.getActiveSessionWithPlayers(currentPlayerNames)

                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: hasActiveSession ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .foregroundColor(hasActiveSession ? .orange : .green)
                            Text("Selected Group: \(gameManager.favoriteGroups[selectedIndex].name)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()

                            // Clear Selection Button
                            Button(action: {
                                selectedGroupIndex = nil
                                gameManager.resetGame()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                    Text("Clear")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                            }
                        }

                        HStack {
                            Text("\(gameManager.players.count) players loaded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        if hasActiveSession, let activeSession = activeSession {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("Active game: \(activeSession.name)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }

                        // Debug info
                        if !gameManager.players.isEmpty {
                            HStack {
                                Text("Players: \(gameManager.players.map { $0.name }.joined(separator: ", "))")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background((hasActiveSession ? Color.orange : Color.green).opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke((hasActiveSession ? Color.orange : Color.green).opacity(0.3), lineWidth: 1)
                    )
                }

                Spacer()
                
                // Start Game Button
                Button(action: {
                    // If no players exist (no group selected), generate default players
                    if gameManager.players.isEmpty {
                        gameManager.generateDefaultPlayers()
                    }

                    // Check if we can create a new session (max 10 limit)
                    if !gameManager.canCreateNewSession {
                        showingSessionLimitAlert = true
                        return
                    }

                    // Check if there's already an active session with these players
                    let currentPlayerNames = gameManager.players.map { $0.name }
                    if gameManager.hasActiveSessionWithPlayers(currentPlayerNames) {
                        existingActiveSession = gameManager.getActiveSessionWithPlayers(currentPlayerNames)
                        showingDuplicateSessionAlert = true
                    } else {
                        // Create a new game session
                        gameManager.startGame() // Track buy-in amount
                        if let newSession = gameManager.createGameSession() {
                            selectedGameSession = newSession
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        
                        Text("Start Game")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    .accessibilityLabel("Start Game")
                    .accessibilityHint("Start a new poker game with current players")
                }
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
        .sheet(isPresented: $showingGameResults) {
            if let session = selectedGameSession {
                GameResultsView(session: session)
            }
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
        .alert("Active Game Found", isPresented: $showingDuplicateSessionAlert) {
            Button("Resume Existing Game") {
                if let activeSession = existingActiveSession {
                    selectedGameSession = activeSession
                    gameManager.loadPlayersFromSession(activeSession)
                    showingGame = true
                }
            }

            Button("Cancel", role: .cancel) {
                existingActiveSession = nil
            }
        } message: {
            if let activeSession = existingActiveSession {
                Text("There's already an active game '\(activeSession.name)' with these players. You can resume the existing game or wait until it's completed to start a new one.")
            }
        }
        .alert("Session Limit Reached", isPresented: $showingSessionLimitAlert) {
            Button("OK") { }
        } message: {
            Text("You have reached the maximum limit of 10 game sessions. Please delete an existing session before creating a new one.")
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
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    // Selection indicator
                    if isSelectMode {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                            .font(.title3)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: statusIcon)
                                .foregroundColor(statusColor)
                                .font(.caption)
                            Text(statusText)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(statusColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(8)

                        Text("\(session.players.count) players")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Players preview
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.blue)
                        .font(.caption)

                    let playerNames = session.players.prefix(3).map { $0.name }
                    Text(playerNames.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    if session.players.count > 3 {
                        Text("+\(session.players.count - 3) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }

                    Spacer()
                }

                // Game info
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Buy-in: \(Int(session.creditsPerBuyIn))")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text("Pot: \(Int(session.totalPotCredits))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if let completedDateString = formattedCompletedDate {
                        Text("Finished: \(completedDateString)")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(statusColor.opacity(0.3), lineWidth: 1)
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
                        // ChipTally logo
                        Image("chiptally_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)

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
                        VStack(spacing: 12) {
                            Text("🏆 Biggest Winner")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)

                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color.yellow.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(String(winner.name.prefix(1)).uppercased())
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.yellow)
                                    )

                                Text(winner.name)
                                    .font(.title)
                                    .fontWeight(.bold)

                                Text("\(Int(winner.totalCredits))")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                    .fontWeight(.semibold)

                                let profit = winner.totalCredits - (Double(winner.buyIns) * session.creditsPerBuyIn)
                                Text(profit >= 0 ? "+\(Int(profit))" : "-\(Int(abs(profit)))")
                                    .font(.subheadline)
                                    .foregroundColor(profit >= 0 ? .green : .red)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(16)
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
                            StatRow(label: "Players", value: "\(session.players.count)")
                            StatRow(label: "Buy-in", value: "\(Int(session.creditsPerBuyIn))")
                            StatRow(label: "Pot", value: "\(Int(session.totalPotCredits))")
                            StatRow(label: "Final Credits", value: "\(Int(totalCreditsInPlay))")
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

                Text("\(player.buyIns) buy-in\(player.buyIns == 1 ? "" : "s") • Invested: \(Int(Double(player.buyIns) * session.creditsPerBuyIn))")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
