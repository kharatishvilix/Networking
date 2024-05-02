//
//  NetworkService.swift
//  CarFacts
//
//  Created by Luka  Kharatishvili on 01.05.24.
//

import Foundation

public enum NetworkError: Error {
    case decodeError
    case wrongResponse
    case wrongStatusCode(code: Int)
}

public class NetworkService {
    public init() { }

    public func getData<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        let url = URL(string: urlString)!

        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in

            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "NetworkService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "NetworkService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP status code \(httpResponse.statusCode)"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "NetworkService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }

            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(T.self, from: data)

                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
