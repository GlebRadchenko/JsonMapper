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
                case let .dictionary(key, valuesType, optional):
                    print(4)
                    guard var jsonDictionary = json as? [String: AnyObject] else {
                        throw MapperError.wrongFormat
                    }
                    try self.process(object: object, with: jsonDictionary[key])
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
        
        object.relations.forEach() { (propertyName, mappingProperty) in
            switch mappingProperty {
            case let .property(type, key, optional):
                if let property = jsonDictionary[key] {
                    propertyDictionary[propertyName] = property
                }
                
                break
            case let .mappingObject(key, childType, optional):
                let mirror = Mirror(reflecting: object)
                let child = mirror.children.filter() {$0.label == propertyName}.first
                
                if let aValue = child?.value {
                    var aChild = aValue
                    do {
                        aChild = try self.map(jsonDictionary[key],
                                              type: childType as! Mapable.Type)
                        propertyDictionary[propertyName] = aChild as AnyObject?
                    } catch {
                        print(error)
                    }
                } else {
                    
                }
                break
            default:
                break
            }
        }
        object.map(with: propertyDictionary)
    }
}
