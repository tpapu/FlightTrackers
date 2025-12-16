//
//  AuthenticationService.swift
//  FlightTracker
//
//  Service for handling user authentication with secure password hashing.
//

import Foundation
import CryptoKit

/// Service for managing user authentication and password security
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated = false
    @Published var currentUserId: String?
    
    private let userDefaultsKey = "FlightTrackerUsers"
    private var users: [String: StoredUser] = [:]
    
    /// Stored user data with hashed password
    struct StoredUser: Codable {
        let id: String
        let username: String
        let email: String
        let passwordHash: String
        let salt: String
        let createdAt: Date
    }
    
    private init() {
        loadUsers()
        checkAuthentication()
    }
    
    // MARK: - Authentication Status
    
    /// Check if user is already logged in
    private func checkAuthentication() {
        if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
            currentUserId = userId
            isAuthenticated = true
        }
    }
    
    // MARK: - Sign Up
    
    /// Create a new user account
    /// - Parameters:
    ///   - username: Desired username
    ///   - email: User email address
    ///   - password: Plain text password (will be hashed)
    ///   - firstName: User's first name
    ///   - lastName: User's last name
    /// - Returns: Result with user ID or error
    func signUp(
        username: String,
        email: String,
        password: String,
        firstName: String,
        lastName: String
    ) -> Result<String, AuthError> {
        // Validation
        guard !username.isEmpty else {
            return .failure(.emptyUsername)
        }
        
        guard !email.isEmpty, email.contains("@") else {
            return .failure(.invalidEmail)
        }
        
        guard password.count >= 6 else {
            return .failure(.weakPassword)
        }
        
        // Check if username already exists
        if users.values.contains(where: { $0.username.lowercased() == username.lowercased() }) {
            return .failure(.usernameTaken)
        }
        
        // Check if email already exists
        if users.values.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            return .failure(.emailTaken)
        }
        
        // Generate salt and hash password
        let salt = generateSalt()
        let passwordHash = hashPassword(password, salt: salt)
        
        // Create user ID
        let userId = UUID().uuidString
        
        // Create stored user
        let storedUser = StoredUser(
            id: userId,
            username: username,
            email: email,
            passwordHash: passwordHash,
            salt: salt,
            createdAt: Date()
        )
        
        // Save user
        users[userId] = storedUser
        saveUsers()
        
        // Create user profile in DataManager
        DataManager.shared.createUser(
            id: userId,
            username: username,
            email: email,
            firstName: firstName,
            lastName: lastName
        )
        
        // Log in the user
        login(userId: userId)
        
        return .success(userId)
    }
    
    // MARK: - Login
    
    /// Authenticate user with credentials
    /// - Parameters:
    ///   - username: Username or email
    ///   - password: Plain text password
    /// - Returns: Result with user ID or error
    func login(username: String, password: String) -> Result<String, AuthError> {
        // Find user by username or email
        guard let storedUser = users.values.first(where: {
            $0.username.lowercased() == username.lowercased() ||
            $0.email.lowercased() == username.lowercased()
        }) else {
            return .failure(.invalidCredentials)
        }
        
        // Verify password
        let passwordHash = hashPassword(password, salt: storedUser.salt)
        guard passwordHash == storedUser.passwordHash else {
            return .failure(.invalidCredentials)
        }
        
        // Log in the user
        login(userId: storedUser.id)
        
        return .success(storedUser.id)
    }
    
    /// Set user as logged in
    private func login(userId: String) {
        currentUserId = userId
        isAuthenticated = true
        UserDefaults.standard.set(userId, forKey: "currentUserId")
        
        // Update last login in DataManager
        DataManager.shared.updateLastLogin()
    }
    
    // MARK: - Logout
    
    /// Log out current user
    func logout() {
        currentUserId = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "currentUserId")
    }
    
    // MARK: - Password Security
    
    /// Generate random salt for password hashing
    private func generateSalt() -> String {
        let saltData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        return saltData.base64EncodedString()
    }
    
    /// Hash password with salt using SHA256
    /// - Parameters:
    ///   - password: Plain text password
    ///   - salt: Salt string
    /// - Returns: Hashed password as hex string
    private func hashPassword(_ password: String, salt: String) -> String {
        let saltedPassword = password + salt
        let data = Data(saltedPassword.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Persistence
    
    /// Load users from UserDefaults
    private func loadUsers() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return
        }
        
        do {
            users = try JSONDecoder().decode([String: StoredUser].self, from: data)
        } catch {
            print("Error loading users: \(error)")
        }
    }
    
    /// Save users to UserDefaults
    private func saveUsers() {
        do {
            let data = try JSONEncoder().encode(users)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error saving users: \(error)")
        }
    }
    
    // MARK: - Error Types
    
    enum AuthError: LocalizedError {
        case emptyUsername
        case invalidEmail
        case weakPassword
        case usernameTaken
        case emailTaken
        case invalidCredentials
        
        var errorDescription: String? {
            switch self {
            case .emptyUsername:
                return "Username cannot be empty"
            case .invalidEmail:
                return "Please enter a valid email address"
            case .weakPassword:
                return "Password must be at least 6 characters"
            case .usernameTaken:
                return "Username is already taken"
            case .emailTaken:
                return "Email is already registered"
            case .invalidCredentials:
                return "Invalid username or password"
            }
        }
    }
}
