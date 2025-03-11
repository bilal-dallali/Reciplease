//
//  NetworkService.swift
//  Reciplease
//
//  Created by Bilal Dallali on 03/03/2025.
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ url: String, completion: @escaping (Result<T, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    private let sessionManager: Session
    
    init(sessionManager: Session = .default) {
        self.sessionManager = sessionManager
    }
    
    func request<T: Decodable>(_ url: String, completion: @escaping (Result<T, Error>) -> Void) {
        sessionManager.request(url, headers: ["Edamam-Account-User": "Reciplease"])
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
