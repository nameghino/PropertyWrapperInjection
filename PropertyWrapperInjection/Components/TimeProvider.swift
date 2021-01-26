//
//  TimeProvider.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import Foundation

protocol TimeProviderProtocol: AnyObject  {
    var now: Date { get }
}

class Realtime: TimeProviderProtocol {
    var now: Date { return Date() }
}

class MockTimeProvider: TimeProviderProtocol {
    private let date: Date
    var now: Date { return date }

    init(with date: Date) {
        self.date = date
    }
}
