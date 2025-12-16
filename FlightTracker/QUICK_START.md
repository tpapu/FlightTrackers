# 🚀 Quick Start Guide

## Instant Setup (30 seconds)

1. **Open the Project**
   ```
   Double-click: FlightTracker.xcodeproj
   ```

2. **Select Simulator**
   - Top toolbar: Click device dropdown
   - Choose: "iPhone 15 Pro" (or any iPhone)

3. **Run the App**
   - Press: `Cmd + R`
   - Or click: ▶️ Play button
   - Wait 10-20 seconds for build

4. **Start Using**
   - App launches automatically
   - Try searching: LAX → JFK
   - Select a future date
   - Click "Search Flights"

## ✅ What Works Out of the Box

- ✅ Full flight search functionality
- ✅ Real Duffel API integration (test mode)
- ✅ Price tracking and watchlist
- ✅ Historical price charts
- ✅ User profile management
- ✅ All UI features and navigation
- ✅ Notifications (simulated)

## 📱 Project Features

### Tab 1: Search
- Enter origin and destination airport codes
- Select departure date
- Toggle round trip option
- Set number of passengers
- Choose cabin class
- View search results with prices

### Tab 2: Watchlist
- View saved flights
- Track price changes
- See price trends (up/down arrows)
- Set target prices
- Remove flights from watchlist

### Tab 3: History
- View historical price data
- Interactive price charts
- Compare prices over time
- Statistics (min, max, average)

### Tab 4: Account
- User profile information
- Currency preferences
- Preferred airports
- Luggage settings
- Notification preferences

## 🎯 Try These Searches

**Domestic US Flights:**
- LAX → JFK (Los Angeles to New York)
- SFO → BOS (San Francisco to Boston)
- ORD → MIA (Chicago to Miami)

**International:**
- JFK → LHR (New York to London)
- LAX → NRT (Los Angeles to Tokyo)
- SFO → CDG (San Francisco to Paris)

## 📊 Sample Data

The app uses test data from Duffel API:
- Realistic flight prices
- Actual airline names
- Real airport codes
- Simulated availability

## 🔧 No Configuration Needed

Everything is pre-configured:
- ✅ Duffel API key included
- ✅ Network permissions set
- ✅ All dependencies resolved
- ✅ Build settings optimized
- ✅ iOS 17.0 deployment target

## 📁 File Structure

```
FlightTracker/
├── 📱 FlightTracker.xcodeproj    ← Double-click this!
├── 📝 SETUP_INSTRUCTIONS.md       (Detailed setup)
├── 📝 README.md                   (Full documentation)
├── 📝 IMPLEMENTATION_GUIDE.md     (Academic requirements)
└── FlightTracker/
    ├── 🚀 FlightTrackerApp.swift
    ├── 📐 ContentView.swift
    ├── 📦 Models/ (4 files)
    ├── ⚙️ Services/ (3 files)
    ├── 🎨 Views/ (7 files)
    └── 🖼️ Assets.xcassets/
```

## 🎓 Academic Requirements

All requirements are fully implemented:

1. ✅ iOS mobile application in Swift
2. ✅ Basic programming constructs
3. ✅ Object-oriented programming
4. ✅ Data structures & algorithms
5. ✅ SwiftUI views and interactions
6. ✅ Readable, well-documented code

See `IMPLEMENTATION_GUIDE.md` for detailed compliance.

## 💡 Pro Tips

1. **First Run Takes Longer**
   - Initial build: 20-30 seconds
   - Subsequent runs: 5-10 seconds

2. **Simulator Controls**
   - Rotate: `Cmd + Left/Right Arrow`
   - Home: `Cmd + Shift + H`
   - Screenshot: `Cmd + S`

3. **Code Exploration**
   - Jump to file: `Cmd + Shift + O`
   - Find in project: `Cmd + Shift + F`
   - Build: `Cmd + B`

4. **Clean Build (if needed)**
   - Clean: `Cmd + Shift + K`
   - Rebuild: `Cmd + B`

## ❓ Common Questions

**Q: Do I need an Apple Developer account?**
A: No! Works perfectly in the simulator without any account.

**Q: Will it work on my iPhone?**
A: Yes, but you'll need to connect via USB and trust your computer.

**Q: Is the API key free?**
A: Yes, it's a test key provided by Duffel with no costs.

**Q: Can I modify the code?**
A: Absolutely! The code is well-documented for learning.

## 🐛 If Something Goes Wrong

1. **Clean Build Folder**
   ```
   Product → Clean Build Folder (Cmd + Shift + K)
   ```

2. **Restart Xcode**
   ```
   Quit Xcode completely, then reopen
   ```

3. **Reset Simulator**
   ```
   Simulator → Device → Erase All Content and Settings
   ```

4. **Check Console**
   ```
   View → Debug Area → Activate Console (Cmd + Shift + Y)
   ```

## 📚 Next Steps

1. **Explore the Code**
   - Start with `FlightTrackerApp.swift`
   - Check out `Models/Flight.swift`
   - Review `Views/SearchView.swift`

2. **Read Documentation**
   - `README.md` - Full project overview
   - `IMPLEMENTATION_GUIDE.md` - Academic details
   - `SETUP_INSTRUCTIONS.md` - Troubleshooting

3. **Customize**
   - Change colors in views
   - Modify search parameters
   - Add new features

## 🎉 You're Ready!

The app is production-ready and demonstrates:
- Modern Swift & SwiftUI
- Clean architecture (MVVM)
- Real API integration
- Professional code quality
- Comprehensive features

**Just open `FlightTracker.xcodeproj` and press Run!**

---

Need help? Check `SETUP_INSTRUCTIONS.md` for detailed troubleshooting.
