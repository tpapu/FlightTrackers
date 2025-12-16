# Flight Tracker iOS App

A comprehensive iOS application built with Swift and SwiftUI for tracking flight prices, managing watchlists, and finding the best deals on air travel.

## 📱 Features

### Core Features
- **Flight Search**: Search for flights with flexible date and route options
- **Real-time Price Tracking**: Monitor flight prices with automatic updates
- **Watchlist Management**: Save favorite flights and track price changes
- **Price History**: View historical price data with interactive charts
- **Price Alerts**: Receive notifications when prices drop or reach target amounts
- **Multi-leg Support**: Handle complex itineraries with multiple stops
- **Airport Maps**: Visual representation of flight routes
- **User Accounts**: Persistent user profiles with preferences

### Advanced Features
- **Luggage Preferences**: Filter flights based on baggage requirements
- **Preferred Airports**: Quick access to frequently used airports
- **Currency Settings**: View prices in preferred currency
- **Search History**: Quick access to recent searches
- **AI Assistance**: Built-in chat support for travel queries
- **Notification System**: Customizable price alerts and reminders

## 🏗️ Architecture

### Design Patterns
- **MVVM (Model-View-ViewModel)**: Separation of concerns for maintainability
- **ObservableObject**: Reactive state management with Combine
- **Environment Objects**: Shared state across view hierarchy
- **Protocol-Oriented**: Extensible and testable code

### Project Structure
```
FlightTracker/
├── Models/
│   ├── Flight.swift           # Flight data structures
│   ├── User.swift             # User account model
│   ├── PriceHistory.swift     # Price tracking data
│   └── WatchlistItem.swift    # Saved flight tracking
├── Views/
│   ├── SearchView.swift       # Flight search interface
│   ├── WatchlistView.swift    # Saved flights display
│   ├── PriceHistoryView.swift # Historical price charts
│   ├── AccountView.swift      # User profile & settings
│   ├── FlightDetailView.swift # Detailed flight information
│   ├── Components/            # Reusable UI components
│   └── SupportingViews.swift  # Additional views
├── Services/
│   ├── DuffelAPIService.swift # API integration
│   ├── DataManager.swift      # Data persistence
│   └── NotificationManager.swift # Push notifications
└── App/
    ├── FlightTrackerApp.swift # App entry point
    └── ContentView.swift      # Main navigation

```

## 🛠️ Technical Implementation

### Programming Constructs Used

#### 1. Data Types & Variables
```swift
// Strong typing throughout
let flightId: String
var price: Double
let departureDate: Date
var passengers: Int
```

#### 2. Constants & Enumerations
```swift
enum CabinClass: String, CaseIterable {
    case economy = "Economy"
    case business = "Business"
    case first = "First Class"
}

enum NotificationType {
    case priceDropped, priceIncreased, targetPriceReached
}
```

#### 3. Control Flow
```swift
// Conditional logic
if item.priceAlertEnabled && item.belowTargetPrice {
    sendNotification()
}

// Switch statements
switch sortOption {
case .price: results.sort { $0.price < $1.price }
case .duration: results.sort { $0.duration < $1.duration }
case .departure: results.sort { $0.departureDate < $1.departureDate }
}

// Guard statements for validation
guard let user = currentUser else { return }
```

#### 4. Functions & Methods
```swift
func searchFlights(origin: String, destination: String) async throws -> [Flight]
func addToWatchlist(flight: Flight, targetPrice: Double?)
func updatePriceHistory(for flight: Flight)
```

#### 5. Closures
```swift
// Sorting with closures
watchlistItems.sorted { $0.priceChangePercentage < $1.priceChangePercentage }

// Filtering
results.filter { $0.stops <= maxStops }

// Async operations
Task {
    await dataManager.updateWatchlistPrices()
}
```

### Object-Oriented Programming

#### 1. Classes
```swift
class DataManager: ObservableObject {
    @Published var watchlistItems: [WatchlistItem] = []
    
    func addToWatchlist(flight: Flight) { }
    private func saveData() { }
}
```

#### 2. Structures
```swift
struct Flight: Identifiable, Codable {
    let id: String
    let price: Double
    var formattedPrice: String { }
}
```

#### 3. Properties
```swift
// Computed properties
var averagePrice: Double {
    pricePoints.reduce(0.0) { $0 + $1.price } / Double(pricePoints.count)
}

// Property observers
@Published var searchResults: [Flight] = [] {
    didSet { saveToHistory() }
}
```

#### 4. Collections
```swift
var watchlistItems: [WatchlistItem] = []
var priceHistory: [PriceSnapshot] = []
var preferredAirports: Set<String> = []
var flightCache: [String: Flight] = [:]
```

#### 5. Error Handling
```swift
enum APIError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error): return error.localizedDescription
        case .invalidResponse: return "Invalid server response"
        }
    }
}

do {
    let flights = try await searchFlights()
} catch {
    errorMessage = error.localizedDescription
}
```

### Data Structures & Algorithms

#### 1. Sorting Algorithms
```swift
// Price sorting
func sortByPrice(_ flights: [Flight]) -> [Flight] {
    return flights.sorted { $0.price < $1.price }
}

// Custom comparators
watchlistItems.sorted { 
    $0.priceChangePercentage < $1.priceChangePercentage 
}
```

#### 2. Search Algorithms
```swift
// Linear search in watchlist
func isInWatchlist(_ flight: Flight) -> Bool {
    return watchlistItems.contains { $0.flight.id == flight.id }
}

// Binary search for price history (if sorted)
func findPricePoint(at date: Date) -> PricePoint? {
    // Implementation
}
```

#### 3. Data Filtering
```swift
// Filter by criteria
var filteredFlights: [Flight] {
    flights
        .filter { $0.stops <= maxStops }
        .filter { $0.price <= maxPrice ?? .infinity }
}
```

### SwiftUI Views & Interactions

#### 1. View Composition
```swift
struct SearchView: View {
    var body: some View {
        VStack {
            searchFormSection
            searchButton
            searchResultsSection
        }
    }
}
```

#### 2. Stacks
```swift
// VStack, HStack, ZStack
VStack(spacing: 16) {
    HStack {
        Text("Origin")
        Spacer()
        Text("Destination")
    }
}
```

#### 3. State Management
```swift
@State private var searchText = ""
@StateObject private var viewModel = SearchViewModel()
@EnvironmentObject var dataManager: DataManager
@Published var watchlistItems: [WatchlistItem]
```

#### 4. Navigation
```swift
NavigationStack {
    List(flights) { flight in
        NavigationLink {
            FlightDetailView(flight: flight)
        } label: {
            FlightCard(flight: flight)
        }
    }
}
```

## 🔌 API Integration

### Duffel API
The app integrates with the Duffel API for real-time flight data:

```swift
class DuffelAPIService {
    private let apiKey = "duffel_test_nQJcuQAfxqpTTa2r0Rw73CYBq_Qo-jyerBvCSjZHqMn"
    
    func searchFlights(
        origin: String,
        destination: String,
        departureDate: Date
    ) async throws -> [Flight]
}
```

### API Features Used
- Flight offer requests
- Multi-city search
- Cabin class filtering
- Real-time pricing

## 💾 Data Persistence

### UserDefaults
```swift
func saveData() {
    let encoder = JSONEncoder()
    let data = try encoder.encode(container)
    UserDefaults.standard.set(data, forKey: userDefaultsKey)
}
```

### Codable Protocol
All models implement `Codable` for serialization:
```swift
struct Flight: Codable {
    let id: String
    let price: Double
    // Automatic encoding/decoding
}
```

## 🔔 Notifications

### Local Notifications
```swift
func sendPriceAlert(for item: WatchlistItem) {
    let content = UNMutableNotificationContent()
    content.title = "Price Drop Alert!"
    content.body = "Price dropped to \(item.flight.formattedPrice)"
    
    UNUserNotificationCenter.current().add(request)
}
```

## 📖 Code Quality

### Readable Code Practices
1. **Descriptive naming**: `calculatePriceChangePercentage()` vs `calc()`
2. **Comments**: Documenting complex logic and algorithms
3. **Consistent formatting**: Proper indentation and spacing
4. **MARK comments**: Organizing code into logical sections
5. **Type safety**: Leveraging Swift's strong typing

### Example:
```swift
/// Calculate the percentage change from initial to current price
/// - Returns: The percentage change, positive for increases, negative for decreases
func calculatePriceChangePercentage() -> Double {
    guard initialPrice > 0 else { return 0 }
    let difference = currentPrice - initialPrice
    return (difference / initialPrice) * 100
}
```

## 🚀 Getting Started

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Active Duffel API key

### Installation
1. Clone the repository
2. Open `FlightTracker.xcodeproj` in Xcode
3. Update the Duffel API key in `DuffelAPIService.swift`
4. Build and run on simulator or device

### Configuration
```swift
// Update API key
private let apiKey = "YOUR_DUFFEL_API_KEY"

// Customize default settings
let defaultCurrency = "USD"
let maxSearchResults = 50
```

## 📋 Usage Examples

### Searching for Flights
```swift
let results = try await DuffelAPIService.shared.searchFlights(
    origin: "LAX",
    destination: "JFK",
    departureDate: Date().addingTimeInterval(86400 * 30),
    passengers: 2,
    cabinClass: .economy
)
```

### Adding to Watchlist
```swift
dataManager.addToWatchlist(
    flight: selectedFlight,
    targetPrice: 250.00,
    notes: "Summer vacation trip"
)
```

### Tracking Price History
```swift
let history = dataManager.getPriceHistory(
    origin: "LAX",
    destination: "JFK",
    date: departureDate
)
```

## 🧪 Testing

### Unit Tests
```swift
func testPriceChangeCalculation() {
    let item = WatchlistItem(initialPrice: 300, currentPrice: 270)
    XCTAssertEqual(item.priceChangePercentage, -10.0)
}
```

### UI Tests
```swift
func testFlightSearch() {
    app.textFields["Origin"].tap()
    app.textFields["Origin"].typeText("LAX")
    // Continue test flow
}
```

## 🎨 UI/UX Features

- **Dark Mode Support**: Automatic adaptation to system theme
- **Accessibility**: VoiceOver support and dynamic type
- **Animations**: Smooth transitions and loading states
- **Error Handling**: User-friendly error messages
- **Pull to Refresh**: Update flight prices manually

## 📝 Future Enhancements

- [ ] iCloud sync for multi-device support
- [ ] Apple Pay integration for booking
- [ ] Widget for home screen price tracking
- [ ] Apple Watch companion app
- [ ] Share flight details via Messages/Email
- [ ] Export price history as CSV
- [ ] Travel itinerary builder
- [ ] Offline mode with cached data

## 📄 License

This project is created for educational purposes demonstrating iOS development with Swift.

## 👥 Contributing

This is an educational project. Contributions for learning purposes are welcome.

## 📞 Support

For issues or questions about the implementation, please refer to the inline code documentation.

---

**Built with ❤️ using Swift & SwiftUI**
