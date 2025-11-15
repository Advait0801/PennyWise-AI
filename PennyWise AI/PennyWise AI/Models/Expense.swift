//
//  Expense.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import Foundation

// MARK: - Expense Model
struct Expense: Identifiable, Codable {
    let id: Int
    let description: String
    let amount: Double
    let date: String?
    let category: String
    let probability: Double
    
    var formattedAmount: String {
        String(format: "%.2f", amount)
    }
    
    var formattedDate: String {
        guard let date = date else { return "Today" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dateObj = formatter.date(from: date) {
            formatter.dateStyle = .medium
            return formatter.string(from: dateObj)
        }
        return date
    }
    
    var confidencePercentage: String {
        String(format: "%.0f%%", probability * 100)
    }
}

// MARK: - Expense Create Request
struct ExpenseCreate: Codable {
    let description: String
    let amount: Double
    let date: String?
    
    init(description: String, amount: Double, date: String? = nil) {
        self.description = description
        self.amount = amount
        self.date = date
    }
}

// MARK: - Expenses Response
struct ExpensesResponse: Codable {
    let expenses: [Expense]
}
