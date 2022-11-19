//
//  NetworkImageFatch.swift
//  Marvelgram
//
//  Created by Elisey on 11.11.2022.
//

import Foundation

class NetworkImageFatch {
    
    static let shared = NetworkImageFatch()
    private init() {}
    
    func requestImage(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {return}
            }
        }
        .resume()
    }
}
