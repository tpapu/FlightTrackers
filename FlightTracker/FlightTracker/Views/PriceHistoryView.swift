//
//  PriceHistoryView.swift
//  FlightTracker
//
//  View for displaying price history and trends with charts.
//

import SwiftUI
import Charts

struct PriceHistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedHistory: PriceHistory?
    
    var body: some View {
        NavigationStack {
            Group {
                if dataManager.priceHistories.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .navigationTitle("Price History")
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Price History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Search for flights to start tracking price changes over time")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - History List
    
    private var historyList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(dataManager.priceHistories) { history in
                    PriceHistoryCard(history: history)
                        .onTapGesture {
                            selectedHistory = history
                        }
                }
            }
            .padding()
        }
        .sheet(item: $selectedHistory) { history in
            PriceHistoryDetailView(history: history)
        }
    }
}

// MARK: - Price History Card

struct PriceHistoryCard: View {
    let history: PriceHistory
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(history.origin.code) → \(history.destination.code)")
                        .font(.headline)
                    Text(history.departureDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let changePercentage = history.priceChangePercentage {
                    HStack(spacing: 4) {
                        Image(systemName: changePercentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text(String(format: "%.1f%%", abs(changePercentage)))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(changePercentage >= 0 ? .red : .green)
                }
            }
            
            // Mini chart
            if history.pricePoints.count >= 2 {
                Chart {
                    ForEach(history.pricePoints) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(.blue)
                        
                        AreaMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.3), .blue.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 60)
            }
            
            Divider()
            
            // Price statistics
            HStack {
                StatColumn(title: "Current", value: formatPrice(history.currentPrice))
                Spacer()
                StatColumn(title: "Lowest", value: formatPrice(history.lowestPrice), color: .green)
                Spacer()
                StatColumn(title: "Average", value: formatPrice(history.averagePrice))
                Spacer()
                StatColumn(title: "Highest", value: formatPrice(history.highestPrice), color: .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatPrice(_ price: Double?) -> String {
        guard let price = price else { return "N/A" }
        return String(format: "$%.0f", price)
    }
}

// MARK: - Stat Column

struct StatColumn: View {
    let title: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Price History Detail View

struct PriceHistoryDetailView: View {
    let history: PriceHistory
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTimeRange: TimeRange = .all
    
    enum TimeRange: String, CaseIterable {
        case week = "1W"
        case month = "1M"
        case all = "All"
    }
    
    var filteredPricePoints: [PriceHistory.PricePoint] {
        let now = Date()
        switch selectedTimeRange {
        case .week:
            let weekAgo = now.addingTimeInterval(-7 * 86400)
            return history.pricePoints(from: weekAgo, to: now)
        case .month:
            let monthAgo = now.addingTimeInterval(-30 * 86400)
            return history.pricePoints(from: monthAgo, to: now)
        case .all:
            return history.pricePoints
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Route info
                    routeInfoSection
                    
                    // Time range picker
                    timeRangePicker
                    
                    // Main chart
                    priceChart
                    
                    // Statistics
                    statisticsSection
                    
                    // Price points list
                    pricePointsList
                }
                .padding()
            }
            .navigationTitle("Price History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Route Info Section
    
    private var routeInfoSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text(history.origin.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                
                Text(history.destination.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Text(history.departureDate, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Price Chart
    
    private var priceChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price Trend")
                .font(.headline)
            
            if filteredPricePoints.count >= 2 {
                Chart {
                    ForEach(filteredPricePoints) { point in
                        LineMark(
                            x: .value("Date", point.timestamp),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", point.timestamp),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(.blue)
                        
                        AreaMark(
                            x: .value("Date", point.timestamp),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.3), .blue.opacity(0.05)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
            } else {
                Text("Not enough data to display chart")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(spacing: 12) {
            HStack {
                StatisticBox(
                    title: "Current Price",
                    value: formatPrice(history.currentPrice),
                    color: .blue
                )
                
                StatisticBox(
                    title: "Price Change",
                    value: formatPercentage(history.priceChangePercentage),
                    color: (history.priceChangePercentage ?? 0) >= 0 ? .red : .green
                )
            }
            
            HStack {
                StatisticBox(
                    title: "Lowest",
                    value: formatPrice(history.lowestPrice),
                    color: .green
                )
                
                StatisticBox(
                    title: "Highest",
                    value: formatPrice(history.highestPrice),
                    color: .red
                )
            }
            
            StatisticBox(
                title: "Average Price",
                value: formatPrice(history.averagePrice),
                color: .primary
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Price Points List
    
    private var pricePointsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Updates")
                .font(.headline)
            
            ForEach(filteredPricePoints.reversed()) { point in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(point.timestamp, style: .date)
                            .font(.subheadline)
                        Text(point.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatPrice(point.price))
                            .font(.headline)
                        if let airline = point.airline {
                            Text(airline)
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
    
    // MARK: - Helper Methods
    
    private func formatPrice(_ price: Double?) -> String {
        guard let price = price else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = history.pricePoints.first?.currency ?? "USD"
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    private func formatPercentage(_ percentage: Double?) -> String {
        guard let percentage = percentage else { return "N/A" }
        let sign = percentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", percentage))%"
    }
}

// MARK: - Statistic Box

struct StatisticBox: View {
    let title: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    PriceHistoryView()
        .environmentObject(DataManager.shared)
}
