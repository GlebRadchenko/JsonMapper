//
//  Mapper.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 03.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

public class Mapper {
    /*TODO:
     - implement processing of all mapping properties - done
     - add recursively searching - done
     - implement all types of helping path - done
     - implement correct error throwing
     - refactoring and extending functionality
     */
    public class func map<T: Mapable>(_ json: AnyObject) throws -> T {
        return try map(json, type: T.self) as! T
    }
//    public class func map<T>(_ json: AnyObject) throws -> [T] where T: Mapable {
//        if let objects: [T] = try map(json, type: T.self) {
//            return objects
//        }
//        throw MapperError.wrongFormat
//    }
    internal class func searchType(for path: [MapPathable]) throws -> MapperSearchType {
        if path.isEmpty {
            return .recursive
        }
        let isContainsTargetPaths = path.contains { (path) -> Bool in
            switch path {
            case .target:
                return true
            default:
                return false
            }
        }
        let isContainsDestination = path.contains { (path) -> Bool in
            switch path {
            case .destination:
                return true
            default:
                return false
            }
        }
        let isContainsNone  = path.contains { (path) -> Bool in
            switch path {
            case .none:
                return true
            default:
                return false
            }
        }
        if isContainsNone {
            if isContainsTargetPaths || isContainsDestination {
                throw MapperError.wrongFormat
            }
            return .recursive
        }
        if isContainsTargetPaths {
            if isContainsDestination {
                return .determined
            } else {
                throw MapperError.wrongFormat
            }
        }
        if isContainsDestination {
            if !isContainsTargetPaths {
                return .recursiveWithDestination
            }
        }
        return .determined
    }
//    internal class func map(_ json: AnyObject?, type: Mapable.Type) throws -> [Mapable] {
//        throw MapperError.wrongFormat
//    }
    internal class func map(_ json: AnyObject?, type: Mapable.Type) throws -> Mapable {
        guard let json = json else {
            throw MapperError.wrongFormat
        }
        var object = type.init()
        let searchingType = try searchType(for: object.helpingPath)
        switch searchingType {
        case .determined:
            try map(initialObject: object, json: json)
            break
        case .recursive:
            try mapRecursively(initialObject: object, json: json)
            break
        case .recursiveWithDestination:
            guard let destinationPath = object.helpingPath.first else {
                throw MapperError.wrongSetting
            }
            switch destinationPath {
            case let .destination(nodeType):
                switch nodeType {
                case let .dictionary(key, _):
                    guard let key = key else {
                        throw MapperError.wrongSetting
                    }
                    try mapRecursively(initialObject: object, destinationKey: key, json: json)
                default:
                    throw MapperError.wrongSetting
                }
            default:
                throw MapperError.wrongSetting
            }
            break
        }
        return object
    }
    internal class func mapRecursively(initialObject: Mapable, destinationKey: String, json: AnyObject) throws {
        if isContainsOnlyAtomaryValues(json) {
            throw MapperError.notFound
        }
        if let jsonDictionary = json as? [String: AnyObject] {
            do {
                try bind(dictionary: jsonDictionary, to: initialObject)
                return
            } catch { }
        }
        return try mapRecursively(object: initialObject, key: destinationKey, json: json)
    }
    internal class func mapRecursively(object: Mapable, key: String, json: AnyObject) throws {
        if isContainsOnlyAtomaryValues(json) {
            throw MapperError.notFound
        }
        if let jsonDictionary = json as? [String: AnyObject] {
            for (nodeKey, childNode) in jsonDictionary {
                if nodeKey == key {
                    if let dict = childNode as? [String: AnyObject] {
                        do {
                            try bind(dictionary: dict, to: object)
                            return
                        } catch {}
                    }
                }
                do {
                    try mapRecursively(object: object, key: key, json: childNode)
                    return
                } catch {}
            }
        }
        if let jsonArray = json as? [AnyObject] {
            for childNode in jsonArray {
                do {
                    try mapRecursively(object: object, key: key, json: childNode)
                    return
                } catch {}
            }
        }
        
        throw MapperError.notFound
    }
    internal class func map(initialObject: Mapable, json: AnyObject) throws {
        var paths = initialObject.helpingPath
        let initialPath = paths.removeFirst()
        switch initialPath {
        case let .target(nodeType):
            switch nodeType {
            case .array:
                if !(json is Array<AnyObject>) {
                    throw MapperError.wrongSetting
                }
                break
            case .dictionary:
                if !(json is [String: AnyObject]) {
                    throw MapperError.wrongSetting
                }
                break
            }
            break
        default:
            throw MapperError.wrongSetting
        }
        guard let jsonNode = json as? [String: AnyObject] else {
            throw MapperError.wrongFormat
        }
        //Try somehow to reduce this
        var processingJson: AnyObject = jsonNode as AnyObject
        for atomaryPath in initialObject.helpingPath {
            var isFallenThrought = false
            switch atomaryPath {
            case let .target(nodeType), let .destination(nodeType):
                switch nodeType {
                case let .array(key, index):
                    if let key = key {
                        if let dictionaryNode = processingJson as? [String: AnyObject], let arrayNode = dictionaryNode[key] as? [AnyObject] {
                            processingJson = arrayNode as AnyObject
                            isFallenThrought = true
                        } else {
                            throw MapperError.wrongSetting
                        }
                    }
                    if let index = index {
                        if let arrayNode = processingJson as? [AnyObject] {
                            if arrayNode.count > index {
                                if let desctinationNode = arrayNode[index] as? [AnyObject] {
                                    processingJson = desctinationNode as AnyObject
                                    isFallenThrought = true
                                } else {
                                    throw MapperError.wrongSetting
                                }
                            } else {
                                throw MapperError.wrongSetting
                            }
                        } else {
                            throw MapperError.wrongSetting
                        }
                    }
                    if index == nil, key == nil {
                        throw MapperError.wrongSetting
                    }
                    break
                case let .dictionary(key, index):
                    if let key = key {
                        if let dictionaryNode = processingJson as? [String: AnyObject], let dictNode = dictionaryNode[key] as? [String: AnyObject] {
                            processingJson = dictNode as AnyObject
                            isFallenThrought = true
                        } else {
                            throw MapperError.wrongSetting
                        }
                    }
                    if let index = index {
                        if let arrayNode = processingJson as? [AnyObject] {
                            if arrayNode.count > index {
                                if let desctinationNode = arrayNode[index] as? [String: AnyObject] {
                                    processingJson = desctinationNode as AnyObject
                                    isFallenThrought = true
                                } else {
                                    throw MapperError.wrongSetting
                                }
                            } else {
                                throw MapperError.wrongSetting
                            }
                        } else {
                            throw MapperError.wrongSetting
                        }
                    }
                    if index == nil, key == nil {
                        throw MapperError.wrongSetting
                    }
                    break
                }
                if !isFallenThrought {
                    throw MapperError.wrongSetting
                }
                break
            case .none:
                throw MapperError.wrongSetting
            }
        }
        //at this point we have final object wich we should bind to object
        if let objectDictionary = processingJson as? [String: AnyObject] {
            try bind(dictionary: objectDictionary, to: initialObject)
        } else {
            throw MapperError.wrongSetting
        }
    }
    internal class func mapRecursively(initialObject: Mapable, json: AnyObject) throws {
        var propertyDictionary = [String: AnyObject?]()
        try initialObject.relations.forEach { (nameOfProperty, mappingProperty) in
            if let aProperty = try findRecursively(mappingProperty, json: json) {
                propertyDictionary[nameOfProperty] = aProperty
            } else {
                try handleForNilValue(isOptional: mappingProperty.isOptional)
                propertyDictionary[nameOfProperty] = nil
            }
        }
        initialObject.map(with: Wrapping(propertyDictionary))
    }
    internal class func bind(dictionary: [String: AnyObject], to object: Mapable) throws {
        var propertyDictionary = [String: AnyObject]()
        for (propertyName, mappingProperty) in object.relations {
            switch mappingProperty {
            case let .property(type, key, optional):
                if let property = dictionary[key] {
                    if isValid(property: property, for: type) {
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
            case let .array(key, valuesType, optional):
                if let arrayProperty = dictionary[key] as? [AnyObject] {
                    if isValid(array: arrayProperty, for: valuesType) {
                        propertyDictionary[propertyName] = arrayProperty as AnyObject?
                    } else {
                        try handleForNilValue(isOptional: optional)
                        propertyDictionary[propertyName] = nil
                    }
                } else {
                    try handleForNilValue(isOptional: optional)
                    propertyDictionary[propertyName] = nil
                }
                break
            case let .dictionary(key, optional):
                if let dictionaryProperty = dictionary[key] as? [String: AnyObject] {
                    propertyDictionary[propertyName] = dictionaryProperty as AnyObject?
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
                    aChild = try map(dictionary[key],
                                     type: childType)
                    propertyDictionary[propertyName] = aChild as AnyObject?
                } else {
                    try handleForNilValue(isOptional: optional)
                    propertyDictionary[propertyName] = nil
                }
                break
            }
        }
        object.map(with: Wrapping(propertyDictionary))
    }
    
    internal class func isValid(property: AnyObject, for type: MappingType) -> Bool {
        if let string = property as? String {
            let mirror = Mirror(reflecting: string)
            if !type.validTypes.contains() {$0 == mirror.subjectType} {
                return false
            }
        }
        if let double = property as? Double {
            let mirror = Mirror(reflecting: double)
            if !type.validTypes.contains() {$0 == mirror.subjectType} {
                return false
            }
        }
        if let bool = property as? Bool {
            let mirror = Mirror(reflecting: bool)
            if !type.validTypes.contains() {$0 == mirror.subjectType} {
                return false
            }
        }
        return true
    }
    internal class func isValid(array: [AnyObject], for type: MappingType) -> Bool {
        for value in array {
            if !isValid(property: value, for: type) {
                return false
            }
        }
        return true
    }
    internal class func handleForNilValue(isOptional: Bool) throws {
        if !isOptional {
            throw MapperError.notFound
        }
    }
}

//MARK: Search Methods
extension Mapper {
    internal class func findRecursively(_ mappingProperty: MappingProperty, json: AnyObject) throws -> AnyObject? {
        switch mappingProperty {
        case let .property(type, key, _):
            return findRecursively(propertyKey: key, mappingType: type, json: json)
        case let .array(key, valuesType, _):
            return findRecursively(arrayKey: key, valuesType: valuesType, json: json)
        case let .dictionary(key, _):
            return findRecursively(dictionaryKey: key, json: json)
        case let .mappingObject(key, type, _):
            return findRecursively(objectKey: key, type: type, json: json) as AnyObject?
        }
    }
    
    //Search for an object
    internal class func findRecursively(objectKey: String, type: Mapable.Type, json: AnyObject) -> Mapable? {
        if isContainsOnlyAtomaryValues(json) {
            return nil
        }
        if let jsonDictionary = json as? [String: AnyObject] {
            for (key, childNode) in jsonDictionary {
                if key == objectKey {
                    if let dictionaryValue = childNode as? [String: AnyObject] {
                        do {
                            let object = type.init()
                            try bind(dictionary: dictionaryValue, to: object)
                            return object
                        } catch {
                            if let foundValue = findRecursively(objectKey: objectKey, type: type, json: childNode) {
                                return foundValue
                            }
                        }
                    }
                }
                if let foundValue = findRecursively(objectKey: objectKey, type: type, json: childNode) {
                    return foundValue
                }
            }
        }
        if let jsonArray = json as? [AnyObject] {
            for childNode in jsonArray {
                if let foundedValue = findRecursively(objectKey: objectKey, type: type, json: childNode) {
                    return foundedValue
                }
            }
        }
        return nil
    }
    //Search for a dictionary
    internal class func findRecursively(dictionaryKey: String, json: AnyObject) -> AnyObject? {
        if isContainsOnlyAtomaryValues(json) {
            return nil
        }
        if let jsonDictionary = json as? [String: AnyObject] {
            for (key, childNode) in jsonDictionary {
                if key == dictionaryKey {
                    if let dictionaryValue = childNode as? [String: AnyObject] {
                        return dictionaryValue as AnyObject?
                    }
                } else {
                    if let foundedValue = findRecursively(dictionaryKey: dictionaryKey, json: childNode) {
                        return foundedValue
                    }
                }
            }
        }
        if let jsonArray = json as? [AnyObject] {
            for childNode in jsonArray {
                if let foundedValue = findRecursively(dictionaryKey: dictionaryKey, json: childNode) {
                    return foundedValue
                }
            }
        }
        return nil
    }
    //Search for an array
    internal class func findRecursively(arrayKey: String, valuesType: MappingType, json: AnyObject) -> AnyObject? {
        if isContainsOnlyAtomaryValues(json) {
            return nil
        }
        if let jsonDictionary = json as? [String: AnyObject] {
            for (key, childNode) in jsonDictionary {
                if key == arrayKey {
                    if let arrayValue = childNode as? [AnyObject], isValid(array: arrayValue, for: valuesType) {
                        return arrayValue as AnyObject?
                    }
                } else {
                    if let foundedValue = findRecursively(arrayKey: arrayKey, valuesType: valuesType, json: childNode) {
                        return foundedValue
                    }
                }
            }
        }
        if let jsonArray = json as? [AnyObject] {
            for childNode in jsonArray {
                if let foundedValue = findRecursively(arrayKey: arrayKey, valuesType: valuesType, json: childNode) {
                    return foundedValue
                }
            }
        }
        return nil
    }
    //Search for a single property
    internal class func findRecursively(propertyKey: String, mappingType: MappingType, json: AnyObject) -> AnyObject? {
        //Base of recursion
        if isContainsOnlyAtomaryValues(json) {
            //At this point we are reached last level of JSON tree
            if let jsonDictionary = json as? [String: AnyObject] {
                for (key, childJson) in jsonDictionary {
                    if key == propertyKey, isValid(property: childJson, for: mappingType) {
                        return childJson
                    }
                }
            }
            return nil
        } else {
            //Our JSON object contains values in wich we can fallthhrought
            
            //if JSON object is Dictionary - check it
            if let jsonDictionary = json as? [String: AnyObject] {
                for (key, childNode) in jsonDictionary {
                    if key == propertyKey {
                        if isValid(property: childNode, for: mappingType) {
                            return childNode
                        }
                    } else {
                        if let foundValue = findRecursively(propertyKey: propertyKey, mappingType: mappingType, json: childNode) {
                            return foundValue
                        }
                    }
                }
            }
            //if JSON object is Array - check it
            if let jsonArray = json as? [AnyObject] {
                for childNode in jsonArray {
                    if let foundValue = findRecursively(propertyKey: propertyKey, mappingType: mappingType, json: childNode) {
                        return foundValue
                    }
                }
            }
            return nil
        }
    }
    //Detecting last level of JSON Tree
    internal class func isContainsOnlyAtomaryValues(_ json: AnyObject) -> Bool {
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
}
