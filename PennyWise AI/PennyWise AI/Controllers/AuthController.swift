//
//  AuthController.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI
internal import Combine

// MARK: - Auth Controller
@MainActor
class AuthController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var accessToken: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    // MARK: - Authentication State Management
    func checkAuthStatus() {
        // Check if token exists in UserDefaults
        if let token = UserDefaults.standard.string(forKey: "access_token"),
           let userData = UserDefaults.standard.data(forKey: "current_user"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.accessToken = token
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func register(username: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userCreate = UserCreate(username: username, email: email, password: password)
            let user = try await apiService.register(userCreate)
            
            // After registration, automatically login
            await login(username: username, password: password)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userLogin = UserLogin(username: username, password: password)
            let tokenResponse = try await apiService.login(userLogin)
            
            // Get user info (we'll need to decode from token or make another call)
            // For now, we'll store the token and fetch user info
            self.accessToken = tokenResponse.accessToken
            
            // Store token and user in UserDefaults
            UserDefaults.standard.set(tokenResponse.accessToken, forKey: "access_token")
            
            // Fetch user info by making a test call or decode from token
            // For simplicity, we'll create a user object from username
            // In production, you'd decode the JWT or make an API call
            let user = User(id: 0, username: username, email: "")
            self.currentUser = user
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "current_user")
            }
            
            self.isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func logout() {
        accessToken = nil
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "current_user")
    }
}
