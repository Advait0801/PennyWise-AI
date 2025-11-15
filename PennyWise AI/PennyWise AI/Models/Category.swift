//
//  Category.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI

// MARK: - Category Model
struct Category: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    
    static let allCategories: [Category] = [
        Category(name: "Food", color: .categoryColor(for: "Food")),
        Category(name: "Travel", color: .categoryColor(for: "Travel")),
        Category(name: "Shopping", color: .categoryColor(for: "Shopping")),
        Category(name: "Rent", color: .categoryColor(for: "Rent")),
        Category(name: "Utilities", color: .categoryColor(for: "Utilities")),
        Category(name: "Entertainment", color: .categoryColor(for: "Entertainment")),
        Category(name: "Healthcare", color: .categoryColor(for: "Healthcare")),
        Category(name: "Transportation", color: .categoryColor(for: "Transportation")),
        Category(name: "Other", color: .categoryColor(for: "Other"))
    ]
    
    static func color(for categoryName: String) -> Color {
        Color.categoryColor(for: categoryName)
    }
}

// MARK: - Category Stat
struct CategoryStat: Identifiable, Codable {
    let id = UUID()
    let category: String
    let totalAmount: Double
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case category
        case totalAmount = "total_amount"
        case count
    }
    
    var formattedAmount: String {
        String(format: "%.2f", totalAmount)
    }
}

// MARK: - Category Stats Response
struct CategoryStatsResponse: Codable {
    let stats: [CategoryStat]
}
