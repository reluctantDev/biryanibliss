# Active Session Validation

## 🎯 Overview

The Active Session Validation system prevents creating duplicate active sessions with the same group of players, ensuring clean session management and preventing user confusion.

## 🛡️ Validation Logic

### **Duplicate Prevention**
- **Player set comparison**: Uses Set comparison for exact matching
- **Active session detection**: Only considers non-completed sessions
- **Real-time validation**: Checks current state at creation time
- **Smart blocking**: Allows new sessions after completion

### **Validation Trigger**
- **Before session creation**: Validates when "Start Game" is clicked
- **Same player detection**: Compares complete player name sets
- **Alert presentation**: Shows options when conflict detected
- **User choice**: Resume existing or cancel creation

## 📱 User Experience

### **Normal Flow (No Conflict)**
1. **Select group** → Green banner with checkmark
2. **Click "Start Game"** → Creates session normally
3. **Session appears** → Orange "In Progress" badge

### **Conflict Flow (Active Session Exists)**
1. **Select group** → Orange banner with warning triangle
2. **Banner shows**: "Active game: Game X"
3. **Click "Start Game"** → Alert dialog appears
4. **Choose option**: Resume existing or cancel

### **Alert Dialog**
```
🚨 Active Game Found

There's already an active game 'Game 1' with these players. 
You can resume the existing game or wait until it's completed 
to start a new one.

[Resume Existing Game] [Cancel]
```

## 🎨 Visual Indicators

### **Group Selection Banner**

#### **Available Group (No Conflict)**
- **Green banner** with checkmark icon
- **Text**: "Selected Group: Weekend Warriors"
- **Status**: "4 players loaded"
- **Color scheme**: Green background and borders

#### **Active Session Warning (Conflict)**
- **Orange banner** with warning triangle
- **Text**: "Selected Group: Weekend Warriors"
- **Warning**: "Active game: Game 1"
- **Color scheme**: Orange background and borders

### **Session Status Badges**

#### **In Progress Sessions**
- **Orange badge** with play icon
- **Background**: Orange tinted with rounded corners
- **Text**: "In Progress" with medium font weight
- **Icon**: Play circle fill

#### **Completed Sessions**
- **Green badge** with checkmark icon
- **Background**: Green tinted with rounded corners
- **Text**: "Completed" with medium font weight
- **Icon**: Checkmark circle fill

## 🔧 Technical Implementation

### **Validation Methods**
```swift
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
```

### **UI State Management**
```swift
@State private var showingDuplicateSessionAlert = false
@State private var existingActiveSession: GameSession?
```

### **Validation Flow**
1. **Check players**: Get current player names
2. **Validate**: Check for active sessions with same players
3. **Branch logic**: Create session or show alert
4. **User choice**: Resume existing or cancel

## ✨ Key Features

### **Smart Validation**
- **Exact matching**: Compares complete player sets using Set comparison
- **Status awareness**: Only blocks active (non-completed) sessions
- **Real-time checking**: Validates at the moment of creation
- **Flexible rules**: Allows new sessions after previous completion

### **Enhanced Visual Design**
- **Color coding**: Orange for warnings, green for available
- **Icon integration**: Warning triangles and status icons
- **Prominent badges**: Clear status indicators with backgrounds
- **Consistent design**: Unified color scheme across features

### **User-Friendly Workflow**
- **Clear messaging**: Explains why duplicate isn't allowed
- **Resume option**: Easy access to existing active game
- **Cancel option**: Return to setup without creating session
- **Visual feedback**: Immediate indication of conflicts

## 🎯 Benefits

### **Prevents Confusion**
- **No duplicate games**: Eliminates multiple active sessions with same players
- **Clear game state**: Always know which session is active
- **Organized history**: Clean, logical session progression
- **Reduced errors**: Prevents accidental duplicate creation

### **Improved User Experience**
- **Visual clarity**: Obvious status indicators and warnings
- **Smart suggestions**: Automatic resume option for existing games
- **Conflict resolution**: Clear choices when conflicts arise
- **Professional interface**: Polished session management

### **Data Integrity**
- **Consistent state**: No conflicting active sessions in system
- **Proper tracking**: Accurate game status monitoring
- **Clean organization**: Logical session flow and management
- **Reliable validation**: Robust duplicate detection algorithm

## 📋 Usage Scenarios

### **Weekly Poker Night**
1. **Week 1**: Create "Game 1" with Friday Night Crew → In Progress
2. **Same week**: Try to create another with same players → Alert appears
3. **Options**: Resume Game 1 or wait until completed
4. **Week 2**: After Game 1 completed → Can create Game 2 normally

### **Tournament Management**
1. **Round 1**: Create sessions for different player groups
2. **Attempt duplicate**: Try to create session with same group → Blocked
3. **Resume option**: Continue existing session instead
4. **Round 2**: After completion → Create new sessions normally

### **Multi-Table Events**
1. **Table 1**: Create session with Group A → Active
2. **Table 2**: Create session with Group B → Active (different players)
3. **Table 1 duplicate**: Try Group A again → Validation blocks
4. **Resume**: Continue existing Table 1 session

## 🔄 Validation States

### **Available for New Session**
- **Green indicators**: Checkmark icons and green banners
- **Clear messaging**: "X players loaded" and ready
- **Normal flow**: "Start Game" creates session immediately

### **Active Session Conflict**
- **Orange indicators**: Warning triangles and orange banners
- **Conflict messaging**: "Active game: Game X" warning
- **Blocked flow**: "Start Game" shows alert instead of creating

### **Post-Completion**
- **Return to available**: After session marked completed
- **Green indicators**: Back to normal creation flow
- **New session allowed**: Can create fresh session with same players

## ✅ Complete Validation System

The Active Session Validation provides:
- ✅ **Duplicate prevention** with intelligent player matching
- ✅ **Visual warning system** with color-coded indicators
- ✅ **User-friendly alerts** with clear resolution options
- ✅ **Resume functionality** for existing active sessions
- ✅ **Professional status management** with consistent design
- ✅ **Real-time validation** at session creation
- ✅ **Clean session organization** without conflicts

---

Active Session Validation ensures ChipTally maintains clean, organized session management while providing clear visual feedback and intuitive conflict resolution! 🛡️✨
