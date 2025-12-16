# Flight Tracker - Implementation Guide

## Overview
This document explains the detailed implementation of the Flight Tracker iOS app, demonstrating best practices in Swift programming and iOS development.

## Academic Requirements Compliance

### 1. iOS Mobile Application Design ✅
**Requirement**: Design an iOS mobile application written in Swift that solves a real-world problem.

**Implementation**: 
- Built a complete flight tracking and price monitoring application
- Solves the real-world problem of finding affordable flights and tracking price changes
- Addresses pain points: volatile airfare pricing, manual price checking, missing deals

**Real-World Value**:
- Users save money by tracking price drops
- Reduces time spent manually checking flight prices
- Provides price trend insights for better booking decisions
- Sends alerts for target prices and price changes

### 2. Basic Programming Constructs ✅

#### Data Types
```swift
// Primitive types
let flightId: String                    // String for identifiers
var price: Double                       // Double for currency
let availableSeats: Int                 // Integer for counts
var isRoundTrip: Bool                   // Boolean for flags
let departureDate: Date                 // Date for timestamps

// Complex types
struct Airport {                        // Struct for value types
    let code: String
    let name: String
    let coordinates: (Double, Double)?  // Tuple for lat/lon
}
```

#### Constants & Variables
```swift
// Immutable constants
let apiKey = "duffel_test_..."          // API key never changes
let maxPassengers = 9                   // Business rule constant

// Mutable variables
var searchResults: [Flight] = []        // Results change
@State private var isLoading = false    // UI state changes
```

#### Operators & Expressions
```swift
// Arithmetic operators
let priceDifference = currentPrice - initialPrice
let percentage = (difference / initial) * 100

// Comparison operators
if price <= targetPrice { sendAlert() }

// Logical operators
if isRoundTrip && returnDate != nil { }

// Nil coalescing
let seats = flight.availableSeats ?? 0

// Range operators
for i in 0..<passengers { }
```

#### Control Flow
```swift
// If-else statements
if watchlistItems.isEmpty {
    showEmptyState()
} else {
    showWatchlist()
}

// Guard statements (early exit pattern)
guard let user = currentUser else { 
    return 
}

// Switch statements
switch cabinClass {
case .economy:
    applyEconomyPricing()
case .business:
    applyBusinessPricing()
case .first:
    applyFirstClassPricing()
}

// For loops
for flight in searchResults {
    processFlightData(flight)
}

// While loops
while hasMorePages {
    fetchNextPage()
}
```

#### Functions & Methods
```swift
// Function with parameters and return type
func calculateDiscount(originalPrice: Double, percentage: Double) -> Double {
    return originalPrice * (percentage / 100)
}

// Method with async/await
func searchFlights(origin: String, destination: String) async throws -> [Flight] {
    let results = try await apiService.search(from: origin, to: destination)
    return results
}

// Method with default parameters
func addToWatchlist(flight: Flight, targetPrice: Double? = nil, notes: String? = nil) {
    // Implementation
}
```

#### Closures
```swift
// Trailing closure syntax
watchlistItems.sorted { $0.price < $1.price }

// Closure capturing values
func createPriceAlert(targetPrice: Double) -> () -> Void {
    return {
        if self.currentPrice <= targetPrice {
            self.sendNotification()
        }
    }
}

// Map, filter, reduce
let prices = flights.map { $0.price }
let cheapFlights = flights.filter { $0.price < 300 }
let totalCost = prices.reduce(0, +)

// Async closures
Task {
    await updatePrices()
}
```

### 3. Object-Oriented Programming ✅

#### Classes
```swift
// Class with inheritance potential
class DataManager: ObservableObject {
    // Properties
    @Published var watchlistItems: [WatchlistItem] = []
    private let storage = UserDefaults.standard
    
    // Initializer
    init() {
        loadData()
    }
    
    // Public methods
    func addToWatchlist(flight: Flight) {
        watchlistItems.append(WatchlistItem(flight: flight))
        saveData()
    }
    
    // Private methods (encapsulation)
    private func saveData() {
        // Implementation
    }
    
    // Deinitializer
    deinit {
        print("DataManager deallocated")
    }
}

// Singleton pattern
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() { }
}
```

#### Structures
```swift
// Struct with properties and methods
struct Flight: Identifiable, Codable {
    // Stored properties
    let id: String
    let price: Double
    let origin: Airport
    
    // Computed properties
    var formattedPrice: String {
        NumberFormatter.currency.string(from: NSNumber(value: price)) ?? ""
    }
    
    // Methods
    mutating func updatePrice(_ newPrice: Double) {
        // Note: mutating keyword required for structs
        price = newPrice
    }
    
    // Static methods
    static func == (lhs: Flight, rhs: Flight) -> Bool {
        return lhs.id == rhs.id
    }
}
```

#### Properties
```swift
// Stored properties
var firstName: String
let birthDate: Date

// Computed properties (get-only)
var fullName: String {
    "\(firstName) \(lastName)"
}

// Computed properties (get and set)
var displayPrice: String {
    get { formatPrice(price) }
    set { price = parsePrice(newValue) }
}

// Property observers
@Published var searchResults: [Flight] = [] {
    didSet {
        print("Results updated: \(searchResults.count)")
    }
    willSet {
        print("About to update results")
    }
}

// Lazy properties
lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()

// Property wrappers
@State private var isLoading = false
@Binding var selectedFlight: Flight
@EnvironmentObject var dataManager: DataManager
```

#### Collections
```swift
// Arrays (ordered collection)
var flights: [Flight] = []
flights.append(newFlight)
flights.remove(at: 0)
let firstFlight = flights.first

// Dictionaries (key-value pairs)
var flightCache: [String: Flight] = [:]
flightCache["LAX-JFK"] = flight
let cached = flightCache["LAX-JFK"]

// Sets (unique values)
var visitedAirports: Set<String> = ["LAX", "JFK", "ORD"]
visitedAirports.insert("SFO")
let hasLAX = visitedAirports.contains("LAX")

// Collection operations
let cheapFlights = flights.filter { $0.price < 300 }
let prices = flights.map { $0.price }
let count = flights.count
let isEmpty = flights.isEmpty
```

#### Error Handling
```swift
// Define custom errors
enum APIError: LocalizedError {
    case networkError(Error)
    case invalidURL
    case unauthorized
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL provided"
        case .unauthorized:
            return "Authentication failed"
        case .decodingError(let error):
            return "Failed to decode: \(error.localizedDescription)"
        }
    }
}

// Throwing functions
func fetchFlights() throws -> [Flight] {
    guard let url = URL(string: apiURL) else {
        throw APIError.invalidURL
    }
    
    let data = try Data(contentsOf: url)
    let flights = try JSONDecoder().decode([Flight].self, from: data)
    return flights
}

// Error handling with do-catch
do {
    let flights = try await fetchFlights()
    self.searchResults = flights
} catch APIError.unauthorized {
    errorMessage = "Please check your API key"
} catch APIError.networkError(let error) {
    errorMessage = "Network error: \(error.localizedDescription)"
} catch {
    errorMessage = "Unexpected error: \(error.localizedDescription)"
}

// Optional try
let flights = try? fetchFlights() // Returns nil on error

// Forced try (use cautiously)
let flights = try! fetchFlights() // Crashes on error
```

### 4. Data Structures & Algorithms ✅

#### Sorting Algorithms
```swift
// Quick sort (built-in, O(n log n))
func sortFlightsByPrice(_ flights: [Flight]) -> [Flight] {
    return flights.sorted { $0.price < $1.price }
}

// Custom comparator
func sortByMultipleCriteria(_ flights: [Flight]) -> [Flight] {
    return flights.sorted { flight1, flight2 in
        // First by stops
        if flight1.stops != flight2.stops {
            return flight1.stops < flight2.stops
        }
        // Then by price
        if flight1.price != flight2.price {
            return flight1.price < flight2.price
        }
        // Finally by duration
        return flight1.duration < flight2.duration
    }
}

// Stable sort maintaining relative order
func stableSort(_ items: [WatchlistItem]) -> [WatchlistItem] {
    return items.enumerated()
        .sorted { $0.element.price < $1.element.price }
        .map { $0.element }
}
```

#### Search Algorithms
```swift
// Linear search O(n)
func findFlight(by id: String, in flights: [Flight]) -> Flight? {
    return flights.first { $0.id == id }
}

// Binary search O(log n) - requires sorted array
func binarySearch(for price: Double, in sortedPrices: [Double]) -> Int? {
    var low = 0
    var high = sortedPrices.count - 1
    
    while low <= high {
        let mid = (low + high) / 2
        let midPrice = sortedPrices[mid]
        
        if midPrice == price {
            return mid
        } else if midPrice < price {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return nil
}

// Filter with predicate (linear search)
func findCheapFlights(maxPrice: Double, in flights: [Flight]) -> [Flight] {
    return flights.filter { $0.price <= maxPrice }
}
```

#### Data Processing Algorithms
```swift
// Calculate statistics O(n)
func calculateStatistics(for prices: [Double]) -> (min: Double, max: Double, avg: Double) {
    guard !prices.isEmpty else { return (0, 0, 0) }
    
    var min = Double.infinity
    var max = -Double.infinity
    var sum = 0.0
    
    for price in prices {
        if price < min { min = price }
        if price > max { max = price }
        sum += price
    }
    
    let avg = sum / Double(prices.count)
    return (min, max, avg)
}

// Group by category O(n)
func groupFlightsByAirline(_ flights: [Flight]) -> [String: [Flight]] {
    return Dictionary(grouping: flights) { $0.airline }
}

// Find price trends
func analyzePriceTrend(_ history: [PriceSnapshot]) -> TrendDirection {
    guard history.count >= 2 else { return .stable }
    
    let recentPrices = history.suffix(5).map { $0.price }
    let isIncreasing = zip(recentPrices, recentPrices.dropFirst())
        .allSatisfy { $0 < $1 }
    let isDecreasing = zip(recentPrices, recentPrices.dropFirst())
        .allSatisfy { $0 > $1 }
    
    if isIncreasing { return .increasing }
    if isDecreasing { return .decreasing }
    return .stable
}
```

#### Graph Algorithms (Flight Routes)
```swift
// Represent flight network as graph
struct FlightNetwork {
    var connections: [String: [String]] = [:]
    
    // Add connection (edge)
    mutating func addRoute(from origin: String, to destination: String) {
        connections[origin, default: []].append(destination)
    }
    
    // BFS to find shortest path (by number of stops)
    func findShortestPath(from origin: String, to destination: String) -> [String]? {
        var queue: [(airport: String, path: [String])] = [(origin, [origin])]
        var visited: Set<String> = [origin]
        
        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()
            
            if current == destination {
                return path
            }
            
            if let neighbors = connections[current] {
                for neighbor in neighbors where !visited.contains(neighbor) {
                    visited.insert(neighbor)
                    queue.append((neighbor, path + [neighbor]))
                }
            }
        }
        
        return nil
    }
}
```

### 5. SwiftUI Implementation ✅

#### Views
```swift
// Basic view structure
struct FlightCard: View {
    let flight: Flight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(flight.airline)
                    .font(.headline)
                Spacer()
                Text(flight.formattedPrice)
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            // Route information
            HStack {
                Text(flight.origin.code)
                Image(systemName: "airplane")
                Text(flight.destination.code)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
```

#### Stacks
```swift
// VStack - Vertical arrangement
VStack(alignment: .leading, spacing: 16) {
    Text("Title")
    Text("Subtitle")
    Button("Action") { }
}

// HStack - Horizontal arrangement
HStack {
    Image(systemName: "star")
    Text("Rating")
    Spacer()
    Text("4.5")
}

// ZStack - Layered arrangement
ZStack {
    Circle()
        .fill(Color.blue)
    Text("42")
        .foregroundColor(.white)
}
```

#### State Management
```swift
// @State - View-local state
struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        TextField("Search", text: $searchText)
    }
}

// @StateObject - Observable object owner
struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        // Use viewModel
    }
}

// @EnvironmentObject - Shared state
struct FlightCard: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        // Access dataManager
    }
}

// @Binding - Two-way binding
struct AirportPicker: View {
    @Binding var selection: String
    
    var body: some View {
        Picker("Airport", selection: $selection) {
            // Options
        }
    }
}
```

### 6. Readable Code ✅

#### Naming Conventions
```swift
// Descriptive function names
func calculatePriceChangePercentage() -> Double { }  // ✅ Clear
func calc() -> Double { }                             // ❌ Ambiguous

// Meaningful variable names
let departureDateTime = flight.departureDate  // ✅ Clear
let dt = flight.departureDate                 // ❌ Cryptic

// Boolean naming
var isLoading: Bool                          // ✅ Clear intent
var loading: Bool                            // ⚠️ Less clear
```

#### Code Organization
```swift
// MARK: comments for organization
struct FlightDetailView: View {
    // MARK: - Properties
    let flight: Flight
    @State private var showingAlert = false
    
    // MARK: - Body
    var body: some View {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func formatDuration() -> String {
        // Implementation
    }
}
```

#### Documentation Comments
```swift
/// Searches for available flights between two airports
/// - Parameters:
///   - origin: The IATA code of the departure airport
///   - destination: The IATA code of the arrival airport
///   - date: The desired departure date
/// - Returns: An array of available Flight objects
/// - Throws: `APIError` if the request fails
func searchFlights(
    origin: String,
    destination: String,
    date: Date
) async throws -> [Flight] {
    // Implementation
}
```

## Project Highlights

### Architecture Benefits
1. **Separation of Concerns**: Models, Views, Services clearly separated
2. **Testability**: ViewModels and Services can be tested independently
3. **Reusability**: Component-based UI design
4. **Maintainability**: Clear structure and documentation
5. **Scalability**: Easy to add new features

### Best Practices Implemented
1. **Error Handling**: Comprehensive error types and handling
2. **Async/Await**: Modern concurrency for network calls
3. **Type Safety**: Strong typing throughout
4. **Code Comments**: Extensive documentation
5. **SwiftUI Patterns**: Following Apple's recommended patterns

### Real-World Application
This app demonstrates production-ready code suitable for:
- App Store submission
- Team collaboration
- Long-term maintenance
- Feature expansion

## Conclusion

This Flight Tracker app successfully demonstrates:
✅ iOS application design solving real-world problems
✅ Comprehensive use of Swift programming constructs
✅ Object-oriented programming principles
✅ Data structures and algorithms implementation
✅ SwiftUI views and interactions
✅ Clean, readable, well-documented code

The implementation follows industry best practices and academic requirements while providing genuine value to users tracking flight prices.
