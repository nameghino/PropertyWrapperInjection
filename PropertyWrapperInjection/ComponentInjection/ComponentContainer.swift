//
//  ComponentContainer.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import Foundation

public class ComponentContainer {

    public static let `default` = ComponentContainer()

    public enum Error: Swift.Error {
        case unknownComponent(ComponentContainer.Key)
        case typeError(key: ComponentContainer.Key, resolved: Any)
    }

    public struct Key: Hashable {
        let type: Any.Type
        let label: String?

        public static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.type == rhs.type
                && lhs.label == rhs.label
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine("\(type)")
            hasher.combine(label)
        }
    }

    typealias ComponentEntry = (block: (ComponentContainer) throws -> Any, scope: Scope)

    private var container: [Key: ComponentEntry] = [:]
    private var applicationScope: [Key: Any] = [:]

    // maybe implement stacking?

    public enum Scope {
        case transient, application
    }

    public func register<T>(type: T.Type, label: String? = nil, scope: Scope = .application, factory: @escaping (ComponentContainer) -> T) {
        let entry: ComponentEntry = (block: factory, scope: scope)
        let key = Key(type: type, label: label)
        container[key] = entry
    }

    public func resolve<T>(type: T.Type, label: String? = nil) throws -> T {
        let key = Key(type: type, label: label)
        guard let entry = self.container[key] else {
            throw Error.unknownComponent(key)
        }

        let component: Any = try {
            if entry.scope == .application, let existing = applicationScope[key] {
                return existing
            }

            let c: Any = try entry.block(self)

            if entry.scope == .application {
                self.applicationScope[key] = c
            }
            return c
        }()

        guard let typedComponent = component as? T else {
            throw Error.typeError(key: key, resolved: component)
        }
        return typedComponent
    }
}
