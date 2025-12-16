//
//  Flight.swift
//  FlightTracker
//
//  Data model for flight information with pricing and route details.
//

import Foundation

/// Represents a flight offer with all relevant details
struct Flight: Identifiable, Codable, Equatable {
    let id: String
    let origin: Airport
    let destination: Airport
    let departureDate: Date
    let arrivalDate: Date
    let price: Double
    let currency: String
    let airline: String
    let flightNumber: String
    let availableSeats: Int
    let cabinClass: CabinClass
    let duration: TimeInterval
    let stops: Int
    var isMultiLeg: Bool
    var legs: [FlightLeg]?
    
    /// Enum for cabin class types
    enum CabinClass: String, Codable, CaseIterable {
        case economy = "Economy"
        case premiumEconomy = "Premium Economy"
        case business = "Business"
        case first = "First Class"
    }
    
    /// Formatted price string with currency
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price)) ?? "\(currency) \(price)"
    }
    
    /// Formatted duration string
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    /// Check if two flights are equal based on key properties
    static func == (lhs: Flight, rhs: Flight) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Represents an individual leg of a multi-leg journey
struct FlightLeg: Codable, Identifiable {
    let id: String
    let origin: Airport
    let destination: Airport
    let departureDate: Date
    let arrivalDate: Date
    let airline: String
    let flightNumber: String
    let duration: TimeInterval
}

/// Represents an airport with code and location information
struct Airport: Codable, Equatable, Hashable {
    let code: String // IATA code (e.g., "LAX")
    let name: String
    let city: String
    let country: String
    var latitude: Double?
    var longitude: Double?
    
    /// Display name combining city and code
    var displayName: String {
        return "\(city) (\(code))"
    }
    
    static func == (lhs: Airport, rhs: Airport) -> Bool {
        return lhs.code == rhs.code
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}

/// Sample data for previews and testing
extension Flight {
    static var sample: Flight {
        Flight(
            id: "sample1",
            origin: Airport(code: "LAX", name: "Los Angeles International Airport", 
                          city: "Los Angeles", country: "United States",
                          latitude: 33.9416, longitude: -118.4085),
            destination: Airport(code: "JFK", name: "John F. Kennedy International Airport",
                               city: "New York", country: "United States",
                               latitude: 40.6413, longitude: -73.7781),
            departureDate: Date().addingTimeInterval(86400 * 7),
            arrivalDate: Date().addingTimeInterval(86400 * 7 + 19800),
            price: 299.99,
            currency: "USD",
            airline: "Delta Airlines",
            flightNumber: "DL1234",
            availableSeats: 12,
            cabinClass: .economy,
            duration: 19800,
            stops: 0,
            isMultiLeg: false,
            legs: nil
        )
    }
}

extension Airport {
    static var samples: [Airport] {
        [
            Airport(code: "LAX", name: "Los Angeles International Airport",
                   city: "Los Angeles", country: "United States",
                   latitude: 33.9416, longitude: -118.4085),
            Airport(code: "JFK", name: "John F. Kennedy International Airport",
                   city: "New York", country: "United States",
                   latitude: 40.6413, longitude: -73.7781),
            Airport(code: "LHR", name: "London Heathrow Airport",
                   city: "London", country: "United Kingdom",
                   latitude: 51.4700, longitude: -0.4543),
            Airport(code: "CDG", name: "Charles de Gaulle Airport",
                   city: "Paris", country: "France",
                   latitude: 49.0097, longitude: 2.5479),
            Airport(code: "DXB", name: "Dubai International Airport",
                   city: "Dubai", country: "United Arab Emirates",
                   latitude: 25.2532, longitude: 55.3657)
        ]
    }
}
