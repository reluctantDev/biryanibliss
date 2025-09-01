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

                        Text("Chip Ledger")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)

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

                // Players List
                LazyVStack(spacing: 12) {
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
                .padding(.horizontal, 12)
                
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
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.subheadline)

                                Text("Restart")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
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
        .alert("Restart Game", isPresented: $showingRestartAlert) {
            Button("Restart", role: .destructive) {
                // Update session before resetting
                if let session = gameSession {
                    var updatedSession = session
                    updatedSession.players = gameManager.players
                    gameManager.updateGameSession(updatedSession)
                }

                gameManager.resetGame()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset the entire game and return to setup. Are you sure?")
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
    
    var body: some View {
        VStack(spacing: 12) {
            // Player Header with Editable Name
            HStack {
                // Player Avatar
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(player.name.prefix(1)).uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )

                // Player Name (Editable)
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .onTapGesture {
                            tempName = player.name
                            showingNameInput = true
                        }

                    Text("Tap to edit")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Edit Name Button
                Button(action: {
                    tempName = player.name
                    showingNameInput = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            // Buy-ins and Credits in single row
            HStack {
                // Buy-ins
                HStack(spacing: 4) {
                    Text("Buy-ins:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        if player.buyIns > 1 {
                            onBuyInsChange(player.buyIns - 1)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Text("\(player.buyIns)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(minWidth: 20)

                    Button(action: {
                        onBuyInsChange(player.buyIns + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                // Initial Credits (Non-editable)
                HStack(spacing: 4) {
                    Text("Initial Credits:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(player.totalCredits))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .frame(minWidth: 30)
                }
            }

        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
    }
}

struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        GamePlayView(gameManager: GameManager(), gameSession: nil)
    }
}
