//
//  Wrapping.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 05.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

enum WrappingError: Error {
    case extractFailed(description: String?)
}

public class Wrapping {
    public var context: Dictionary<String, AnyObject>
    
    public init(_ context: Dictionary<String, AnyObject>) {
        self.context = context
    }
    
    public func get<T: Mapable>(_ key: String) throws -> T {
        guard let object = context[key] as? T else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return object
    }
    
    public func get<T: Mapable>(_ key: String) throws -> T? {
        return context[key] as? T
    }
    
    public func get<T: Mapable>(_ key: String) throws -> [T] {
        guard let objects = context[key] as? [T] else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return objects
    }
    
    public func get<T: Mapable>(_ key: String) throws -> [T]? {
        return context[key] as? [T]
    }
    
    public func get<T: Mapable>(_ key: String) throws -> [String: T] {
        guard let dictionary = context[key] as? [String: T] else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return dictionary
    }
    
    public func get<T: Mapable>(_ key: String) throws -> [String: T]? {
        return context[key] as? [String: T]
    }
    
    
    public func get<T: AtomaryMapable>(_ key: String) throws -> T {
        guard let value = context[key] as? T else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return value
    }
    
    public func get<T: AtomaryMapable>(_ key: String) throws -> T? {
        return context[key] as? T
    }
    
    public func get<T: AtomaryMapable>(_ key: String) throws -> [T] {
        guard let values = context[key] as? [T] else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return values
    }
    
    public func get<T: AtomaryMapable>(_ key: String) throws -> [T]? {
        return context[key] as? [T]
    }
    
    public func get<T: AtomaryMapable>(_ key: String) throws -> [String: T] {
        guard let values = context[key] as? [String: T] else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return values
    }
    
    public func get<T: AtomaryMapable>(_ key: String) throws -> [String: T]? {
        return context[key] as? [String: T]
    }
    
    public func get<T: AtomaryMapable, U>(_ key: String, _ formatting: (_ rawValue: T) throws -> U) throws -> [U] {
        guard let rawValues = context[key] as? [T] else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return try rawValues.map { try formatting($0) }
    }
    
    public func get<T: AtomaryMapable, U>(_ key: String, _ formatting: (_ rawValue: T) throws -> U) throws -> U {
        guard let rawValue = context[key] as? T else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return try formatting(rawValue)
    }
    
    public func get<T: AtomaryMapable, U>(_ key: String, _ formatting: (_ rawValue: T) throws -> U?) throws -> U? {
        guard let rawValue = context[key] as? T else {
            throw WrappingError.extractFailed(description: "cannot extract value of type: \(T.self) for key \(key)")
        }
        
        return try formatting(rawValue)
    }
}
