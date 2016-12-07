//
//  MapperProtocols.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 03.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

public protocol Mapable {
    static var helpingPath: [MapPathable] {get set}
    static var relations: [String: MappingProperty] {get}
    init?(_ wrapping: Wrapping)
}
public enum MapperError: Error, CustomStringConvertible {
    case notFound
    case wrongSetting
    case wrongFormat
    
    public var description: String {
        switch self {
        default:
            return "Mapper error"
        }
    }
}
public enum MappingType {
    case string
    case bool
    case number
    case anyObject
    
    var validTypes: [Any.Type] {
        switch self {
        case .string:
            return [String.self]
        case .number:
            return [Int.self, Double.self, Float.self, NSNumber.self]
        case .bool:
            return [Bool.self]
        case .anyObject:
            return [AnyObject.self]
        }
    }
}
// enum for make relations between properties and mapping
public enum MappingProperty {
    case property(type: MappingType, key: String, optional: Bool)
    
    case mappingObject(key: String, type: Mapable.Type, optional: Bool)
    case mappingObjectsArray(key: String?, types: Mapable.Type, optional: Bool)
    case array(key: String, valuesType: MappingType, optional: Bool)
    case dictionary(key: String, optional: Bool)
    
    var isOptional: Bool {
        switch self {
        case let .property(_, _, optional),
             let .array(_, _, optional),
             let .dictionary(_, optional),
             let .mappingObject(_, _, optional),
             let .mappingObjectsArray(_, _, optional):
            return optional
        }
    }
}

// enum for speeding object Mapping
public enum MapPathable {
    case none
    case target(nodeType: JsonNodeType)
    case destination(nodeType: JsonNodeType)
}
public enum JsonNodeType {
    case array(key: String?, index: Int?)
    case dictionary(key: String?, index: Int?)
}
enum MapperSearchType {
    case recursive
    case recursiveWithDestination
    case determined
}


