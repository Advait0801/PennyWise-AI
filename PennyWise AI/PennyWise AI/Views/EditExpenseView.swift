//
//  EditExpenseView.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI

// MARK: - Edit Expense View
struct EditExpenseView: View {
    @ObservedObject var expenseController: ExpenseController
    @Environment(\.dismiss) var dismiss
    let expense: Expense
    let token: String
    
    @State private var description: String
    @State private var amount: String
    @State private var selectedDate: Date
    @State private var useCustomDate: Bool
    @State private var classificationResult: ClassifyResponse?
    @State private var isClassifying = false
    @State private var descriptionError: String? = nil
    @State private var amountError: String? = nil
    @State private var showValidationAlert = false
    @State private var validationAlertMessage = ""
    @State private var showDeleteConfirmation = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(expense: Expense, expenseController: ExpenseController, token: String) {
        self.expense = expense
        self.expenseController = expenseController
        self.token = token
        
        // Initialize state from expense
        _description = State(initialValue: expense.description)
        
        let expenseAmount = expense.amount
        _amount = State(initialValue: String(format: "%.2f", expenseAmount))
        
        // Parse date from expense
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dateString = expense.date, let date = formatter.date(from: dateString) {
            _selectedDate = State(initialValue: date)
            _useCustomDate = State(initialValue: true)
        } else {
            _selectedDate = State(initialValue: Date())
            _useCustomDate = State(initialValue: false)
        }
    }
    
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
                            hideKeyboard()
                            validateAllFields()
                            
                            if isValid {
                                saveExpense()
                            } else {
                                if !isDescriptionValid {
                                    validationAlertMessage = "Description cannot be empty and must be under 500 characters"
                                } else if !isAmountValid {
                                    validationAlertMessage = "Amount must be a valid number greater than 0 and less than $1,000,000"
                                } else {
                                    validationAlertMessage = "Please correct the input fields"
                                }
                                showValidationAlert = true
                            }
                        }) {
                            Text("Save Changes")
                                .font(.system(size: dynamicFontSize(geometry, base: 18), weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: dynamicButtonHeight(geometry))
                                .background(isValid ? Color.primaryMint : Color.textSecondary.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(!isValid)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.top, geometry.size.height * 0.02)
                        
                        // Delete Button
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text("Delete Expense")
                                .font(.system(size: dynamicFontSize(geometry, base: 18), weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: dynamicButtonHeight(geometry))
                                .background(Color.negativeRed)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.top, geometry.size.height * 0.01)
                    }
                    .padding(.bottom, geometry.size.height * 0.05)
                }
                .background(Color.backgroundSoft)
                .navigationTitle("Edit Expense")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.textPrimary)
                    }
                }
                .alert(isPresented: $showValidationAlert) {
                    Alert(
                        title: Text("Validation Error"),
                        message: Text(validationAlertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .alert("Delete Expense", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deleteExpense()
                    }
                } message: {
                    Text("Are you sure you want to delete this expense? This action cannot be undone.")
                }
            }
        }
        .onAppear {
            // Classify on appear
            if !description.isEmpty {
                classifyDescription()
            }
        }
    }
    
    // MARK: - Validation Helpers
    private func validateDescription() {
        let trimmed = description.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            descriptionError = nil
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
            amountError = nil
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
            await expenseController.updateExpense(
                expenseId: expense.id,
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
    
    private func deleteExpense() {
        Task {
            await expenseController.deleteExpense(expenseId: expense.id, token: token)
            
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

