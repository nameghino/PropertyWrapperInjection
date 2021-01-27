//
//  ComponentContainer.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import Foundation

public class ComponentContainer {

    private static var stack: [ComponentContainer] = []
    public static var current: ComponentContainer {
        guard let last = self.stack.last else {
            fatalError("no containers are configured")
        }

        return last
    }

    public static func set(root: ComponentContainer, forceDelete: Bool = false) {
        precondition(root.parent == nil)

        guard self.stack.isEmpty || forceDelete == true else {
            fatalError("cannot set root, child components are configured. set forceDelete if you really need this")
        }

        self.stack = [root]
    }

    public static func push(container: ComponentContainer) {
        precondition(!stack.isEmpty)

        let parent = ComponentContainer.current
        container.parent = parent

        stack.append(container)
    }

    @discardableResult
    public static func pop() -> ComponentContainer {
        guard
            self.stack.count > 1,
            let popped = stack.popLast()

        else {
            fatalError("cannot pop root container")
        }

        return popped
    }

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

    private weak var parent: ComponentContainer?
    private var container: [Key: ComponentEntry] = [:]
    private var applicationScope: [Key: Any] = [:]

    // maybe implement stacking? - see experimental/stacking

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


        if
            !self.container.keys.contains(key),
            let parent = self.parent {
            return try parent.resolve(type: type, label: label)
        }

        guard
            let entry = self.container[key]
        else {
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
