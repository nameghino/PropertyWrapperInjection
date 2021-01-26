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
    let path: [String]

    init(label: String? = nil, container: ComponentContainer = .default, path: String? = nil) {
        self.label = label
        self.container = container
        if let path = path {
            self.path = Array(path.components(separatedBy: "."))
        } else {
            self.path = []
        }
    }

    var wrappedValue: Component {
        get {
            var currentContainer = self.container
            if !path.isEmpty {
                for layer in self.path {
                    currentContainer = try! currentContainer.resolve(type: ComponentContainer.self, label: layer)
                }
            }
            return try! currentContainer.resolve(type: Component.self, label: label)
        }
    }
}
