//
//  PriceHistory.swift
//  FlightTracker
//
//  Data model for tracking historical price changes of flights.
//

import Foundation

/// Represents the price history for a specific flight route
struct PriceHistory: Identifiable, Codable {
    let id: String
    let routeId: String // Unique identifier for origin-destination pair
    let origin: Airport
    let destination: Airport
    var pricePoints: [PricePoint]
    var departureDate: Date
    var createdAt: Date
    var lastUpdated: Date
    
    /// Individual price data point
    struct PricePoint: Codable, Identifiable {
        let id: String
        let price: Double
        let currency: String
        let timestamp: Date
        let airline: String?
        let cabinClass: Flight.CabinClass?
        
        init(id: String = UUID().uuidString, price: Double, currency: String, 
             timestamp: Date = Date(), airline: String? = nil, 
             cabinClass: Flight.CabinClass? = nil) {
            self.id = id
            self.price = price
            self.currency = currency
            self.timestamp = timestamp
            self.airline = airline
            self.cabinClass = cabinClass
        }
    }
    
    /// Current price (most recent price point)
    var currentPrice: Double? {
        return pricePoints.last?.price
    }
    
    /// Lowest recorded price
    var lowestPrice: Double? {
        return pricePoints.map { $0.price }.min()
    }
    
    /// Highest recorded price
    var highestPrice: Double? {
        return pricePoints.map { $0.price }.max()
    }
    
    /// Average price across all data points
    var averagePrice: Double {
        guard !pricePoints.isEmpty else { return 0 }
        let sum = pricePoints.reduce(0.0) { $0 + $1.price }
        return sum / Double(pricePoints.count)
    }
    
    /// Price change percentage from first to last point
    var priceChangePercentage: Double? {
        guard let first = pricePoints.first?.price,
              let last = pricePoints.last?.price,
              first > 0 else {
            return nil
        }
        return ((last - first) / first) * 100
    }
    
    /// Add a new price point to the history
    mutating func addPricePoint(_ point: PricePoint) {
        pricePoints.append(point)
        lastUpdated = Date()
    }
    
    /// Get price points for a specific date range
    func pricePoints(from startDate: Date, to endDate: Date) -> [PricePoint] {
        return pricePoints.filter { point in
            point.timestamp >= startDate && point.timestamp <= endDate
        }
    }
    
    /// Route identifier combining origin and destination
    static func makeRouteId(origin: String, destination: String, date: Date) -> String {
        let dateString = ISO8601DateFormatter().string(from: date)
        return "\(origin)-\(destination)-\(dateString)"
    }
}

/// Sample price history for previews
extension PriceHistory {
    static var sample: PriceHistory {
        let now = Date()
        let pricePoints = [
            PricePoint(price: 350.00, currency: "USD", 
                      timestamp: now.addingTimeInterval(-86400 * 7)),
            PricePoint(price: 320.00, currency: "USD", 
                      timestamp: now.addingTimeInterval(-86400 * 6)),
            PricePoint(price: 310.00, currency: "USD", 
                      timestamp: now.addingTimeInterval(-86400 * 5)),
            PricePoint(price: 330.00, currency: "USD", 
                      timestamp: now.addingTimeInterval(-86400 * 4)),
            PricePoint(price: 299.99, currency: "USD", 
                      timestamp: now.addingTimeInterval(-86400 * 3)),
            PricePoint(price: 289.99, currency: "USD", 
                      timestamp: now.addingTimeInterval(-86400 * 2)),
            PricePoint(price: 295.00, currency: "USD", 
                      timestamp: now.addingTimeInterval(-86400)),
            PricePoint(price: 299.99, currency: "USD", timestamp: now)
        ]
        
        return PriceHistory(
            id: UUID().uuidString,
            routeId: "LAX-JFK-2025-01-15",
            origin: Airport.samples[0],
            destination: Airport.samples[1],
            pricePoints: pricePoints,
            departureDate: now.addingTimeInterval(86400 * 30),
            createdAt: now.addingTimeInterval(-86400 * 7),
            lastUpdated: now
        )
    }
}
