//
//  NotificationManager.swift
//  FlightTracker
//
//  Manager for handling local notifications and price alerts.
//

import Foundation
import UserNotifications

/// Manager for scheduling and handling notifications
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationPermissionGranted = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    enum NotificationType {
        case priceDropped
        case priceIncreased
        case targetPriceReached
        case departureReminder
    }
    
    // MARK: - Authorization
    
    /// Request notification permissions from user
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = granted
            }
            
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    /// Check current authorization status
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Price Alerts
    
    /// Send a price alert notification
    func sendPriceAlert(for item: WatchlistItem, type: NotificationType, percentage: Double) {
        guard notificationPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        
        switch type {
        case .priceDropped:
            content.title = "Price Drop Alert! 📉"
            content.body = "\(item.flight.origin.code) → \(item.flight.destination.code): Price dropped \(String(format: "%.1f", percentage))% to \(item.flight.formattedPrice)"
            content.sound = .default
            
        case .priceIncreased:
            content.title = "Price Increase Alert 📈"
            content.body = "\(item.flight.origin.code) → \(item.flight.destination.code): Price increased \(String(format: "%.1f", percentage))% to \(item.flight.formattedPrice)"
            content.sound = .default
            
        case .targetPriceReached:
            content.title = "Target Price Reached! 🎯"
            content.body = "\(item.flight.origin.code) → \(item.flight.destination.code) is now at your target price: \(item.flight.formattedPrice)"
            content.sound = .default
            
        case .departureReminder:
            content.title = "Upcoming Flight Reminder ✈️"
            content.body = "Your flight \(item.flight.flightNumber) from \(item.flight.origin.code) to \(item.flight.destination.code) departs soon"
            content.sound = .default
        }
        
        content.badge = 1
        content.categoryIdentifier = "FLIGHT_ALERT"
        content.userInfo = ["watchlistItemId": item.id]
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    /// Schedule a departure reminder notification
    func scheduleDepartureReminder(for item: WatchlistItem, hoursBefore: Double = 24) {
        guard notificationPermissionGranted else { return }
        
        let reminderTime = item.flight.departureDate.addingTimeInterval(-hoursBefore * 3600)
        
        // Only schedule if reminder time is in the future
        guard reminderTime > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Flight Reminder ✈️"
        content.body = "Your flight \(item.flight.flightNumber) from \(item.flight.origin.displayName) to \(item.flight.destination.displayName) departs in \(Int(hoursBefore)) hours"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "DEPARTURE_REMINDER"
        content.userInfo = ["watchlistItemId": item.id]
        
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderTime
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "departure_\(item.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling departure reminder: \(error)")
            }
        }
    }
    
    /// Cancel all scheduled notifications for a watchlist item
    func cancelNotifications(for itemId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["departure_\(itemId)"]
        )
    }
    
    /// Clear all notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    /// Get pending notification count
    func getPendingNotificationCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
}
