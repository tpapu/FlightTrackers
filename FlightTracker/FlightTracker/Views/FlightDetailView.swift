//
//  FlightDetailView.swift
//  FlightTracker
//
//  Detailed view of a single flight with options to save and set alerts.
//

import SwiftUI

struct FlightDetailView: View {
    let flight: Flight
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddToWatchlist = false
    @State private var targetPrice = ""
    @State private var notes = ""
    @State private var showingPriceHistory = false
    
    var isInWatchlist: Bool {
        dataManager.isInWatchlist(flight)
    }
    
    var priceHistory: PriceHistory? {
        dataManager.getPriceHistory(
            origin: flight.origin.code,
            destination: flight.destination.code,
            date: flight.departureDate
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Route header
                routeHeader
                
                // Price section
                priceSection
                
                // Flight details
                flightDetailsSection
                
                // Multi-leg details if applicable
                if flight.isMultiLeg, let legs = flight.legs {
                    multiLegSection(legs: legs)
                }
                
                // Price history button and section
                if priceHistory != nil {
                    priceHistoryButton
                    
                    if showingPriceHistory {
                        priceHistorySection
                    }
                }
                
                // Action buttons
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Flight Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddToWatchlist) {
            addToWatchlistSheet
        }
    }
    
    // MARK: - Route Header
    
    private var routeHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(flight.origin.city)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(flight.origin.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "airplane")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(flight.destination.city)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(flight.destination.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if flight.stops > 0 {
                Text("\(flight.stops) stop\(flight.stops > 1 ? "s" : "")")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            } else {
                Text("Direct Flight")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Price Section
    
    private var priceSection: some View {
        VStack(spacing: 8) {
            Text("Total Price")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(flight.formattedPrice)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
            
            Text(flight.cabinClass.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Flight Details Section
    
    private var flightDetailsSection: some View {
        VStack(spacing: 16) {
            DetailRow(
                icon: "calendar",
                title: "Departure Date",
                value: flight.departureDate.formatted(date: .long, time: .omitted)
            )
            
            DetailRow(
                icon: "clock",
                title: "Departure Time",
                value: flight.departureDate.formatted(date: .omitted, time: .shortened)
            )
            
            DetailRow(
                icon: "clock.arrow.2.circlepath",
                title: "Arrival Time",
                value: flight.arrivalDate.formatted(date: .omitted, time: .shortened)
            )
            
            DetailRow(
                icon: "hourglass",
                title: "Duration",
                value: flight.formattedDuration
            )
            
            DetailRow(
                icon: "building.2",
                title: "Airline",
                value: flight.airline
            )
            
            DetailRow(
                icon: "airplane",
                title: "Flight Number",
                value: flight.flightNumber
            )
            
            if flight.availableSeats < 10 {
                DetailRow(
                    icon: "chair",
                    title: "Available Seats",
                    value: "\(flight.availableSeats)",
                    valueColor: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Multi-Leg Section
    
    private func multiLegSection(legs: [FlightLeg]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flight Legs")
                .font(.headline)
            
            ForEach(Array(legs.enumerated()), id: \.element.id) { index, leg in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Leg \(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(leg.flightNumber)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(leg.departureDate, style: .time)
                                .font(.headline)
                            Text(leg.origin.code)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(leg.arrivalDate, style: .time)
                                .font(.headline)
                            Text(leg.destination.code)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons
    
    private var priceHistoryButton: some View {
        Button {
            withAnimation {
                showingPriceHistory.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("Price History")
                    .font(.headline)
                Spacer()
                Image(systemName: showingPriceHistory ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private var priceHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let history = priceHistory {
                // Statistics
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatPrice(history.currentPrice))
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Lowest")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatPrice(history.lowestPrice))
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Highest")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatPrice(history.highestPrice))
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Average")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatPrice(history.averagePrice))
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // Price trend indicator
                if let changePercentage = history.priceChangePercentage {
                    HStack {
                        Image(systemName: changePercentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(changePercentage >= 0 ? .red : .green)
                        Text("Price \(changePercentage >= 0 ? "increased" : "decreased") by \(String(format: "%.1f", abs(changePercentage)))%")
                            .font(.subheadline)
                        Spacer()
                    }
                }
                
                Divider()
                
                // Recent price points
                Text("Recent Price Updates")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(history.pricePoints.suffix(5).reversed()) { point in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(point.timestamp, style: .date)
                                .font(.caption)
                            Text(point.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatPrice(point.price))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            if let airline = point.airline {
                                Text(airline)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatPrice(_ price: Double?) -> String {
        guard let price = price else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = flight.currency
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if isInWatchlist {
                Button {
                    if let item = dataManager.watchlistItems.first(where: { $0.flight.id == flight.id }) {
                        dataManager.removeFromWatchlist(item)
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "star.slash")
                        Text("Remove from Watchlist")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            } else {
                Button {
                    showingAddToWatchlist = true
                } label: {
                    HStack {
                        Image(systemName: "star")
                        Text("Add to Watchlist")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            Button {
                // Share functionality
                shareFlightDetails()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Flight")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Add to Watchlist Sheet
    
    private var addToWatchlistSheet: some View {
        NavigationStack {
            Form {
                Section("Set Target Price (Optional)") {
                    TextField("Target Price", text: $targetPrice)
                        .keyboardType(.decimalPad)
                    
                    Text("You'll be notified when the price drops to or below this amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add to Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddToWatchlist = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let target = Double(targetPrice)
                        dataManager.addToWatchlist(
                            flight: flight,
                            targetPrice: target,
                            notes: notes.isEmpty ? nil : notes
                        )
                        showingAddToWatchlist = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func shareFlightDetails() {
        let text = """
        Flight: \(flight.flightNumber)
        Route: \(flight.origin.displayName) → \(flight.destination.displayName)
        Date: \(flight.departureDate.formatted(date: .long, time: .shortened))
        Price: \(flight.formattedPrice)
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(.blue)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    NavigationStack {
        FlightDetailView(flight: .sample)
            .environmentObject(DataManager.shared)
    }
}
