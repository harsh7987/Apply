//
//  NetworkHelper.swift
//  ApiCalling
//
//  Created by Pranjal Verma on 04/01/26.
//

import Foundation

import Foundation

// MARK: - Enums
enum RestApiAction: String {
    case post = "POST"
}

// MARK: - Protocol
protocol NetworkRequest {
    var baseURL: String { get }
    var endPoint: String { get }
    var header: [String : String]? { get }
    var action: RestApiAction { get }
    var body: [String : Any]? { get }
    func getRequest() -> URLRequest?
}

// MARK: - The Manager
class NetworkManager {
    static let shared = NetworkManager() // Singleton
    
    private init() {}
    
    func callAPI<T: Codable>(request: NetworkRequest, responseType: T.Type) async throws -> T {
        guard let urlRequest = request.getRequest() else {
            throw URLError(.badURL)
        }
        
        // print("🚚 Request: \(urlRequest.url?.absoluteString ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("❌ Server Error: \(String(data: data, encoding: .utf8) ?? "Unknown")")
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("❌ Decoding Error: \(error)")
            throw error
        }
    }
}
