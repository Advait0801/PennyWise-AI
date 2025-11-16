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
    @State private var usernameError: String? = nil
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var confirmPasswordError: String? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Validation computed properties
    private var isUsernameValid: Bool {
        if username.isEmpty {
            return false
        }
        if isLoginMode {
            return username.count >= 3
        } else {
            return username.count >= 3 && username.count <= 50
        }
    }
    
    private var isEmailValid: Bool {
        if isLoginMode { return true }
        if email.isEmpty { return false }
        return isValidEmail(email)
    }
    
    private var isPasswordValid: Bool {
        if password.isEmpty { return false }
        if isLoginMode {
            return password.count >= 6
        } else {
            return password.count >= 6
        }
    }
    
    private var isConfirmPasswordValid: Bool {
        if isLoginMode { return true }
        if confirmPassword.isEmpty { return false }
        return password == confirmPassword
    }
    
    private var isFormValid: Bool {
        let baseValid = isUsernameValid && isPasswordValid
        if isLoginMode {
            return baseValid
        } else {
            return baseValid && isEmailValid && isConfirmPasswordValid
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: dynamicSpacing(geometry)) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: dynamicFontSize(geometry, base: 60)))
                            .foregroundColor(.primaryMint)
                        
                        Text("PennyWise AI")
                            .font(.system(size: dynamicFontSize(geometry, base: 32), weight: .bold))
                            .foregroundColor(.textPrimary)
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(usernameError != nil ? Color.negativeRed : Color.clear, lineWidth: 2)
                                )
                                .onChange(of: username) { _ in
                                    validateUsername()
                                }
                                .onChange(of: isLoginMode) { _ in
                                    validateUsername()
                                }
                            
                            if let error = usernameError {
                                Text(error)
                                    .font(.system(size: dynamicFontSize(geometry, base: 12)))
                                    .foregroundColor(.negativeRed)
                            }
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
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(emailError != nil ? Color.negativeRed : Color.clear, lineWidth: 2)
                                    )
                                    .onChange(of: email) { _ in
                                        validateEmail()
                                    }
                                
                                if let error = emailError {
                                    Text(error)
                                        .font(.system(size: dynamicFontSize(geometry, base: 12)))
                                        .foregroundColor(.negativeRed)
                                }
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(passwordError != nil ? Color.negativeRed : Color.clear, lineWidth: 2)
                                )
                                .onChange(of: password) { _ in
                                    validatePassword()
                                    if !isLoginMode {
                                        validateConfirmPassword()
                                    }
                                }
                                .onChange(of: isLoginMode) { _ in
                                    validatePassword()
                                }
                            
                            if let error = passwordError {
                                Text(error)
                                    .font(.system(size: dynamicFontSize(geometry, base: 12)))
                                    .foregroundColor(.negativeRed)
                            }
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
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(confirmPasswordError != nil ? Color.negativeRed : Color.clear, lineWidth: 2)
                                    )
                                    .onChange(of: confirmPassword) { _ in
                                        validateConfirmPassword()
                                    }
                                
                                if let error = confirmPasswordError {
                                    Text(error)
                                        .font(.system(size: dynamicFontSize(geometry, base: 12)))
                                        .foregroundColor(.negativeRed)
                                }
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
                        // Validate all fields before submitting
                        validateAllFields()
                        
                        if isFormValid {
                            Task {
                                if isLoginMode {
                                    await authController.login(username: username.trimmingCharacters(in: .whitespaces), password: password)
                                } else {
                                    await authController.register(
                                        username: username.trimmingCharacters(in: .whitespaces),
                                        email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                                        password: password
                                    )
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
                        .background(isFormValid ? Color.primaryMint : Color.textSecondary.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(authController.isLoading || !isFormValid)
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .padding(.top, geometry.size.height * 0.02)
                }
                .frame(minHeight: geometry.size.height)
            }
            .background(Color.backgroundSoft)
        }
    }
    
    // MARK: - Validation Helpers
    private func validateUsername() {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            usernameError = nil // Don't show error while typing
            return
        }
        
        if trimmed.count < 3 {
            usernameError = "Username must be at least 3 characters"
        } else if !isLoginMode && trimmed.count > 50 {
            usernameError = "Username must be less than 50 characters"
        } else {
            usernameError = nil
        }
    }
    
    private func validateEmail() {
        let trimmed = email.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmed.isEmpty {
            emailError = nil // Don't show error while typing
            return
        }
        
        if !isValidEmail(trimmed) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = nil
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = nil // Don't show error while typing
            return
        }
        
        if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
        } else {
            passwordError = nil
        }
    }
    
    private func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = nil // Don't show error while typing
            return
        }
        
        if password != confirmPassword {
            confirmPasswordError = "Passwords do not match"
        } else {
            confirmPasswordError = nil
        }
    }
    
    private func validateAllFields() {
        validateUsername()
        if !isLoginMode {
            validateEmail()
            validateConfirmPassword()
        }
        validatePassword()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
