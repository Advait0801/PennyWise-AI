//
//  ViewExtensions.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI

// MARK: - Dynamic Sizing Utilities
extension View {
    // Responsive padding based on screen size
    func responsivePadding(_ edges: Edge.Set = .all) -> some View {
        GeometryReader { geometry in
            self.padding(edges, geometry.size.width * 0.04)
        }
    }
    
    // Responsive font scaling
    func responsiveFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        GeometryReader { geometry in
            self.font(.system(size: min(size, geometry.size.width * 0.05), weight: weight))
        }
    }
    
    // Get screen width percentage
    func screenWidth(_ percentage: CGFloat) -> CGFloat {
        UIScreen.main.bounds.width * percentage
    }
    
    // Get screen height percentage
    func screenHeight(_ percentage: CGFloat) -> CGFloat {
        UIScreen.main.bounds.height * percentage
    }
}

// MARK: - Size Class Helper
struct SizeClassHelper {
    static func isCompact(horizontal: UserInterfaceSizeClass?) -> Bool {
        horizontal == .compact
    }
    
    static func isRegular(horizontal: UserInterfaceSizeClass?) -> Bool {
        horizontal == .regular
    }
}
