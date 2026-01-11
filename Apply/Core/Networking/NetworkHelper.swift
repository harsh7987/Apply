//
//  NetworkHelper.swift
//  ApiCalling
//
//  Created by Pranjal Verma on 04/01/26.
//

import Foundation

class NetworkHelper {
    
    func callAPI<T: Codable>(request: RestApi, responseType: T.Type) async throws -> T {
         
        guard let urlRequest = request.getRequest() else {
            throw URLError(.badURL)
        }
        
        print("🚚 Sending Request to: \(urlRequest.url?.absoluteString ?? "Unknown")")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("Decoding error \(error)")
            throw error
        }
    }
}
