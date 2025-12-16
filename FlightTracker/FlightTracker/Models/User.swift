//
//  User.swift
//  FlightTracker
//
//  Data model for user account information and preferences.
//

import Foundation

/// Represents a user account with preferences and settings
struct User: Codable, Identifiable {
    let id: String
    var username: String
    var email: String
    var firstName: String
    var lastName: String
    var preferredCurrency: String
    var preferredAirports: [String] // IATA codes
    var notificationPreferences: NotificationPreferences
    var luggagePreference: LuggagePreference
    var createdAt: Date
    var lastLogin: Date
    
    /// Full name of the user
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    /// User initials for avatar display
    var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        return "\(first)\(last)"
    }
}

/// Notification preferences for price alerts
struct NotificationPreferences: Codable {
    var enablePriceDropAlerts: Bool
    var enablePriceIncreaseAlerts: Bool
    var priceDropThreshold: Double // Percentage
    var priceIncreaseThreshold: Double // Percentage
    var enableDeparturReminders: Bool
    var reminderTimeBefore: TimeInterval // Seconds before departure
    
    static var `default`: NotificationPreferences {
        NotificationPreferences(
            enablePriceDropAlerts: true,
            enablePriceIncreaseAlerts: false,
            priceDropThreshold: 10.0,
            priceIncreaseThreshold: 20.0,
            enableDeparturReminders: true,
            reminderTimeBefore: 86400 // 24 hours
        )
    }
}

/// Luggage preferences for filtering flights
struct LuggagePreference: Codable {
    var carryOnBags: Int
    var checkedBags: Int
    var preferredWeight: WeightUnit
    
    enum WeightUnit: String, Codable, CaseIterable {
        case kilograms = "kg"
        case pounds = "lbs"
    }
    
    static var `default`: LuggagePreference {
        LuggagePreference(
            carryOnBags: 1,
            checkedBags: 1,
            preferredWeight: .kilograms
        )
    }
}

/// Sample user for previews
extension User {
    static var sample: User {
        User(
            id: UUID().uuidString,
            username: "traveler123",
            email: "user@example.com",
            firstName: "John",
            lastName: "Doe",
            preferredCurrency: "USD",
            preferredAirports: ["LAX", "JFK", "SFO"],
            notificationPreferences: .default,
            luggagePreference: .default,
            createdAt: Date().addingTimeInterval(-86400 * 30),
            lastLogin: Date()
        )
    }
}
