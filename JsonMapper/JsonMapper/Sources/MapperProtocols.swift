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
    static func concrete(from value: AnyObject) throws -> Self
}

public extension AtomaryMapable {
    public static func concrete(from value: AnyObject) throws -> Self {
        guard let concrete = value as? Self else {
            throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(Self.self)")
        }
        return concrete
    }
}

extension String: AtomaryMapable {
    public static func concrete(from value: AnyObject) throws -> String {
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
        
        guard let concrete = value as? String else {
            throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(String.self)")
        }
        return concrete
    }
}
extension Int: AtomaryMapable {}
extension Double: AtomaryMapable {
    public static func concrete(from value: AnyObject) throws -> Double {
        if let concrete = value as? Double {
            return concrete
        }
        
        if let concrete = value.doubleValue {
            return concrete
        }
        
        if let stringValue = try? String.concrete(from: value), let concrete = Double(stringValue) {
            return concrete
        }
        
        throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(Double.self)")
    }
}

extension Bool: AtomaryMapable {
    public static func concrete(from value: AnyObject) throws -> Bool {
        if let concrete = value as? Bool {
            return concrete
        }
        
        if let concrete = value.boolValue {
            return concrete
        }
        
        if let stringValue = try? String.concrete(from: value), let concrete = Bool(stringValue) {
            return concrete
        }
        
        throw MapperError.wrongFormat(value: value, description: "Cannot bind value to \(Bool.self)")
    }
}

extension Float: AtomaryMapable {
    public static func concrete(from value: AnyObject) throws -> Float {
        if let concrete = value as? Float {
            return concrete
        }
        
        if let concrete = value.floatValue {
            return concrete
        }
        
        if let stringValue = try? String.concrete(from: value), let concrete = Float(stringValue) {
            return concrete
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
    public static var mappingPath: [TargetNode] { return [] }
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


