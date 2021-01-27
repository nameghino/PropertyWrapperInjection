//
//  Networking.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import Foundation

protocol NetworkingProtocol {
    func submit(request: URLRequest, callback: @escaping(Data?) -> Void)
}

extension URLSession: NetworkingProtocol {
    func submit(request: URLRequest, callback: @escaping (Data?) -> Void) {
        let task = self.dataTask(with: request) { (data, _, _) in
            callback(data)
        }
        task.resume()
    }
}

class MockNetworking: NetworkingProtocol {
    private var responseDictionary: [String: Data] = [:]

    func register(data: Data, for path: String) {
        self.responseDictionary[path] = data
    }

    func register<Response: Codable>(value: Response, for path: String) {
        let data = try! JSONEncoder().encode(value)
        self.register(data: data, for: path)
    }

    func submit(request: URLRequest, callback: @escaping (Data?) -> Void) {
        guard let path = request.url?.path else {
            callback(nil)
            return
        }

        callback(self.responseDictionary[path])
    }
}
