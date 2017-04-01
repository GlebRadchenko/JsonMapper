//
//  Wrapping.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 05.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

public class Wrapping {
    var content: [String: AnyObject]
    
    init(_ content: [String: AnyObject]) {
        self.content = content
    }
    
    public func get<T: Mapable>(_ propertyName: String) throws -> [T] {
        guard let value = content[propertyName] as? [T] else {
            throw WrappingError.wrongProperty(name: propertyName)
        }
        return value
    }
    
    public func get<T: Mapable>(_ propertyName: String) throws -> T {
        guard let value = content[propertyName] as? T else {
            throw WrappingError.wrongProperty(name: propertyName)
        }
        return value
    }
    
    public func get<T: AtomaryMapable>(_ propertyName: String) throws -> T {
        guard let value = content[propertyName] else {
            throw WrappingError.wrongProperty(name: propertyName)
        }
        return try convert(value)
    }
    
    public func get<T: AtomaryMapable>(_ propertyName: String) throws -> [T] {
        guard let value = content[propertyName] else {
            throw WrappingError.wrongProperty(name: propertyName)
        }
        
        guard let arrayOfValues = value as? [AnyObject] else {
            throw WrappingError.wrongProperty(name: propertyName)
        }
        
        return try arrayOfValues.map { try convert($0) }
    }
    
    private func convert<T: AtomaryMapable>(_ value: AnyObject) throws -> T {
        #if swift(>=3.1)
            return try T.concrete(from: value)
        #else
            return try T.concrete(from: value) as! T
        #endif
    }
}

public enum WrappingError: Error, CustomStringConvertible {
    case wrongProperty(name: String)
    public var description: String {
        switch self {
        case let .wrongProperty(name):
            return "Wrong property: " + name
        }
    }
}
