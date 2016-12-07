//
//  TestClasses.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 05.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

class Chair: Mapable {
    var id: String
    var stickCount: NSNumber
    
    static var helpingPath: [MapPathable] = [.none]
    static var relations: [String: MappingProperty] = ["id": .property(type: .string, key: "id", optional: false),
                                                "stickCount": .property(type: .number, key: "stickCount", optional: false)]
    
    //Mapable protocol implementation
    public required init?(_ wrapping: Wrapping) {
        do {
            id = try wrapping.get("id")!
            stickCount = try wrapping.get("stickCount")!
        } catch {
            return nil
        }
    }
}

class User: Mapable {
    var name: String
    var age: Int
    var isMale: Bool
    var chairs: [Chair]?
    
    //Mapable protocol implementation
    public required init?(_ wrapping: Wrapping) {
        do {
            self.name = try wrapping.get("name")!
            self.age = try wrapping.get("age")!
            self.isMale = try wrapping.get("isMale")!
            self.chairs = try wrapping.get("chairs")
        } catch {
            return nil
        }
    }
    
    static var helpingPath: [MapPathable] = [.none]//[.destination(nodeType: .dictionary(key: "user", index: nil))]
    static var relations: [String: MappingProperty] {
        return ["name": .property(type: .string, key: "name", optional: false),
                "age": .property(type: .number, key: "age", optional: false),
                "isMale": .property(type: .bool, key: "male", optional: false),
                "chairs": .mappingObjectsArray(key: "chairs", types: Chair.self, optional: true)]
    }
}
