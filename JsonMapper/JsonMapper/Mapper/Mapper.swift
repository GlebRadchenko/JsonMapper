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
        guard var json = json else {
            throw MapperError.wrongFormat
        }
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
//    public class func map<T: Mapable>(_ json: AnyObject) throws -> [T] {
//    }
    private static func process(object: Mapable, with json: AnyObject?) throws {
        guard let jsonDictionary = json as? [String: AnyObject] else {
            throw MapperError.wrongFormat
        }
        var propertyDictionary = [String: AnyObject]()
        
        try object.relations.forEach() { (propertyName, mappingProperty) in
            switch mappingProperty {
            case let .property(type, key, optional):
                if let property = jsonDictionary[key] {
                    if isValid(property: property, for: type, optional: optional) {
                        propertyDictionary[propertyName] = property
                    } else {
                        try handleForNilValue(isOptional: optional)
                        propertyDictionary[propertyName] = nil
                    }
                } else {
                    try handleForNilValue(isOptional: optional)
                    propertyDictionary[propertyName] = nil
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
                    propertyDictionary[propertyName] = nil
                }
                break
            default:
                break
            }
        }
        object.map(with: propertyDictionary)
    }
    
    private static func mapRecursively(initialObject: Mapable, json: AnyObject, optional: Bool) throws {
        var propertyDictionary = [String: AnyObject?]()
        try initialObject.relations.forEach { (nameOfProperty, mappingProperty) in
            if let aProperty = try findRecursively(mappingProperty, optional: optional, json: json) {
                propertyDictionary[nameOfProperty] = aProperty
            } else {
                try handleForNilValue(isOptional: optional)
                propertyDictionary[nameOfProperty] = nil
            }
        }
        initialObject.map(with: propertyDictionary)
    }
    
    private static func findRecursively(_ mappingProperty: MappingProperty, optional: Bool, json: AnyObject) throws -> AnyObject? {
        switch mappingProperty {
        case let .property(type, key, optional):
            return findRecursively(key, mappingType: type, optional: optional, json: json)
        case let .array(key, valuesType, optional):
            break
        case let .dictionary(key, valuesType, optional):
            break
        case let .mappingObject(key, type, optional):
            break
        }
        throw MapperError.notFound
    }
    
    //Search for a single property
    private static func findRecursively(_ propertyKey: String, mappingType: MappingType, optional: Bool, json: AnyObject) -> AnyObject? {
        //Base of recursion
        if isContainsOnlyAtomaryValues(json) {
            //At this point we are reached last level of JSON tree
            if let jsonDictionary = json as? [String: AnyObject] {
                for (key, value) in jsonDictionary {
                    if key == propertyKey {
                        if isValid(property: value, for: mappingType, optional: optional) {
                            return value
                        }
                    }
                }
            }
            return nil
        } else {
            //Our JSON object contains values in wich we can fallthhrought
            
            //if JSON object is Dictionary - check it
            if let jsonDictionary = json as? [String: AnyObject] {
                for (key, value) in jsonDictionary {
                    if key == propertyKey {
                        if isValid(property: value, for: mappingType, optional: optional) {
                            return value
                        }
                    } else {
                        if let findedValue = findRecursively(propertyKey, mappingType: mappingType, optional: optional, json: value) {
                            return findedValue
                        }
                    }
                }
            }
            //if JSON object is Array - check it
            if let jsonArray = json as? [AnyObject] {
                for value in jsonArray {
                    if let findedValue = findRecursively(propertyKey, mappingType: mappingType, optional: optional, json: value) {
                        return findedValue
                    }
                }
            }
            
            return nil
        }
    }
    private static func isContainsOnlyAtomaryValues(_ json: AnyObject) -> Bool {
        if let jsonDictionary = json as? [String: AnyObject] {
            for (_, value) in jsonDictionary {
                if value is Dictionary<String, Any> {
                    return false
                }
                if value is Array<Any> {
                    return false
                }
            }
        }
        if let jsonArray = json as? [AnyObject] {
            for value in jsonArray {
                if value is Dictionary<String, Any> {
                    return false
                }
                if value is Array<Any> {
                    return false
                }
            }
        }
        return true
    }
    
    
    private static func isValid(property: AnyObject, for type: MappingType, optional: Bool) -> Bool {
        let mirror = Mirror(reflecting: property)
        if !type.validTypes.contains() {$0 == mirror.subjectType} {
            return false
        }
        return true
    }
    private static func handleForNilValue(isOptional: Bool) throws {
        if !isOptional {
            throw MapperError.notFound
        }
    }
}
