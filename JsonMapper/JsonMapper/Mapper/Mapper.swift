//
//  Mapper.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 03.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

public class Mapper {
    private class func map(_ json: AnyObject?, type: Mapable.Type) throws -> Mapable {
        var object = type.init()
        if object.helpingPath.isEmpty {
            throw MapperError.wrongSetting
        }
        for path in object.helpingPath {
            switch path {
            case let .target(property):
                //handle property
                break
            case let .destination(property):
                switch property {
                case let .dictionary(key, _, optional):
                    if let jsonDictionary = json as? [String: AnyObject] {
                        try self.process(object: object, with: jsonDictionary[key])
                    } else {
                        try handleForNilValue(isOptional: optional)
                    }
                    break
                default:
                    break
                }
                break
            case .none:
                try self.process(object: object, with: json)
                break
            }
        }
        return object
    }
    /*TODO:
     - implement processing of all mapping properties
     - add recursively searching
     - implement all types of helping path
     - implement correct error throwing
     - refactoring and extending functionality
    */
    public class func map<T: Mapable>(_ json: AnyObject) throws -> T {
        if let object = try self.map(json, type: T.self) as? T {
            return object
        }
        throw MapperError.wrongFormat
    }
    private static func process(object: Mapable, with json: AnyObject?) throws {
        guard let jsonDictionary = json as? [String: AnyObject] else {
            throw MapperError.wrongFormat
        }
        var propertyDictionary = [String: AnyObject]()
        
        try object.relations.forEach() { (propertyName, mappingProperty) in
            switch mappingProperty {
            case let .property(type, key, optional):
                if let property = jsonDictionary[key] {
                    try check(property: property, for: type, optional: optional)
                    propertyDictionary[propertyName] = property
                } else {
                    try handleForNilValue(isOptional: optional)
                }
                break
            case let .mappingObject(key, childType, optional):
                let mirror = Mirror(reflecting: object)
                let child = mirror.children.filter() {$0.label == propertyName}.first
                
                if let aValue = child?.value {
                    var aChild = aValue
                    aChild = try map(jsonDictionary[key],
                                          type: childType)
                    propertyDictionary[propertyName] = aChild as AnyObject?
                } else {
                    try handleForNilValue(isOptional: optional)
                }
                break
            default:
                break
            }
        }
        object.map(with: propertyDictionary)
    }
    private static func check(property: AnyObject, for type: MappingType, optional: Bool) throws {
        let mirror = Mirror(reflecting: property)
        if !type.validTypes.contains() {$0 == mirror.subjectType} {
            throw MapperError.wrongFormat
        }
    }
    private static func handleForNilValue(isOptional: Bool) throws {
        if !isOptional {
            throw MapperError.wrongFormat
        }
    }
}
