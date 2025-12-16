//
//  DataManager.swift
//  FlightTracker
//
//  Central data management class using UserDefaults for persistence.
//  Manages user data, watchlist, and price history.
//

import Foundation
import Combine

/// Observable data manager for app-wide state and persistence
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var currentUser: User?
    @Published var watchlistItems: [WatchlistItem] = []
    @Published var priceHistories: [PriceHistory] = []
    @Published var recentSearches: [SearchQuery] = []
    
    private let userDefaultsKey = "FlightTrackerData"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        setupAutoSave()
    }
    
    // MARK: - User Management
    
    /// Create a new user account
    func createUser(id: String, username: String, email: String, firstName: String, lastName: String) {
        let user = User(
            id: id,
            username: username,
            email: email,
            firstName: firstName,
            lastName: lastName,
            preferredCurrency: "USD",
            preferredAirports: [],
            notificationPreferences: .default,
            luggagePreference: .default,
            createdAt: Date(),
            lastLogin: Date()
        )
        currentUser = user
        saveData()
    }
    
    /// Update user profile
    func updateUser(_ user: User) {
        currentUser = user
        saveData()
    }
    
    /// Update user's last login time
    func updateLastLogin() {
        guard var user = currentUser else { return }
        user.lastLogin = Date()
        currentUser = user
        saveData()
    }
    
    // MARK: - Watchlist Management
    
    /// Add a flight to the watchlist
    func addToWatchlist(flight: Flight, targetPrice: Double? = nil, notes: String? = nil) {
        let item = WatchlistItem(
            id: UUID().uuidString,
            userId: currentUser?.id ?? "",
            flight: flight,
            initialPrice: flight.price,
            targetPrice: targetPrice,
            priceAlertEnabled: true,
            addedAt: Date(),
            lastChecked: Date(),
            priceHistory: [WatchlistItem.PriceSnapshot(price: flight.price)],
            notes: notes
        )
        watchlistItems.append(item)
        saveData()
    }
    
    /// Remove a flight from the watchlist
    func removeFromWatchlist(_ item: WatchlistItem) {
        watchlistItems.removeAll { $0.id == item.id }
        saveData()
    }
    
    /// Update a watchlist item
    func updateWatchlistItem(_ item: WatchlistItem) {
        if let index = watchlistItems.firstIndex(where: { $0.id == item.id }) {
            watchlistItems[index] = item
            saveData()
        }
    }
    
    /// Check if a flight is in the watchlist
    func isInWatchlist(_ flight: Flight) -> Bool {
        return watchlistItems.contains { $0.flight.id == flight.id }
    }
    
    /// Update prices for all watchlist items
    func updateWatchlistPrices() async {
        for (index, item) in watchlistItems.enumerated() {
            do {
                // Simulate price update (in real app, would fetch from API)
                let priceVariation = Double.random(in: -20...20)
                let newPrice = max(item.flight.price + priceVariation, 50)
                
                var updatedItem = item
                updatedItem.updatePrice(newPrice)
                
                // Update in main thread
                await MainActor.run {
                    watchlistItems[index] = updatedItem
                }
                
                // Check for price alerts
                checkPriceAlerts(for: updatedItem)
            } catch {
                print("Error updating price for \(item.flight.flightNumber): \(error)")
            }
        }
        
        await MainActor.run {
            saveData()
        }
    }
    
    // MARK: - Price History Management
    
    /// Add or update price history for a route
    func addPriceHistory(for flight: Flight) {
        let routeId = PriceHistory.makeRouteId(
            origin: flight.origin.code,
            destination: flight.destination.code,
            date: flight.departureDate
        )
        
        if let index = priceHistories.firstIndex(where: { $0.routeId == routeId }) {
            // Update existing history
            var history = priceHistories[index]
            let pricePoint = PriceHistory.PricePoint(
                price: flight.price,
                currency: flight.currency,
                airline: flight.airline,
                cabinClass: flight.cabinClass
            )
            history.addPricePoint(pricePoint)
            priceHistories[index] = history
        } else {
            // Create new history
            let pricePoint = PriceHistory.PricePoint(
                price: flight.price,
                currency: flight.currency,
                airline: flight.airline,
                cabinClass: flight.cabinClass
            )
            
            let history = PriceHistory(
                id: UUID().uuidString,
                routeId: routeId,
                origin: flight.origin,
                destination: flight.destination,
                pricePoints: [pricePoint],
                departureDate: flight.departureDate,
                createdAt: Date(),
                lastUpdated: Date()
            )
            priceHistories.append(history)
        }
        
        saveData()
    }
    
    /// Get price history for a specific route
    func getPriceHistory(origin: String, destination: String, date: Date) -> PriceHistory? {
        let routeId = PriceHistory.makeRouteId(origin: origin, destination: destination, date: date)
        return priceHistories.first { $0.routeId == routeId }
    }
    
    // MARK: - Search History
    
    /// Add a search query to recent searches
    func addSearchQuery(_ query: SearchQuery) {
        // Remove duplicate if exists
        recentSearches.removeAll { $0.origin == query.origin && $0.destination == query.destination }
        
        // Add to beginning
        recentSearches.insert(query, at: 0)
        
        // Keep only last 10 searches
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        saveData()
    }
    
    /// Clear search history
    func clearSearchHistory() {
        recentSearches.removeAll()
        saveData()
    }
    
    // MARK: - Price Alerts
    
    /// Check if price alerts should be triggered for a watchlist item
    private func checkPriceAlerts(for item: WatchlistItem) {
        guard item.priceAlertEnabled,
              let user = currentUser,
              let prefs = user.notificationPreferences as? NotificationPreferences else {
            return
        }
        
        let changePercentage = abs(item.priceChangePercentage)
        
        // Check for price drop
        if item.priceDifference < 0 && prefs.enablePriceDropAlerts {
            if changePercentage >= prefs.priceDropThreshold {
                NotificationManager.shared.sendPriceAlert(
                    for: item,
                    type: .priceDropped,
                    percentage: changePercentage
                )
            }
        }
        
        // Check for price increase
        if item.priceDifference > 0 && prefs.enablePriceIncreaseAlerts {
            if changePercentage >= prefs.priceIncreaseThreshold {
                NotificationManager.shared.sendPriceAlert(
                    for: item,
                    type: .priceIncreased,
                    percentage: changePercentage
                )
            }
        }
        
        // Check for target price reached
        if item.belowTargetPrice {
            NotificationManager.shared.sendPriceAlert(
                for: item,
                type: .targetPriceReached,
                percentage: 0
            )
        }
    }
    
    // MARK: - Persistence
    
    /// Load data from UserDefaults
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            // Create sample user if no data exists
            currentUser = User.sample
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let container = try decoder.decode(DataContainer.self, from: data)
            currentUser = container.user
            watchlistItems = container.watchlistItems
            priceHistories = container.priceHistories
            recentSearches = container.recentSearches
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    /// Save data to UserDefaults
    private func saveData() {
        let container = DataContainer(
            user: currentUser,
            watchlistItems: watchlistItems,
            priceHistories: priceHistories,
            recentSearches: recentSearches
        )
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(container)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    /// Setup automatic saving when data changes
    private func setupAutoSave() {
        // Save whenever published properties change
        Publishers.CombineLatest4(
            $currentUser,
            $watchlistItems,
            $priceHistories,
            $recentSearches
        )
        .dropFirst() // Skip initial values
        .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.saveData()
        }
        .store(in: &cancellables)
    }
    
    /// Container for encoding/decoding all data
    private struct DataContainer: Codable {
        let user: User?
        let watchlistItems: [WatchlistItem]
        let priceHistories: [PriceHistory]
        let recentSearches: [SearchQuery]
    }
}

/// Represents a search query for storing in history
struct SearchQuery: Codable, Identifiable {
    let id: String
    let origin: String
    let destination: String
    let departureDate: Date
    let returnDate: Date?
    let passengers: Int
    let cabinClass: Flight.CabinClass
    let timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        origin: String,
        destination: String,
        departureDate: Date,
        returnDate: Date? = nil,
        passengers: Int = 1,
        cabinClass: Flight.CabinClass = .economy,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.passengers = passengers
        self.cabinClass = cabinClass
        self.timestamp = timestamp
    }
}
