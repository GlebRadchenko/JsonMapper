//
//  Mapper.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 03.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

public class Mapper {
    typealias DictionaryNode = Dictionary<String, AnyObject>
    typealias ArrayNode = Array<AnyObject>
    /*TODO:
     - implement processing of all mapping properties - done
     - add recursively searching - done
     - implement all types of helping path - done
     - implement mapping of arrays - done
     - change logic of binding (without creating object)
     - added pattern search
     - implement correct error throwing
     - test coverage of all methods
     - refactoring and extending functionality
     - split empty initializer and map function
     */
    public class func map<T: Mapable>(_ json: AnyObject) throws -> T {
        return try map(json, type: T.self) as! T
    }
    public class func map<T: Mapable>(_ json: AnyObject) throws -> [T] {
        return try map(json, types: T.self) as! [T]
    }
    
    internal class func map (_ json: AnyObject?, types: Mapable.Type) throws -> [Mapable] {
        guard let json = json else {
            throw MapperError.wrongFormat
        }
        if let arrayOfObjects = findRecursively(objectsKey: nil, type: types, json: json) {
            return arrayOfObjects
        }
        throw MapperError.notFound
    }
    internal class func map(_ json: AnyObject?, type: Mapable.Type) throws -> Mapable {
        guard let json = json else {
            throw MapperError.wrongFormat
        }
        let searchingType = try searchType(for: type.helpingPath)
        switch searchingType {
        case .determined:
            return try map(type, json: json)
        case .recursive:
            return try mapRecursively(type, json: json)
        case .recursiveWithDestination:
            guard let destinationPath = type.helpingPath.first else {
                throw MapperError.wrongSetting
            }
            switch destinationPath {
            case let .destination(nodeType):
                switch nodeType {
                case let .dictionary(key, _):
                    guard let key = key else {
                        throw MapperError.wrongSetting
                    }
                    return try mapRecursively(type, destinationKey: key, json: json)
                default:
                    throw MapperError.wrongSetting
                }
            default:
                throw MapperError.wrongSetting
            }
        }
    }
    internal class func mapRecursively(_ objectType: Mapable.Type, json: AnyObject) throws -> Mapable {
        var propertyDictionary = DictionaryNode()
        try objectType.relations.forEach { (nameOfProperty, mappingProperty) in
            guard let aProperty = try findRecursively(mappingProperty, json: json) else {
                try handleForNilValue(isOptional: mappingProperty.isOptional)
                propertyDictionary[nameOfProperty] = nil
                return
            }
            propertyDictionary[nameOfProperty] = aProperty
        }
        guard let object = objectType.init(Wrapping(propertyDictionary)) else {
            throw MapperError.notFound
        }
        return object
    }
    internal class func mapRecursively(_ objectType: Mapable.Type, destinationKey: String, json: AnyObject) throws -> Mapable {
        if isContainsOnlyAtomaryValues(json) {
            throw MapperError.notFound
        }
        if let jsonDictionary = json as? DictionaryNode {
            do {
                return try bind(jsonDictionary, to: objectType)
            } catch { }
        }
        return try mapRecursively(objectType, key: destinationKey, json: json)
    }
    internal class func mapRecursively(_ objectType: Mapable.Type, key: String, json: AnyObject) throws -> Mapable {
        if isContainsOnlyAtomaryValues(json) {
            throw MapperError.notFound
        }
        if let jsonDictionary = json as? DictionaryNode {
            for (nodeKey, childNode) in jsonDictionary {
                if nodeKey == key {
                    if let dict = childNode as? DictionaryNode {
                        do {
                            return try bind(dict, to: objectType)
                        } catch {}
                    }
                }
                do {
                    return try mapRecursively(objectType, key: key, json: childNode)
                } catch {}
            }
        }
        if let jsonArray = json as? ArrayNode {
            for childNode in jsonArray {
                do {
                    return try mapRecursively(objectType, key: key, json: childNode)
                } catch {}
            }
        }
        throw MapperError.notFound
    }
    
    internal class func map(_ objectType: Mapable.Type, json: AnyObject) throws -> Mapable {
        var paths = objectType.helpingPath
        let initialPath = paths.removeFirst()
        switch initialPath {
        case let .target(nodeType):
            try check(json, for: nodeType)
            break
        default:
            throw MapperError.wrongSetting
        }
        var processingJson = json
        for atomaryPath in objectType.helpingPath {
            switch atomaryPath {
            case let .target(nodeType), let .destination(nodeType):
                guard let nextNode = try fall(through: processingJson, nextNode: nodeType) else {
                    throw MapperError.wrongSetting
                }
                processingJson = nextNode
                break
            case .none:
                throw MapperError.wrongSetting
            }
        }
        //At this point we have final object wich we should bind to object
        if let objectDictionary = processingJson as? DictionaryNode {
            return try bind(objectDictionary, to: objectType)
        } else {
            throw MapperError.wrongSetting
        }
    }
    internal static func fall(through json: AnyObject, nextNode: JsonNodeType) throws -> AnyObject? {
        switch nextNode {
        case let .array(key, index):
            if index == nil, key == nil { throw MapperError.wrongSetting }
            if let key = key {
                if let dictionaryNode = json as? DictionaryNode, let arrayNode = dictionaryNode[key] as? ArrayNode {
                    return arrayNode as AnyObject
                } else {
                    throw MapperError.wrongSetting
                }
            }
            if let index = index {
                if let arrayNode = json as? ArrayNode, arrayNode.count > index, let desctinationNode = arrayNode[index] as? ArrayNode {
                    return desctinationNode as AnyObject
                } else {
                    throw MapperError.wrongSetting
                }
            }
            break
        case let .dictionary(key, index):
            if index == nil, key == nil { throw MapperError.wrongSetting }
            if let key = key {
                if let dictionaryNode = json as? DictionaryNode, let dictNode = dictionaryNode[key] as? DictionaryNode {
                    return dictNode as AnyObject
                } else {
                    throw MapperError.wrongSetting
                }
            }
            if let index = index {
                if let arrayNode = json as? ArrayNode, arrayNode.count > index, let desctinationNode = arrayNode[index] as? DictionaryNode {
                    return desctinationNode as AnyObject
                } else {
                    throw MapperError.wrongSetting
                }
            }
            break
        }
        return nil
    }
    internal class func bind(_ arrayOfNodes: ArrayNode, to objectType: Mapable.Type) throws -> [Mapable] {
        var objects = [Mapable]()
        for node in arrayOfNodes {
            if let dictNode = node as? DictionaryNode {
                do {
                    let object = try bind(dictNode, to: objectType)
                    objects.append(object)
                } catch {
                    debugPrint("Cannot bind ", dictNode, " to ", objectType)
                }
            }
        }
        if objects.count == 0 {
            if arrayOfNodes.count != 0 {
                throw MapperError.notFound
            }
        }
        return objects
    }
    internal class func bind(_ dictionary: DictionaryNode, to objectType: Mapable.Type) throws -> Mapable {
        var propertyDictionary = DictionaryNode()
        for (propertyName, mappingProperty) in objectType.relations {
            propertyDictionary[propertyName] = try validate(property: mappingProperty, dictionary: dictionary)
        }
        guard let object = objectType.init(Wrapping(propertyDictionary)) else {
            throw MapperError.wrongFormat
        }
        return object
    }
}
//MARK: - Helpers
extension Mapper {
    internal class func check(_ json: AnyObject, for type: JsonNodeType) throws {
        switch type {
        case .array:
            if !(json is Array<AnyObject>) {
                throw MapperError.wrongSetting
            }
            break
        case .dictionary:
            if !(json is DictionaryNode) {
                throw MapperError.wrongSetting
            }
            break
        }
    }
    internal class func searchType(for path: [MapPathable]) throws -> MapperSearchType {
        if path.isEmpty { return .recursive }
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
}

//MARK: - Validation methods
extension Mapper {
    internal class func validate(property: MappingProperty, dictionary: DictionaryNode) throws -> AnyObject? {
        switch property {
        case let .property(type, key, optional):
            return try validate(key, type: type, optional: optional, dictionary: dictionary)
        case let .array(key, valuesType, optional):
            return try validate(key, types: valuesType, optional: optional, dictionary: dictionary)
        case let .dictionary(key, optional):
            return try validate(key, optional: optional, dictionary: dictionary)
        case let .mappingObject(key, childType, optional):
            return try validate(key, type: childType, optional: optional, dictionary: dictionary)
        case let .mappingObjectsArray(key, types, optional):
            return try validate(key, type: types, optional: optional, dictionary: dictionary)
        }
    }
    internal class func validate(_ propertyKey: String, type: MappingType, optional: Bool, dictionary: DictionaryNode) throws -> AnyObject? {
        guard let property = dictionary[propertyKey], isValid(property, for: type) else {
            try handleForNilValue(isOptional: optional)
            return nil
        }
        return property
    }
    internal class func validate(_ arrayKey: String, types: MappingType, optional: Bool, dictionary: DictionaryNode) throws -> AnyObject? {
        guard let arrayProperty = dictionary[arrayKey] as? ArrayNode, isValid(array: arrayProperty, for: types) else {
            try handleForNilValue(isOptional: optional)
            return nil
        }
        return arrayProperty as AnyObject?
    }
    internal class func validate(_ dictionaryKey: String, optional: Bool, dictionary: DictionaryNode) throws -> AnyObject? {
        guard let dictionaryProperty = dictionary[dictionaryKey] as? DictionaryNode else {
            try handleForNilValue(isOptional: optional)
            return nil
        }
        return dictionaryProperty as AnyObject?
    }
    internal class func validate(_ objectKey: String, type: Mapable.Type, optional: Bool, dictionary: DictionaryNode) throws -> AnyObject? {
        do {
            let childObject = try map(dictionary[objectKey], type: type)
            return childObject as AnyObject?
        } catch {
            try handleForNilValue(isOptional: optional)
            return nil
        }
    }
    internal class func validate(_ objectsArrayKey: String?, type: Mapable.Type, optional: Bool, dictionary: DictionaryNode) throws -> AnyObject? {
        guard let arrayKey = objectsArrayKey else {
            try handleForNilValue(isOptional: optional)
            return nil
        }
        do {
            return try map(dictionary[arrayKey], types: type) as AnyObject?
        } catch {
            try handleForNilValue(isOptional: optional)
            return nil
        }
    }
    internal class func isValid(_ property: AnyObject, for type: MappingType) -> Bool {
        if let _ = property as? String {
            if !type.validTypes.contains() {$0 == String.self} { return false }
        }
        if let _ = property as? Double {
            if !type.validTypes.contains() {$0 == Double.self} { return false }
        }
        if let _ = property as? Bool {
            if !type.validTypes.contains() {$0 == Bool.self} { return false }
        }
        //think about anyobject
        return true
    }
    internal class func isValid(array: ArrayNode, for type: MappingType) -> Bool {
        for value in array {
            if !isValid(value, for: type) { return false }
        }
        return true
    }
    internal class func handleForNilValue(isOptional: Bool) throws {
        if !isOptional { throw MapperError.notFound }
    }
}

//MARK: - Search Methods
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
            return findRecursively(objectKey: key, type: type, json: json) as AnyObject
        case let .mappingObjectsArray(key, types, _):
            return findRecursively(objectsKey: key, type: types, json: json) as AnyObject
        }
    }
    
    //Search for an array of objects
    internal class func findRecursively(objectsKey: String?, type: Mapable.Type, json: AnyObject) -> [Mapable]? {
        if let jsonArray = json as? ArrayNode {
            do {
                return try bind(jsonArray, to: type)
            } catch {}
        }
        if isContainsOnlyAtomaryValues(json) { return nil }
        return objectsKey == nil ? findRecursively(arrayOf: type, json: json) : findRecursively(objectsKey: objectsKey!, type: type, json: json)
    }
    internal class func findRecursively(arrayOf type: Mapable.Type, json: AnyObject) -> [Mapable]? {
        if isContainsOnlyAtomaryValues(json) { return nil }
        var childNodes = ArrayNode()
        if let jsonDictionary = json as? DictionaryNode {
            childNodes = jsonDictionary.map() { return $0.value }
        }
        if let jsonArray = json as? ArrayNode { childNodes = jsonArray }
        for node in childNodes {
            if let arrayValue = node as? ArrayNode, arrayValue.count > 0 {
                do {
                    return try bind(arrayValue, to: type)
                } catch { }
            }
            if let foundValues = findRecursively(arrayOf: type, json: node) { return foundValues }
        }
        return nil
    }
    internal class func findRecursively(objectsKey: String, type: Mapable.Type, json: AnyObject) -> [Mapable]? {
        if isContainsOnlyAtomaryValues(json) { return nil }
        var childNodes = ArrayNode()
        var potentialFittingNodes = ArrayNode()
        if let jsonDictionary = json as? DictionaryNode {
            potentialFittingNodes = jsonDictionary.filter { $0.key == objectsKey }.map() { $0.value }
            for potentialNode in potentialFittingNodes {
                do {
                    if let arrayNode = potentialNode as? ArrayNode {
                        return try bind(arrayNode, to: type)
                    }
                } catch {}
            }
            childNodes = jsonDictionary.map() { $0.value }
        }
        if let jsonArray = json as? ArrayNode { childNodes.append(contentsOf: jsonArray) }
        for childNode in childNodes {
            if let foundValues = findRecursively(objectsKey: objectsKey, type: type, json: childNode) {
                return foundValues
            }
        }
        return nil
    }
    //Search for an object
    internal class func findRecursively(objectKey: String, type: Mapable.Type, json: AnyObject) -> Mapable? {
        if isContainsOnlyAtomaryValues(json) { return nil }
        var childNodes = ArrayNode()
        var potentialFittingNodes = ArrayNode()
        if let jsonDictionary = json as? DictionaryNode {
            potentialFittingNodes = jsonDictionary.filter { $0.key == objectKey }.map() { $0.value }
            for potentialNode in potentialFittingNodes {
                if let dictionaryNode = potentialNode as? DictionaryNode {
                    do {
                        return try bind(dictionaryNode, to: type)
                    } catch {}
                }
            }
            childNodes = jsonDictionary.map() { $0.value }
        }
        if let jsonArray = json as? ArrayNode { childNodes.append(contentsOf: jsonArray) }
        for childNode in childNodes {
            if let foundValue = findRecursively(objectKey: objectKey, type: type, json: childNode) {
                return foundValue
            }
        }
        return nil
    }
    //Search for a dictionary
    internal class func findRecursively(dictionaryKey: String, json: AnyObject) -> AnyObject? {
        if isContainsOnlyAtomaryValues(json) { return nil }
        var childNodes = ArrayNode()
        var potentialFittingNodes = ArrayNode()
        if let jsonDictionary = json as? DictionaryNode {
            potentialFittingNodes = jsonDictionary.filter() { $0.key == dictionaryKey && $0.value is DictionaryNode }.map() { $0.value }
            if let fittingNode = potentialFittingNodes.first { return fittingNode }
            childNodes = jsonDictionary.map() { $0.value }
        }
        if let jsonArray = json as? ArrayNode {
            childNodes = jsonArray
        }
        for childNode in childNodes {
            if let foundedValue = findRecursively(dictionaryKey: dictionaryKey, json: childNode) {
                return foundedValue
            }
        }
        return nil
    }
    //Search for an array
    internal class func findRecursively(arrayKey: String, valuesType: MappingType, json: AnyObject) -> AnyObject? {
        if isContainsOnlyAtomaryValues(json) { return nil }
        var childNodes = ArrayNode()
        var potentialFittingNodes = ArrayNode()
        if let jsonDictionary = json as? DictionaryNode {
            potentialFittingNodes = jsonDictionary.filter() { $0.key == arrayKey && $0.value is Array<AnyObject> }.map() { $0.value }
            if let fittingNode = potentialFittingNodes.first { return fittingNode }
            childNodes = jsonDictionary.map() { $0.value }
        }
        if let jsonArray = json as? ArrayNode {
            childNodes = jsonArray
        }
        for childNode in childNodes {
            if let foundedValue = findRecursively(arrayKey: arrayKey, valuesType: valuesType, json: childNode) {
                return foundedValue
            }
        }
        return nil
    }
    //Search for a single property
    internal class func findRecursively(propertyKey: String, mappingType: MappingType, json: AnyObject) -> AnyObject? {
        //Base of recursion
        if isContainsOnlyAtomaryValues(json), let jsonDictionary = json as? DictionaryNode {
            //At this point we are reached last level of JSON tree
            for (key, childJson) in jsonDictionary {
                if key == propertyKey, isValid(childJson, for: mappingType) {
                    return childJson
                }
            }
            return nil
        } else {
            //Our JSON object contains values in wich we can fallthhrought
            
            //if JSON object is Dictionary - check it
            if let jsonDictionary = json as? DictionaryNode {
                for (key, childNode) in jsonDictionary {
                    if key == propertyKey, isValid(childNode, for: mappingType) {
                        return childNode
                    } else {
                        if let foundValue = findRecursively(propertyKey: propertyKey, mappingType: mappingType, json: childNode) {
                            return foundValue
                        }
                    }
                }
            }
            //if JSON object is Array - check it
            if let jsonArray = json as? ArrayNode {
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
        var nodesToCheck = ArrayNode()
        if let jsonDictionary = json as? DictionaryNode { nodesToCheck = jsonDictionary.values.map { $0 as AnyObject} }
        if let jsonArray = json as? ArrayNode { nodesToCheck = jsonArray }
        for node in nodesToCheck {
            if node is DictionaryNode || node is ArrayNode { return false }
        }
        return true
    }
}
