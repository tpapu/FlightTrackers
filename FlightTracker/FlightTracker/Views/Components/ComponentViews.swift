//
//  ComponentViews.swift
//  FlightTracker
//
//  Reusable UI components for displaying flight and watchlist information.
//

import SwiftUI

// MARK: - Flight Card

struct FlightCard: View {
    let flight: Flight
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Header: Airline and price
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.airline)
                        .font(.headline)
                    Text(flight.flightNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text(flight.cabinClass.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Flight times and route
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.departureDate, style: .time)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(flight.origin.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(flight.formattedDuration)
                        .font(.caption)
                    
                    Image(systemName: "airplane")
                        .foregroundColor(.blue)
                    
                    if flight.stops > 0 {
                        Text("\(flight.stops) stop\(flight.stops > 1 ? "s" : "")")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else {
                        Text("Direct")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.arrivalDate, style: .time)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(flight.destination.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Additional info
            HStack {
                if flight.availableSeats < 10 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("\(flight.availableSeats) seats left")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
                
                Spacer()
                
                Button {
                    if dataManager.isInWatchlist(flight) {
                        if let item = dataManager.watchlistItems.first(where: { $0.flight.id == flight.id }) {
                            dataManager.removeFromWatchlist(item)
                        }
                    } else {
                        dataManager.addToWatchlist(flight: flight)
                    }
                } label: {
                    Image(systemName: dataManager.isInWatchlist(flight) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Watchlist Card

struct WatchlistCard: View {
    let item: WatchlistItem
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with price change indicator
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.flight.origin.code) → \(item.flight.destination.code)")
                        .font(.headline)
                    Text(item.flight.airline)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: item.priceTrend.iconName)
                            .font(.caption)
                        Text(String(format: "%.1f%%", abs(item.priceChangePercentage)))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(item.priceChangePercentage >= 0 ? .red : .green)
                    
                    Text(item.flight.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            
            Divider()
            
            // Flight details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.flight.departureDate, style: .date)
                        .font(.subheadline)
                    Text(item.flight.departureDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let targetPrice = item.targetPrice {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Target")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatPrice(targetPrice, currency: item.flight.currency))
                            .font(.subheadline)
                            .foregroundColor(item.belowTargetPrice ? .green : .primary)
                    }
                }
            }
            
            // Notes if available
            if let notes = item.notes, !notes.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func formatPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price)) ?? "\(currency) \(price)"
    }
}

// MARK: - Airport Picker

struct AirportPicker: View {
    @Binding var selection: String
    let placeholder: String
    
    @State private var searchText = ""
    @State private var isSearching = false
    
    private let commonAirports = Airport.samples
    
    var body: some View {
        Menu {
            ForEach(commonAirports, id: \.code) { airport in
                Button {
                    selection = airport.code
                } label: {
                    Text(airport.displayName)
                }
            }
            
            Divider()
            
            Button {
                isSearching = true
            } label: {
                Label("Search Other Airports", systemImage: "magnifyingglass")
            }
        } label: {
            HStack {
                if selection.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                } else {
                    if let airport = commonAirports.first(where: { $0.code == selection }) {
                        Text(airport.displayName)
                    } else {
                        Text(selection)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
        .sheet(isPresented: $isSearching) {
            AirportSearchView(selection: $selection)
        }
    }
}

// MARK: - Airport Search View

struct AirportSearchView: View {
    @Binding var selection: String
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    
    private let airports = Airport.samples
    
    var filteredAirports: [Airport] {
        if searchText.isEmpty {
            return airports
        }
        return airports.filter {
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredAirports, id: \.code) { airport in
                Button {
                    selection = airport.code
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(airport.displayName)
                            .font(.headline)
                        Text(airport.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search airports")
            .navigationTitle("Select Airport")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Recent Search Row

struct RecentSearchRow: View {
    let search: SearchQuery
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(search.origin) → \(search.destination)")
                        .font(.headline)
                    HStack {
                        Text(search.departureDate, style: .date)
                        if let returnDate = search.returnDate {
                            Text("•")
                            Text(returnDate, style: .date)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Flight Card") {
    FlightCard(flight: .sample)
        .environmentObject(DataManager.shared)
        .padding()
}

#Preview("Watchlist Card") {
    WatchlistCard(item: .sample)
        .padding()
}
