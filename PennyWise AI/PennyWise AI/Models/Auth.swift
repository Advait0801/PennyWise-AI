//
//  Auth.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import Foundation

// MARK: - User Model
struct User: Codable {
    let id: Int
    let username: String
    let email: String
}

// MARK: - User Create Request
struct UserCreate: Codable {
    let username: String
    let email: String
    let password: String
}

// MARK: - User Login Request
struct UserLogin: Codable {
    let username: String
    let password: String
}

// MARK: - Token Response
struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

// MARK: - Classify Request
struct ClassifyRequest: Codable {
    let description: String
}

// MARK: - Classify Response
struct ClassifyResponse: Codable {
    let category: String
    let probability: Double
    let topClasses: [String]
    
    enum CodingKeys: String, CodingKey {
        case category
        case probability
        case topClasses = "top_classes"
    }
    
    var confidencePercentage: String {
        String(format: "%.0f%%", probability * 100)
    }
}
