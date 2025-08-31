# Edit & Delete Groups

## 🎯 Overview

The Edit & Delete Groups feature provides complete CRUD (Create, Read, Update, Delete) operations for favorite player groups, allowing users to fully customize and manage their saved groups.

## ✨ Key Features

### **Full Group Management**
- **Edit any group**: Modify names and player lists for all groups
- **Delete any group**: Remove unwanted groups including defaults
- **No restrictions**: Complete control over all saved groups
- **Context menu access**: Long press for management options

### **Edit Functionality**
- **Pre-filled forms**: Current group data loaded automatically
- **Dynamic fields**: Add/remove players (3-8 supported)
- **Real-time validation**: Ensures minimum requirements
- **Save/cancel options**: Standard form controls

## 📱 User Interface

### **Context Menu Access**
Long press any group card to reveal:
1. **🔵 Select Group** - Load players (same as tap)
2. **✏️ Edit Group** - Open edit form
3. **🗑️ Delete Group** - Remove group (red/destructive)

### **Edit Group Form**
- **Modal presentation**: Clean overlay interface
- **Group name field**: Editable text input
- **Player list**: Dynamic fields for each player
- **Add/remove controls**: Buttons to manage player count
- **Navigation bar**: Cancel/Save buttons

### **Form Validation**
- **Required fields**: Group name and minimum 3 players
- **Real-time feedback**: Save button enabled/disabled based on validity
- **Error prevention**: Cannot save invalid configurations

## 🎮 User Workflow

### **Editing a Group**
1. **Long press** any group card
2. **Select "Edit Group"** from context menu
3. **Modify** group name and/or player list
4. **Add/remove players** as needed (3-8 total)
5. **Save changes** or **Cancel** to discard

### **Deleting a Group**
1. **Long press** any group card
2. **Select "Delete Group"** (red option)
3. **Group removed** immediately from list
4. **UI updates** automatically

### **Managing Default Groups**
- **Weekend Warriors**: Can be edited to match your actual weekend group
- **Poker Pros**: Customize for your regular tournament players
- **Full customization**: Make default groups truly your own

## 🔧 Technical Implementation

### **State Management**
```swift
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
```

### **Core Methods**
```swift
func updateFavoriteGroup(at index: Int, with updatedGroup: PlayerGroup) {
    if index < favoriteGroups.count {
        favoriteGroups[index] = updatedGroup
    }
}

func removeFavoriteGroup(at index: Int) {
    if index < favoriteGroups.count {
        favoriteGroups.remove(at: index)
    }
}
```

### **UI Components**
- **EditFavoriteGroupView**: Complete edit interface
- **Context menus**: Long press interaction
- **Form validation**: Real-time input checking

## ✅ Key Benefits

### **Complete Control**
- **No restrictions**: Edit or delete any group including defaults
- **Full customization**: Make all groups match your actual players
- **Flexible management**: Add, edit, delete as needs change
- **Persistent changes**: All modifications saved automatically

### **User-Friendly Design**
- **Familiar interface**: Standard iOS context menu pattern
- **Clear actions**: Obvious icons and labels for each option
- **Destructive indication**: Delete action clearly marked in red
- **Consistent UI**: Edit form matches add form design

### **Data Safety**
- **Form validation**: Prevents invalid group configurations
- **Immediate feedback**: Real-time validation during editing
- **Cancel option**: Can discard changes without saving
- **No data loss**: Editing preserves existing data until saved

## 🎯 Use Cases

### **Personalizing Default Groups**
1. **Edit "Weekend Warriors"** → Change to "Saturday Night Poker"
2. **Replace default names** → Add your actual friends' names
3. **Adjust player count** → Match your typical group size
4. **Save changes** → Now perfectly customized for your group

### **Seasonal Updates**
1. **Edit existing groups** when regular players change
2. **Add new players** who join your games
3. **Remove players** who no longer participate
4. **Update group names** for clarity or seasons

### **Event-Specific Groups**
1. **Create tournament groups** for special events
2. **Edit after events** to reflect actual participants
3. **Delete temporary groups** after one-time events
4. **Maintain core groups** for regular games

## 🔄 Management Workflow

### **Group Lifecycle**
1. **Create**: Add new group with initial players
2. **Use**: Select and load for games
3. **Edit**: Modify as players or preferences change
4. **Delete**: Remove when no longer needed

### **Maintenance Best Practices**
- **Regular updates**: Keep groups current with active players
- **Clear naming**: Use descriptive names for easy identification
- **Clean organization**: Remove unused groups periodically
- **Backup important**: Consider recreating critical groups if deleted

## 🛠️ Technical Details

### **Edit Form Features**
- **Pre-population**: Loads current group data automatically
- **Dynamic fields**: Player list expands/contracts as needed
- **Validation logic**: Ensures 3-8 players and valid group name
- **State persistence**: Maintains form state during editing

### **Delete Functionality**
- **Immediate removal**: Groups deleted instantly from list
- **Index management**: Proper handling of array indices
- **UI updates**: Automatic refresh of group display
- **No confirmation**: Standard iOS pattern for context menu deletion

### **Error Handling**
- **Bounds checking**: Validates indices before operations
- **State cleanup**: Proper cleanup of editing state
- **Graceful degradation**: Handles edge cases smoothly

## ✨ Advanced Features

### **Smart Editing**
- **Minimum field guarantee**: Always shows at least 5 player fields
- **Add/remove controls**: Dynamic player management
- **Real-time validation**: Immediate feedback on form validity
- **Keyboard handling**: Proper text input management

### **Context-Aware Actions**
- **Selection preservation**: Maintains selected group during edits
- **Index tracking**: Proper management during deletions
- **State synchronization**: Keeps UI and data in sync

## ✅ Complete CRUD Operations

The Edit & Delete Groups feature provides:
- ✅ **Create** new groups with custom names and players
- ✅ **Read** and display all groups with visual cards
- ✅ **Update** any group including defaults with full editing
- ✅ **Delete** any group with simple context menu action
- ✅ **Validate** all operations to ensure data integrity
- ✅ **Persist** all changes automatically

---

Edit & Delete Groups gives users complete control over their favorite groups, making ChipTally truly customizable for any poker environment! ✏️🗑️✨
