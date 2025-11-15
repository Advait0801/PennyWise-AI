//
//  AuthScreen.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI

// MARK: - Auth Screen
struct AuthScreen: View {
    @ObservedObject var authController: AuthController
    @State private var isLoginMode = true
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: dynamicSpacing(geometry)) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: dynamicFontSize(geometry, base: 60)))
                            .foregroundColor(.primaryMint)
                        
                        Text("Smart Expense")
                            .font(.system(size: dynamicFontSize(geometry, base: 32), weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        Text("Classifier")
                            .font(.system(size: dynamicFontSize(geometry, base: 24), weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, geometry.size.height * 0.1)
                    .padding(.bottom, geometry.size.height * 0.05)
                    
                    // Toggle between Login and Register
                    Picker("Mode", selection: $isLoginMode) {
                        Text("Login").tag(true)
                        Text("Register").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.bottom, geometry.size.height * 0.03)
                    
                    // Form
                    VStack(spacing: dynamicSpacing(geometry)) {
                        // Username
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username")
                                .font(.system(size: dynamicFontSize(geometry, base: 14), weight: .medium))
                            TextField("Enter username", text: $username)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .font(.system(size: dynamicFontSize(geometry, base: 16)))
                        }
                        
                        // Email (only for register)
                        if !isLoginMode {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.system(size: dynamicFontSize(geometry, base: 14), weight: .medium))
                                TextField("Enter email", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .font(.system(size: dynamicFontSize(geometry, base: 16)))
                            }
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: dynamicFontSize(geometry, base: 14), weight: .medium))
                            SecureField("Enter password", text: $password)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .textContentType(.none)
                                .font(.system(size: dynamicFontSize(geometry, base: 16)))
                        }
                        
                        // Confirm Password (only for register)
                        if !isLoginMode {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Confirm Password")
                                    .font(.system(size: dynamicFontSize(geometry, base: 14), weight: .medium))
                                SecureField("Confirm password", text: $confirmPassword)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .textContentType(.none)
                                    .font(.system(size: dynamicFontSize(geometry, base: 16)))
                            }
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.1)
                    
                    // Error Message
                    if let errorMessage = authController.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: dynamicFontSize(geometry, base: 14)))
                            .foregroundColor(.negativeRed)
                            .padding(.horizontal, geometry.size.width * 0.1)
                            .padding(.top, 8)
                    }
                    
                    // Submit Button
                    Button(action: {
                        Task {
                            if isLoginMode {
                                await authController.login(username: username, password: password)
                            } else {
                                if password == confirmPassword {
                                    await authController.register(username: username, email: email, password: password)
                                } else {
                                    authController.errorMessage = "Passwords do not match"
                                }
                            }
                        }
                    }) {
                        HStack {
                            if authController.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isLoginMode ? "Login" : "Register")
                                .font(.system(size: dynamicFontSize(geometry, base: 18), weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: dynamicButtonHeight(geometry))
                        .background(Color.primaryMint)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(authController.isLoading || username.isEmpty || password.isEmpty || (!isLoginMode && email.isEmpty))
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.top, geometry.size.height * 0.02)
                }
                .frame(minHeight: geometry.size.height)
            }
            .background(Color.backgroundSoft)
        }
    }
    
    // MARK: - Dynamic Sizing Helpers
    private func dynamicFontSize(_ geometry: GeometryProxy, base: CGFloat) -> CGFloat {
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return base * max(scaleFactor, 0.8)
    }
    
    private func dynamicSpacing(_ geometry: GeometryProxy) -> CGFloat {
        let baseSpacing: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return baseSpacing * max(scaleFactor, 0.8)
    }
    
    private func dynamicButtonHeight(_ geometry: GeometryProxy) -> CGFloat {
        let baseHeight: CGFloat = 50
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return baseHeight * max(scaleFactor, 0.8)
    }
}
