//
//  TestClasses.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 05.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

class Chair: Mapable {
    var id: Double
    var stickCount: String
    var someOptionalValue: Int?
    
    static var helpingPath: [MapPathable] = [.none]
    static var relations: [String: MappingProperty] = ["id": .property(type: .number,
                                                                       key: "id",
                                                                       optional: false),
                                                       "stickCount": .property(type: .string,
                                                                               key: "stickCount",
                                                                               optional: false),
                                                       "someOptionalValue": .property(type: .number,
                                                                                      key: "value",
                                                                                      optional: true)]
    
    //Mapable protocol implementation
    public required init(_ wrapping: Wrapping) throws {
        id = try wrapping.get("id")!
        stickCount = try wrapping.get("stickCount")!
        someOptionalValue = try wrapping.get("someOptionalValue")
    }
}

class User: Mapable {
    var name: String
    var age: Int
    var isMale: Bool
    var chairs: [Chair]?
    
    //Mapable protocol implementation
    public required init(_ wrapping: Wrapping) throws {
        name = try wrapping.get("name")!
        age = try wrapping.get("age")!
        isMale = try wrapping.get("isMale")!
        chairs = try wrapping.get("chairs")
    }
    
    static var helpingPath: [MapPathable] = [.none]//[.destination(nodeType: .dictionary(key: "user", index: nil))]
    static var relations: [String: MappingProperty] {
        return ["name": .property(type: .string, key: "name", optional: false),
                "age": .property(type: .number, key: "age", optional: false),
                "isMale": .property(type: .bool, key: "male", optional: false),
                "chairs": .mappingObjectsArray(key: "chairs", types: Chair.self, optional: true)]
    }
}
