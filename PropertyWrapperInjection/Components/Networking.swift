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
    private let data: Data?

    init(response: Data?) {
        self.data = response
    }

    func submit(request: URLRequest, callback: @escaping (Data?) -> Void) {
        callback(self.data)
    }
}
