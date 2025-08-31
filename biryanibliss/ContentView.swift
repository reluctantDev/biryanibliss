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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                VStack(spacing: 12) {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Chip Ledger")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Manage buy-ins and chips")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Game Setup
                VStack(spacing: 16) {
                    Text("Game Configuration")
                        .font(.headline)
                        .fontWeight(.semibold)
                    

                    
                    // Buy-in Credits (Editable)
                    HStack {
                        Text("Buy-in Chips:")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Spacer()

                        TextField("200", value: $gameManager.creditsPerBuyIn, format: .number)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: gameManager.creditsPerBuyIn) { _ in
                                gameManager.updateTotalPotCredits()
                            }

                        Text("Chips")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                            .frame(minWidth: 30)

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
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Total Pot Credits (Display Only)
                    HStack {
                        Text("Total Pot Chips:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(Int(gameManager.totalPotCredits))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)

                        Text("Chips")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                // Selected Group Indicator
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

                // Game Sessions Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.green)
                            .font(.title2)

                        Text("Game Sessions")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()
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
                        LazyVStack(spacing: 12) {
                            ForEach(Array(gameManager.gameSessions.enumerated().reversed()), id: \.element.id) { index, session in
                                GameSessionCard(
                                    session: session,
                                    onTap: {
                                        selectedGameSession = session
                                        gameManager.loadPlayersFromSession(session)
                                        showingGame = true
                                    },
                                    onDelete: {
                                        gameManager.deleteGameSession(at: gameManager.gameSessions.count - 1 - index)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                // Favorite Groups Section
                VStack(spacing: 16) {
                    HStack {
                        Text("Favorite Groups")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Spacer()

                        Button(action: {
                            showingAddGroup = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(Array(gameManager.favoriteGroups.enumerated()), id: \.element.id) { index, group in
                            FavoriteGroupCard(
                                group: group,
                                gameManager: gameManager,
                                isSelected: selectedGroupIndex == index,
                                onSelect: {
                                    // Only load if not already selected
                                    if selectedGroupIndex != index {
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

                Spacer()
                
                // Start Game Button
                Button(action: {
                    // If no players exist (no group selected), generate default players
                    if gameManager.players.isEmpty {
                        gameManager.generateDefaultPlayers()
                    }

                    // Check if there's already an active session with these players
                    let currentPlayerNames = gameManager.players.map { $0.name }
                    if gameManager.hasActiveSessionWithPlayers(currentPlayerNames) {
                        existingActiveSession = gameManager.getActiveSessionWithPlayers(currentPlayerNames)
                        showingDuplicateSessionAlert = true
                    } else {
                        // Create a new game session
                        let newSession = gameManager.createGameSession()
                        selectedGameSession = newSession
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

                        if playerNames.count < 8 {
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
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        playerNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 3
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

                        if playerNames.count < 8 {
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
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        playerNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 3
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

        let updatedGroup = PlayerGroup(name: groupName.trimmingCharacters(in: .whitespacesAndNewlines),
                                     playerNames: validPlayerNames)
        gameManager.updateFavoriteGroup(at: groupIndex, with: updatedGroup)
        dismiss()
    }
}

struct GameSessionCard: View {
    let session: GameSession
    let onTap: () -> Void
    let onDelete: () -> Void

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
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
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
                        Text("Buy-in: $\(Int(session.creditsPerBuyIn))")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text("Pot: $\(Int(session.totalPotCredits))")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
