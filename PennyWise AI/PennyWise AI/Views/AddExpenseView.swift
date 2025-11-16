//
//  AddExpenseView.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI

// MARK: - Add Expense View
struct AddExpenseView: View {
    @ObservedObject var expenseController: ExpenseController
    @Environment(\.dismiss) var dismiss
    let token: String
    
    @State private var description = ""
    @State private var amount = ""
    @State private var selectedDate = Date()
    @State private var useCustomDate = false
    @State private var classificationResult: ClassifyResponse?
    @State private var isClassifying = false
    @State private var descriptionError: String? = nil
    @State private var amountError: String? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Validation computed properties
    private var isDescriptionValid: Bool {
        let trimmed = description.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= 500
    }
    
    private var isAmountValid: Bool {
        let trimmed = amount.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return false
        }
        guard let amountValue = Double(trimmed) else {
            return false
        }
        return amountValue > 0 && amountValue <= 1_000_000
    }
    
    private var isValid: Bool {
        isDescriptionValid && isAmountValid
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack(spacing: dynamicSpacing(geometry)) {
                        // Description Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: dynamicFontSize(geometry, base: 16), weight: .semibold))
                            TextField("e.g., lunch at restaurant", text: $description)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: dynamicFontSize(geometry, base: 16)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(descriptionError != nil ? Color.negativeRed : Color.clear, lineWidth: 2)
                                )
                                .onChange(of: description) { newValue in
                                    validateDescription()
                                    if !newValue.isEmpty {
                                        classifyDescription()
                                    }
                                }
                            
                            if let error = descriptionError {
                                Text(error)
                                    .font(.system(size: dynamicFontSize(geometry, base: 12)))
                                    .foregroundColor(.negativeRed)
                            }
                            
                            // Character count indicator
                            if !description.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("\(description.count)/500")
                                        .font(.system(size: dynamicFontSize(geometry, base: 11)))
                                        .foregroundColor(description.count > 500 ? .negativeRed : .textSecondary)
                                }
                            }
                            
                            // Classification Result
                            if let result = classificationResult {
                                HStack {
                                    Label(result.category, systemImage: "tag.fill")
                                        .font(.system(size: dynamicFontSize(geometry, base: 14), weight: .medium))
                                        .foregroundColor(Category.color(for: result.category))
                                    Spacer()
                                    Text("\(result.confidencePercentage) confidence")
                                        .font(.system(size: dynamicFontSize(geometry, base: 12)))
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Category.color(for: result.category).opacity(0.15),
                                            Category.color(for: result.category).opacity(0.05)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                            }
                            
                            if isClassifying {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryMint))
                                    Text("Classifying...")
                                        .font(.system(size: dynamicFontSize(geometry, base: 12)))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.top, geometry.size.height * 0.02)
                        
                        // Amount Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.system(size: dynamicFontSize(geometry, base: 16), weight: .semibold))
                            HStack {
                                Text("$")
                                    .font(.system(size: dynamicFontSize(geometry, base: 18), weight: .medium))
                                TextField("0.00", text: $amount)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: dynamicFontSize(geometry, base: 16)))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(amountError != nil ? Color.negativeRed : Color.clear, lineWidth: 2)
                                    )
                                    .onChange(of: amount) { _ in
                                        validateAmount()
                                    }
                            }
                            
                            if let error = amountError {
                                Text(error)
                                    .font(.system(size: dynamicFontSize(geometry, base: 12)))
                                    .foregroundColor(.negativeRed)
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        // Date Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Use custom date", isOn: $useCustomDate)
                                .font(.system(size: dynamicFontSize(geometry, base: 16)))
                            
                            if useCustomDate {
                                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .font(.system(size: dynamicFontSize(geometry, base: 16)))
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        // Error Message
                        if let errorMessage = expenseController.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: dynamicFontSize(geometry, base: 14)))
                                .foregroundColor(.negativeRed)
                                .padding(.horizontal, geometry.size.width * 0.05)
                        }
                        
                        // Save Button
                        Button(action: {
                            // Validate all fields before submitting
                            validateAllFields()
                            
                            if isValid {
                                saveExpense()
                            }
                        }) {
                            HStack {
                                if expenseController.isAddingExpense {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text("Save Expense")
                                    .font(.system(size: dynamicFontSize(geometry, base: 18), weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: dynamicButtonHeight(geometry))
                            .background(isValid ? Color.primaryMint : Color.textSecondary.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isValid || expenseController.isAddingExpense)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.top, geometry.size.height * 0.02)
                    }
                    .padding(.bottom, geometry.size.height * 0.05)
                }
                .background(Color.backgroundSoft)
                .navigationTitle("Add Expense")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.textPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Validation Helpers
    private func validateDescription() {
        let trimmed = description.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            descriptionError = nil // Don't show error while typing
            return
        }
        
        if trimmed.count > 500 {
            descriptionError = "Description must be less than 500 characters"
        } else {
            descriptionError = nil
        }
    }
    
    private func validateAmount() {
        let trimmed = amount.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            amountError = nil // Don't show error while typing
            return
        }
        
        guard let amountValue = Double(trimmed) else {
            amountError = "Please enter a valid number"
            return
        }
        
        if amountValue <= 0 {
            amountError = "Amount must be greater than 0"
        } else if amountValue > 1_000_000 {
            amountError = "Amount must be less than $1,000,000"
        } else {
            amountError = nil
        }
    }
    
    private func validateAllFields() {
        validateDescription()
        validateAmount()
    }
    
    // MARK: - Actions
    private func classifyDescription() {
        guard !description.isEmpty else { return }
        
        isClassifying = true
        Task {
            let result = await expenseController.classifyDescription(description)
            await MainActor.run {
                classificationResult = result
                isClassifying = false
            }
        }
    }
    
    private func saveExpense() {
        let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
        let trimmedAmount = amount.trimmingCharacters(in: .whitespaces)
        
        guard let amountValue = Double(trimmedAmount), amountValue > 0 else { return }
        guard !trimmedDescription.isEmpty else { return }
        
        let dateString = useCustomDate ? formatDate(selectedDate) : nil
        
        Task {
            await expenseController.addExpense(
                description: trimmedDescription,
                amount: amountValue,
                date: dateString,
                token: token
            )
            
            await MainActor.run {
                if expenseController.errorMessage == nil {
                    dismiss()
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Dynamic Sizing Helpers
    private func dynamicFontSize(_ geometry: GeometryProxy, base: CGFloat) -> CGFloat {
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return base * max(scaleFactor, 0.8)
    }
    
    private func dynamicSpacing(_ geometry: GeometryProxy) -> CGFloat {
        let baseSpacing: CGFloat = 20
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return baseSpacing * max(scaleFactor, 0.8)
    }
    
    private func dynamicButtonHeight(_ geometry: GeometryProxy) -> CGFloat {
        let baseHeight: CGFloat = 50
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return baseHeight * max(scaleFactor, 0.8)
    }
}
