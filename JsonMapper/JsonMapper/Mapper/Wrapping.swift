//
//  Wrapping.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 05.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

public class Wrapping {
    var content: [String: AnyObject?]
    init(_ content: [String: AnyObject?]) {
        self.content = content
    }
    func get<T>(_ propertyName: String) throws -> T? {
        if content.keys.contains(propertyName) {
            if let aValue = content[propertyName] as? T {
                return aValue
            } else {
                return nil
            }
        }
        throw WrappingError.wrongProperty(name: propertyName)
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
