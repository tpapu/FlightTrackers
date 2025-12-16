//
//  WatchlistView.swift
//  FlightTracker
//
//  View for displaying and managing watchlist items with price tracking.
//

import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingSortOptions = false
    @State private var sortOption: SortOption = .dateAdded
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Date Added"
        case priceChange = "Price Change"
        case departureDate = "Departure Date"
        case price = "Price"
    }
    
    var sortedWatchlist: [WatchlistItem] {
        switch sortOption {
        case .dateAdded:
            return dataManager.watchlistItems.sorted { $0.addedAt > $1.addedAt }
        case .priceChange:
            return dataManager.watchlistItems.sorted { $0.priceChangePercentage < $1.priceChangePercentage }
        case .departureDate:
            return dataManager.watchlistItems.sorted { $0.flight.departureDate < $1.flight.departureDate }
        case .price:
            return dataManager.watchlistItems.sorted { $0.flight.price < $1.flight.price }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataManager.watchlistItems.isEmpty {
                    emptyState
                } else {
                    watchlistContent
                }
            }
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await dataManager.updateWatchlistPrices()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Saved Flights")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Search for flights and add them to your watchlist to track price changes")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Watchlist Content
    
    private var watchlistContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Summary card
                summaryCard
                
                // Watchlist items
                ForEach(sortedWatchlist) { item in
                    NavigationLink {
                        WatchlistItemDetailView(item: item)
                    } label: {
                        WatchlistCard(item: item)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation {
                                dataManager.removeFromWatchlist(item)
                            }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Tracking")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(dataManager.watchlistItems.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Avg. Change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: averagePriceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text(String(format: "%.1f%%", abs(averagePriceChange)))
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(averagePriceChange >= 0 ? .red : .green)
                }
            }
            
            Divider()
            
            HStack {
                StatItem(
                    title: "Best Deal",
                    value: bestDealPercentage,
                    color: .green
                )
                
                Spacer()
                
                StatItem(
                    title: "Worst Deal",
                    value: worstDealPercentage,
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var averagePriceChange: Double {
        guard !dataManager.watchlistItems.isEmpty else { return 0 }
        let sum = dataManager.watchlistItems.reduce(0.0) { $0 + $1.priceChangePercentage }
        return sum / Double(dataManager.watchlistItems.count)
    }
    
    private var bestDealPercentage: String {
        guard let best = dataManager.watchlistItems.min(by: { $0.priceChangePercentage < $1.priceChangePercentage }) else {
            return "N/A"
        }
        return String(format: "%.1f%%", abs(best.priceChangePercentage))
    }
    
    private var worstDealPercentage: String {
        guard let worst = dataManager.watchlistItems.max(by: { $0.priceChangePercentage < $1.priceChangePercentage }) else {
            return "N/A"
        }
        return String(format: "%.1f%%", abs(worst.priceChangePercentage))
    }
}

// MARK: - Stat Item View

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
    }
}

#Preview {
    WatchlistView()
        .environmentObject(DataManager.shared)
        .environmentObject(NotificationManager.shared)
}
