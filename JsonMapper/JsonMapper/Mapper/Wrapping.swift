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
    
    func get<T>(_ propertyName: String) throws -> T? {
        if content.keys.contains(propertyName) {
            if let aValue = content[propertyName] as? T {
                return aValue
            }
            guard let value = content[propertyName] else {
                return nil
            }
            do {
                return try convert(value)
            } catch { debugPrint(error) }
        }
        return nil
    }
    
    private func convert<T>(_ value: AnyObject) throws -> T? {
        if MappingType.number.validTypes.contains(where: {$0 == T.self}) {
            if T.self == Double.self {
                return value.doubleValue as? T
            }
            if T.self == Float.self {
                return value.floatValue as? T
            }
            if T.self == Int.self {
                return Int(value.int64Value) as? T
            }
        }
        if MappingType.string.validTypes.contains(where: {$0 == T.self}) {
            if T.self == String.self {
                return value.stringValue as? T
            }
        }
        if MappingType.bool.validTypes.contains(where: {$0 == T.self}) {
            if T.self == Bool.self {
                return value.boolValue as? T
            }
        }
        throw WrappingError.wrongProperty(name: "\(value)")
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
