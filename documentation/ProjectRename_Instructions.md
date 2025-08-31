# Project Rename Instructions: biryanibliss → chiptally

## Files Updated by AI Assistant

### ✅ Code Files Updated
1. **biryaniblissApp.swift** → **chiptallyApp.swift**
   - Updated struct name: `biryaniblissApp` → `chiptallyApp`
   - Updated file header comment

2. **ContentView.swift**
   - Updated file header comment to reference `chiptally`

3. **BouncingImageView.swift**
   - Added file header comment with `chiptally` reference

### ✅ Test Files Updated
1. **biryaniblissTests.swift** → **chiptallyTests.swift**
   - Updated struct name: `biryaniblissTests` → `chiptallyTests`
   - Updated import: `@testable import biryanibliss` → `@testable import chiptally`
   - Updated file header comments

2. **PlayerTests.swift**
   - Updated import and file header

3. **GameLogicTests.swift**
   - Updated import and file header

4. **PerformanceTests.swift**
   - Updated import and file header

5. **ValidationTests.swift**
   - Updated import and file header

### ✅ UI Test Files Updated
1. **biryaniblissUITests.swift** → **chiptallyUITests.swift**
   - Updated class name: `biryaniblissUITests` → `chiptallyUITests`
   - Updated file header

2. **AppFlowUITests.swift**
   - Updated file header

### ✅ Documentation Updated
1. **TestPlan.md**
   - Updated all references from "BiryaniBliss" to "ChipTally"
   - Updated test command examples
   - Updated file and folder references

## Manual Steps Required in Xcode

### 1. Rename the Project
1. **Select the project** in Xcode Navigator
2. **Click on the project name** at the top
3. **Change "biryanibliss" to "chiptally"**
4. **Press Enter** and confirm the rename

### 2. Rename the App Target
1. **Select the app target** under the project
2. **Change target name** from "biryanibliss" to "chiptally"
3. **Update Bundle Identifier** (e.g., `com.yourname.chiptally`)

### 3. Rename Test Targets
1. **Rename "biryaniblissTests"** to **"chiptallyTests"**
2. **Rename "biryaniblissUITests"** to **"chiptallyUITests"**

### 4. Rename Schemes
1. **Go to Product → Scheme → Manage Schemes**
2. **Rename "biryanibliss"** to **"chiptally"**
3. **Update test schemes** if needed

### 5. Rename Folders (Optional but Recommended)
1. **Rename "biryanibliss" folder** to **"chiptally"**
2. **Rename "biryaniblissTests" folder** to **"chiptallyTests"**
3. **Rename "biryaniblissUITests" folder** to **"chiptallyUITests"**

### 6. Update File Names in Xcode
1. **Rename "biryaniblissApp.swift"** to **"chiptallyApp.swift"**
2. **Rename test files** as indicated above

### 7. Clean and Rebuild
1. **Product → Clean Build Folder** (⌘+Shift+K)
2. **Build the project** (⌘+B) to ensure everything works

## Verification Checklist

### ✅ Code Verification
- [ ] Project builds successfully
- [ ] App launches without errors
- [ ] All functionality works as expected
- [ ] No build warnings or errors

### ✅ Test Verification
- [ ] Unit tests run successfully
- [ ] UI tests run successfully
- [ ] All test targets are properly renamed
- [ ] Test coverage reports show correct project name

### ✅ App Store Preparation
- [ ] Bundle identifier updated
- [ ] App name in Info.plist updated
- [ ] Display name updated (if different from bundle name)
- [ ] All references to old name removed

## Benefits of "ChipTally" Name

### ✅ Better App Store Presence
- **Clear Purpose**: "Chip" + "Tally" clearly indicates poker/gaming credit management
- **Memorable**: Short, catchy name that's easy to remember
- **Professional**: Sounds like a dedicated gaming tool
- **Searchable**: Better keywords for App Store discovery

### ✅ User Understanding
- **Immediate Recognition**: Users instantly understand it's for chip/credit tracking
- **Gaming Context**: Clearly positioned in the gaming/poker space
- **Professional Tool**: Suggests serious gaming management

## Post-Rename Testing

### Required Tests
1. **Build and Run**: Ensure app launches correctly
2. **All Features**: Test complete user flow from setup to leaderboard
3. **Tests**: Run all unit and UI tests
4. **Archive**: Test app archiving for App Store submission

### App Store Submission
- Update app name in App Store Connect
- Update keywords and description
- Ensure all metadata reflects new name
- Test app installation from TestFlight

## Notes
- All code functionality remains exactly the same
- Only naming and branding have changed
- Comprehensive test suite ensures quality is maintained
- Ready for App Store submission with new name
