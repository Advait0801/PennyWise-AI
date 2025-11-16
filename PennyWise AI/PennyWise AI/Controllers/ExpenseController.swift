//
//  ExpenseController.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI
internal import Combine

// MARK: - Expense Controller
@MainActor
class ExpenseController: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var categoryStats: [CategoryStat] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAddingExpense = false
    
    private let apiService = APIService.shared
    
    // MARK: - Load Expenses
    func loadExpenses(token: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getExpenses(token: token)
            self.expenses = response.expenses.sorted {
                ($0.date ?? "1970-01-01") > ($1.date ?? "1970-01-01")
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Add Expense
    func addExpense(description: String, amount: Double, date: String?, token: String) async {
        isAddingExpense = true
        errorMessage = nil
        
        do {
            let expenseCreate = ExpenseCreate(description: description, amount: amount, date: date)
            let newExpense = try await apiService.createExpense(expenseCreate, token: token)
            
            // Optimistically add to list
            self.expenses.insert(newExpense, at: 0)
            isAddingExpense = false
            
            // Reload to ensure sync
            await loadExpenses(token: token)
            await loadCategoryStats(token: token)
        } catch {
            errorMessage = error.localizedDescription
            isAddingExpense = false
        }
    }
    
    // MARK: - Load Category Stats
    func loadCategoryStats(token: String) async {
        do {
            let response = try await apiService.getCategoryStats(token: token)
            self.categoryStats = response.stats
        } catch {
            // Silently fail for stats, not critical
            print("Failed to load stats: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Classify Description
    func classifyDescription(_ description: String) async -> ClassifyResponse? {
        do {
            let request = ClassifyRequest(description: description)
            return try await apiService.classify(request)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Total Expenses
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Expenses by Category
    func expenses(for category: String) -> [Expense] {
        expenses.filter { $0.category == category }
    }
}
