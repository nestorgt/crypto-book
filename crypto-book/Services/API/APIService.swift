//
//  APIService.swift
//  crypto-book
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import Foundation
import UIKit

/// Service used to make any http request
protocol APIServiceProtocol {
    
    /// Generic method to make any http request and returning a result.
    /// - Note: A succesfull result is returned in form of Data. The responsability of decoding that properly belongs to each Repository.
    /// - Parameters:
    ///   - urlRequest: URLRequest to be performed.
    ///   - completion: async completion with the result in form of Data (on success) or APIError (on failure).
    func perform(urlRequest: URLRequest, completion: @escaping (Result<Data, APIError>) -> Void)
}

final class APIService: APIServiceProtocol {
    
    private let urlSession: URLSession
    
    // MARK: Lifecycle
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    // MARK: Requests
    
    func perform(urlRequest: URLRequest, completion: @escaping (Result<Data, APIError>) -> Void) {
        urlSession.dataTask(with: urlRequest) { (data, response, error) in
            Log.message(urlRequest.url?.absoluteString, level: .info, type: .api)
            if let error = error {
                Log.message("Request error: \(error.localizedDescription)", level: .error, type: .api)
                completion(.failure(.generic(message: error.localizedDescription)))
            } else if let response = response as? HTTPURLResponse, let data = data {
                if let apiError = APIError.error(from: response.statusCode) {
                    Log.message("Request response code: \(response.statusCode)", level: .error, type: .api)
                    completion(.failure(apiError))
                } else {
                    Log.message("Request OK: \(response.statusCode)", level: .info, type: .api)
                    completion(.success(data))
                }
            } else {
                Log.message("Request Error: no response/data", level: .error, type: .api)
                completion(.failure(.generic(message: "no response/data")))
            }
        }.resume()
    }
}
