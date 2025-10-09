//
//  NetworkClass.swift
//  RecipeApp
//
//  Created by SaiPrakash Cheera on 09/10/25.
//

import Foundation
import Network
import Combine

protocol NetworkServiceProtocol {
    func getServerRequest<T: Decodable>(
        urlPath: String,
        responseModel: T.Type
    ) async -> (Bool, T?, Error?)
}

final class NetworkClass: NetworkServiceProtocol {
    
    //URLS
    static let recipeUrl = "https://dummyjson.com/recipes"
    
    private let monitor = NetworkMonitor.shared
    
    final func getServerRequest<T: Decodable>(
        urlPath: String,
        responseModel: T.Type
    ) async -> (Bool, T?, Error?) {
        
        guard monitor.isConnected else {
            print("No Internet Connection")
            return (false, nil, URLError(.notConnectedToInternet))
        }
        
        guard let url = URL(string: urlPath) else {
            print("Invalid URL")
            return (false, nil, URLError(.badURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return (false, nil, URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server returned status: \(httpResponse.statusCode)")
                return (false, nil, URLError(.badServerResponse))
            }
            
            let decoded = try JSONDecoder().decode(responseModel, from: data)
            return (true, decoded, nil)
            
        } catch {
            print("Network or Decoding Error: \(error.localizedDescription)")
            return (false, nil, error)
        }
    }
}


final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    @Published private(set) var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}

