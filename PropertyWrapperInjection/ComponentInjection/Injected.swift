//
//  Injected.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import Foundation

@propertyWrapper struct Injected<Component> {
    let label: String?

    init(label: String? = nil) {
        self.label = label
    }

    var wrappedValue: Component {
        get {
            try! ComponentContainer.default.resolve(type: Component.self, label: label)
        }
    }
}
