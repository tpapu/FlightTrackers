//
//  AccountView.swift
//  FlightTracker
//
//  View for managing user account, preferences, and settings.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var authService: AuthenticationService
    
    @State private var showingEditProfile = false
    @State private var showingNotificationSettings = false
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile section
                profileSection
                
                // Preferences section
                preferencesSection
                
                // Notifications section
                notificationsSection
                
                // App info section
                appInfoSection
            }
            .navigationTitle("Account")
            .sheet(isPresented: $showingEditProfile) {
                if let user = dataManager.currentUser {
                    EditProfileView(user: user)
                }
            }
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView()
            }
        }
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        Section {
            if let user = dataManager.currentUser {
                HStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 60, height: 60)
                        
                        Text(user.initials)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullName)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingEditProfile = true
                    } label: {
                        Text("Edit")
                            .font(.subheadline)
                    }
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text("Profile")
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        Section {
            NavigationLink {
                CurrencySettingsView()
            } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.green)
                    Text("Preferred Currency")
                    Spacer()
                    Text(dataManager.currentUser?.preferredCurrency ?? "USD")
                        .foregroundColor(.secondary)
                }
            }
            
            NavigationLink {
                PreferredAirportsView()
            } label: {
                HStack {
                    Image(systemName: "airplane.circle")
                        .foregroundColor(.blue)
                    Text("Preferred Airports")
                    Spacer()
                    Text("\(dataManager.currentUser?.preferredAirports.count ?? 0)")
                        .foregroundColor(.secondary)
                }
            }
            
            NavigationLink {
                LuggagePreferencesView()
            } label: {
                HStack {
                    Image(systemName: "briefcase")
                        .foregroundColor(.orange)
                    Text("Luggage Preferences")
                }
            }
        } header: {
            Text("Preferences")
        }
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        Section {
            HStack {
                Image(systemName: "bell.circle")
                    .foregroundColor(.red)
                Text("Notifications")
                Spacer()
                Text(notificationManager.notificationPermissionGranted ? "Enabled" : "Disabled")
                    .foregroundColor(.secondary)
            }
            
            Button {
                showingNotificationSettings = true
            } label: {
                Text("Notification Settings")
            }
        } header: {
            Text("Alerts")
        } footer: {
            if !notificationManager.notificationPermissionGranted {
                Text("Enable notifications in Settings to receive price alerts")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        Section {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            Link(destination: URL(string: "https://example.com/privacy")!) {
                HStack {
                    Image(systemName: "hand.raised.circle")
                        .foregroundColor(.purple)
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Link(destination: URL(string: "https://example.com/terms")!) {
                HStack {
                    Image(systemName: "doc.text.circle")
                        .foregroundColor(.gray)
                    Text("Terms of Service")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(role: .destructive) {
                showingLogoutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out")
                }
            }
        } header: {
            Text("About")
        }
        .confirmationDialog("Log Out", isPresented: $showingLogoutConfirmation) {
            Button("Log Out", role: .destructive) {
                authService.logout()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State var user: User
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    
    init(user: User) {
        _user = State(initialValue: user)
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName)
        _email = State(initialValue: user.email)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        dataManager.updateUser(user)
        dismiss()
    }
}

// MARK: - Currency Settings View

struct CurrencySettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    let currencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY"]
    
    var body: some View {
        List(currencies, id: \.self) { currency in
            Button {
                if var user = dataManager.currentUser {
                    user.preferredCurrency = currency
                    dataManager.updateUser(user)
                    dismiss()
                }
            } label: {
                HStack {
                    Text(currency)
                    Spacer()
                    if currency == dataManager.currentUser?.preferredCurrency {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Currency")
    }
}

// MARK: - Preferred Airports View

struct PreferredAirportsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    let airports = Airport.samples
    
    var body: some View {
        List(airports, id: \.code) { airport in
            Button {
                toggleAirport(airport.code)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(airport.displayName)
                            .font(.headline)
                        Text(airport.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isPreferred(airport.code) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Preferred Airports")
    }
    
    private func isPreferred(_ code: String) -> Bool {
        dataManager.currentUser?.preferredAirports.contains(code) ?? false
    }
    
    private func toggleAirport(_ code: String) {
        guard var user = dataManager.currentUser else { return }
        
        if let index = user.preferredAirports.firstIndex(of: code) {
            user.preferredAirports.remove(at: index)
        } else {
            user.preferredAirports.append(code)
        }
        
        dataManager.updateUser(user)
    }
}

// MARK: - Luggage Preferences View

struct LuggagePreferencesView: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State private var carryOnBags: Int
    @State private var checkedBags: Int
    @State private var weightUnit: LuggagePreference.WeightUnit
    
    init() {
        let preference = DataManager.shared.currentUser?.luggagePreference ?? .default
        _carryOnBags = State(initialValue: preference.carryOnBags)
        _checkedBags = State(initialValue: preference.checkedBags)
        _weightUnit = State(initialValue: preference.preferredWeight)
    }
    
    var body: some View {
        Form {
            Section("Baggage") {
                Stepper("Carry-on bags: \(carryOnBags)", value: $carryOnBags, in: 0...3)
                Stepper("Checked bags: \(checkedBags)", value: $checkedBags, in: 0...5)
            }
            
            Section("Weight Unit") {
                Picker("Unit", selection: $weightUnit) {
                    ForEach(LuggagePreference.WeightUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Luggage Preferences")
        .onChange(of: carryOnBags) { _, _ in savePreferences() }
        .onChange(of: checkedBags) { _, _ in savePreferences() }
        .onChange(of: weightUnit) { _, _ in savePreferences() }
    }
    
    private func savePreferences() {
        guard var user = dataManager.currentUser else { return }
        user.luggagePreference = LuggagePreference(
            carryOnBags: carryOnBags,
            checkedBags: checkedBags,
            preferredWeight: weightUnit
        )
        dataManager.updateUser(user)
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var enablePriceDropAlerts: Bool
    @State private var enablePriceIncreaseAlerts: Bool
    @State private var priceDropThreshold: Double
    @State private var priceIncreaseThreshold: Double
    
    init() {
        let prefs = DataManager.shared.currentUser?.notificationPreferences ?? .default
        _enablePriceDropAlerts = State(initialValue: prefs.enablePriceDropAlerts)
        _enablePriceIncreaseAlerts = State(initialValue: prefs.enablePriceIncreaseAlerts)
        _priceDropThreshold = State(initialValue: prefs.priceDropThreshold)
        _priceIncreaseThreshold = State(initialValue: prefs.priceIncreaseThreshold)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Price Drop Alerts", isOn: $enablePriceDropAlerts)
                    
                    if enablePriceDropAlerts {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alert when price drops by:")
                                .font(.subheadline)
                            
                            Slider(value: $priceDropThreshold, in: 5...50, step: 5) {
                                Text("Threshold")
                            } minimumValueLabel: {
                                Text("5%")
                            } maximumValueLabel: {
                                Text("50%")
                            }
                            
                            Text("\(Int(priceDropThreshold))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Price Drop Alerts")
                } footer: {
                    Text("Get notified when flight prices decrease")
                }
                
                Section {
                    Toggle("Price Increase Alerts", isOn: $enablePriceIncreaseAlerts)
                    
                    if enablePriceIncreaseAlerts {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alert when price increases by:")
                                .font(.subheadline)
                            
                            Slider(value: $priceIncreaseThreshold, in: 10...50, step: 5) {
                                Text("Threshold")
                            } minimumValueLabel: {
                                Text("10%")
                            } maximumValueLabel: {
                                Text("50%")
                            }
                            
                            Text("\(Int(priceIncreaseThreshold))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Price Increase Alerts")
                } footer: {
                    Text("Get notified when flight prices increase significantly")
                }
            }
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSettings() {
        guard var user = dataManager.currentUser else { return }
        var prefs = user.notificationPreferences
        prefs.enablePriceDropAlerts = enablePriceDropAlerts
        prefs.enablePriceIncreaseAlerts = enablePriceIncreaseAlerts
        prefs.priceDropThreshold = priceDropThreshold
        prefs.priceIncreaseThreshold = priceIncreaseThreshold
        user.notificationPreferences = prefs
        dataManager.updateUser(user)
    }
}

#Preview {
    AccountView()
        .environmentObject(DataManager.shared)
        .environmentObject(NotificationManager.shared)
        .environmentObject(AuthenticationService.shared)
}
