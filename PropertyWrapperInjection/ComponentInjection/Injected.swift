//
//  Injected.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import Foundation

@propertyWrapper struct Injected<Component> {
    let label: String?
    let container: ComponentContainer

    init(label: String? = nil, container: ComponentContainer = .default) {
        self.label = label
        self.container = container
    }

    var wrappedValue: Component {
        get {
            try! self.container.resolve(type: Component.self, label: label)
        }
    }
}
