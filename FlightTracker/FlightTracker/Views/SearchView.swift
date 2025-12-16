//
//  SearchView.swift
//  FlightTracker
//
//  View for searching flights with origin/destination selection,
//  date pickers, and displaying search results.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel = SearchViewModel()
    
    @State private var showingFilters = false
    @State private var showingMap = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Search form
                    searchFormSection
                    
                    // Recent searches
                    if !dataManager.recentSearches.isEmpty && viewModel.searchResults.isEmpty {
                        recentSearchesSection
                    }
                    
                    // Search button
                    searchButton
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        ProgressView("Searching flights...")
                            .padding()
                    }
                    
                    // Error message
                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }
                    
                    // Search results
                    if !viewModel.searchResults.isEmpty {
                        searchResultsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Search Flights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingMap.toggle()
                    } label: {
                        Image(systemName: "map")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingMap) {
                if !viewModel.origin.isEmpty && !viewModel.destination.isEmpty {
                    FlightMapView(
                        origin: viewModel.origin,
                        destination: viewModel.destination
                    )
                }
            }
        }
    }
    
    // MARK: - Search Form Section
    
    private var searchFormSection: some View {
        VStack(spacing: 16) {
            // Origin and Destination
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    AirportPicker(
                        selection: $viewModel.origin,
                        placeholder: "Origin"
                    )
                }
                
                Button {
                    viewModel.swapAirports()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    AirportPicker(
                        selection: $viewModel.destination,
                        placeholder: "Destination"
                    )
                }
            }
            
            // Dates
            HStack {
                DatePicker(
                    "Departure",
                    selection: $viewModel.departureDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                
                if viewModel.isRoundTrip {
                    DatePicker(
                        "Return",
                        selection: Binding(
                            get: { viewModel.returnDate ?? viewModel.departureDate },
                            set: { viewModel.returnDate = $0 }
                        ),
                        in: viewModel.departureDate...,
                        displayedComponents: .date
                    )
                }
            }
            
            // Trip type toggle
            Toggle("Round trip", isOn: $viewModel.isRoundTrip)
            
            // Passengers and cabin class
            HStack {
                Stepper("Passengers: \(viewModel.passengers)", value: $viewModel.passengers, in: 1...9)
                
                Spacer()
                
                Picker("Class", selection: $viewModel.cabinClass) {
                    ForEach(Flight.CabinClass.allCases, id: \.self) { cabinClass in
                        Text(cabinClass.rawValue).tag(cabinClass)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Recent Searches Section
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear") {
                    dataManager.clearSearchHistory()
                }
                .font(.caption)
            }
            
            ForEach(dataManager.recentSearches.prefix(3)) { search in
                RecentSearchRow(search: search) {
                    viewModel.loadSearch(search)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Search Button
    
    private var searchButton: some View {
        Button {
            Task {
                await viewModel.searchFlights(dataManager: dataManager)
            }
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search Flights")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canSearch ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canSearch || viewModel.isLoading)
    }
    
    // MARK: - Search Results Section
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Found \(viewModel.searchResults.count) flights")
                    .font(.headline)
                
                Spacer()
                
                Picker("Sort", selection: $viewModel.sortOption) {
                    Text("Price").tag(SearchViewModel.SortOption.price)
                    Text("Duration").tag(SearchViewModel.SortOption.duration)
                    Text("Departure").tag(SearchViewModel.SortOption.departure)
                }
                .pickerStyle(.menu)
            }
            
            ForEach(viewModel.sortedResults) { flight in
                NavigationLink {
                    FlightDetailView(flight: flight)
                } label: {
                    FlightCard(flight: flight)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Search ViewModel

class SearchViewModel: ObservableObject {
    @Published var origin = ""
    @Published var destination = ""
    @Published var departureDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
    @Published var returnDate: Date?
    @Published var passengers = 1
    @Published var cabinClass: Flight.CabinClass = .economy
    @Published var isRoundTrip = false
    
    @Published var searchResults: [Flight] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var sortOption: SortOption = .price
    @Published var maxStops: Int = 2
    @Published var maxPrice: Double?
    
    enum SortOption {
        case price, duration, departure
    }
    
    var canSearch: Bool {
        !origin.isEmpty && !destination.isEmpty
    }
    
    var sortedResults: [Flight] {
        var results = searchResults
        
        // Apply filters
        results = results.filter { $0.stops <= maxStops }
        if let maxPrice = maxPrice {
            results = results.filter { $0.price <= maxPrice }
        }
        
        // Sort
        switch sortOption {
        case .price:
            results.sort { $0.price < $1.price }
        case .duration:
            results.sort { $0.duration < $1.duration }
        case .departure:
            results.sort { $0.departureDate < $1.departureDate }
        }
        
        return results
    }
    
    func swapAirports() {
        let temp = origin
        origin = destination
        destination = temp
    }
    
    func loadSearch(_ search: SearchQuery) {
        origin = search.origin
        destination = search.destination
        departureDate = search.departureDate
        returnDate = search.returnDate
        passengers = search.passengers
        cabinClass = search.cabinClass
        isRoundTrip = search.returnDate != nil
    }
    
    @MainActor
    func searchFlights(dataManager: DataManager) async {
        isLoading = true
        errorMessage = nil
        searchResults = []
        
        do {
            let results = try await DuffelAPIService.shared.searchFlights(
                origin: origin,
                destination: destination,
                departureDate: departureDate,
                returnDate: isRoundTrip ? returnDate : nil,
                passengers: passengers,
                cabinClass: cabinClass
            )
            
            searchResults = results
            
            // Save search query
            let query = SearchQuery(
                origin: origin,
                destination: destination,
                departureDate: departureDate,
                returnDate: isRoundTrip ? returnDate : nil,
                passengers: passengers,
                cabinClass: cabinClass
            )
            dataManager.addSearchQuery(query)
            
            // Add to price history
            for flight in results {
                dataManager.addPriceHistory(for: flight)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    SearchView()
        .environmentObject(DataManager.shared)
        .environmentObject(NotificationManager.shared)
}
