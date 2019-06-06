//
//  MapperProtocols.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 03.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

import Foundation

public protocol AtomaryMapable {
    static func specific(from value: AnyObject) throws -> Self
}

public extension AtomaryMapable {
    static func specific(from value: AnyObject) throws -> Self {
        guard let specific = value as? Self else {
            throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(Self.self)")
        }
        return specific
    }
}

extension String: AtomaryMapable {
    public static func specific(from value: AnyObject) throws -> String {
        if let stringValue = value as? String {
            return stringValue
        }
        
        if let intValue = value as? Int {
            return "\(intValue)"
        }
        
        if let doubleValue = value.doubleValue {
            return "\(doubleValue)"
        }
        
        if let floatValue = value.floatValue  {
            return "\(floatValue)"
        }
        
        guard let specific = value as? String else {
            throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(String.self)")
        }
        return specific
    }
}
extension Int: AtomaryMapable {}
extension Double: AtomaryMapable {
    public static func specific(from value: AnyObject) throws -> Double {
        if let specific = value as? Double {
            return specific
        }
        
        if let specific = value.doubleValue {
            return specific
        }
        
        if let stringValue = try? String.specific(from: value), let specific = Double(stringValue) {
            return specific
        }
        
        throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(Double.self)")
    }
}

extension Bool: AtomaryMapable {
    public static func specific(from value: AnyObject) throws -> Bool {
        if let specific = value as? Bool {
            return specific
        }
        
        if let specific = value.boolValue {
            return specific
        }
        
        if let stringValue = try? String.specific(from: value), let specific = Bool(stringValue) {
            return specific
        }
        
        throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(Bool.self)")
    }
}

extension Float: AtomaryMapable {
    public static func specific(from value: AnyObject) throws -> Float {
        if let specific = value as? Float {
            return specific
        }
        
        if let specific = value.floatValue {
            return specific
        }
        
        if let stringValue = try? String.specific(from: value), let specific = Float(stringValue) {
            return specific
        }
        
        throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(Float.self)")
    }
}


public protocol Mapable {
    init(_ wrapping: Wrapping) throws
    static var properties: [MapableProperty] { get }
    static var mappingPath: [TargetNode] { get }
}

public extension Mapable {
    static var mappingPath: [TargetNode] { return [] }
}

public enum MapableProperty {
    
    case value(type: AtomaryMapable.Type, key: String, optional: Bool)
    case array(type: AtomaryMapable.Type, key: String, optional: Bool)
    case dictionary(type: AtomaryMapable.Type, key: String, optional: Bool)
    case object(type: Mapable.Type, key: String, optional: Bool)
    case objectsArray(type: Mapable.Type, key: String, optional: Bool)
    case objectsDictionary(type: Mapable.Type, key: String, optional: Bool)
    
    var keyValue: String {
        switch self {
        case let .value(_, key, _): return key
        case let .array(_, key, _): return key
        case let .dictionary(_, key, _): return key
        case let .object(_, key, _): return key
        case let .objectsArray(_, key, _): return key
        case let .objectsDictionary(_, key, _): return key
        }
    }
}

public struct TargetNode {
    var key: String?
    var index: Int?
    var isDestination: Bool
    
    private init(_ key: String?, _ index: Int?, isDestination: Bool = false) {
        self.key = key
        self.index = index
        self.isDestination = isDestination
    }
    
    public static func dictionaryNode(key: String, isDestination: Bool = false) -> TargetNode {
        return TargetNode(key, nil, isDestination: isDestination)
    }
    
    public static func arrayNode(index: Int, isDestination: Bool = false) -> TargetNode {
        return TargetNode(nil, index, isDestination: isDestination)
    }
}


