//
//  Authentication.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import Foundation

struct UserSession {
    var username: String
    var validUntil: Date
}

protocol AuthenticationProtocol {
    func authenticate(username: String, password: String, callback: @escaping(UserSession?) -> Void)
}

class MockAuthenticator: AuthenticationProtocol {
    @Injected<NetworkingProtocol>
    var networking

    func authenticate(username: String, password: String, callback: @escaping (UserSession?) -> Void) {
        // do something with networking
        let session = UserSession(username: username, validUntil: Date().addingTimeInterval(86400))
        callback(session)
    }
}
