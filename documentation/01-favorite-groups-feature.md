# Favorite Groups Feature

## 🎯 Overview

The Favorite Groups feature allows users to save and quickly load predefined player groups, dramatically reducing setup time for regular poker games.

## ✨ Key Features

### **Quick Player Setup**
- **One-tap loading** of complete player groups
- **Pre-configured defaults** ready to use immediately
- **Custom group creation** with 3-12 players
- **Visual card interface** for easy selection

### **Default Groups Included**
1. **Weekend Warriors** (4 players): Morgan, Riley, Avery, Quinn
2. **Poker Pros** (6 players): Blake, Cameron, Drew, Emery, Finley, Harper

### **Group Management**
- **Create unlimited groups** with custom names
- **Edit existing groups** including defaults
- **Delete unwanted groups** with confirmation
- **Visual highlighting** for selected groups

## 📱 User Interface

### **Group Cards Display**
- **2-column grid layout** for optimal space usage
- **Player count badges** showing group size
- **Player preview** with first 3 names + overflow indicator
- **Selection highlighting** with blue borders and scaling

### **Add/Edit Group Interface**
- **Clean modal forms** for group creation/editing
- **Dynamic player fields** (3-12 players supported)
- **Real-time validation** ensuring minimum requirements
- **Intuitive add/remove** player functionality

## 🎮 User Workflow

### **Using Existing Groups**
1. **View groups** on main screen
2. **Tap group card** to select and highlight
3. **See selection banner** with player count
4. **Start game** with pre-loaded players

### **Creating Custom Groups**
1. **Tap + button** in Favorite Groups section
2. **Enter group name** and player names
3. **Add/remove players** as needed (3-8 total)
4. **Save group** for future use

### **Managing Groups**
- **Long press** any group for context menu
- **Edit** to modify names and players
- **Delete** to remove unwanted groups
- **Select** to load players immediately

## 🔧 Technical Implementation

### **Data Model**
```swift
struct PlayerGroup: Identifiable, Codable {
    let id = UUID()
    var name: String
    var playerNames: [String]
    var dateCreated: Date
}
```

### **Core Methods**
- `loadDefaultFavoriteGroups()` - Initialize default groups
- `addFavoriteGroup(_:)` - Add new group
- `updateFavoriteGroup(at:with:)` - Edit existing group
- `removeFavoriteGroup(at:)` - Delete group
- `loadPlayersFromGroup(_:)` - Load players from group

### **UI Components**
- **FavoriteGroupCard** - Individual group display
- **AddFavoriteGroupView** - Group creation form
- **EditFavoriteGroupView** - Group editing form

## ✅ Benefits

### **Time Savings**
- **Instant setup** for regular games
- **No re-typing** of player names
- **Quick group switching** for different occasions

### **Organization**
- **Named groups** for easy identification
- **Visual overview** of all saved groups
- **Flexible management** with full CRUD operations

### **Professional Use**
- **Tournament ready** with pre-configured groups
- **Club management** for different player sets
- **Event organization** with specific groups

## 🎯 Best Practices

### **Group Naming**
- Use **descriptive names** like "Friday Night Crew"
- Include **occasion** or **frequency** in names
- Keep names **short** for better display

### **Player Management**
- Use **real names** for actual games
- Keep **consistent spelling** across groups
- Consider **nickname preferences** of players

### **Organization**
- Create groups for **different occasions**
- Delete **unused groups** to keep list clean
- Edit groups when **players change**

---

The Favorite Groups feature transforms ChipTally from a simple tracker into a comprehensive poker session management tool! 🎰✨
