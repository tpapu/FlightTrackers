//
//  FlightTrackerApp.swift
//  FlightTracker
//
//  A comprehensive flight tracking application that helps users monitor
//  and find the best flight deals with real-time price tracking.
//

import SwiftUI

@main
struct FlightTrackerApp: App {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                ContentView()
                    .environmentObject(dataManager)
                    .environmentObject(NotificationManager.shared)
                    .environmentObject(authService)
                    .onAppear {
                        // Request notification permissions on app launch
                        NotificationManager.shared.requestAuthorization()
                    }
            } else {
                WelcomeView()
                    .environmentObject(authService)
                    .environmentObject(dataManager)
            }
        }
    }
}
