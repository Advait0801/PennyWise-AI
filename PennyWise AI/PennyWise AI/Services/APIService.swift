//
//  APIService.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import Foundation

// MARK: - API Service
class APIService {
    static let shared = APIService()
    
    // Update this URL based on your setup
    // For Simulator: http://localhost:8000 or http://127.0.0.1:8000
    // For Physical Device: http://YOUR_MAC_IP:8000 (e.g., http://192.168.1.100:8000)
    private let baseURL = "http://localhost:8000"
    
    private init() {}
    
    // MARK: - Generic Request Method
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        token: String? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorData.detail)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    // MARK: - Health Check
    func checkHealth() async throws -> HealthResponse {
        return try await request<HealthResponse>(endpoint: "/health")
    }
    
    // MARK: - Authentication
    func register(_ userCreate: UserCreate) async throws -> User {
        return try await request<User>(endpoint: "/auth/register", method: "POST", body: userCreate)
    }
    
    func login(_ userLogin: UserLogin) async throws -> TokenResponse {
        return try await request<TokenResponse>(endpoint: "/auth/login", method: "POST", body: userLogin)
    }
    
    // MARK: - Classification
    func classify(_ classifyRequest: ClassifyRequest) async throws -> ClassifyResponse {
        return try await request<ClassifyResponse>(endpoint: "/classify", method: "POST", body: classifyRequest)
    }
    
    // MARK: - Expenses
    func createExpense(_ expense: ExpenseCreate, token: String) async throws -> Expense {
        return try await request<Expense>(endpoint: "/expenses", method: "POST", body: expense, token: token)
    }
    
    func getExpenses(token: String) async throws -> ExpensesResponse {
        return try await request<ExpensesResponse>(endpoint: "/expenses", method: "GET", token: token)
    }
    
    // MARK: - Statistics
    func getCategoryStats(token: String) async throws -> CategoryStatsResponse {
        return try await request<CategoryStatsResponse>(endpoint: "/stats/category", method: "GET", token: token)
    }
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        case .networkError:
            return "Network connection failed"
        }
    }
}

// MARK: - Response Models
struct HealthResponse: Codable {
    let status: String
}

struct ErrorResponse: Codable {
    let detail: String
}
