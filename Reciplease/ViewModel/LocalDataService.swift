//
//  MockLocalDataService.swift
//  Reciplease
//
//  Created by Bilal Dallali on 05/03/2025.
//
//
//import Foundation
//
//protocol LocalDataServiceProtocol {
//    func fetchLocalData<T: Decodable>(fileName: String, completion: @escaping (Result<T, Error>) -> Void)
//}
//
//class LocalDataService: LocalDataServiceProtocol {
//    func fetchLocalData<T: Decodable>(fileName: String, completion: @escaping (Result<T, Error>) -> Void) {
//        guard let url = Bundle.main.url(forResource: "mockDataService", withExtension: "json") else {
//            completion(.failure(NSError(domain: "File Not Found", code: -1, userInfo: nil)))
//            return
//        }
//
//        do {
//            let data = try Data(contentsOf: url)
//            let decodedData = try JSONDecoder().decode(T.self, from: data)
//            completion(.success(decodedData))
//        } catch {
//            completion(.failure(error))
//        }
//    }
//}
