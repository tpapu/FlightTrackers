//
//  WatchlistItem.swift
//  FlightTracker
//
//  Data model for flights saved to user's watchlist with price tracking.
//

import Foundation

/// Represents a flight saved to the user's watchlist
struct WatchlistItem: Identifiable, Codable {
    let id: String
    let userId: String
    var flight: Flight
    var initialPrice: Double
    var targetPrice: Double?
    var priceAlertEnabled: Bool
    var addedAt: Date
    var lastChecked: Date
    var priceHistory: [PriceSnapshot]
    var notes: String?
    
    /// Price snapshot for tracking changes over time
    struct PriceSnapshot: Codable, Identifiable {
        let id: String
        let price: Double
        let timestamp: Date
        
        init(id: String = UUID().uuidString, price: Double, timestamp: Date = Date()) {
            self.id = id
            self.price = price
            self.timestamp = timestamp
        }
    }
    
    /// Current price difference from initial price
    var priceDifference: Double {
        return flight.price - initialPrice
    }
    
    /// Percentage change from initial price
    var priceChangePercentage: Double {
        guard initialPrice > 0 else { return 0 }
        return (priceDifference / initialPrice) * 100
    }
    
    /// Whether the current price is lower than the target price
    var belowTargetPrice: Bool {
        guard let target = targetPrice else { return false }
        return flight.price <= target
    }
    
    /// Price trend: increasing, decreasing, or stable
    var priceTrend: PriceTrend {
        guard priceHistory.count >= 2 else { return .stable }
        
        let recentPrices = priceHistory.suffix(3).map { $0.price }
        let isIncreasing = zip(recentPrices, recentPrices.dropFirst()).allSatisfy { $0 < $1 }
        let isDecreasing = zip(recentPrices, recentPrices.dropFirst()).allSatisfy { $0 > $1 }
        
        if isIncreasing {
            return .increasing
        } else if isDecreasing {
            return .decreasing
        } else {
            return .stable
        }
    }
    
    enum PriceTrend {
        case increasing
        case decreasing
        case stable
        
        var iconName: String {
            switch self {
            case .increasing: return "arrow.up.right"
            case .decreasing: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
        
        var color: String {
            switch self {
            case .increasing: return "red"
            case .decreasing: return "green"
            case .stable: return "gray"
            }
        }
    }
    
    /// Add a new price snapshot to the history
    mutating func addPriceSnapshot(_ snapshot: PriceSnapshot) {
        priceHistory.append(snapshot)
        lastChecked = Date()
    }
    
    /// Update the flight price and add to history
    mutating func updatePrice(_ newPrice: Double) {
        // Create a new flight with updated price
        flight = Flight(
            id: flight.id,
            origin: flight.origin,
            destination: flight.destination,
            departureDate: flight.departureDate,
            arrivalDate: flight.arrivalDate,
            price: newPrice,
            currency: flight.currency,
            airline: flight.airline,
            flightNumber: flight.flightNumber,
            availableSeats: flight.availableSeats,
            cabinClass: flight.cabinClass,
            duration: flight.duration,
            stops: flight.stops,
            isMultiLeg: flight.isMultiLeg,
            legs: flight.legs
        )
        addPriceSnapshot(PriceSnapshot(price: newPrice))
    }
}

/// Sample watchlist item for previews
extension WatchlistItem {
    static var sample: WatchlistItem {
        let flight = Flight.sample
        let now = Date()
        
        let priceHistory = [
            PriceSnapshot(price: 299.99, timestamp: now.addingTimeInterval(-86400 * 5)),
            PriceSnapshot(price: 289.99, timestamp: now.addingTimeInterval(-86400 * 3)),
            PriceSnapshot(price: 279.99, timestamp: now.addingTimeInterval(-86400))
        ]
        
        return WatchlistItem(
            id: UUID().uuidString,
            userId: "user123",
            flight: flight,
            initialPrice: 299.99,
            targetPrice: 250.00,
            priceAlertEnabled: true,
            addedAt: now.addingTimeInterval(-86400 * 5),
            lastChecked: now,
            priceHistory: priceHistory,
            notes: "Trip for summer vacation"
        )
    }
}
