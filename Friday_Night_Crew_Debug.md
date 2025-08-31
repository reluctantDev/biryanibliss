# Friday Night Crew Black Screen Debug Guide

## 🔍 Issue Investigation: Black Screen on Friday Night Crew Selection

I've added debugging code to help identify why the Friday Night Crew group shows a black screen when selected.

## 🛠️ Debugging Code Added

### **1. Player Loading Debug (Player.swift)**
```swift
func loadPlayersFromGroup(_ group: PlayerGroup) {
    print("Loading group: \(group.name) with \(group.playerNames.count) players")
    // ... existing code ...
    print("Added player: \(playerName)")
    // ... existing code ...
    print("Total players loaded: \(players.count)")
}
```

### **2. GamePlayView Debug (GamePlayView.swift)**
```swift
.onAppear {
    print("GamePlayView appeared with \(gameManager.players.count) players")
    for player in gameManager.players {
        print("Player: \(player.name)")
    }
}
```

### **3. Enhanced Start Game Logic (ContentView.swift)**
- Added validation to ensure players exist before starting game
- Only starts game if `!gameManager.players.isEmpty`

## 🧪 Testing Steps

### **Step 1: Check Console Output**
1. **Open Xcode Console** (View → Debug Area → Console)
2. **Run the app** in simulator
3. **Tap Friday Night Crew** group
4. **Look for debug output**:
   ```
   Loading group: Friday Night Crew with 5 players
   Added player: Alex
   Added player: Jordan
   Added player: Sam
   Added player: Taylor
   Added player: Casey
   Total players loaded: 5
   ```

### **Step 2: Test Game Start**
1. **After selecting Friday Night Crew**
2. **Tap Start Game**
3. **Check console for**:
   ```
   GamePlayView appeared with 5 players
   Player: Alex
   Player: Jordan
   Player: Sam
   Player: Taylor
   Player: Casey
   ```

### **Step 3: Compare with Other Groups**
1. **Test Weekend Warriors** (should work)
2. **Test Poker Pros** (should work)
3. **Compare console output** between working and non-working groups

## 🔍 Potential Causes & Solutions

### **Cause 1: Data Issue**
**Symptoms**: Console shows "Loading group: Friday Night Crew with 0 players"
**Solution**: Check if Friday Night Crew data is corrupted

### **Cause 2: Navigation Issue**
**Symptoms**: Players load correctly but GamePlayView shows black screen
**Solution**: Check if there's a NavigationView conflict

### **Cause 3: Timing Issue**
**Symptoms**: Players load but GamePlayView appears before data is ready
**Solution**: Add delay or ensure proper state updates

### **Cause 4: Memory Issue**
**Symptoms**: App crashes or shows black screen randomly
**Solution**: Check for memory leaks or retain cycles

## 🔧 Quick Fixes to Try

### **Fix 1: Force Refresh GamePlayView**
Add this to ContentView Start Game button:
```swift
// Force a small delay to ensure data is loaded
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    showingGame = true
}
```

### **Fix 2: Add Validation Check**
Ensure GamePlayView has players before rendering:
```swift
// In GamePlayView body
if gameManager.players.isEmpty {
    Text("Loading players...")
        .font(.headline)
        .foregroundColor(.secondary)
} else {
    // Existing GamePlayView content
}
```

### **Fix 3: Reset and Reload**
Try clearing and reloading the Friday Night Crew:
```swift
// In selection logic
gameManager.players.removeAll()
gameManager.loadPlayersFromGroup(group)
```

## 📋 Debugging Checklist

### **Console Output Checks**
- [ ] Friday Night Crew loads with 5 players
- [ ] All 5 player names appear in console
- [ ] GamePlayView appears with 5 players
- [ ] No error messages in console

### **Visual Checks**
- [ ] Friday Night Crew highlights when selected
- [ ] Green banner shows "5 players ready"
- [ ] Start Game button is enabled
- [ ] GamePlayView shows content (not black screen)

### **Comparison Tests**
- [ ] Weekend Warriors works correctly
- [ ] Poker Pros works correctly
- [ ] Default player generation works
- [ ] Only Friday Night Crew has issues

## 🚨 Emergency Workaround

If the issue persists, here's a temporary fix:

### **Replace Friday Night Crew Data**
```swift
// In loadDefaultFavoriteGroups()
PlayerGroup(name: "Friday Night Crew", playerNames: ["Player1", "Player2", "Player3", "Player4", "Player5"])
```

### **Or Delete and Recreate**
1. **Delete Friday Night Crew** (long press → delete)
2. **Create new group** with same name
3. **Add players manually**: Alex, Jordan, Sam, Taylor, Casey

## 📞 Next Steps

### **If Console Shows Correct Data**
- Issue is in GamePlayView rendering
- Check for NavigationView conflicts
- Verify ZStack and ScrollView structure

### **If Console Shows No Players**
- Issue is in data loading
- Check PlayerGroup data integrity
- Verify loadPlayersFromGroup function

### **If Console Shows Errors**
- Check error messages for specific issues
- Look for memory warnings
- Check for nil pointer exceptions

## 🔄 Removing Debug Code

Once issue is identified, remove debug prints:
```swift
// Remove these lines from Player.swift
print("Loading group: \(group.name) with \(group.playerNames.count) players")
print("Added player: \(playerName)")
print("Total players loaded: \(players.count)")

// Remove these lines from GamePlayView.swift
.onAppear {
    print("GamePlayView appeared with \(gameManager.players.count) players")
    for player in gameManager.players {
        print("Player: \(player.name)")
    }
}
```

Run the app and check the console output to help identify what's causing the black screen issue! 🔍✨
