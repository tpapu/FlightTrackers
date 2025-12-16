//
//  WelcomeView.swift
//  FlightTracker
//
//  Welcome screen with authentication for new and returning users.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingSignUp = false
    @State private var showingLogin = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue, .cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App logo and title
                VStack(spacing: 16) {
                    Image(systemName: "airplane.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                    
                    Text("FlightTracker")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Track prices, save money, travel smarter")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Features list
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "magnifyingglass", text: "Search thousands of flights")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track price changes")
                    FeatureRow(icon: "bell.fill", text: "Get price drop alerts")
                    FeatureRow(icon: "star.fill", text: "Save your favorite routes")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button {
                        showingSignUp = true
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        showingLogin = true
                    } label: {
                        Text("I Already Have an Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Sign Up View

struct SignUpView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account Information") {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                }
                
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section {
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                } header: {
                    Text("Password")
                } footer: {
                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button {
                        signUp()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty &&
        !firstName.isEmpty && !lastName.isEmpty &&
        password == confirmPassword
    }
    
    private func signUp() {
        errorMessage = ""
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        
        let result = authService.signUp(
            username: username,
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        
        isLoading = false
        
        switch result {
        case .success:
            dismiss()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Login") {
                    TextField("Username or Email", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button {
                        login()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isLoading || username.isEmpty || password.isEmpty)
                }
            }
            .navigationTitle("Log In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func login() {
        errorMessage = ""
        isLoading = true
        
        let result = authService.login(username: username, password: password)
        
        isLoading = false
        
        switch result {
        case .success:
            dismiss()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

#Preview("Welcome") {
    WelcomeView()
        .environmentObject(AuthenticationService.shared)
}

#Preview("Sign Up") {
    SignUpView()
        .environmentObject(AuthenticationService.shared)
}

#Preview("Login") {
    LoginView()
        .environmentObject(AuthenticationService.shared)
}
