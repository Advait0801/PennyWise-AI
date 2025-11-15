//
//  PennyWise_AIApp.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI

@main
struct PennyWise_AIApp: App {
    @StateObject private var authController = AuthController()
    @StateObject private var expenseController = ExpenseController()
    
    init() {
        // Configure app appearance if needed
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authController)
                .environmentObject(expenseController)
                .onAppear {
                    authController.checkAuthStatus()
                }
        }
    }
    
    private func setupAppearance() {
        // Customize navigation bar appearance with mint theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.backgroundCard)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.textPrimary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.textPrimary)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.primaryMint)
        
        // Configure segmented control
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.primaryMint)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.textPrimary)], for: .normal)
    }
}

// MARK: - Content View (Root)
struct ContentView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var expenseController: ExpenseController
    
    var body: some View {
        Group {
            if authController.isAuthenticated {
                MainScreen(
                    authController: authController,
                    expenseController: expenseController
                )
            } else {
                AuthScreen(authController: authController)
            }
        }
    }
}

