//
//  Authentication.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 27/01/2021.
//

import Foundation

protocol UserCredentialsProtocol: Encodable {}

struct UserCredentials: UserCredentialsProtocol {
    var username: String
    var password: String
}

struct UserSession: Codable {
    let username: String
    let validUntil: Date
}

protocol AuthenticatorProtocol {
    func authenticate<Credentials: UserCredentialsProtocol & Encodable>(with credentials: Credentials,
                                                                        callback: @escaping (UserSession?) -> Void)
}

class Authenticator: AuthenticatorProtocol {
    @Injected var networking: NetworkingProtocol

    func authenticate<Credentials: UserCredentialsProtocol & Encodable>(with credentials: Credentials,
                                                                        callback: @escaping (UserSession?) -> Void) {
        let url = URL(string: "http://example.com/v1/login")!
        var authenticationRequest = URLRequest(url: url)
        authenticationRequest.httpBody = try! JSONEncoder().encode(credentials)
        authenticationRequest.httpMethod = "POST"
        networking.submit(request: authenticationRequest) { data in
            guard let data = data else {
                callback(nil)
                return
            }

            let session = try! JSONDecoder().decode(UserSession.self, from: data)
            callback(session)
        }
    }
}
