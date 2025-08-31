import SwiftUI

struct AddPlayerView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @State private var playerName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Add New Player")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Enter player name to add to the game")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Player Name Input
                VStack(spacing: 16) {
                    Text("Player Name")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Enter player name", text: $playerName)
                        .font(.title3)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            addPlayer()
                        }
                    
                    // Available Slots Info
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        
                        Text("\(gameManager.numberOfPlayers - gameManager.players.count) slot(s) remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Current Players Preview
                if !gameManager.players.isEmpty {
                    VStack(spacing: 16) {
                        Text("Current Players")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(gameManager.players) { player in
                                    HStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Text(String(player.name.prefix(1)).uppercased())
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.blue)
                                            )
                                        
                                        Text(player.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(player.totalCredits)) Credits")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: addPlayer) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            
                            Text("Add Player")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(playerName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(25)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(playerName.isEmpty)
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addPlayer() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        if trimmedName.isEmpty {
            alertMessage = "Please enter a player name"
            showingAlert = true
            return
        }
        
        if trimmedName.count < 2 {
            alertMessage = "Player name must be at least 2 characters long"
            showingAlert = true
            return
        }
        
        // Check for duplicate names
        if gameManager.players.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            alertMessage = "A player with this name already exists"
            showingAlert = true
            return
        }
        
        // Check if we have room for more players
        if gameManager.players.count >= gameManager.numberOfPlayers {
            alertMessage = "Maximum number of players reached"
            showingAlert = true
            return
        }
        
        // Add the player
        gameManager.addPlayer(name: trimmedName)
        playerName = ""
        isPresented = false
    }
}

struct AddPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerView(
            gameManager: GameManager(),
            isPresented: .constant(true)
        )
    }
}
