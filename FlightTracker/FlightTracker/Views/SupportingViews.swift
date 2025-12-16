//
//  SupportingViews.swift
//  FlightTracker
//
//  Additional supporting views for map display, filters, and watchlist details.
//

import SwiftUI
import MapKit

// MARK: - Flight Map View

struct FlightMapView: View {
    let origin: String
    let destination: String
    @Environment(\.dismiss) var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )
    
    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                MapMarker(coordinate: annotation.coordinate, tint: annotation.color)
            }
            .navigationTitle("Flight Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                setupMap()
            }
        }
    }
    
    private var annotations: [MapAnnotation] {
        let airports = Airport.samples
        var results: [MapAnnotation] = []
        
        if let originAirport = airports.first(where: { $0.code == origin }),
           let originLat = originAirport.latitude,
           let originLon = originAirport.longitude {
            results.append(MapAnnotation(
                id: origin,
                coordinate: CLLocationCoordinate2D(latitude: originLat, longitude: originLon),
                title: originAirport.city,
                color: .green
            ))
        }
        
        if let destAirport = airports.first(where: { $0.code == destination }),
           let destLat = destAirport.latitude,
           let destLon = destAirport.longitude {
            results.append(MapAnnotation(
                id: destination,
                coordinate: CLLocationCoordinate2D(latitude: destLat, longitude: destLon),
                title: destAirport.city,
                color: .red
            ))
        }
        
        return results
    }
    
    private func setupMap() {
        let airports = Airport.samples
        guard let originAirport = airports.first(where: { $0.code == origin }),
              let destAirport = airports.first(where: { $0.code == destination }),
              let originLat = originAirport.latitude,
              let originLon = originAirport.longitude,
              let destLat = destAirport.latitude,
              let destLon = destAirport.longitude else {
            return
        }
        
        // Calculate center point and span
        let centerLat = (originLat + destLat) / 2
        let centerLon = (originLon + destLon) / 2
        let latSpan = abs(originLat - destLat) * 1.5
        let lonSpan = abs(originLon - destLon) * 1.5
        
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(latSpan, 10), longitudeDelta: max(lonSpan, 10))
        )
    }
}

struct MapAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let title: String
    let color: Color
}

// MARK: - Filter View

struct FilterView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var maxStops: Double
    @State private var maxPrice: String
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        _maxStops = State(initialValue: Double(viewModel.maxStops))
        _maxPrice = State(initialValue: viewModel.maxPrice.map { String(format: "%.0f", $0) } ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Maximum Stops")
                            .font(.subheadline)
                        
                        Slider(value: $maxStops, in: 0...3, step: 1) {
                            Text("Stops")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("3")
                        }
                        
                        HStack {
                            ForEach(0...3, id: \.self) { stops in
                                Text(stops == 0 ? "Direct" : "\(stops)")
                                    .font(.caption)
                                    .foregroundColor(Int(maxStops) == stops ? .blue : .secondary)
                                if stops < 3 {
                                    Spacer()
                                }
                            }
                        }
                    }
                } header: {
                    Text("Stops")
                }
                
                Section {
                    TextField("Maximum Price", text: $maxPrice)
                        .keyboardType(.decimalPad)
                    
                    if !maxPrice.isEmpty {
                        Button("Clear") {
                            maxPrice = ""
                        }
                    }
                } header: {
                    Text("Price Limit")
                } footer: {
                    Text("Leave empty for no limit")
                }
                
                Section {
                    Button("Apply Filters") {
                        applyFilters()
                        dismiss()
                    }
                    
                    Button("Reset Filters", role: .destructive) {
                        resetFilters()
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        applyFilters()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func applyFilters() {
        viewModel.maxStops = Int(maxStops)
        viewModel.maxPrice = Double(maxPrice)
    }
    
    private func resetFilters() {
        maxStops = 2
        maxPrice = ""
        viewModel.maxStops = 2
        viewModel.maxPrice = nil
    }
}

// MARK: - Watchlist Item Detail View

struct WatchlistItemDetailView: View {
    let item: WatchlistItem
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Flight card
                FlightCard(flight: item.flight)
                
                // Price tracking section
                priceTrackingSection
                
                // Price history chart
                if item.priceHistory.count >= 2 {
                    priceHistoryChart
                }
                
                // Notes section
                if let notes = item.notes, !notes.isEmpty {
                    notesSection(notes)
                }
                
                // Actions
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Watchlist Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditWatchlistItemView(item: item)
        }
    }
    
    // MARK: - Price Tracking Section
    
    private var priceTrackingSection: some View {
        VStack(spacing: 12) {
            Text("Price Tracking")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Initial Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatPrice(item.initialPrice))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: item.priceDifference >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text(String(format: "%.1f%%", abs(item.priceChangePercentage)))
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(item.priceDifference >= 0 ? .red : .green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(item.flight.formattedPrice)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            if let targetPrice = item.targetPrice {
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Target Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatPrice(targetPrice))
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    if item.belowTargetPrice {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Target Reached!")
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                    } else {
                        let difference = item.flight.price - targetPrice
                        Text(formatPrice(difference) + " away")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Price History Chart
    
    private var priceHistoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price History")
                .font(.headline)
            
            // Simple line representation (Charts framework used in production)
            VStack(spacing: 4) {
                ForEach(item.priceHistory.suffix(5)) { snapshot in
                    HStack {
                        Text(snapshot.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatPrice(snapshot.price))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Notes Section
    
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            
            Text(notes)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    // Simulate price update
                    var updatedItem = item
                    let newPrice = item.flight.price + Double.random(in: -20...20)
                    updatedItem.updatePrice(max(newPrice, 50))
                    dataManager.updateWatchlistItem(updatedItem)
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Check Price Now")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(role: .destructive) {
                dataManager.removeFromWatchlist(item)
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Remove from Watchlist")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = item.flight.currency
        return formatter.string(from: NSNumber(value: price)) ?? "\(item.flight.currency) \(price)"
    }
}

// MARK: - Edit Watchlist Item View

struct EditWatchlistItemView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State var item: WatchlistItem
    @State private var targetPrice: String
    @State private var notes: String
    @State private var priceAlertEnabled: Bool
    
    init(item: WatchlistItem) {
        _item = State(initialValue: item)
        _targetPrice = State(initialValue: item.targetPrice.map { String(format: "%.0f", $0) } ?? "")
        _notes = State(initialValue: item.notes ?? "")
        _priceAlertEnabled = State(initialValue: item.priceAlertEnabled)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Target Price") {
                    TextField("Target Price", text: $targetPrice)
                        .keyboardType(.decimalPad)
                }
                
                Section("Price Alerts") {
                    Toggle("Enable Price Alerts", isOn: $priceAlertEnabled)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Watchlist Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        item.targetPrice = Double(targetPrice)
        item.notes = notes.isEmpty ? nil : notes
        item.priceAlertEnabled = priceAlertEnabled
        dataManager.updateWatchlistItem(item)
        dismiss()
    }
}

#Preview("Map View") {
    FlightMapView(origin: "LAX", destination: "JFK")
}

#Preview("Watchlist Detail") {
    NavigationStack {
        WatchlistItemDetailView(item: .sample)
            .environmentObject(DataManager.shared)
    }
}
