//
//  Mapper.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 03.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

/// enum representing Mapper errors
///
/// - wrongFormat: value describing wrong format for mapping property
/// - invalidPath: value describing wrong path for mapping property
/// - notFound: value describing not found key
public enum MapperError: Error {
    case wrongFormat(value: AnyObject?, description: String)
    case invalidPath(path: [TargetNode], desctiption: String)
    case notFound(key: String?, description: String)
}


/// Mapper class for map json to objects and structs
public class Mapper {
    
    typealias DictionaryNode = Dictionary<String, AnyObject>
    typealias ArrayNode = Array<AnyObject>
    
}

//MARK: - Public methods
extension Mapper {
    
    /// map function
    ///
    /// - Parameter json: json node
    /// - Returns: Mapable object
    /// - Throws: MapperError
    public class func map<T: Mapable>(_ json: AnyObject) throws -> T {
        return try map(type: T.self, json) as! T
    }
    
    /// map function
    ///
    /// - Parameter json: json node
    /// - Returns: array of Mapable objects
    /// - Throws: MapperError
    public class func map<T: Mapable>(_ json: AnyObject) throws -> [T] {
        return try objectsArray(type: T.self, json) as! [T]
    }
    
    /// map function
    ///
    /// - Parameter json: json node
    /// - Returns: dictionary with Mapable values
    /// - Throws: MapperError
    public class func map<T: Mapable>(_ json: AnyObject) throws -> [String: T] {
        return try objectsDictionary(type: T.self, json) as! [String: T]
    }
    
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - json: json node
    /// - Returns: AtomaryMapable object
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable>(for key: String, _ json: AnyObject) throws -> T {
        return try value(for: key, json: json, with: T.self) as! T
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - json: json node
    /// - Returns: array of AtomaryMapable objects
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable>(for key: String, _ json: AnyObject) throws -> [T] {
        return try array(for: key, json: json, with: T.self) as! [T]
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - json: json node
    /// - Returns: dictionary of AtomaryMapable objects
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable>(for key: String, _ json: AnyObject) throws -> [String: T] {
        return try dictionary(for: key, json: json, with: T.self) as! [String: T]
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - json: json node
    ///   - formatting: formatting closure
    /// - Returns: formatted AtomaryMapable value
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable, U>(for key: String, _ json: AnyObject, _ formatting: (_ rawValue: T) throws -> U) throws -> U {
        return try formatting(try map(for: key, json))
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - json: json node
    ///   - formatting: formatting closure
    /// - Returns: formatted array
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable, U>(for key: String, _ json: AnyObject, _ formatting: (_ rawValue: T) throws -> U) throws -> [U] {
        let values: [T] = try map(for: key, json)
        return try values.map(formatting)
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - json: json node
    ///   - formatting: formatting closure
    /// - Returns: formatted dictionary
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable, U>(for key: String, _ json: AnyObject, _ formatting: (_ rawValue: T) throws -> U) throws -> [String: U] {
        let values: [String: T] = try map(for: key, json)
        var formattedDictionary = [String: U]()
        
        try values.forEach { formattedDictionary[$0] = try formatting($1) }
        
        return formattedDictionary
    }
    
    /// map function
    ///
    /// - Parameter data: data representing json object
    /// - Returns: Mapable object
    /// - Throws: MapperError
    public class func map<T: Mapable>(_ data: Data) throws -> T {
        return try map(type: T.self, data.json()) as! T
    }
    
    /// map function
    ///
    /// - Parameter data: data representing json object
    /// - Returns: array of Mapable objects
    /// - Throws: MapperError
    public class func map<T: Mapable>(_ data: Data) throws -> [T] {
        return try objectsArray(type: T.self, data.json()) as! [T]
    }
    
    /// map function
    ///
    /// - Parameter data: data representing json object
    /// - Returns: dictionary of Mapable objects
    /// - Throws: MapperError
    public class func map<T: Mapable>(_ data: Data) throws -> [String: T] {
        return try objectsDictionary(type: T.self, data.json()) as! [String: T]
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - data: data representing json object
    /// - Returns: AtomaryMapable object
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable>(for key: String, _ data: Data) throws -> T {
        return try value(for: key, json: data.json(), with: T.self) as! T
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - data: data representing json object
    /// - Returns: array of AtomaryMapable objects
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable>(for key: String, _ data: Data) throws -> [T] {
        return try array(for: key, json: data.json(), with: T.self) as! [T]
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - data: data representing json object
    /// - Returns: dictionary of AtomaryMapable objects
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable>(for key: String, _ data: Data) throws -> [String: T] {
        return try dictionary(for: key, json: try data.json(), with: T.self) as! [String: T]
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - data: data representing json object
    ///   - formatting: formatting closure
    /// - Returns: formatted AtomaryMapable value
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable, U>(for key: String, _ data: Data, _ formatting: (_ rawValue: T) throws -> U) throws -> U {
        return try map(for: key, data.json(), formatting)
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - data: data representing json object
    ///   - formatting: formatting closure
    /// - Returns: formatted array
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable, U>(for key: String, _ data: Data, _ formatting: (_ rawValue: T) throws -> U) throws -> [U] {
        return try map(for: key, data.json(), formatting)
    }
    
    /// map function
    ///
    /// - Parameters:
    ///   - key: key for desired node
    ///   - data: data representing json object
    ///   - formatting: formatting closure
    /// - Returns: formatted dictionary
    /// - Throws: MapperError
    public class func map<T: AtomaryMapable, U>(for key: String, _ data: Data, _ formatting: (_ rawValue: T) throws -> U) throws -> [String: U] {
        return try map(for: key, data.json(), formatting)
    }
}

extension Mapper {
    
    class func map(type: Mapable.Type, _ json: AnyObject) throws -> Mapable {
        let searchType = try validate(type.mappingPath)
        switch searchType {
        case .recursive: return try object(for: nil, type: type, json)
        case .determined:
            if type.mappingPath.count == 1 {
                return try object(for: type.mappingPath.first?.key, type: type, json)
            }
            
            guard let objectNode = try extractNode(from: type.mappingPath, json: json) as? DictionaryNode else {
                throw MapperError.invalidPath(path: type.mappingPath, desctiption: "Cannot extract node for given path")
            }
            
            return try bind(type: type, objectDictionary: objectNode)
        }
    }
    
}

//MARK: - Path processing
extension Mapper {
    
    enum SearchType {
        case recursive
        case determined
    }
    
    class func validate(_ paths: [TargetNode]) throws -> SearchType {
        if paths.isEmpty {
            return .recursive
        }
        
        let nodesCount = paths.count
        guard let indexOfDestinationNode = paths.index(where: { $0.isDestination }) else {
            throw MapperError.invalidPath(path: paths, desctiption: "No destination node")
        }
        
        if indexOfDestinationNode != nodesCount - 1 {
            throw MapperError.invalidPath(path: [paths[indexOfDestinationNode]], desctiption: "Desctination node must be at last position")
        }
        
        return .determined
    }
    
    class func extractNode(from path: [TargetNode], json: AnyObject) throws -> AnyObject {
        var path = path
        var currentNode = json
        
        while !path.isEmpty {
            let target = path.removeFirst()
            
            if let index = target.index, let array = currentNode as? ArrayNode, index < array.count {
                currentNode = array[index]
            }
            
            if let key = target.key, let dictionary = currentNode as? DictionaryNode, let node = dictionary[key] {
                currentNode = node
            }
            
            throw MapperError.invalidPath(path: [target], desctiption: "Cannot extract node with given path")
        }
        
        return currentNode
    }
}

//MARK: - Recursive Search BFS
extension Mapper {
    
    class func objectsDictionary(for key: String? = nil, type: Mapable.Type, _ json: AnyObject) throws -> [String: Mapable] {
        
        if let key = key,
            let node = json as? DictionaryNode,
            let nodesDictionary = node[key] as? [String: DictionaryNode],
            let objectsDictionary = try? bind(type: type, objectsDictionary: nodesDictionary) {
            
            return objectsDictionary
        }
        
        if let nodesDictionary = json as? [String: DictionaryNode], let objectsDictionary = try? bind(type: type, objectsDictionary: nodesDictionary) {
            return objectsDictionary
        }
        
        if isLeaf(json) { throw MapperError.notFound(key: key, description: "Cannot find dictionary node") }
        var queue = plainNodes(of: json)
        while !queue.isEmpty {
            let nodeToCheck = queue.removeFirst()
            if let objects = try? objectsDictionary(for: key, type: type, nodeToCheck) {
                return objects
            }
        }
        
        throw MapperError.notFound(key: key, description: "Cannot find dictionary node")
    }
    
    class func objectsArray(for key: String? = nil, type: Mapable.Type, _ json: AnyObject) throws -> [Mapable] {
        if let key = key,
            let node = json as? DictionaryNode,
            let objectsNode = node[key] as? Array<DictionaryNode>,
            let objectsArray = try? bind(type: type, objectsArray: objectsNode) {
            
            return objectsArray
        }
        
        if let nodesArray = json as? Array<DictionaryNode>, let objectsArray = try? bind(type: type, objectsArray: nodesArray) {
            return objectsArray
        }
        
        if isLeaf(json) { throw MapperError.notFound(key: key, description: "Cannot find array node") }
        var queue = plainNodes(of: json)
        while !queue.isEmpty {
            let nodeToCheck = queue.removeFirst()
            if let objects = try? objectsArray(for: key, type: type, nodeToCheck) {
                return objects
            }
        }
        
        throw MapperError.notFound(key: key, description: "Cannot find array node")
    }
    
    class func object(for key: String? = nil, type: Mapable.Type, _ json: AnyObject) throws -> Mapable {
        if let key = key,
            let node = json as? DictionaryNode,
            let objectNode = node[key] as? DictionaryNode,
            let object = try? bind(type: type, objectDictionary: objectNode) {
            
            return object
        }
        
        
        if let node = json as? DictionaryNode, let object = try? bind(type: type, objectDictionary: node) {
            return object
        }
        
        var queue = plainNodes(of: json)
        while !queue.isEmpty {
            let nodeToCheck = queue.removeFirst()
            if let object = try? object(for: key, type: type, nodeToCheck) {
                return object
            }
        }
        
        throw MapperError.notFound(key: key, description: "Cannot find object node")
    }
    
    class func dictionary(for key: String? = nil, json: AnyObject, with type: AtomaryMapable.Type) throws -> [String: AtomaryMapable]? {
        
        if let key = key,
            let dictionary = json as? Dictionary<String, AnyObject>,
            let neededDictionary = dictionary[key] as? DictionaryNode {
            
            var mappedDictionary = Dictionary<String, AtomaryMapable>()
            neededDictionary.forEach {
                if let concrete = try? type.concrete(from: $0.value) {
                    mappedDictionary[$0.key] = concrete
                }
            }
            
            return mappedDictionary
        }
        
        guard !isLeaf(json) else {
            guard let dictionary = json as? DictionaryNode else {
                throw MapperError.notFound(key: key, description: "Cannot find dictionary node")
            }
            var mappedDictionary = Dictionary<String, AtomaryMapable>()
            dictionary.forEach {
                if let concrete = try? type.concrete(from: $0.value) {
                    mappedDictionary[$0.key] = concrete
                }
            }
            
            return mappedDictionary
        }
        
        var queue = plainNodes(of: json)
        while !queue.isEmpty {
            let nodeToCheck = queue.removeFirst()
            if let dictionary = try? dictionary(for: key, json: nodeToCheck, with: type) {
                return dictionary
            }
            queue.append(contentsOf: plainNodes(of: nodeToCheck))
        }
        
        throw MapperError.notFound(key: key, description: "Cannot find dictionary node")
    }
    
    class func array(for key: String? = nil, json: AnyObject, with type: AtomaryMapable.Type) throws -> [AtomaryMapable] {
        if let key = key,
            let dictionary = json as? Dictionary<String, AnyObject>,
            let array = dictionary[key] as? ArrayNode {
            
            return array.flatMap { try? type.concrete(from: $0) }
        }
        
        guard !isLeaf(json) else {
            guard let array = json as? ArrayNode else {
                throw MapperError.notFound(key: key, description: "Cannot find array node")
            }
            
            return array.flatMap { try? type.concrete(from: $0) }
        }
        
        var queue = plainNodes(of: json)
        while !queue.isEmpty {
            let nodeToCheck = queue.removeFirst()
            if let array = try? array(for: key, json: nodeToCheck, with: type) {
                return array
            }
            queue.append(contentsOf: plainNodes(of: nodeToCheck))
        }
        
        throw MapperError.notFound(key: key, description: "Cannot find array node")
    }
    
    class func value(for key: String, json: AnyObject, with type: AtomaryMapable.Type) throws -> AtomaryMapable {
        guard !isLeaf(json) else {
            guard let dictionaryNode = json as? DictionaryNode, let value = dictionaryNode[key] else {
                throw MapperError.notFound(key: key, description: "Cannot find object node")
            }
            return try type.concrete(from: value)
        }
        
        var queue = plainNodes(of: json)
        while !queue.isEmpty {
            let nodeToCheck = queue.removeFirst()
            if let value = try? value(for: key, json: nodeToCheck, with: type) {
                return value
            }
            queue.append(contentsOf: plainNodes(of: nodeToCheck))
        }
        
        throw MapperError.notFound(key: key, description: "Cannot find object node")
    }
}

//MARK: - Binding
extension Mapper {
    
    /// Method for binding dictionary to Mapable objects dictionary without recursion
    ///
    /// - Parameters:
    ///   - type: Mapable type of objects
    ///   - objectsDictionary: json node, potentially representing dictionary of objects
    /// - Returns: dictionary of Mapable objects
    /// - Throws: throws error describing bind error
    class func bind(type: Mapable.Type, objectsDictionary: [String: DictionaryNode]) throws -> [String: Mapable] {
        var resultDictionary = [String: Mapable]()
        try objectsDictionary.forEach { resultDictionary[$0.key] = try bind(type: type, objectDictionary: $0.value)}
        return resultDictionary
    }
    
    /// Method for binding array to Mapable objects array without recursion
    ///
    /// - Parameters:
    ///   - type: Mapable type of objects
    ///   - objectsArray: json node, potentially representing array of objects
    /// - Returns: array of Mapable objects
    /// - Throws: throws error describing bind error
    class func bind(type: Mapable.Type, objectsArray: Array<DictionaryNode>) throws -> [Mapable] {
        return try objectsArray.map { try bind(type: type, objectDictionary: $0) }
    }
    
    /// Method for binding dictionary to Mapable object without recursion
    ///
    /// - Parameters:
    ///   - type: Mapable type of object
    ///   - objectDictionary: json node, potentially representing object
    /// - Returns: Mapable object
    /// - Throws: throws error describing bind error
    class func bind(type: Mapable.Type, objectDictionary: DictionaryNode) throws -> Mapable {
        var context = Dictionary<String, AnyObject>()
        try type.properties.forEach { context[$0.keyValue] = try bind($0, with: objectDictionary) }
        return try type.init(Wrapping(context))
    }
    
    ///  Method for binding dictionary to MapableProperty
    ///
    /// - Parameters:
    ///   - property: MapableProperty describing type of property
    ///   - dictionary: initial json node
    /// - Returns: returns Mapable or AtomaryMapable object or nil
    /// - Throws: throws error describing bind error
    class func bind(_ property: MapableProperty, with dictionary: DictionaryNode) throws -> AnyObject? {
        switch property {
        case let .value(type, key, optional): return try bindValue(type: type, key, optional, dictionary)
        case let .array(type, key, optional): return try bindArray(type: type, key, optional, dictionary)
        case let .dictionary(type, key, optional): return try bindDictionary(type: type, key, optional, dictionary)
        case let .object(type, key, optional): return try bindObject(type: type, key, optional, dictionary)
        case let .objectsArray(type, key, optional): return try bindArray(type: type, key, optional, dictionary)
        case let .objectsDictionary(type, key, optional): return try bindDictionary(type: type, key, optional, dictionary)
        }
    }
    
    /// Method for binding dictionary to dictionary with Mapable values
    ///
    /// - Parameters:
    ///   - type: type of needed Mapable objects
    ///   - key: key for desired json node
    ///   - optional: value describing if output can be nullable
    ///   - dictionary: initial json node
    /// - Returns: returns dictionary of mapable objects or nil
    /// - Throws: throws error describing bind error
    class func bindDictionary(type: Mapable.Type,
                              _ key: String,
                              _ optional: Bool,
                              _ dictionary: DictionaryNode) throws -> AnyObject? {
        
        guard let objectsDictionary = dictionary[key] as? [String: DictionaryNode] else {
            try validate(nil, isOptional: optional)
            return nil
        }
        
        return try bind(type: type, objectsDictionary: objectsDictionary) as AnyObject
    }
    
    /// Method for binding dictionary to array of Mapable objects
    ///
    /// - Parameters:
    ///   - type: type of needed Mapable objects
    ///   - key: key for desired json node
    ///   - optional: value describing if output can be nullable
    ///   - dictionary: initial json node
    /// - Returns: returns array of mapable objects or nil
    /// - Throws: throws error describing bind error
    class func bindArray(type: Mapable.Type,
                         _ key: String,
                         _ optional: Bool,
                         _ dictionary: DictionaryNode) throws -> AnyObject? {
        
        guard let objectsArray = dictionary[key] as? Array<DictionaryNode> else {
            try validate(nil, isOptional: optional)
            return nil
        }
        
        return try bind(type: type, objectsArray: objectsArray) as AnyObject
    }
    
    /// Method for binding dictionary to AtomaryMapable value
    ///
    /// - Parameters:
    ///   - type: type of needed Mapable object
    ///   - key: key for desired json node
    ///   - optional: value describing if output can be nullable
    ///   - dictionary: initial json node
    /// - Returns: returns mapable object or nil
    /// - Throws: throws error describing bind error
    class func bindObject(type: Mapable.Type,
                          _ key: String,
                          _ optional: Bool,
                          _ dictionary: DictionaryNode) throws -> AnyObject? {
        
        guard let objectDictionary = dictionary[key] as? DictionaryNode, let object = try? bind(type: type, objectDictionary: objectDictionary) else {
            try validate(nil, isOptional: optional)
            return nil
        }
        
        return object as AnyObject
    }
    
    
    /// Method for binding dictionary to AtomaryMapable dictionary [String: AtomaryMapable]
    ///
    /// - Parameters:
    ///   - type: type of needed value of dictionary
    ///   - key: key for desired json node
    ///   - optional: value describing if output can be nullable
    ///   - dictionary: initial json node
    /// - Returns: returns AtomaryMapable value or nil
    /// - Throws: throws error describing bind error
    class func bindDictionary(type: AtomaryMapable.Type,
                              _ key: String,
                              _ optional: Bool,
                              _ dictionary: DictionaryNode) throws -> AnyObject? {
        
        guard let valuesDictionary = dictionary[key] as? DictionaryNode else {
            try validate(nil, isOptional: optional)
            return nil
        }
        
        var resultDictionary = Dictionary<String, AtomaryMapable>()
        try valuesDictionary.forEach { resultDictionary[$0.key] = try type.concrete(from: $0.value) }
        return resultDictionary as AnyObject
    }
    
    /// Method for retreiving array of AtomaryMapable objects
    ///
    /// - Parameters:
    ///   - type: type of objects in array
    ///   - key: key for desired node
    ///   - optional: value describing if output can be nullable
    ///   - dictionary: json node to bind
    /// - Returns: returns an array of AtomaryMapable objects
    /// - Throws: error describing bind error
    class func bindArray(type: AtomaryMapable.Type,
                         _ key: String,
                         _ optional: Bool,
                         _ dictionary: DictionaryNode) throws -> AnyObject? {
        
        guard let valuesArray = dictionary[key] as? ArrayNode else {
            try validate(nil, isOptional: optional)
            return nil
        }
        
        return try valuesArray.map { try type.concrete(from: $0) } as AnyObject
    }
    
    /// Method for retreiving AtomaryMapable from json node
    ///
    /// - Parameters:
    ///   - type: AtomaryMapable type
    ///   - key: key for desired value
    ///   - optional: bool value indicating if value is nullable
    ///   - dictionary: json node to bind
    /// - Returns: concrete AtomaryMapable value
    /// - Throws: Error describing validation error
    class func bindValue(type: AtomaryMapable.Type,
                         _ key: String,
                         _ optional: Bool,
                         _ dictionary: DictionaryNode) throws -> AnyObject? {
        
        guard let value = dictionary[key], let concreteValue = try? type.concrete(from: value) else {
            try validate(nil, isOptional: optional)
            return nil
        }
        return concreteValue as AnyObject
    }
    
    /// Method for validating if nil response can be returned or not
    ///
    /// - Parameters:
    ///   - value: value or nil
    ///   - isOptional: value which describes if input value can be nil or not
    /// - Throws: throws an error if value is nil, but it cannot be nullable
    class func validate(_ value: AnyObject?, isOptional: Bool) throws {
        if value != nil { return }
        if !isOptional { throw MapperError.wrongFormat(value: value, description: "Value cannot be optional") }
    }
}

//MARK: - Mapper helpers
extension Mapper {
    
    /// Method for retrieving children of json node
    ///
    /// - Parameter jsonNode: Node representing Json value
    /// - Returns: array of child nodes of given node
    class func plainNodes(of jsonNode: AnyObject) -> ArrayNode {
        if let array = jsonNode as? ArrayNode {
            return array
        }
        
        if let dictionary = jsonNode as? DictionaryNode {
            return dictionary.map { $0.value }
        }
        
        return []
    }
    
    /// Method for check if given node of Json is leaf
    ///
    /// - Parameter node: Node representing Json value
    /// - Returns: true if given node is leaf of node tree
    class func isLeaf(_ node: AnyObject) -> Bool {
        var nodesToCheck = ArrayNode()
        if let array = node as? ArrayNode {
            nodesToCheck = array
        }
        
        if let dictionary = node as? DictionaryNode {
            nodesToCheck = dictionary.map { $0.value }
        }
        
        return !nodesToCheck.contains(where: {$0 is ArrayNode || $0 is DictionaryNode })
    }
    
}

