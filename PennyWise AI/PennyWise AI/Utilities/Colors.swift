//
//  Colors.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        
        if hex.count == 6 {
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        } else {
            r = 0; g = 0; b = 0
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - App Color Palette (Mint Finance)
extension Color {
    // Primary Brand Colors
    static let primaryMint       = Color(hex: "#4ADE80")   // Vibrant mint green
    static let secondaryEmerald  = Color(hex: "#059669")   // Deep emerald
    static let accentLime        = Color(hex: "#A3E635")   // Soft lime-green accent
    
    // Backgrounds
    static let backgroundSoft    = Color(hex: "#F8FAFC")   // Off white
    static let backgroundCard    = Color(hex: "#FFFFFF")   // Pure white surfaces
    
    // Text
    static let textPrimary       = Color(hex: "#0F172A")   // Dark charcoal
    static let textSecondary     = Color(hex: "#475569")   // Cool gray
    
    // Semantic Colors
    static let positiveGreen     = Color(hex: "#10B981")   // Good trends
    static let negativeRed       = Color(hex: "#EF4444")   // Overspending
    static let warningAmber      = Color(hex: "#F59E0B")   // Caution
    
    // Chart Colors (for categories)
    static let chartMint         = Color(hex: "#86EFAC")
    static let chartYellow       = Color(hex: "#FDE047")
    static let chartBlue         = Color(hex: "#38BDF8")
    static let chartPurple       = Color(hex: "#A78BFA")
    static let chartPink         = Color(hex: "#F472B6")
    static let chartOrange       = Color(hex: "#FB923C")
    static let chartRed          = Color(hex: "#F87171")
    static let chartCyan         = Color(hex: "#22D3EE")
    static let chartEmerald      = Color(hex: "#34D399")
}

// MARK: - Category Color Mapping
extension Color {
    static func categoryColor(for categoryName: String) -> Color {
        switch categoryName {
        case "Food":
            return .chartOrange
        case "Travel":
            return .chartBlue
        case "Shopping":
            return .chartPink
        case "Rent":
            return .chartPurple
        case "Utilities":
            return .chartYellow
        case "Entertainment":
            return .chartRed
        case "Healthcare":
            return .positiveGreen
        case "Transportation":
            return .chartCyan
        case "Other":
            return .textSecondary
        default:
            return .textSecondary
        }
    }
}
