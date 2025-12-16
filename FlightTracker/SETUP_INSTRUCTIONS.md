# Flight Tracker - Xcode Setup Instructions

## Prerequisites
- macOS Monterey or later
- Xcode 15.0 or later
- iOS 17.0+ SDK

## Quick Start

### Method 1: Open in Xcode (Recommended)
1. Download and extract the `FlightTracker` folder
2. Double-click `FlightTracker.xcodeproj` to open in Xcode
3. Select a simulator (iPhone 15 Pro recommended) or connect your iOS device
4. Press `Cmd + R` or click the Play button to build and run

### Method 2: Manual Setup (if needed)
If the project doesn't open correctly:

1. **Create New Xcode Project:**
   - Open Xcode
   - File → New → Project
   - Choose "iOS" → "App"
   - Product Name: `FlightTracker`
   - Interface: SwiftUI
   - Language: Swift
   - Click "Next" and save

2. **Replace Files:**
   - Delete the default `ContentView.swift` and `FlightTrackerApp.swift`
   - Drag all folders from the downloaded project into your new project:
     - Models/
     - Services/
     - Views/
   - Drag the main files:
     - FlightTrackerApp.swift
     - ContentView.swift
   - When prompted, select "Copy items if needed"

## Project Structure

```
FlightTracker/
├── FlightTracker.xcodeproj/        # Xcode project file
│   └── project.pbxproj
└── FlightTracker/                   # Source code
    ├── FlightTrackerApp.swift      # App entry point
    ├── ContentView.swift            # Main navigation
    ├── Models/                      # Data models
    │   ├── Flight.swift
    │   ├── User.swift
    │   ├── PriceHistory.swift
    │   └── WatchlistItem.swift
    ├── Services/                    # Business logic
    │   ├── DuffelAPIService.swift
    │   ├── DataManager.swift
    │   └── NotificationManager.swift
    ├── Views/                       # UI views
    │   ├── SearchView.swift
    │   ├── WatchlistView.swift
    │   ├── PriceHistoryView.swift
    │   ├── AccountView.swift
    │   ├── FlightDetailView.swift
    │   ├── SupportingViews.swift
    │   └── Components/
    │       └── ComponentViews.swift
    └── Assets.xcassets/             # App assets
        ├── AppIcon.appiconset/
        └── AccentColor.colorset/
```

## Configuration

### 1. Update Duffel API Key
The test API key is already included in `DuffelAPIService.swift`:
```swift
private let apiKey = "duffel_test_nQJcuQAfxqpTTa2r0Rw73CYBq_Qo-jyerBvCSjZHqMn"
```

To use your own API key:
1. Open `Services/DuffelAPIService.swift`
2. Replace the `apiKey` value on line 16
3. Save the file

### 2. Configure Signing & Capabilities
1. Select the project in the Navigator
2. Select the "FlightTracker" target
3. Go to "Signing & Capabilities"
4. Select your Development Team (or leave blank for simulator)
5. Xcode will automatically handle the bundle identifier

### 3. Enable Notifications (Optional)
To test push notifications on a real device:
1. In "Signing & Capabilities", click "+ Capability"
2. Add "Push Notifications"
3. Notifications will work in the simulator without this

## Building and Running

### Simulator (No Apple Developer Account Needed)
1. Select any iPhone simulator from the device menu (iPhone 15 Pro recommended)
2. Press `Cmd + R` or click the Play button
3. App will launch in the simulator

### Physical Device (Requires Apple Developer Account)
1. Connect your iPhone via USB
2. Trust the computer on your device
3. Select your device from the device menu
4. First time: Go to Settings → General → VPN & Device Management on your iPhone
5. Trust your developer certificate
6. Press `Cmd + R` to run

## Testing the App

### 1. Search for Flights
- Open the "Search" tab
- Enter:
  - Origin: LAX (Los Angeles)
  - Destination: JFK (New York)
  - Select a future date
  - Click "Search Flights"

### 2. Add to Watchlist
- Tap any flight card
- Click "Add to Watchlist"
- Set a target price (optional)
- Add notes (optional)
- Click "Save"

### 3. View Price History
- Go to "History" tab
- View price trends for searched routes
- Tap any route for detailed chart

### 4. Manage Account
- Go to "Account" tab
- Update profile information
- Set notification preferences
- Configure luggage preferences

## Troubleshooting

### Build Errors

**"Cannot find type 'Flight' in scope"**
- Solution: Make sure all files are added to the target
- Right-click each file → Show File Inspector → Check "Target Membership"

**"No such module 'Charts'"**
- Solution: The Charts framework is built into iOS 16+
- Make sure deployment target is iOS 17.0 (already set in project)

**"Command CodeSign failed"**
- Solution: This is a signing issue
- Either use simulator (no signing needed)
- Or add your Apple ID in Xcode → Settings → Accounts

### Runtime Issues

**"Network request failed"**
- The Duffel test API key is rate-limited
- Wait a few minutes and try again
- Or sign up for your own test key at duffel.com

**App crashes on launch**
- Clean build folder: Product → Clean Build Folder (`Cmd + Shift + K`)
- Rebuild: `Cmd + B`
- If still issues, delete derived data:
  - Xcode → Settings → Locations → Derived Data → Delete

**Notifications not working**
- Notifications work in simulator but won't show actual alerts
- For testing, check Xcode console for notification logs
- On real device, grant notification permissions when prompted

## Features Overview

### Implemented Requirements ✅

1. **iOS Application Design**
   - Complete SwiftUI application
   - Solves real-world flight price tracking problem

2. **Basic Programming Constructs**
   - Data types, variables, constants
   - Operators and expressions
   - Control flow (if, switch, for, while)
   - Functions with parameters and return types
   - Closures and higher-order functions

3. **Object-Oriented Programming**
   - Classes (DataManager, NotificationManager, DuffelAPIService)
   - Structures (Flight, User, Airport, etc.)
   - Properties (stored, computed, lazy)
   - Collections (Arrays, Dictionaries, Sets)
   - Error handling with custom error types

4. **Data Structures & Algorithms**
   - Sorting (price, duration, date)
   - Searching (linear search in watchlist)
   - Filtering (stops, price range)
   - Data aggregation (statistics, trends)

5. **SwiftUI Views**
   - Multiple view files with composition
   - VStack, HStack, ZStack layouts
   - State management (@State, @StateObject, @EnvironmentObject)
   - Navigation with NavigationStack

6. **Code Quality**
   - Extensive comments and documentation
   - Clear, descriptive naming conventions
   - Organized file structure
   - MARK: comments for sections

## API Usage Notes

The app uses the Duffel API test environment:
- Test API key provided (limited to test data)
- Real flight searches work with test data
- For production use, you'd need a production API key
- Test environment is free and requires no credit card

## Learning Resources

- **SwiftUI**: developer.apple.com/tutorials/swiftui
- **Swift Language**: docs.swift.org/swift-book
- **Xcode**: developer.apple.com/xcode
- **iOS Development**: developer.apple.com/ios

## Support

If you encounter issues:
1. Check the Troubleshooting section above
2. Review the Implementation Guide
3. Check Xcode's Issue Navigator (Cmd + 5) for specific errors
4. Clean and rebuild the project

## License

This project is created for educational purposes demonstrating iOS development with Swift.

---

**Happy Coding! 🚀✈️**
