import SwiftUI

struct GamePlayView: View {
    @ObservedObject var gameManager: GameManager
    let gameSession: GameSession?
    @Environment(\.dismiss) private var dismiss
    @State private var showingGameEnd = false
    @State private var showingRestartAlert = false
    @State private var showingAddPlayer = false
    @State private var showingBuyInConfirmation = false
    @State private var pendingBuyInAmount: Double = 0.0
    @State private var originalBuyInAmount: Double = 0.0

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationView {
            if gameManager.players.isEmpty {
                // Show loading state if no players
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("No Players Loaded")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Please go back and select a group")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button("Go Back") {
                        dismiss()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
            } else {
                // Normal game view
            ZStack {
                // Subtle bouncing animation in background
                SimpleBouncingView(imageName: "dollarsign.circle.fill", imageSize: 20)
                    .position(x: 350, y: 80)
                    .opacity(0.2)

                ScrollView {
                    VStack(spacing: 12) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        VStack(spacing: 2) {
                            HStack(spacing: 8) {
                                Text(gameSession?.name ?? "Current Game")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)

                                if let session = gameSession {
                                    Circle()
                                        .fill(session.isCompleted ? Color.gray : Color.green)
                                        .frame(width: 8, height: 8)
                                }
                            }

                            if let session = gameSession {
                                Text("Started: \(session.dateCreated, formatter: timeFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Button(action: {
                            // Show game options
                        }) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Game Summary
                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("Buy-in Amount")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Button(action: {
                                originalBuyInAmount = gameManager.creditsPerBuyIn
                                pendingBuyInAmount = gameManager.creditsPerBuyIn
                                showingBuyInConfirmation = true
                            }) {
                                Text("\(Int(gameManager.creditsPerBuyIn))")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                                    .underline()
                            }
                        }

                        VStack(spacing: 2) {
                            Text("Players")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(gameManager.players.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }

                        VStack(spacing: 2) {
                            Text("Total Credits")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(gameManager.getTotalPotInCredits()))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(12)
                .background(Color(.systemBackground))

                // Players Section
                VStack(alignment: .leading, spacing: 16) {
                    // Section Header
                    HStack {
                        Text("Players")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(.primary)

                        Spacer()

                        Text("\(gameManager.players.count) players")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)

                    // Players List
                    LazyVStack(spacing: 16) {
                        ForEach(Array(gameManager.players.enumerated()), id: \.element.id) { index, player in
                            PlayerGameCard(
                                player: player,
                                onNameChange: { newName in
                                    gameManager.updatePlayerName(playerId: player.id, newName: newName)
                                },
                                onBuyInsChange: { newBuyIns in
                                    gameManager.updatePlayerBuyIns(playerId: player.id, newBuyIns: newBuyIns)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Action Buttons
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Button(action: {
                            showingGameEnd = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "flag.checkered.circle.fill")
                                    .font(.subheadline)

                                Text("End Game")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(16)
                        }

                        Button(action: {
                            showingRestartAlert = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.subheadline)

                                Text("Abandon")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.indigo)
                            .cornerRadius(16)
                        }
                    }

                    Button(action: {
                        showingAddPlayer = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.subheadline)

                            Text("Add Player")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(16)
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Back to Setup")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                .padding(12)
                .background(Color(.systemBackground))
                }
                .padding(.bottom, 12)
                }
                .background(Color(.systemGray6))
            }
            .navigationBarHidden(true)
            } // Close else block
        }
        .sheet(isPresented: $showingGameEnd) {
            GameEndView(gameManager: gameManager, isPresented: $showingGameEnd, gameSession: gameSession, onNewGame: {
                // Dismiss GamePlayView to go back to ContentView
                dismiss()
            })
        }
        .alert("Abandon Game", isPresented: $showingRestartAlert) {
            Button("Abandon", role: .destructive) {
                // Delete the session since user is abandoning the game
                if let session = gameSession {
                    if let index = gameManager.gameSessions.firstIndex(where: { $0.id == session.id }) {
                        gameManager.deleteGameSession(at: index)
                    }
                }

                gameManager.resetGame()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will abandon the current game and return to setup. The session will be permanently deleted. Are you sure?")
        }
        .alert("Change Buy-in Amount", isPresented: $showingBuyInConfirmation) {
            TextField("Buy-in amount", value: $pendingBuyInAmount, format: .number)
                .keyboardType(.decimalPad)

            Button("Confirm") {
                // Apply the new buy-in amount
                gameManager.creditsPerBuyIn = pendingBuyInAmount
                gameManager.updateTotalPotCredits()

                // Update all existing players' credits to match new buy-in
                for i in 0..<gameManager.players.count {
                    gameManager.players[i].totalCredits = pendingBuyInAmount * Double(gameManager.players[i].buyIns)
                }
            }

            Button("Cancel", role: .cancel) {
                // Reset to original amount
                pendingBuyInAmount = originalBuyInAmount
            }
        } message: {
            Text("Are you sure you want to change the buy-in amount from \(Int(originalBuyInAmount)) to \(Int(pendingBuyInAmount)) chips? This will update all players' credits accordingly.")
        }
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerView(
                gameManager: gameManager,
                isPresented: $showingAddPlayer
            )
        }
    }
}

struct PlayerGameCard: View {
    let player: Player
    let onNameChange: (String) -> Void
    let onBuyInsChange: (Int) -> Void

    @State private var showingNameInput = false
    @State private var tempName = ""
    @State private var showingBuyInConfirmation = false

    private var playerInitials: String {
        let components = player.name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            return String(player.name.prefix(2)).uppercased()
        }
    }

    private var avatarColor: Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .indigo]
        let hash = abs(player.name.hashValue)
        return colors[hash % colors.count]
    }

    var body: some View {
        HStack(spacing: 16) {
            // Enhanced Player Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [avatarColor.opacity(0.8), avatarColor.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Text(playerInitials)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: avatarColor.opacity(0.3), radius: 4, x: 0, y: 2)

            // Player Info Section
            VStack(alignment: .leading, spacing: 8) {
                // Player Name with Edit Button
                HStack(spacing: 8) {
                    Text(player.name)
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Button(action: {
                        tempName = player.name
                        showingNameInput = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }

                // Stats Row
                HStack(spacing: 20) {
                    // Buy-ins Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Buy-ins")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        HStack(spacing: 8) {
                            // Buy-in Display with Indicator
                            HStack(spacing: 4) {
                                Text("\(player.buyIns)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                if player.buyIns > 1 {
                                    HStack(spacing: 2) {
                                        Text("(1")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.blue)

                                        Text("+\(player.buyIns - 1)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.orange)

                                        Text(")")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }

                            // Add Buy-in Button
                            Button(action: {
                                showingBuyInConfirmation = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // Additional Buy-ins Indicator
                        if player.buyIns > 1 {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)

                                Text("\(player.buyIns - 1) additional buy-in\(player.buyIns > 2 ? "s" : "")")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        }
                    }

                    // Credits Section
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Credits")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        Text("\(Int(player.totalCredits))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    }

                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(player.name), \(player.buyIns) buy-ins, \(Int(player.totalCredits)) credits")
        .alert("Edit Player Name", isPresented: $showingNameInput) {
            TextField("Player name", text: $tempName)
                .textInputAutocapitalization(.words)

            Button("Update") {
                let trimmedName = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedName.isEmpty && trimmedName.count >= 2 {
                    onNameChange(trimmedName)
                }
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter new name for this player")
        }
        .alert("Add Buy-in", isPresented: $showingBuyInConfirmation) {
            Button("Confirm") {
                onBuyInsChange(player.buyIns + 1)
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            let buyInAmount = Int(player.totalCredits / Double(player.buyIns))
            Text("\(player.name) will receive an additional buy-in worth \(buyInAmount) credits.")
        }
    }
}

struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        GamePlayView(gameManager: GameManager(), gameSession: nil)
    }
}
