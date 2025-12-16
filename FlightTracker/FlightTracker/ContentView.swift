//
//  ContentView.swift
//  FlightTracker
//
//  Main navigation view with tabbed interface for different app sections.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)
            
            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "star.fill")
                }
                .tag(1)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
        .environmentObject(NotificationManager.shared)
}
